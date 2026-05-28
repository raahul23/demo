import { Server } from 'socket.io';
import { Queue } from 'bullmq';
import { query, queryOne, withTransaction } from '../../config/database';
import { redis } from '../../config/redis';
import { AppError } from '../../middleware/error';
import { fetchRoute } from '../../services/google-routes.service';
import { calculateFare, getFareQuote } from './fare.service';
import { DbRide, VehicleType, GeoPoint, RideStatus, FareQuote } from '../../types';

let ioRef: Server | null = null;
let matchingQueueRef: Queue | null = null;

export function initRideService(io: Server, matchingQueue: Queue): void {
  ioRef = io;
  matchingQueueRef = matchingQueue;
}

function generateOtp(): string {
  return String(Math.floor(1000 + Math.random() * 9000));
}

interface BookRideDto {
  vehicleType: VehicleType;
  pickup: GeoPoint & { address?: string };
  drop: GeoPoint & { address?: string };
  encodedPolyline?: string;
  distanceMeters?: number;
  durationSeconds?: number;
}

export async function bookRide(riderId: string, dto: BookRideDto): Promise<DbRide> {
  // Check no active ride
  const active = await queryOne<{ id: string }>(
    `SELECT id FROM rides WHERE rider_id = $1 AND status NOT IN ('RIDE_COMPLETED','CANCELLED')`,
    [riderId]
  );
  if (active) throw new AppError('You already have an active ride', 409, 'RIDE_ALREADY_ACTIVE');

  // Fetch route from Google (or use provided values)
  let encodedPolyline = dto.encodedPolyline ?? '';
  let distanceMeters = dto.distanceMeters ?? 0;
  let durationSeconds = dto.durationSeconds ?? 0;

  if (!encodedPolyline || !distanceMeters) {
    const route = await fetchRoute(dto.pickup, dto.drop);
    encodedPolyline = route.encodedPolyline;
    distanceMeters = route.distanceMeters;
    durationSeconds = route.durationSeconds;
  }

  const estimatedFare = calculateFare(dto.vehicleType, distanceMeters);
  const otp = generateOtp();

  const ride = await queryOne<DbRide>(
    `INSERT INTO rides
      (rider_id, vehicle_type, pickup_address, pickup_lat, pickup_lng,
       drop_address, drop_lat, drop_lng, encoded_polyline, distance_meters,
       duration_seconds, estimated_fare, otp, status)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,'SEARCHING_FOR_DRIVER')
     RETURNING *`,
    [
      riderId,
      dto.vehicleType,
      dto.pickup.address ?? null,
      dto.pickup.lat,
      dto.pickup.lng,
      dto.drop.address ?? null,
      dto.drop.lat,
      dto.drop.lng,
      encodedPolyline,
      distanceMeters,
      durationSeconds,
      estimatedFare,
      otp,
    ]
  );

  if (!ride) throw new AppError('Failed to create ride', 500);

  // Cache session in Redis
  await redis.set(`ride:session:${ride.id}`, JSON.stringify(ride), 'EX', 3600);

  // Notify rider via socket
  ioRef?.to(`rider:${riderId}`).emit('ride:searching', {
    rideId: ride.id,
    estimatedWaitSec: 60,
  });

  // Enqueue matching job
  await matchingQueueRef?.add(
    'match-ride',
    { rideId: ride.id },
    { attempts: 3, backoff: { type: 'exponential', delay: 5_000 } }
  );

  return ride;
}

export async function getRide(rideId: string): Promise<DbRide> {
  // Try cache first
  const cached = await redis.get(`ride:session:${rideId}`);
  if (cached) return JSON.parse(cached) as DbRide;

  const ride = await queryOne<DbRide>('SELECT * FROM rides WHERE id = $1', [rideId]);
  if (!ride) throw new AppError('Ride not found', 404);
  return ride;
}

export async function getActiveRide(riderId: string): Promise<DbRide | null> {
  return queryOne<DbRide>(
    `SELECT * FROM rides WHERE rider_id = $1 AND status NOT IN ('RIDE_COMPLETED','CANCELLED')
     ORDER BY created_at DESC LIMIT 1`,
    [riderId]
  );
}

