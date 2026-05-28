import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authMiddleware } from '../../middleware/auth';
import { requireRole } from '../../middleware/role';
import { validate } from '../../middleware/validate';
import { query, queryOne } from '../../config/database';
import { getOrCreateDriver } from './driver.service';
import { AppError } from '../../middleware/error';

export const onboardingRouter = Router();

onboardingRouter.use(authMiddleware);

const ProfileSchema = z.object({
  name: z.string().min(1),
  city: z.string().optional(),
  vehicle_type: z.enum(['bike', 'auto', 'car']),
  plate_number: z.string().min(1),
  vehicle_make: z.string().optional(),
  vehicle_model: z.string().optional(),
  vehicle_color: z.string().optional(),
  vehicle_year: z.coerce.number().optional(),
});

onboardingRouter.post('/profile', validate(ProfileSchema), async (req, res, next) => {
  try {
    const driver = await getOrCreateDriver(req.user!.id);

    await query(
      `UPDATE users SET name=$1, updated_at=NOW() WHERE id=$2`,
      [req.body.name, req.user!.id]
    );
    await query(
      `UPDATE drivers SET city=$1, vehicle_type=$2, updated_at=NOW() WHERE id=$3`,
      [req.body.city ?? null, req.body.vehicle_type, driver.id]
    );

    // Upsert vehicle
    const existing = await queryOne<{ id: string }>(
      'SELECT id FROM vehicles WHERE driver_id=$1 AND is_active=TRUE',
      [driver.id]
    );

    if (existing) {
      await query(
        `UPDATE vehicles SET plate_number=$1, vehicle_type=$2, make=$3, model=$4, color=$5 WHERE id=$6`,
        [req.body.plate_number, req.body.vehicle_type, req.body.vehicle_make ?? null,
         req.body.vehicle_model ?? null, req.body.vehicle_color ?? null, existing.id]
      );
    } else {
      await query(
        `INSERT INTO vehicles (driver_id, plate_number, vehicle_type, make, model, color, year)
         VALUES ($1,$2,$3,$4,$5,$6,$7)`,
        [driver.id, req.body.plate_number, req.body.vehicle_type,
         req.body.vehicle_make ?? null, req.body.vehicle_model ?? null,
         req.body.vehicle_color ?? null, req.body.vehicle_year ?? null]
      );
    }

    res.json({ message: 'Profile saved', driver_id: driver.id });
  } catch (err) { next(err); }
});

onboardingRouter.get('/progress', async (req, res, next) => {
  try {
    const driver = await queryOne<{
      id: string; onboarding_status: string; vehicle_type: string; city: string;
    }>(
      `SELECT d.id, d.onboarding_status, d.vehicle_type, d.city
       FROM drivers d WHERE d.user_id=$1`,
      [req.user!.id]
    );

    if (!driver) {
      res.json({ step: 'profile', onboarding_status: 'PENDING', completed_steps: [] });
      return;
    }

    const docs = await query<{ doc_type: string; status: string }>(
      'SELECT doc_type, status FROM documents WHERE driver_id=$1',
      [driver.id]
    );

    res.json({
      driver_id: driver.id,
      onboarding_status: driver.onboarding_status,
      vehicle_type: driver.vehicle_type,
      city: driver.city,
      documents: docs,
    });
  } catch (err) { next(err); }
});

onboardingRouter.post('/submit', async (req, res, next) => {
  try {
    const driver = await queryOne<{ id: string }>(
      'SELECT id FROM drivers WHERE user_id=$1',
      [req.user!.id]
    );
    if (!driver) throw new AppError('Driver profile not found', 404);

    await query(
      `UPDATE drivers SET onboarding_status='DOCUMENTS_SUBMITTED', updated_at=NOW() WHERE id=$1`,
      [driver.id]
    );

    res.json({ message: 'Documents submitted for review', onboarding_status: 'DOCUMENTS_SUBMITTED' });
  } catch (err) { next(err); }
});
