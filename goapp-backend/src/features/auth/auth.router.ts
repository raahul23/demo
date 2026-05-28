import { Router, Request, Response, NextFunction } from 'express';
import { validate } from '../../middleware/validate';
import { authMiddleware } from '../../middleware/auth';
import {
  RequestOtpSchema,
  VerifyOtpSchema,
  ResendOtpSchema,
  RefreshTokenSchema,
} from './auth.schema';
import {
  handleRequestOtp,
  handleLogin,
  handleResendOtp,
  handleRefresh,
  handleLogout,
} from './auth.service';

export const authRouter = Router();

authRouter.post(
  '/request-otp',
  validate(RequestOtpSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { phone } = req.body as { phone: string };
      const otpId = await handleRequestOtp(phone);
      res.json({ message: 'OTP sent', otp_id: otpId });
    } catch (err) {
      next(err);
    }
  }
);

authRouter.post(
  '/login',
  validate(VerifyOtpSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { phone, otp, otp_id, deviceId } = req.body as {
        phone: string;
        otp: string;
        otp_id?: string;
        deviceId?: string;
      };
      const result = await handleLogin(phone, otp, deviceId);
      res.json(result.user);
    } catch (err) {
      next(err);
    }
  }
);

authRouter.post(
  '/resend-otp',
  validate(ResendOtpSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { phone } = req.body as { phone: string };
      await handleResendOtp(phone);
      res.json({ message: 'OTP resent' });
    } catch (err) {
      next(err);
    }
  }
);

authRouter.post(
  '/refresh',
  validate(RefreshTokenSchema),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { refreshToken } = req.body as { refreshToken: string };
      const tokens = await handleRefresh(refreshToken);
      res.json(tokens);
    } catch (err) {
      next(err);
    }
  }
);

authRouter.post(
  '/logout',
  authMiddleware,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      await handleLogout(req.user!.sessionId);
      res.json({ message: 'Logged out' });
    } catch (err) {
      next(err);
    }
  }
);
