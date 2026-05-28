import { z } from 'zod';

const GeoPointSchema = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  address: z.string().max(300).optional(),
});

export const BookRideSchema = z.object({
  vehicleType: z.enum(['bike', 'auto', 'car']),
  pickup: GeoPointSchema,
  drop: GeoPointSchema,
  encodedPolyline: z.string().optional(),
  distanceMeters: z.number().int().positive().optional(),
  durationSeconds: z.number().int().positive().optional(),
});

export const CancelRideSchema = z.object({
  reason: z.string().max(300).optional(),
});

export const RateRideSchema = z.object({
  score: z.number().int().min(1).max(5),
  comment: z.string().max(500).optional(),
});

export const FareQuoteQuerySchema = z.object({
  pickupLat: z.coerce.number(),
  pickupLng: z.coerce.number(),
  dropLat: z.coerce.number(),
  dropLng: z.coerce.number(),
});
