import { createApp } from './app';
import { env } from './config/env';
import { pool } from './config/database';
import { redis } from './config/redis';

async function main(): Promise<void> {
  const { server } = await createApp();

  server.listen(env.PORT, () => {
    console.log(`\n🚀 GoApp Backend running on http://localhost:${env.PORT}`);
    console.log(`   Environment : ${env.NODE_ENV}`);
    console.log(`   OTP bypass  : ${env.OTP_BYPASS ? 'ON (use "0000")' : 'OFF (real SMS)'}`);
    console.log(`   Health      : http://localhost:${env.PORT}/health/ready\n`);
  });

  // Graceful shutdown
  const shutdown = async (signal: string) => {
    console.log(`\n${signal} received — shutting down gracefully...`);
    server.close(async () => {
      await Promise.allSettled([pool.end(), redis.quit()]);
      console.log('Server closed');
      process.exit(0);
    });
    setTimeout(() => process.exit(1), 10_000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));

  process.on('unhandledRejection', (reason) => {
    console.error('Unhandled rejection:', reason);
  });
}

main().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
