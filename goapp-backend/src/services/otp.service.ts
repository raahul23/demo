import { redis } from '../config/redis';
import { env, isDev } from '../config/env';
import { AppError } from '../middleware/error';

const OTP_TTL_SECONDS = 600;
const MAX_OTP_ATTEMPTS = 3;
const RATE_WINDOW_SECONDS = 600;

function generateOtp(): string {
  if (env.OTP_BYPASS) return '0000';
  return String(Math.floor(1000 + Math.random() * 9000));
}

async function sendSms(phone: string, message: string): Promise<void> {
  if (!env.MSG91_AUTH_KEY) {
    if (isDev) {
      console.log(`[OTP SMS] To: ${phone} | Message: ${message}`);
    }
    return;
  }

  const { default: axios } = await import('axios');
  await axios.post(
    'https://api.msg91.com/api/v5/otp',
    {
      template_id: env.MSG91_TEMPLATE_ID,
      mobile: phone,
      authkey: env.MSG91_AUTH_KEY,
      otp: message,
    },
    { headers: { 'Content-Type': 'application/json' } }
  );
}

export async function requestOtp(phone: string): Promise<string> {
  const rateKey = `otp:rate:${phone}`;
  const count = await redis.incr(rateKey);
  if (count === 1) await redis.expire(rateKey, RATE_WINDOW_SECONDS);
  if (count > MAX_OTP_ATTEMPTS) {
    throw new AppError('Too many OTP requests. Try again in 10 minutes.', 429, 'TOO_MANY_OTP_REQUESTS');
  }

  const otp = generateOtp();
  const otpId = `${phone}_${Date.now()}`;

  await redis.set(`otp:${phone}`, JSON.stringify({ otp, otpId }), 'EX', OTP_TTL_SECONDS);
  await sendSms(phone, `Your GoApp OTP is ${otp}. Valid for 10 minutes.`);

  return otpId;
}

export async function verifyOtp(phone: string, submittedOtp: string): Promise<void> {
  const raw = await redis.get(`otp:${phone}`);
  if (!raw) throw new AppError('OTP expired or not found', 400, 'OTP_EXPIRED');

  const { otp } = JSON.parse(raw) as { otp: string; otpId: string };

  if (otp !== submittedOtp) {
    throw new AppError('Invalid OTP', 400, 'OTP_INVALID');
  }

  await redis.del(`otp:${phone}`);
}

export async function resendOtp(phone: string): Promise<void> {
  await requestOtp(phone);
}
