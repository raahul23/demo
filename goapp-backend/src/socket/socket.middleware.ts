import { Socket } from 'socket.io';
import * as jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { JwtPayload, UserRole } from '../types';

export interface AuthenticatedSocket extends Socket {
  data: {
    userId: string;
    role: UserRole;
    sessionId: string;
  };
}

export function socketJwtMiddleware(
  socket: Socket,
  next: (err?: Error) => void
): void {
  const token =
    socket.handshake.auth?.token ||
    (socket.handshake.headers.authorization as string | undefined)?.replace('Bearer ', '');

  if (!token) {
    next(new Error('Authentication required'));
    return;
  }

  try {
    const payload = jwt.verify(token, env.JWT_SECRET) as JwtPayload;
    socket.data = {
      userId: payload.sub,
      role: payload.role,
      sessionId: payload.sessionId,
    };
    next();
  } catch {
    next(new Error('Invalid token'));
  }
}
