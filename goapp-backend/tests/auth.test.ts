import request from 'supertest';
import express from 'express';
import { authRouter } from '../src/features/auth/auth.router';
import { errorHandler } from '../src/middleware/error';
import { redis } from '../src/config/redis';
import { pool } from '../src/config/database';

const app = express();
app.use(express.json());
app.use('/auth', authRouter);
app.use(errorHandler);

afterAll(async () => {
  await redis.quit();
  await pool.end();
});

describe('Auth API', () => {
  const testPhone = `+91${Math.floor(9000000000 + Math.random() * 999999999)}`;

  describe('POST /auth/request-otp', () => {
    test('returns otp_id for valid phone', async () => {
      const res = await request(app)
        .post('/auth/request-otp')
        .send({ phone: testPhone });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('otp_id');
      expect(res.body).toHaveProperty('message', 'OTP sent');
    });

    test('rejects invalid phone number', async () => {
      const res = await request(app)
        .post('/auth/request-otp')
        .send({ phone: 'abc' });

      expect(res.status).toBe(400);
    });

    test('rejects missing phone', async () => {
      const res = await request(app)
        .post('/auth/request-otp')
        .send({});

      expect(res.status).toBe(400);
    });
  });

  describe('POST /auth/login', () => {
    test('returns user with token for valid OTP (bypass mode)', async () => {
      // Request OTP first
      await request(app)
        .post('/auth/request-otp')
        .send({ phone: testPhone });

      // Login with bypass OTP
      const res = await request(app)
        .post('/auth/login')
        .send({ phone: testPhone, otp: '0000' });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('id');
      expect(res.body).toHaveProperty('name');
      expect(res.body).toHaveProperty('token');
      expect(typeof res.body.token).toBe('string');
      expect(res.body.token.length).toBeGreaterThan(0);
    });

    test('rejects wrong OTP', async () => {
      await request(app)
        .post('/auth/request-otp')
        .send({ phone: testPhone });

      const res = await request(app)
        .post('/auth/login')
        .send({ phone: testPhone, otp: '9999' });

      // OTP_BYPASS is true so 0000 works but 9999 should fail
      expect(res.status).toBe(400);
    });

    test('rejects expired/missing OTP', async () => {
      const res = await request(app)
        .post('/auth/login')
        .send({ phone: '+919999999999', otp: '0000' });

      expect(res.status).toBe(400);
    });
  });

  describe('POST /auth/resend-otp', () => {
    test('returns success for valid phone', async () => {
      await request(app).post('/auth/request-otp').send({ phone: testPhone });

      const res = await request(app)
        .post('/auth/resend-otp')
        .send({ phone: testPhone });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message', 'OTP resent');
    });
  });
});
