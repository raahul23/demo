import { query, queryOne } from '../../config/database';
import { AppError } from '../../middleware/error';
import { DbUser } from '../../types';

interface CreateProfileDto {
  name: string;
  gender?: string;
  email?: string;
  emergency_contact?: string;
}

export async function createProfile(
  userId: string,
  dto: CreateProfileDto
): Promise<DbUser> {
  const updated = await queryOne<DbUser>(
    `UPDATE users
     SET name = $1, gender = $2, email = $3, emergency_contact = $4, updated_at = NOW()
     WHERE id = $5
     RETURNING *`,
    [dto.name, dto.gender ?? null, dto.email ?? null, dto.emergency_contact ?? null, userId]
  );

  if (!updated) throw new AppError('User not found', 404);
  return updated;
}

export async function getProfile(userId: string): Promise<DbUser> {
  const user = await queryOne<DbUser>('SELECT * FROM users WHERE id = $1', [userId]);
  if (!user) throw new AppError('User not found', 404);
  return user;
}

export async function updateFcmToken(userId: string, fcmToken: string): Promise<void> {
  await query('UPDATE users SET fcm_token = $1, updated_at = NOW() WHERE id = $2', [fcmToken, userId]);
}
