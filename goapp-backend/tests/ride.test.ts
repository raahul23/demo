import request from 'supertest';
import express from 'express';
import * as jwt from 'jsonwebtoken';
import { authRouter } from '../src/features/auth/auth.router';
import { rideRouter } from '../src/features/ride/ride.router';
import { errorHandler } from '../src/middleware/error';
import { initRideService } from '../src/features/ride/ride.service';
import { redis } from '../src/config/redis';
import { pool } from '../src/config/database';
import { Server } from 'socket.io';
import { Queue } from 'bullmq';
import { createRedisClient } from '../src/config/redis';

// Mock io and queue for unit testing
const mockIo = { to: () => ({ emit: jest.fn() }) } as unknown as Server;
const mockQueue = { add: jest.fn() } as unknown as Queue;
initRideService(mockIo, mockQueue);

const app = express();
app.use(express.json());
app.use('/auth', authRouter);
app.use('/rides', rideRouter);
app.use(errorHandler);

let authToken: string;
let testUserId: string;
const testPhone = `+91${Math.floor(8000000000 + Math.random() * 999999999)}`;

beforeAll(async () => {
  // Register and login
  await request(app).post('/auth/request-otp').send({ phone: testPhone });
  const res = await request(app).post('/auth/login').send({ phone: testPhone, otp: '0000' });
  authToken = res.body.token;
  testUserId = res.body.id;
});

afterAll(async () => {
  // Clean up test user
  if (testUserId) {
    await pool.query('DELETE FROM users WHERE id=$1', [testUserId]);
  }
  await redis.quit();
  await pool.end();
});

describe('Ride API', () => {
  describe('GET /rides/fare-quote', () => {
    test('returns fare quotes for all vehicle types', async () => {
      const res = await request(app)
        .get('/rides/fare-quote')
        .set('Authorization', `Bearer ${authToken}`)
        .query({
          pickupLat: 12.9716,
          pickupLng: 77.5946,
          dropLat: 12.9816,
          dropLng: 77.6046,
        });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('servicePrices.bike');
      expect(res.body).toHaveProperty('servicePrices.auto');
      expect(res.body).toHaveProperty('servicePrices.car');
      expect(res.body.servicePrices.bike).toBeGreaterThan(0);
    });

    test('requires authentication', async () => {
      const res = await request(app).get('/rides/fare-quote').query({
        pickupLat: 12.97, pickupLng: 77.59, dropLat: 12.98, dropLng: 77.60,
      });
      expect(res.status).toBe(401);
    });
  });

  describe('GET /rides/active', () => {
    test('returns null when no active ride', async () => {
      const res = await request(app)
        .get('/rides/active')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.status).toBe(200);
      expect(res.body).toBeNull();
    });
  });

  describe('GET /rides/history', () => {
    test('returns empty array for new user', async () => {
      const res = await request(app)
        .get('/rides/history')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe('POST /rides/book', () => {
    test('rejects booking with invalid body', async () => {
      const res = await request(app)
        .post('/rides/book')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ vehicleType: 'invalid' });

      expect(res.status).toBe(400);
    });

    test('requires authentication', async () => {
      const res = await request(app).post('/rides/book').send({
        vehicleType: 'bike',
        pickup: { lat: 12.97, lng: 77.59 },
        drop: { lat: 12.98, lng: 77.60 },
      });
      expect(res.status).toBe(401);
    });
  });
});
