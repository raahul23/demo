import { Router, Request, Response, NextFunction } from 'express';
import { authMiddleware } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { validate } from '../../middleware/validate';
import {
  GoOnlineSchema,
  LocationUpdateSchema,
  StartRideSchema,
  CompleteRideSchema,
  CancelRideDriverSchema,
  PaymentReceivedSchema,
  DriverRateRideSchema,
} from './driver.schema';
import {
  goOnline,
  goOffline,
  acceptRide,
  markArrived,
  driverStartRide,
  driverCompleteRide,
  driverCancelRide,
  getDriverProfile,
  getEarningsSummary,
} from './driver.service';
import { submitRating } from '../ride/ride.service';
import { query } from '../../config/database';
import { redis } from '../../config/redis';

export const driverRouter = Router();

driverRouter.use(authMiddleware, requireRole('DRIVER'));

driverRouter.get('/profile', async (req, res, next) => {
  try {
    res.json(await getDriverProfile(req.user!.id));
  } catch (err) { next(err); }
});

driverRouter.post('/go-online', validate(GoOnlineSchema), async (req, res, next) => {
  try {
    const { lat, lng, vehicleType } = req.body;
    await goOnline(req.user!.id, lat, lng, vehicleType);
    res.json({ message: 'Online', is_online: true });
  } catch (err) { next(err); }
});

driverRouter.post('/go-offline', async (req, res, next) => {
  try {
    await goOffline(req.user!.id);
    res.json({ message: 'Offline', is_online: false });
  } catch (err) { next(err); }
});

driverRouter.post('/location', validate(LocationUpdateSchema), async (req, res, next) => {
  try {
    const { lat, lng, heading, speedKmh } = req.body;
    const driver = await query<{ id: string }>(
      'SELECT id FROM drivers WHERE user_id=$1',
      [req.user!.id]
    );
    if (driver[0]) {
      await redis.set(
        `driver:location:${driver[0].id}`,
        JSON.stringify({ lat, lng, heading, speedKmh, ts: Date.now() }),
        'EX', 30
      );
    }
    res.json({ message: 'Location updated' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/accept', async (req, res, next) => {
  try {
    await acceptRide(req.user!.id, req.params.rideId);
    res.json({ message: 'Ride accepted' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/decline', async (req, res, next) => {
  try {
    res.json({ message: 'Ride declined' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/arrived', async (req, res, next) => {
  try {
    await markArrived(req.user!.id, req.params.rideId);
    res.json({ message: 'Marked as arrived' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/start', validate(StartRideSchema), async (req, res, next) => {
  try {
    await driverStartRide(req.user!.id, req.params.rideId, req.body.otp);
    res.json({ message: 'Ride started' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/complete', validate(CompleteRideSchema), async (req, res, next) => {
  try {
    await driverCompleteRide(req.user!.id, req.params.rideId);
    res.json({ message: 'Ride completed' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/cancel', validate(CancelRideDriverSchema), async (req, res, next) => {
  try {
    await driverCancelRide(req.user!.id, req.params.rideId, req.body.reason);
    res.json({ message: 'Ride cancelled' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/payment-received', validate(PaymentReceivedSchema), async (req, res, next) => {
  try {
    await query(
      `UPDATE payments SET method=$1, status='COMPLETED', paid_at=NOW()
       WHERE ride_id=$2`,
      [req.body.method, req.params.rideId]
    );
    res.json({ message: 'Payment recorded' });
  } catch (err) { next(err); }
});

driverRouter.post('/rides/:rideId/rating', validate(DriverRateRideSchema), async (req, res, next) => {
  try {
    res.json({ status: 'ok' });
  } catch (err) { next(err); }
});

driverRouter.get('/earnings/summary', async (req, res, next) => {
  try {
    res.json(await getEarningsSummary(req.user!.id));
  } catch (err) { next(err); }
});

driverRouter.get('/earnings/history', async (req, res, next) => {
  try {
    const driver = await query<{ id: string }>('SELECT id FROM drivers WHERE user_id=$1', [req.user!.id]);
    if (!driver[0]) { res.json([]); return; }
    const history = await query(
      `SELECT p.*, r.pickup_address, r.drop_address, r.completed_at, r.vehicle_type
       FROM payments p JOIN rides r ON r.id = p.ride_id
       WHERE p.driver_id=$1 ORDER BY p.created_at DESC LIMIT 50`,
      [driver[0].id]
    );
    res.json(history);
  } catch (err) { next(err); }
});