export async function getRideHistory(
  riderId: string,
  page = 1,
  limit = 20
): Promise<{ rides: DbRide[]; total: number }> {
  const offset = (page - 1) * limit;

  const [rides, countResult] = await Promise.all([
    query<DbRide>(
      `SELECT r.*,
        u.name as driver_name,
        v.model as vehicle_model,
        v.plate_number
       FROM rides r
       LEFT JOIN drivers d ON d.id = r.driver_id
       LEFT JOIN users u ON u.id = d.user_id
       LEFT JOIN vehicles v ON v.driver_id = d.id AND v.is_active = TRUE
       WHERE r.rider_id = $1 AND r.status IN ('RIDE_COMPLETED','CANCELLED')
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [riderId, limit, offset]
    ),
    queryOne<{ count: string }>(
      `SELECT COUNT(*) FROM rides WHERE rider_id = $1 AND status IN ('RIDE_COMPLETED','CANCELLED')`,
      [riderId]
    ),
  ]);

  return { rides, total: parseInt(countResult?.count ?? '0', 10) };
}

export async function cancelRide(
  rideId: string,
  cancelledBy: 'RIDER' | 'DRIVER' | 'SYSTEM',
  reason?: string
): Promise<void> {
  const ride = await queryOne<DbRide>('SELECT * FROM rides WHERE id = $1', [rideId]);
  if (!ride) throw new AppError('Ride not found', 404);

  const cancellable: RideStatus[] = [
    'SEARCHING_FOR_DRIVER',
    'DRIVER_ACCEPTED',
    'DRIVER_ARRIVING',
    'DRIVER_ARRIVED',
  ];
  if (!cancellable.includes(ride.status)) {
    throw new AppError(`Cannot cancel ride in status: ${ride.status}`, 409, 'INVALID_STATUS');
  }

  await query(
    `UPDATE rides SET status='CANCELLED', cancelled_by=$1, cancel_reason=$2,
      cancelled_at=NOW(), updated_at=NOW() WHERE id=$3`,
    [cancelledBy, reason ?? null, rideId]
  );

  await redis.del(`ride:session:${rideId}`);

  ioRef?.to(`ride:${rideId}`).emit('ride:cancelled', {
    rideId,
    cancelledBy,
    reason: reason ?? null,
  });

  // Free driver if they were assigned
  if (ride.driver_id) {
    await redis.del(`driver:activeRide:${ride.driver_id}`);
  }
}

export async function updateRideStatus(
  rideId: string,
  status: RideStatus,
  extra: Record<string, unknown> = {}
): Promise<DbRide> {
  const timestampField: Partial<Record<RideStatus, string>> = {
    DRIVER_ACCEPTED: 'accepted_at',
    DRIVER_ARRIVED: 'arrived_at',
    RIDE_STARTED: 'started_at',
    RIDE_COMPLETED: 'completed_at',
  };

  const tsField = timestampField[status];
  const setClause = tsField
    ? `status=$1, ${tsField}=NOW(), updated_at=NOW()`
    : `status=$1, updated_at=NOW()`;

  const params: unknown[] = [status, rideId];

  if (extra.driverId) {
    const ride = await queryOne<DbRide>(
      `UPDATE rides SET ${setClause}, driver_id=$3 WHERE id=$2 RETURNING *`,
      [...params, extra.driverId]
    );
    if (!ride) throw new AppError('Ride not found', 404);
    await redis.set(`ride:session:${rideId}`, JSON.stringify(ride), 'EX', 3600);
    return ride;
  }

  const ride = await queryOne<DbRide>(
    `UPDATE rides SET ${setClause} WHERE id=$2 RETURNING *`,
    params
  );
  if (!ride) throw new AppError('Ride not found', 404);
  await redis.set(`ride:session:${rideId}`, JSON.stringify(ride), 'EX', 3600);
  return ride;
}

export async function startRide(
  driverId: string,
  rideId: string,
  submittedOtp: string
): Promise<void> {
  const ride = await queryOne<DbRide>('SELECT * FROM rides WHERE id = $1', [rideId]);
  if (!ride) throw new AppError('Ride not found', 404);
  if (ride.driver_id !== driverId) throw new AppError('Unauthorized', 403);
  if (ride.otp !== submittedOtp) throw new AppError('Invalid OTP', 400, 'OTP_INVALID');
  if (ride.status !== 'DRIVER_ARRIVED') {
    throw new AppError('Driver must be at pickup to start ride', 409, 'INVALID_STATUS');
  }

  await updateRideStatus(rideId, 'RIDE_STARTED');
  ioRef?.to(`ride:${rideId}`).emit('ride:started', { rideId, startedAt: new Date() });
}

export async function completeRide(driverId: string, rideId: string): Promise<void> {
  const ride = await queryOne<DbRide>('SELECT * FROM rides WHERE id = $1', [rideId]);
  if (!ride) throw new AppError('Ride not found', 404);
  if (ride.driver_id !== driverId) throw new AppError('Unauthorized', 403);

  const finalFare = ride.final_fare ?? ride.estimated_fare;

  await withTransaction(async (client) => {
    await client.query(
      `UPDATE rides SET status='RIDE_COMPLETED', final_fare=$1, completed_at=NOW(), updated_at=NOW() WHERE id=$2`,
      [finalFare, rideId]
    );
    await client.query(
      `INSERT INTO payments (ride_id, rider_id, driver_id, method, trip_fare, total_charged, total_earnings, status)
       VALUES ($1, $2, $3, 'cash', $4, $4, $5, 'PENDING')`,
      [rideId, ride.rider_id, driverId, finalFare, finalFare * 0.8]
    );
    await client.query(
      `UPDATE drivers SET total_trips = total_trips + 1, updated_at=NOW() WHERE id=$1`,
      [driverId]
    );
  });

  await redis.del(`ride:session:${rideId}`);
  await redis.del(`driver:activeRide:${driverId}`);

  ioRef?.to(`ride:${rideId}`).emit('ride:completed', {
    rideId,
    fare: finalFare,
    duration: ride.duration_seconds,
    distance: ride.distance_meters,
  });

  ioRef?.to(`driver:${driverId}`).emit('trip:completed', {
    rideId,
    payment: {
      totalEarnings: finalFare * 0.8,
      tripFare: finalFare,
      tips: 0,
      discountAmount: 0,
      method: 'cash',
    },
  });
}

export async function getDriverInfo(rideId: string): Promise<object | null> {
  const row = await queryOne<{
    driver_name: string;
    vehicle_model: string;
    plate_number: string;
    phone: string;
    vehicle_type: VehicleType;
    otp: string;
    rating_avg: number;
  }>(
    `SELECT u.name as driver_name, v.model as vehicle_model, v.plate_number,
            u.phone, r.vehicle_type, r.otp, d.rating_avg
     FROM rides r
     JOIN drivers d ON d.id = r.driver_id
     JOIN users u ON u.id = d.user_id
     LEFT JOIN vehicles v ON v.driver_id = d.id AND v.is_active = TRUE
     WHERE r.id = $1`,
    [rideId]
  );

  if (!row) return null;

  return {
    name: row.driver_name,
    vehicle_model: row.vehicle_model ?? 'Vehicle',
    plate_number: row.plate_number ?? 'N/A',
    otp: row.otp,
    phone: row.phone,
    service: row.vehicle_type,
    rating: row.rating_avg,
  };
}

export async function submitRating(
  riderId: string,
  rideId: string,
  score: number,
  comment?: string
): Promise<void> {
  const ride = await queryOne<DbRide>(
    `SELECT * FROM rides WHERE id=$1 AND rider_id=$2 AND status='RIDE_COMPLETED'`,
    [rideId, riderId]
  );
  if (!ride) throw new AppError('Ride not found or not completed', 404);
  if (!ride.driver_id) throw new AppError('No driver assigned to this ride', 400);

  const driverUser = await queryOne<{ user_id: string }>(
    'SELECT user_id FROM drivers WHERE id=$1',
    [ride.driver_id]
  );
  if (!driverUser) throw new AppError('Driver not found', 404);

  await withTransaction(async (client) => {
    await client.query(
      `INSERT INTO ratings (ride_id, rater_id, ratee_id, score, comment)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (ride_id, rater_id) DO UPDATE SET score=$4, comment=$5`,
      [rideId, riderId, driverUser.user_id, score, comment ?? null]
    );
    await client.query(
      `UPDATE drivers SET rating_avg = (
         SELECT AVG(r.score) FROM ratings r
         JOIN drivers d2 ON d2.user_id = r.ratee_id
         WHERE d2.id = drivers.id
       ), updated_at=NOW() WHERE id=$1`,
      [ride.driver_id]
    );
  });
}

export async function getFareQuoteForRoute(
  pickup: GeoPoint,
  drop: GeoPoint
): Promise<FareQuote> {
  const route = await fetchRoute(pickup, drop);
  return getFareQuote(route.distanceMeters);
}
