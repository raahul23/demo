import * as fs from 'fs';
import * as path from 'path';
import { Pool } from 'pg';
import * as dotenv from 'dotenv';

dotenv.config();

async function migrate(): Promise<void> {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });

  const sqlPath = path.join(__dirname, '../migrations/001_schema.sql');
  const sql = fs.readFileSync(sqlPath, 'utf-8');

  console.log('Running migrations...');

  const client = await pool.connect();
  try {
    await client.query(sql);
    console.log('✓ Migration completed successfully');
  } catch (err) {
    console.error('✗ Migration failed:', err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

migrate();
