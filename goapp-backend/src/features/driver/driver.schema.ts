import { z } from 'zod';

export const GoOnlineSchema = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  vehicleType: z.enum(['bike', 'auto', 'car']).optional(),
});

export const LocationUpdateSchema = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  heading: z.number().min(0).max(359).optional(),
  speedKmh: z.number().min(0).optional(),
});

export const AcceptRideSchema = z.object({});

export const StartRideSchema = z.object({
  otp: z.string().length(4),
});

export const CompleteRideSchema = z.object({
  finalLat: z.number().optional(),
  finalLng: z.number().optional(),
});

export const CancelRideDriverSchema = z.object({
  reason: z.string().max(300).optional(),
});

export const PaymentReceivedSchema = z.object({
  method: z.enum(['cash', 'upi', 'card', 'wallet']),
});

export const DriverRateRideSchema = z.object({
  score: z.number().int().min(1).max(5),
  comment: z.string().max(500).optional(),
});
