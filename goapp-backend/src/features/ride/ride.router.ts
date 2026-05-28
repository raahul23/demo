import { Router, Request, Response, NextFunction } from 'express';
import { authMiddleware } from '../../middleware/auth';
import { validate, validateQuery } from '../../middleware/validate';
import {
  BookRideSchema,
  CancelRideSchema,
  RateRideSchema,
  FareQuoteQuerySchema,
} from './ride.schema';
import {
  bookRide,
  getRide,
  getActiveRide,
  getRideHistory,
  cancelRide,
  getDriverInfo,
  submitRating,
  getFareQuoteForRoute,
} from './ride.service';

export const rideRouter = Router();

rideRouter.use(authMiddleware);

rideRouter.get(
  '/fare-quote',
  validateQuery(FareQuoteQuerySchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { pickupLat, pickupLng, dropLat, dropLng } = req.query as {
        pickupLat: string; pickupLng: string; dropLat: string; dropLng: string;
      };
      const quote = await getFareQuoteForRoute(
        { lat: Number(pickupLat), lng: Number(pickupLng) },
        { lat: Number(dropLat), lng: Number(dropLng) }
      );
      res.json(quote);
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.get(
  '/active',
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const ride = await getActiveRide(req.user!.id);
      res.json(ride ?? null);
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.get(
  '/history',
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const page = Math.max(1, Number(req.query.page) || 1);
      const limit = Math.min(50, Number(req.query.limit) || 20);
      const result = await getRideHistory(req.user!.id, page, limit);

      const formatted = result.rides.map((r) => ({
        id: r.id,
        status: r.status,
        pickup_label: r.pickup_address ?? `${r.pickup_lat},${r.pickup_lng}`,
        drop_label: r.drop_address ?? `${r.drop_lat},${r.drop_lng}`,
        started_at: r.started_at,
        ended_at: r.completed_at ?? r.cancelled_at,
        distance_km: ((r.distance_meters ?? 0) / 1000).toFixed(1),
        duration_min: Math.round((r.duration_seconds ?? 0) / 60),
        cancelled_by: r.cancelled_by,
        driver: (r as unknown as { driver_name?: string }).driver_name
          ? {
              name: (r as unknown as { driver_name: string }).driver_name,
              vehicle: (r as unknown as { vehicle_model?: string }).vehicle_model ?? 'Vehicle',
              plate: (r as unknown as { plate_number?: string }).plate_number ?? 'N/A',
              rating: 5.0,
            }
          : null,
        payment: {
          fare: r.final_fare ?? r.estimated_fare ?? 0,
          method: 'Cash',
          transaction_id: null,
        },
        support_note: 'For help with this ride, reach support anytime.',
        receipt_url: `https://api.goapp.com/rides/${r.id}/receipt`,
      }));

      res.json(formatted);
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.post(
  '/book',
  validate(BookRideSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const ride = await bookRide(req.user!.id, req.body);
      res.status(201).json({
        id: ride.id,
        status: ride.status,
        estimated_fare: ride.estimated_fare,
        vehicle_type: ride.vehicle_type,
        pickup: { lat: ride.pickup_lat, lng: ride.pickup_lng, address: ride.pickup_address },
        drop: { lat: ride.drop_lat, lng: ride.drop_lng, address: ride.drop_address },
      });
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.get(
  '/:rideId',
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const ride = await getRide(req.params.rideId);
      res.json(ride);
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.post(
  '/:rideId/cancel',
  validate(CancelRideSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cancelRide(req.params.rideId, 'RIDER', req.body.reason);
      res.json({ message: 'Ride cancelled' });
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.get(
  '/:rideId/driver',
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const info = await getDriverInfo(req.params.rideId);
      if (!info) {
        res.status(404).json({ message: 'Driver not assigned yet' });
        return;
      }
      res.json(info);
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.get(
  '/:rideId/receipt',
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json({ url: `https://api.goapp.com/receipts/${req.params.rideId}.pdf` });
    } catch (err) {
      next(err);
    }
  }
);

rideRouter.post(
  '/:rideId/rating',
  validate(RateRideSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      await submitRating(req.user!.id, req.params.rideId, req.body.score, req.body.comment);
      res.json({ status: 'ok' });
    } catch (err) {
      next(err);
    }
  }
);
