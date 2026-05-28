import { z } from 'zod';

export const RequestOtpSchema = z.object({
  phone: z
    .string()
    .min(10)
    .max(15)
    .regex(/^\+?[0-9]{10,15}$/, 'Invalid phone number'),
  role: z.enum(['RIDER', 'DRIVER']).optional().default('RIDER'),
});

export const VerifyOtpSchema = z.object({
  phone: z.string().min(10).max(15),
  otp: z.string().length(4),
  otp_id: z.string().optional(),
  deviceId: z.string().optional(),
});

export const ResendOtpSchema = z.object({
  phone: z.string().min(10).max(15),
});

export const RefreshTokenSchema = z.object({
  refreshToken: z.string().min(1),
});
