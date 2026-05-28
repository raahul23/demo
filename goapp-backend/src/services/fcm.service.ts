import { env, isDev } from '../config/env';

interface FcmMessage {
  title: string;
  body: string;
  data?: Record<string, string>;
}

let _firebaseApp: unknown = null;

async function getFirebaseApp(): Promise<unknown> {
  if (!env.FIREBASE_SERVICE_ACCOUNT_B64) return null;
  if (_firebaseApp) return _firebaseApp;

  try {
    // eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-explicit-any
    const admin = require('firebase-admin') as any;
    if (admin.apps.length > 0) { _firebaseApp = admin.apps[0]; return _firebaseApp; }
    const serviceAccount = JSON.parse(
      Buffer.from(env.FIREBASE_SERVICE_ACCOUNT_B64, 'base64').toString('utf-8')
    );
    _firebaseApp = admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    return _firebaseApp;
  } catch {
    return null;
  }
}

export async function sendPushNotification(
  fcmToken: string,
  message: FcmMessage
): Promise<void> {
  if (!fcmToken) return;

  const app = await getFirebaseApp();
  if (!app) {
    if (isDev) console.log('[FCM]', { fcmToken: fcmToken.slice(0, 20) + '...', ...message });
    return;
  }

  try {
    // eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-explicit-any
    const admin = require('firebase-admin') as any;
    await admin.messaging(app).send({
      token: fcmToken,
      notification: { title: message.title, body: message.body },
      data: message.data,
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
  } catch (err) {
    if (isDev) console.warn('[FCM] Send failed:', err);
  }
}

export async function sendToMultiple(tokens: string[], message: FcmMessage): Promise<void> {
  if (tokens.length === 0) return;
  await Promise.allSettled(tokens.map((t) => sendPushNotification(t, message)));
}
