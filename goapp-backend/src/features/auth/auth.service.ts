import * as jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { query, queryOne } from '../../config/database';
import { redis } from '../../config/redis';
import { env } from '../../config/env';
import { requestOtp, verifyOtp, resendOtp } from '../../services/otp.service';
import { AppError } from '../../middleware/error';
import { DbUser, UserRole, JwtPayload } from '../../types';

const ACCESS_TOKEN_EXPIRY = '1h';
const REFRESH_TOKEN_EXPIRY = '30d';
const REFRESH_TTL_SECONDS = 30 * 24 * 3600;

export async function handleRequestOtp(phone: string): Promise<string> {
  return requestOtp(phone);
}

export async function handleResendOtp(phone: string): Promise<void> {
  return resendOtp(phone);
}

export async function handleLogin(
  phone: string,
  otp: string,
  deviceId?: string
): Promise<{ accessToken: string; refreshToken: string; user: { id: string; name: string; token: string } }> {
  await verifyOtp(phone, otp);

  let user = await queryOne<DbUser>('SELECT * FROM users WHERE phone = $1', [phone]);

  if (!user) {
    const rows = await query<DbUser>(
      `INSERT INTO users (phone, role) VALUES ($1, 'RIDER') RETURNING *`,
      [phone]
    );
    user = rows[0];
  }

  if (!user.is_active) {
    throw new AppError('Account is disabled', 403, 'ACCOUNT_DISABLED');
  }

  const tokens = await issueTokens(user.id, user.role, deviceId ?? 'unknown');

  if (deviceId) {
    await query('UPDATE users SET updated_at = NOW() WHERE id = $1', [user.id]);
  }

  return {
    ...tokens,
    user: {
      id: user.id,
      name: user.name ?? '',
      token: tokens.accessToken,
    },
  };
}

export async function handleRefresh(
  refreshToken: string
): Promise<{ accessToken: string; refreshToken: string }> {
  let payload: JwtPayload;
  try {
    payload = jwt.verify(refreshToken, env.JWT_REFRESH_SECRET) as JwtPayload;
  } catch {
    throw new AppError('Invalid refresh token', 401, 'INVALID_REFRESH_TOKEN');
  }

  const sessionKey = `refresh:${payload.sessionId}`;
  const sessionRaw = await redis.get(sessionKey);
  if (!sessionRaw) throw new AppError('Session expired', 401, 'SESSION_EXPIRED');

  const session = JSON.parse(sessionRaw) as { userId: string; role: UserRole };

  await redis.del(sessionKey);

  return issueTokens(session.userId, session.role, 'refresh');
}

export async function handleLogout(sessionId: string): Promise<void> {
  await redis.del(`refresh:${sessionId}`);
}

async function issueTokens(
  userId: string,
  role: UserRole,
  deviceId: string
): Promise<{ accessToken: string; refreshToken: string }> {
  const sessionId = uuidv4();

  const accessToken = jwt.sign(
    { sub: userId, role, sessionId } satisfies Omit<JwtPayload, 'iat' | 'exp'>,
    env.JWT_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRY }
  );

  const refreshToken = jwt.sign(
    { sub: userId, sessionId },
    env.JWT_REFRESH_SECRET,
    { expiresIn: REFRESH_TOKEN_EXPIRY }
  );

  await redis.set(
    `refresh:${sessionId}`,
    JSON.stringify({ userId, role, deviceId }),
    'EX',
    REFRESH_TTL_SECONDS
  );

  return { accessToken, refreshToken };
}
