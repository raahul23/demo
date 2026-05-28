import { Server, Socket } from 'socket.io';
import { redis } from '../config/redis';
import { query } from '../config/database';
import { LocationUpdate } from '../types';

function isValidCoord(lat: number, lng: number): boolean {
  return (
    typeof lat === 'number' &&
    typeof lng === 'number' &&
    lat >= -90 && lat <= 90 &&
    lng >= -180 && lng <= 180
  );
}

async function getEtaMin(driverId: string, rideId: string): Promise<number> {
  // Simplified ETA: return a constant for now
  // In production, call Google Routes API with current driver location
  return 5;
}

export function registerLocationHandlers(io: Server): void {
  io.on('connection', (socket: Socket) => {
    const { userId, role } = socket.data as { userId: string; role: string };

    if (role === 'DRIVER') {
      socket.join(`driver:${userId}`);
    } else if (role === 'RIDER') {
      socket.join(`rider:${userId}`);
    }

    socket.on('driver:location', async (data: LocationUpdate) => {
      if (role !== 'DRIVER') return;
      const { lat, lng, heading, speedKmh } = data;
      if (!isValidCoord(lat, lng)) return;

      try {
        // 1. Get driver record
        const rows = await query<{ id: string }>(
          'SELECT id FROM drivers WHERE user_id=$1',
          [userId]
        );
        const driverId = rows[0]?.id;
        if (!driverId) return;

        // 2. Update Redis hot cache
        await redis.set(
          `driver:location:${driverId}`,
          JSON.stringify({ lat, lng, heading: heading ?? 0, speedKmh: speedKmh ?? 0, ts: Date.now() }),
          'EX', 30
        );

        // 3. Push location snapshot to batch list (flushed to DB by worker)
        const rideId = await redis.get(`driver:activeRide:${driverId}`);
        if (!rideId) return;

        await redis.lpush(
          `loc:batch:${rideId}`,
          JSON.stringify({ lat, lng, heading: heading ?? 0, speedKmh: speedKmh ?? 0 })
        );
        await redis.expire(`loc:batch:${rideId}`, 3600);

        // 4. Get rider and forward location
        const rideRaw = await redis.get(`ride:session:${rideId}`);
        if (!rideRaw) return;
        const ride = JSON.parse(rideRaw) as { rider_id: string };
        const etaMin = await getEtaMin(driverId, rideId);

        io.to(`rider:${ride.rider_id}`).emit('ride:driverLocation', {
          rideId,
          lat,
          lng,
          heading: heading ?? 0,
          etaMin,
        });

        // Also broadcast to the ride room
        io.to(`ride:${rideId}`).emit('ride:driverLocation', {
          rideId, lat, lng, heading: heading ?? 0, etaMin,
        });
      } catch {
        // Non-fatal — location update failure should not crash
      }
    });

    socket.on('ride:subscribe', (rideId: string) => {
      socket.join(`ride:${rideId}`);
    });

    socket.on('ride:unsubscribe', (rideId: string) => {
      socket.leave(`ride:${rideId}`);
    });

    socket.on('disconnect', async () => {
      if (role === 'DRIVER') {
        try {
          const rows = await query<{ id: string }>(
            'SELECT id FROM drivers WHERE user_id=$1',
            [userId]
          );
          const driverId = rows[0]?.id;
          if (driverId) {
            await redis.del(`driver:location:${driverId}`);
            // Mark offline after 30s of no reconnect (handled by worker)
          }
        } catch { /* ignore */ }
      }
    });
  });
}
