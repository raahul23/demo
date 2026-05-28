import * as dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),

  JWT_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),

  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string(),

  GOOGLE_MAPS_API_KEY: z.string().default(''),
  FIREBASE_SERVICE_ACCOUNT_B64: z.string().default(''),

  MSG91_AUTH_KEY: z.string().default(''),
  MSG91_TEMPLATE_ID: z.string().default(''),

  AWS_S3_BUCKET: z.string().default(''),
  AWS_REGION: z.string().default('ap-south-1'),
  AWS_ACCESS_KEY_ID: z.string().default(''),
  AWS_SECRET_ACCESS_KEY: z.string().default(''),

  OTP_BYPASS: z.coerce.boolean().default(false),
});

const parsed = EnvSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
export const isDev = env.NODE_ENV === 'development';
export const isTest = env.NODE_ENV === 'test';
