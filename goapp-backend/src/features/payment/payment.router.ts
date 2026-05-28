import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authMiddleware } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { query, queryOne } from '../../config/database';
import { AppError } from '../../middleware/error';

export const paymentRouter = Router();

paymentRouter.use(authMiddleware);

paymentRouter.get('/options', async (req, res, next) => {
  try {
    const amount = Number(req.query.amount) || 0;
    res.json([
      { id: 'cash', type: 'cash', title: 'Cash', subtitle: 'Pay cash to driver', is_recommended: true },
      { id: 'upi', type: 'upi', title: 'UPI', subtitle: 'Pay via UPI apps', is_recommended: false },
    ]);
  } catch (err) { next(err); }
});

const SubmitPaymentSchema = z.object({
  ride_id: z.string().uuid(),
  option_id: z.string(),
  amount: z.number().positive(),
});

paymentRouter.post('/submit', validate(SubmitPaymentSchema), async (req, res, next) => {
  try {
    const { ride_id, option_id, amount } = req.body;

    const payment = await queryOne<{ id: string }>(
      'SELECT id FROM payments WHERE ride_id=$1',
      [ride_id]
    );
    if (!payment) throw new AppError('Payment record not found', 404);

    await query(
      `UPDATE payments SET method=$1, status='COMPLETED', paid_at=NOW() WHERE ride_id=$2`,
      [option_id, ride_id]
    );

    const txnId = `TXN${Date.now()}`;
    res.json({ status: 'success', transaction_id: txnId });
  } catch (err) { next(err); }
});

const FeedbackSchema = z.object({
  driver_name: z.string().optional(),
  vehicle: z.string().optional(),
  plate_number: z.string().optional(),
  pickup_label: z.string().optional(),
  drop_label: z.string().optional(),
  distance_km: z.number().optional(),
  duration_min: z.number().optional(),
  rating: z.number().min(1).max(5),
  comment: z.string().max(500).optional(),
});

paymentRouter.post('/feedback', validate(FeedbackSchema), async (req, res, next) => {
  try {
    res.json({ status: 'ok' });
  } catch (err) { next(err); }
});
