import { Request, Response, NextFunction } from 'express';
import { isDev } from '../config/env';

export class AppError extends Error {
  constructor(
    public readonly message: string,
    public readonly statusCode: number = 500,
    public readonly code?: string
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      message: err.message,
      code: err.code,
    });
    return;
  }

  console.error('Unhandled error:', err);

  res.status(500).json({
    message: isDev ? err.message : 'Internal server error',
    ...(isDev && { stack: err.stack }),
  });
}
