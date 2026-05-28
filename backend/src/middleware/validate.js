// ===================================================================
// ServiceHub Backend — Input Validation Middleware
// Zenith Intercontinental LLC
// ===================================================================

/**
 * Validates the payment completion request body.
 */
function validatePaymentInput(req, res, next) {
  const { bookingId, paymentMethod } = req.body;

  const errors = [];

  if (!bookingId) {
    errors.push('bookingId is required');
  }

  if (!paymentMethod) {
    errors.push('paymentMethod is required');
  } else if (!['CASH', 'MOBILE_WALLET', 'CREDIT_CARD'].includes(paymentMethod)) {
    errors.push('paymentMethod must be CASH, MOBILE_WALLET, or CREDIT_CARD');
  }

  if (paymentMethod === 'MOBILE_WALLET' && !req.body.walletProvider) {
    errors.push('walletProvider is required for MOBILE_WALLET payments (JAZZCASH, EASYPAISA, NAYAPAY)');
  }

  if (errors.length > 0) {
    return res.status(400).json({ error: 'Validation failed', details: errors });
  }

  next();
}

module.exports = { validatePaymentInput };