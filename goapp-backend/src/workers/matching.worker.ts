import { Worker, Queue, ConnectionOptions } from 'bullmq';
import { Server } from 'socket.io';
import { pool, queryOne } from '../config/database';
import { redis } from '../config/redis';
import { env } from '../config/env';
import { DbRide } from '../types';
import { sendPushNotification } from '../services/fcm.service';

interface MatchingJob {
  rideId: string;
}

interface NearbyDriver {
  id: string;
  user_id: string;
  name: string;
  dist_m: number;
  fcm_token: string | null;
}

const SEARCH_RADII = [3000, 5000, 8000];
const WAIT_BETWEEN_MS = 20_000;

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

function parseBullMqConnection(): ConnectionOptions {
  try {
    const url = new URL(env.REDIS_URL);
    const conn: ConnectionOptions = {
      host: url.hostname,
      port: url.port ? parseInt(url.port, 10) : 6379,
    };
    if (url.password) (conn as Record<string, unknown>).password = url.password;
    return conn;
  } catch {
    return { host: 'localhost', port: 6379 };
  }
}

async function waitForAcceptance(rideId: string, timeoutMs: number): Promise<boolean> {
  const lockKey = `ride:lock:${rideId}`;
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const locked = await redis.get(lockKey);
    if (locked) return true;
    await sleep(1_000);
  }
  return false;
}

async function findNearbyDrivers(
  pickupLng: number,
  pickupLat: number,
  vehicleType: string,
  radiusMeters: number
): Promise<NearbyDriver[]> {
  const result = await pool.query<NearbyDriver>(
    `SELECT d.id, d.user_id, u.name,
       ST_Distance(d.current_location, ST_MakePoint($1,$2)::geography) as dist_m,
       u.fcm_token
     FROM drivers d
     JOIN users u ON u.id = d.user_id
     WHERE d.is_online = TRUE
       AND d.vehicle_type = $3
       AND d.onboarding_status = 'VERIFIED'
       AND d.current_location IS NOT NULL
       AND NOT EXISTS (
         SELECT 1 FROM rides r
         WHERE r.driver_id = d.id
           AND r.status NOT IN ('RIDE_COMPLETED', 'CANCELLED')
       )
       AND ST_DWithin(
         d.current_location,
         ST_MakePoint($1,$2)::geography,
         $4
       )
     ORDER BY dist_m ASC
     LIMIT 10`,
    [pickupLng, pickupLat, vehicleType, radiusMeters]
  );
  return result.rows;
}

export function createMatchingWorker(io: Server): Worker {
  const connection = parseBullMqConnection();

  return new Worker<MatchingJob>(
    'match-ride',
    async (job) => {
      const { rideId } = job.data;

      const ride = await queryOne<DbRide>('SELECT * FROM rides WHERE id=$1', [rideId]);
      if (!ride || ride.status !== 'SEARCHING_FOR_DRIVER') return;

      for (let i = 0; i < SEARCH_RADII.length; i++) {
        const radius = SEARCH_RADII[i];
        const drivers = await findNearbyDrivers(
          ride.pickup_lng,
          ride.pickup_lat,
          ride.vehicle_type,
          radius
        );

        if (drivers.length === 0) {
          if (i < SEARCH_RADII.length - 1) await sleep(WAIT_BETWEEN_MS);
          continue;
        }

        for (const driver of drivers) {
          io.to(`driver:${driver.user_id}`).emit('order:available', {
            rideId: ride.id,
            pickup: { lat: ride.pickup_lat, lng: ride.pickup_lng, address: ride.pickup_address },
            drop:   { lat: ride.drop_lat,   lng: ride.drop_lng,   address: ride.drop_address },
            distanceKm: (driver.dist_m / 1000).toFixed(1),
            estimatedFare: ride.estimated_fare,
            vehicleType: ride.vehicle_type,
            expiresInMs: 15_000,
          });

          if (driver.fcm_token) {
            sendPushNotification(driver.fcm_token, {
              title: 'New Ride Request',
              body: `${ride.pickup_address ?? 'Pickup'} → ${ride.drop_address ?? 'Drop'} • ₹${ride.estimated_fare}`,
              data: { rideId: ride.id, type: 'new_ride' },
            }).catch(() => {});
          }

          await redis.sadd(`ride:offered:${rideId}`, driver.user_id);
        }

        const accepted = await waitForAcceptance(rideId, 15_000);
        if (accepted) return;

        if (i < SEARCH_RADII.length - 1) await sleep(WAIT_BETWEEN_MS);
      }

      const stillSearching = await queryOne<{ id: string }>(
        `SELECT id FROM rides WHERE id=$1 AND status='SEARCHING_FOR_DRIVER'`,
        [rideId]
      );
      if (stillSearching) {
        await pool.query(
          `UPDATE rides SET status='CANCELLED', cancelled_by='SYSTEM',
           cancel_reason='No driver found', cancelled_at=NOW(), updated_at=NOW()
           WHERE id=$1`,
          [rideId]
        );
        await redis.del(`ride:session:${rideId}`);
        io.to(`rider:${ride.rider_id}`).emit('ride:noDriverFound', { rideId });
      }
    },
    { connection, concurrency: 10 }
  );
}

export function createMatchingQueue(): Queue {
  const connection = parseBullMqConnection();
  return new Queue('match-ride', { connection });
}
