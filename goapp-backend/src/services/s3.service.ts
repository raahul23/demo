import { env, isDev } from '../config/env';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';

export async function uploadToS3(
  buffer: Buffer,
  originalName: string,
  folder: string
): Promise<string> {
  const ext = path.extname(originalName);
  const key = `${folder}/${uuidv4()}${ext}`;

  if (!env.AWS_ACCESS_KEY_ID) {
    if (isDev) console.log(`[S3 Mock] Would upload to: ${key}`);
    return key;
  }

  try {
    // eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-explicit-any
    const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3') as any;
    const client = new S3Client({
      region: env.AWS_REGION,
      credentials: { accessKeyId: env.AWS_ACCESS_KEY_ID, secretAccessKey: env.AWS_SECRET_ACCESS_KEY },
    });
    await client.send(new PutObjectCommand({
      Bucket: env.AWS_S3_BUCKET, Key: key, Body: buffer, ContentType: getContentType(ext),
    }));
  } catch (err) {
    if (isDev) console.warn('[S3] Upload failed:', err);
  }

  return key;
}

export function getS3Url(key: string): string {
  if (!env.AWS_S3_BUCKET) return `https://example.com/${key}`;
  return `https://${env.AWS_S3_BUCKET}.s3.${env.AWS_REGION}.amazonaws.com/${key}`;
}

function getContentType(ext: string): string {
  const map: Record<string, string> = {
    '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
    '.png': 'image/png',  '.pdf': 'application/pdf',
  };
  return map[ext.toLowerCase()] ?? 'application/octet-stream';
}
