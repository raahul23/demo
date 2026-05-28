import { Router, Request, Response, NextFunction } from 'express';
import { authMiddleware } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { query, queryOne } from '../../config/database';
import { AppError } from '../../middleware/error';

export const adminRouter = Router();

adminRouter.use(authMiddleware, requireRole('ADMIN'));

adminRouter.get('/drivers', async (req, res, next) => {
  try {
    const { status, city, page = '1', limit = '20' } = req.query as Record<string, string>;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    const conditions: string[] = [];
    const params: unknown[] = [];

    if (status) { params.push(status); conditions.push(`d.onboarding_status=$${params.length}`); }
    if (city) { params.push(`%${city}%`); conditions.push(`d.city ILIKE $${params.length}`); }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    params.push(parseInt(limit), offset);

    const drivers = await query(
      `SELECT d.*, u.name, u.phone, u.email
       FROM drivers d JOIN users u ON u.id=d.user_id
       ${where}
       ORDER BY d.created_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params
    );
    res.json(drivers);
  } catch (err) { next(err); }
});

adminRouter.patch('/drivers/:id/verify', async (req, res, next) => {
  try {
    await query(
      `UPDATE drivers SET onboarding_status='VERIFIED', updated_at=NOW() WHERE id=$1`,
      [req.params.id]
    );
    res.json({ message: 'Driver verified' });
  } catch (err) { next(err); }
});

adminRouter.patch('/documents/:id/approve', async (req, res, next) => {
  try {
    await query(
      `UPDATE documents SET status='APPROVED', reviewed_at=NOW() WHERE id=$1`,
      [req.params.id]
    );
    res.json({ message: 'Document approved' });
  } catch (err) { next(err); }
});

adminRouter.patch('/documents/:id/reject', async (req, res, next) => {
  try {
    const { reason } = req.body as { reason?: string };
    await query(
      `UPDATE documents SET status='REJECTED', reject_reason=$1, reviewed_at=NOW() WHERE id=$2`,
      [reason ?? null, req.params.id]
    );
    res.json({ message: 'Document rejected' });
  } catch (err) { next(err); }
});

adminRouter.get('/rides', async (req, res, next) => {
  try {
    const { status, page = '1', limit = '20' } = req.query as Record<string, string>;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    const conditions = status ? `WHERE status='${status}'` : '';
    const rides = await query(
      `SELECT * FROM rides ${conditions} ORDER BY created_at DESC LIMIT $1 OFFSET $2`,
      [parseInt(limit), offset]
    );
    res.json(rides);
  } catch (err) { next(err); }
});

adminRouter.get('/analytics/dashboard', async (req, res, next) => {
  try {
    const [total_rides, active_drivers, today_rides, today_revenue] = await Promise.all([
      queryOne<{ count: string }>('SELECT COUNT(*) FROM rides'),
      queryOne<{ count: string }>('SELECT COUNT(*) FROM drivers WHERE is_online=TRUE'),
      queryOne<{ count: string }>(
        `SELECT COUNT(*) FROM rides WHERE DATE(created_at)=CURRENT_DATE`
      ),
      queryOne<{ sum: string }>(
        `SELECT COALESCE(SUM(total_charged),0) as sum FROM payments WHERE DATE(created_at)=CURRENT_DATE`
      ),
    ]);

    res.json({
      total_rides: parseInt(total_rides?.count ?? '0'),
      active_drivers: parseInt(active_drivers?.count ?? '0'),
      today_rides: parseInt(today_rides?.count ?? '0'),
      today_revenue: parseFloat(today_revenue?.sum ?? '0'),
    });
  } catch (err) { next(err); }
});
