import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { Queue } from 'bullmq';

import { createRedisClient } from './config/redis';
import { checkDbConnection } from './config/database';
import { checkRedisConnection } from './config/redis';
import { env } from './config/env';

import { authRouter } from './features/auth/auth.router';
import { profileRouter } from './features/profile/profile.router';
import { rideRouter } from './features/ride/ride.router';
import { driverRouter } from './features/driver/driver.router';
import { onboardingRouter } from './features/driver/onboarding.router';
import { paymentRouter } from './features/payment/payment.router';
import { walletRouter } from './features/wallet/wallet.router';
import { adminRouter } from './features/admin/admin.router';

import { socketJwtMiddleware } from './socket/socket.middleware';
import { registerLocationHandlers } from './socket/location.gateway';

import { initRideService } from './features/ride/ride.service';
import { initDriverService } from './features/driver/driver.service';
import { createMatchingWorker, createMatchingQueue } from './workers/matching.worker';
import { startLocationFlushWorker } from './workers/location-flush.worker';
import { errorHandler } from './middleware/error';

import { query } from './config/database';

export async function createApp(): Promise<{
  app: express.Application;
  server: http.Server;
  io: Server;
  matchingQueue: Queue;
}> {
  const app = express();
  const server = http.createServer(app);

  // ─── Socket.IO ───────────────────────────────────────────────────────────────
  const io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
    transports: ['websocket', 'polling'],
  });

  // Redis adapter for horizontal scaling
  const pubClient = createRedisClient();
  const subClient = pubClient.duplicate();
  io.adapter(createAdapter(pubClient, subClient));

  // Socket.IO JWT auth
  io.use(socketJwtMiddleware);
  registerLocationHandlers(io);

  // ─── Matching queue + worker ──────────────────────────────────────────────────
  const matchingQueue = createMatchingQueue();
  const matchingWorker = createMatchingWorker(io);

  matchingWorker.on('failed', (job, err) => {
    console.error(`Matching job ${job?.id} failed:`, err.message);
  });

  // ─── Location flush worker ────────────────────────────────────────────────────
  startLocationFlushWorker();

  // ─── Init services with io + queue ───────────────────────────────────────────
  initRideService(io, matchingQueue);
  initDriverService(io);

  // ─── Express middleware ───────────────────────────────────────────────────────
  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(cors({ origin: '*' }));
  app.use(express.json({ limit: '2mb' }));

  // Rate limiting
  app.use(
    '/auth',
    rateLimit({ windowMs: 60_000, max: 20, standardHeaders: true, legacyHeaders: false })
  );
  app.use(
    '/api',
    rateLimit({ windowMs: 60_000, max: 200, standardHeaders: true, legacyHeaders: false })
  );

  // ─── Routes ──────────────────────────────────────────────────────────────────
  app.use('/auth', authRouter);
  app.use('/profile', profileRouter);
  app.use('/rides', rideRouter);
  app.use('/payments', paymentRouter);
  app.use('/wallet', walletRouter);
  app.use('/admin', adminRouter);
  app.use('/feedback', paymentRouter); // /feedback handled inside paymentRouter

  // Driver routes (prefixed both ways for compatibility)
  app.use('/api/v1/driver', driverRouter);
  app.use('/api/v1/rides', driverRouter); // driver ride actions
  app.use('/api/v1/onboarding', onboardingRouter);
  app.use('/api/v1/earnings', driverRouter);
  app.use('/v1/captain', driverRouter); // Captain alias

  // Services list
  app.get('/services', async (_req, res, next) => {
    try {
      const services = await query(
        'SELECT * FROM services WHERE is_active=TRUE ORDER BY sort_order ASC'
      );
      res.json(services);
    } catch (err) { next(err); }
  });

  // ─── Health checks ────────────────────────────────────────────────────────────
  app.get('/health/live', (_req, res) => res.json({ status: 'ok' }));

  app.get('/health/ready', async (_req, res) => {
    const [db, redisOk] = await Promise.all([checkDbConnection(), checkRedisConnection()]);
    if (db && redisOk) {
      res.json({ status: 'ok', db: 'connected', redis: 'connected' });
    } else {
      res.status(503).json({ status: 'error', db: db ? 'ok' : 'error', redis: redisOk ? 'ok' : 'error' });
    }
  });

  // ─── Global error handler ─────────────────────────────────────────────────────
  app.use(errorHandler);

  return { app, server, io, matchingQueue };
}
