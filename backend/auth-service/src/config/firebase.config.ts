import * as admin from 'firebase-admin';
import serviceAccount from './serviceAccountKey.json';

// Avoid double initialization
if (admin.apps.length === 0) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as any),
  });
}

export const db = admin.firestore();
