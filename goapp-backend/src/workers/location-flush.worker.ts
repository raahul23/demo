import { pool } from '../config/database';
import { redis } from '../config/redis';

const FLUSH_INTERVAL_MS = 15_000;

async function flushLocationBatches(): Promise<void> {
  // Find all active ride batch keys
  const keys = await redis.keys('loc:batch:*');

  for (const key of keys) {
    const rideId = key.replace('loc:batch:', '');

    // Get all points and clear atomically
    const points = await redis.lrange(key, 0, -1);
    if (points.length === 0) continue;

    await redis.del(key);

    // Get driver_id from ride session
    const rideRaw = await redis.get(`ride:session:${rideId}`);
    if (!rideRaw) continue;
    const ride = JSON.parse(rideRaw) as { driver_id?: string };
    if (!ride.driver_id) continue;

    // Get driver's actual driver id from user_id (stored as driver.id in activeRide)
    const locationData = points.map((p) => JSON.parse(p) as {
      lat: number; lng: number; heading: number; speedKmh: number;
    });

    // Bulk insert location snapshots
    if (locationData.length > 0) {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        for (const loc of locationData) {
          await client.query(
            `INSERT INTO location_snapshots (ride_id, driver_id, lat, lng, heading, speed_kmh)
             VALUES ($1, $2, $3, $4, $5, $6)`,
            [rideId, ride.driver_id, loc.lat, loc.lng, loc.heading, loc.speedKmh]
          );
        }
        // Also update driver's current_location in PostGIS
        const last = locationData[locationData.length - 1];
        await client.query(
          `UPDATE drivers
           SET current_location = ST_SetSRID(ST_MakePoint($1,$2),4326)::geography,
               updated_at = NOW()
           WHERE id = $3`,
          [last.lng, last.lat, ride.driver_id]
        );
        await client.query('COMMIT');
      } catch {
        await client.query('ROLLBACK');
      } finally {
        client.release();
      }
    }
  }
}

export function startLocationFlushWorker(): NodeJS.Timeout {
  return setInterval(async () => {
    try {
      await flushLocationBatches();
    } catch {
      // Non-fatal
    }
  }, FLUSH_INTERVAL_MS);
}
