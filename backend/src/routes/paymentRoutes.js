// ===================================================================
// ServiceHub Backend — Payment Routes
// Zenith Intercontinental LLC
// ===================================================================

const { Router } = require('express');
const paymentController = require('../controllers/paymentController');
const { authenticate } = require('../middleware/auth');
const { validatePaymentInput } = require('../middleware/validate');

const router = Router();

// ── All payment routes require authentication ──
router.use(authenticate);

/**
 * POST /api/payments/complete-job
 * Complete a job and process payment (cash or digital)
 */
router.post(
  '/complete-job',
  validatePaymentInput,
  paymentController.completeJob,
);

/**
 * GET /api/payments/wallet/:providerId
 * Get provider wallet summary
 */
router.get(
  '/wallet/:providerId',
  paymentController.getWallet,
);

/**
 * POST /api/payments/top-up
 * Initiate a provider wallet top-up
 */
router.post(
  '/top-up',
  paymentController.initiateTopUp,
);

module.exports = router;