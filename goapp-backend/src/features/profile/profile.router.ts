import { Router, Request, Response, NextFunction } from 'express';
import { authMiddleware } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { CreateProfileSchema, UpdateFcmTokenSchema } from './profile.schema';
import { createProfile, getProfile, updateFcmToken } from './profile.service';

export const profileRouter = Router();

profileRouter.use(authMiddleware);

profileRouter.post(
  '/create',
  validate(CreateProfileSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const profile = await createProfile(req.user!.id, req.body);
      res.json({
        id: profile.id,
        name: profile.name,
        gender: profile.gender,
        email: profile.email,
        emergency_contact: profile.emergency_contact,
      });
    } catch (err) {
      next(err);
    }
  }
);

profileRouter.get(
  '/me',
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const profile = await getProfile(req.user!.id);
      res.json({
        id: profile.id,
        name: profile.name,
        phone: profile.phone,
        email: profile.email,
        gender: profile.gender,
        emergency_contact: profile.emergency_contact,
        role: profile.role,
      });
    } catch (err) {
      next(err);
    }
  }
);

profileRouter.post(
  '/fcm-token',
  validate(UpdateFcmTokenSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      await updateFcmToken(req.user!.id, req.body.fcm_token);
      res.json({ message: 'FCM token updated' });
    } catch (err) {
      next(err);
    }
  }
);
