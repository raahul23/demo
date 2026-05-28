import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authMiddleware } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { query, queryOne } from '../../config/database';

export const walletRouter = Router();

walletRouter.use(authMiddleware);

walletRouter.get('/balance', async (req, res, next) => {
  try {
    const result = await queryOne<{ balance: string }>(
      `SELECT COALESCE(
        (SELECT SUM(CASE WHEN type='credit' THEN amount ELSE -amount END)
         FROM wallet_transactions WHERE user_id=$1), 0
      ) as balance`,
      [req.user!.id]
    );
    res.json({ balance: parseFloat(result?.balance ?? '0') });
  } catch (err) { next(err); }
});

const TopupSchema = z.object({
  amount: z.number().positive().max(100_000),
  method: z.enum(['upi', 'card', 'netbanking']),
});

walletRouter.post('/topup', validate(TopupSchema), async (req, res, next) => {
  try {
    const { amount, method } = req.body;
    await query(
      `INSERT INTO wallet_transactions (user_id, type, amount, description, reference)
       VALUES ($1, 'credit', $2, 'Wallet top-up via ${method}', $3)`,
      [req.user!.id, amount, `TOPUP_${Date.now()}`]
    );
    res.json({ message: 'Wallet topped up', amount });
  } catch (err) { next(err); }
});

walletRouter.get('/transactions', async (req, res, next) => {
  try {
    const txns = await query(
      `SELECT * FROM wallet_transactions WHERE user_id=$1 ORDER BY created_at DESC LIMIT 50`,
      [req.user!.id]
    );
    res.json(txns);
  } catch (err) { next(err); }
});
