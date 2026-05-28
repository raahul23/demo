import { z } from 'zod';

export const CreateProfileSchema = z.object({
  name: z.string().min(1).max(100),
  gender: z.string().optional(),
  email: z.string().email().optional().or(z.literal('')),
  emergency_contact: z.string().optional(),
});

export const UpdateFcmTokenSchema = z.object({
  fcm_token: z.string().min(1),
});
