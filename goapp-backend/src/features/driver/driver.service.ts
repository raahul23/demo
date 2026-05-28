import { Server } from 'socket.io';
import { query, queryOne } from '../../config/database';
import { redis } from '../../config/redis';
import { AppError } from '../../middleware/error';
import { DbDriver, DbRide, VehicleType } from '../../types';
import {
  updateRideStatus,
  startRide as rideServiceStart,
  completeRide as rideServiceComplete,
  cancelRide as rideServiceCancel,
} from '../ride/ride.service';

let ioRef: Server | null = null;

export function initDriverService(io: Server): void {
  ioRef = io;
}

export async function getOrCreateDriver(userId: string): Promise<DbDriver> {
  let driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) {
    const rows = await query<DbDriver>(
      'INSERT INTO drivers (user_id) VALUES ($1) RETURNING *',
      [userId]
    );
    driver = rows[0];
  }
  return driver;
}

export async function goOnline(
  userId: string,
  lat: number,
  lng: number,
  vehicleType?: VehicleType
): Promise<void> {
  const driver = await getOrCreateDriver(userId);

  const setVehicle = vehicleType ? `, vehicle_type='${vehicleType}'` : '';
  await query(
    `UPDATE drivers
     SET is_online=TRUE,
         current_location=ST_SetSRID(ST_MakePoint($1,$2),4326)::geography
         ${setVehicle},
         updated_at=NOW()
     WHERE user_id=$3`,
    [lng, lat, userId]
  );

  await redis.set(
    `driver:location:${driver.id}`,
    JSON.stringify({ lat, lng, heading: 0, speedKmh: 0, ts: Date.now() }),
    'EX',
    30
  );
}

export async function goOffline(userId: string): Promise<void> {
  const driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) return;

  await query(
    'UPDATE drivers SET is_online=FALSE, updated_at=NOW() WHERE user_id=$1',
    [userId]
  );
  await redis.del(`driver:location:${driver.id}`);
}

export async function acceptRide(userId: string, rideId: string): Promise<void> {
  const driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) throw new AppError('Driver profile not found', 404);

  // Atomic lock — only one driver can accept
  const lockKey = `ride:lock:${rideId}`;
  const acquired = await redis.set(lockKey, driver.id, 'EX', 10, 'NX');
  if (!acquired) throw new AppError('Ride already accepted by another driver', 409, 'RIDE_TAKEN');

  // Check ride is still searching
  const ride = await queryOne<DbRide>(
    `SELECT * FROM rides WHERE id=$1 AND status='SEARCHING_FOR_DRIVER'`,
    [rideId]
  );
  if (!ride) {
    await redis.del(lockKey);
    throw new AppError('Ride no longer available', 409, 'RIDE_NOT_AVAILABLE');
  }

  await updateRideStatus(rideId, 'DRIVER_ACCEPTED', { driverId: driver.id });
  await redis.set(`driver:activeRide:${driver.id}`, rideId, 'EX', 7200);

  // Notify rider
  ioRef?.to(`rider:${ride.rider_id}`).emit('ride:driverAccepted', {
    rideId,
    driver: {
      id: driver.id,
      name: null, // will be fetched from ride router
      rating: driver.rating_avg,
    },
    etaMin: 5,
  });

  // Notify driver with full trip details
  ioRef?.to(`driver:${userId}`).emit('order:assigned', {
    rideId,
    otp: ride.otp,
    pickup: { lat: ride.pickup_lat, lng: ride.pickup_lng, address: ride.pickup_address },
    drop: { lat: ride.drop_lat, lng: ride.drop_lng, address: ride.drop_address },
    encodedPolyline: ride.encoded_polyline,
  });
}

export async function markArrived(userId: string, rideId: string): Promise<void> {
  const driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) throw new AppError('Driver profile not found', 404);

  await updateRideStatus(rideId, 'DRIVER_ARRIVED');

  ioRef?.to(`ride:${rideId}`).emit('ride:driverArrived', { rideId });
}

export async function driverStartRide(
  userId: string,
  rideId: string,
  otp: string
): Promise<void> {
  const driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) throw new AppError('Driver profile not found', 404);
  await rideServiceStart(driver.id, rideId, otp);
  ioRef?.to(`driver:${userId}`).emit('trip:otpVerified', { rideId });
}

export async function driverCompleteRide(userId: string, rideId: string): Promise<void> {
  const driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) throw new AppError('Driver profile not found', 404);
  await rideServiceComplete(driver.id, rideId);
}

export async function driverCancelRide(
  userId: string,
  rideId: string,
  reason?: string
): Promise<void> {
  const driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) throw new AppError('Driver profile not found', 404);
  await rideServiceCancel(rideId, 'DRIVER', reason);
  await redis.del(`driver:activeRide:${driver.id}`);
}

export async function getDriverProfile(userId: string): Promise<object> {
  const driver = await queryOne<DbDriver & { name: string; phone: string }>(
    `SELECT d.*, u.name, u.phone, u.email
     FROM drivers d JOIN users u ON u.id = d.user_id
     WHERE d.user_id=$1`,
    [userId]
  );
  if (!driver) throw new AppError('Driver profile not found', 404);
  return driver;
}

export async function getEarningsSummary(userId: string): Promise<object> {
  const driver = await queryOne<DbDriver>('SELECT * FROM drivers WHERE user_id=$1', [userId]);
  if (!driver) throw new AppError('Driver not found', 404);

  const today = await queryOne<{ total: string; count: string }>(
    `SELECT COALESCE(SUM(total_earnings),0) as total, COUNT(*) as count
     FROM payments p
     JOIN rides r ON r.id = p.ride_id
     WHERE p.driver_id=$1 AND DATE(r.completed_at) = CURRENT_DATE`,
    [driver.id]
  );

  const week = await queryOne<{ total: string }>(
    `SELECT COALESCE(SUM(total_earnings),0) as total
     FROM payments p
     JOIN rides r ON r.id = p.ride_id
     WHERE p.driver_id=$1 AND r.completed_at >= NOW() - INTERVAL '7 days'`,
    [driver.id]
  );

  return {
    today_earnings: parseFloat(today?.total ?? '0'),
    today_trips: parseInt(today?.count ?? '0', 10),
    week_earnings: parseFloat(week?.total ?? '0'),
    total_trips: driver.total_trips,
    rating: driver.rating_avg,
    wallet_balance: driver.wallet_balance,
  };
}
