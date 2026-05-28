import * as dotenv from 'dotenv';

dotenv.config();

// Override with test values
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_jwt_secret_key_min_32_chars_long';
process.env.JWT_REFRESH_SECRET = 'test_refresh_secret_key_min_32_chars_long';
process.env.DATABASE_URL = process.env.DATABASE_URL ?? 'postgresql://goapp:goapp_secret@localhost:5432/goapp';
process.env.REDIS_URL = process.env.REDIS_URL ?? 'redis://:goapp_redis_secret@localhost:6379';
process.env.OTP_BYPASS = 'true';
