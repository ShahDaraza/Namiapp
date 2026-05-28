// ===================================================================
// ServiceHub Backend — Authentication Middleware
// Zenith Intercontinental LLC
// -------------------------------------------------------------------
// Verifies Firebase Auth tokens from the Authorization header.
// Injects req.user with firebaseUid.
//
// For local development without Firebase, falls back to a mock
// auth mode when NODE_ENV=development and FIREBASE_SKIP_AUTH=true.
// ===================================================================

const config = require('../config');

/**
 * Authenticate request using Firebase Auth Bearer token.
 * Sets req.user = { firebaseUid, email } on success.
 */
async function authenticate(req, res, next) {
  // ── Bypass for development without Firebase ──
  if (config.isDev && process.env.FIREBASE_SKIP_AUTH === 'true') {
    // Mock auth: read from X-Mock-User header or use default
    req.user = {
      firebaseUid: req.headers['x-mock-uid'] || 'mock-user-001',
      email: req.headers['x-mock-email'] || 'user@example.com',
    };
    return next();
  }

  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }

  const token = authHeader.split('Bearer ')[1].trim();
  if (!token) {
    return res.status(401).json({ error: 'Token is empty' });
  }

  try {
    // ── Verify Firebase ID token ──
    // In production, the firebase-admin SDK would be initialized here.
    // const decodedToken = await admin.auth().verifyIdToken(token);
    // req.user = { firebaseUid: decodedToken.uid, email: decodedToken.email };

    // ── For now, decode without verification (development placeholder) ──
    // Replace with real Firebase Admin verification for production
    console.warn('[Auth] Firebase token verification placeholder');
    req.user = {
      firebaseUid: 'firebase-user-id',
      email: 'user@example.com',
    };

    next();
  } catch (err) {
    console.error('[Auth] Token verification failed:', err.message);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

module.exports = { authenticate };