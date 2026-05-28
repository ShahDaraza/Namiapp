// ===================================================================
// ServiceHub Backend — Payment Controller
// Zenith Intercontinental LLC
// -------------------------------------------------------------------
// Routes:
//   POST /api/payments/complete-job — complete a job and process payment
//   GET  /api/payments/wallet/:providerId — get wallet summary
//   POST /api/payments/top-up — provider wallet top-up initiation
// ===================================================================

const prisma = require('../lib/prisma');
const config = require('../config');
const Decimal = require('../lib/decimal');
const walletService = require('../services/walletService');
const paymentGateway = require('../services/paymentGateway');

/**
 * POST /api/payments/complete-job
 *
 * Completes a booking and processes payment based on method:
 *
 * - CASH: Customer pays provider cash. Platform debits 15% commission
 *         from provider's digital wallet (balance goes negative).
 *
 * - DIGITAL (MOBILE_WALLET / CREDIT_CARD): Payment flows through
 *         Paymob with marketplace split. Provider gets gross credited
 *         minus 15% commission. Wallet credited by net amount.
 *
 * Request body:
 *   { bookingId, paymentMethod: "CASH"|"MOBILE_WALLET"|"CREDIT_CARD",
 *     walletProvider?: "JAZZCASH"|"EASYPAISA" (for MOBILE_WALLET) }
 */
async function completeJob(req, res) {
  const { bookingId, paymentMethod, walletProvider } = req.body;

  // ── Validate ──
  if (!bookingId || !paymentMethod) {
    return res.status(400).json({
      error: 'Missing required fields: bookingId, paymentMethod',
    });
  }

  const validMethods = ['CASH', 'MOBILE_WALLET', 'CREDIT_CARD'];
  if (!validMethods.includes(paymentMethod)) {
    return res.status(400).json({
      error: `Invalid paymentMethod. Must be one of: ${validMethods.join(', ')}`,
    });
  }

  try {
    // ── Fetch booking ──
    const booking = await prisma.booking.findUnique({
      where: { id: bookingId },
      include: {
        provider: true,
        user: true,
      },
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    if (booking.status === 'COMPLETED') {
      return res.status(409).json({ error: 'Booking is already completed' });
    }

    const grossAmount = booking.finalCost || booking.estimatedCost;
    const commissionRate = config.commission.rate;
    const commissionFee = Decimal.calculateCommission(grossAmount, commissionRate);
    const netAmount = Decimal.calculateNet(grossAmount, commissionFee);
    const currency = booking.provider.currency || 'PKR';
    const countryCode = booking.provider.countryCode || 'PK';

    // ── Determine if cash ──
    const isCashPayment = paymentMethod === 'CASH';

    // ── For DIGITAL payments: process through gateway ──
    let gatewayRef = null;
    if (!isCashPayment) {
      const gatewayResult = await paymentGateway.processPayment({
        amount: grossAmount,
        currency,
        countryCode,
        method: paymentMethod,
        metadata: {
          bookingId,
          userId: booking.userId,
          providerId: booking.providerId,
          customerEmail: booking.user.email,
          walletProvider: walletProvider || null,
        },
      });

      if (!gatewayResult.success) {
        return res.status(402).json({
          error: 'Payment failed',
          gatewayError: gatewayResult.error,
        });
      }

      gatewayRef = gatewayResult.gatewayRef;
    }

    // ── Process wallet debit (commission for cash, net for digital) ──
    const walletResult = await walletService.processWalletDebit({
      providerId: booking.providerId,
      grossAmount,
      commissionFee,
      netAmount,
      bookingId,
      currency,
      method: paymentMethod,
      isCashPayment,
    });

    // ── Update booking status ──
    const updatedBooking = await prisma.booking.update({
      where: { id: bookingId },
      data: {
        status: 'COMPLETED',
        completedAt: new Date(),
        paymentMethod,
        finalCost: grossAmount,
      },
    });

    // ── Create payment record ──
    const paymentRecord = await prisma.payment.create({
      data: {
        bookingId,
        userId: booking.userId,
        providerId: booking.providerId,
        grossAmount: Decimal.formatMoney(grossAmount),
        commissionFee: Decimal.formatMoney(commissionFee),
        netAmount: Decimal.formatMoney(netAmount),
        currency,
        method: paymentMethod,
        status: 'COMPLETED',
        gatewayReference: gatewayRef,
        completedAt: new Date(),
      },
    });

    // ── Response ──
    return res.status(200).json({
      success: true,
      message: isCashPayment
        ? `Job completed. Customer pays PKR ${grossAmount} cash. 15% commission (PKR ${Decimal.formatMoney(commissionFee)}) debited from wallet.`
        : `Job completed. Payment of PKR ${grossAmount} processed via ${paymentMethod}.`,
      data: {
        booking: {
          id: updatedBooking.id,
          status: updatedBooking.status,
          finalCost: Decimal.formatMoney(updatedBooking.finalCost),
          completedAt: updatedBooking.completedAt,
          paymentMethod: updatedBooking.paymentMethod,
        },
        payment: {
          id: paymentRecord.id,
          grossAmount: paymentRecord.grossAmount,
          commissionFee: paymentRecord.commissionFee,
          netAmount: paymentRecord.netAmount,
          method: paymentRecord.method,
          gatewayRef: paymentRecord.gatewayReference,
        },
        wallet: {
          providerId: walletResult.provider.id,
          balanceBefore: Decimal.formatMoney(
            Decimal.sub(walletResult.provider.walletBalance, 
              isCashPayment ? Decimal.sub(0, commissionFee) : Decimal.sub(grossAmount, commissionFee))
          ),
          balanceAfter: walletResult.provider.walletBalance,
          totalCommissionPaid: walletResult.provider.totalCommission,
          walletLocked: walletResult.provider.walletLocked,
        },
        ledgerEntry: {
          id: walletResult.ledgerEntry.id,
          amount: walletResult.ledgerEntry.amount,
          balanceAfter: walletResult.ledgerEntry.balanceAfter,
          description: walletResult.ledgerEntry.description,
        },
      },
    });
  } catch (err) {
    console.error('[completeJob] Error:', err);
    return res.status(500).json({
      error: 'Failed to complete job payment',
      details: err.message,
    });
  }
}

/**
 * GET /api/payments/wallet/:providerId
 *
 * Retrieves wallet summary for a provider, including:
 * - Current wallet balance
 * - Total earnings (lifetime gross)
 * - Total commission paid to Zenith Intercontinental LLC
 * - Recent transaction ledger (last 50 entries)
 * - Pending top-ups
 */
async function getWallet(req, res) {
  const { providerId } = req.params;

  if (!providerId) {
    return res.status(400).json({ error: 'providerId is required' });
  }

  try {
    const summary = await walletService.getWalletSummary(providerId);

    return res.status(200).json({
      success: true,
      data: summary,
    });
  } catch (err) {
    console.error('[getWallet] Error:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ error: 'Provider not found' });
    }
    return res.status(500).json({
      error: 'Failed to retrieve wallet',
      details: err.message,
    });
  }
}

/**
 * POST /api/payments/top-up
 *
 * Initiates a provider wallet top-up to clear negative balance.
 * In production, this redirects to JazzCash/Easypaisa for payment.
 *
 * Request body:
 *   { providerId, amount, localWalletProvider: "JAZZCASH"|"EASYPAISA"|"NAYAPAY" }
 */
async function initiateTopUp(req, res) {
  const { providerId, amount, localWalletProvider } = req.body;

  if (!providerId || !amount || !localWalletProvider) {
    return res.status(400).json({
      error: 'Missing required fields: providerId, amount, localWalletProvider',
    });
  }

  if (amount <= 0) {
    return res.status(400).json({ error: 'Amount must be positive' });
  }

  const validProviders = ['JAZZCASH', 'EASYPAISA', 'NAYAPAY'];
  if (!validProviders.includes(localWalletProvider)) {
    return res.status(400).json({
      error: `Invalid wallet provider. Must be one of: ${validProviders.join(', ')}`,
    });
  }

  try {
    const provider = await prisma.provider.findUniqueOrThrow({
      where: { id: providerId },
    });

    if (provider.walletBalance >= 0) {
      return res.status(400).json({
        error: `Wallet balance (${Decimal.formatMoney(provider.walletBalance)} ${provider.currency}) is already non-negative. No top-up needed.`,
      });
    }

    const topUp = await walletService.initiateTopUp({
      providerId,
      amount,
      localWalletProvider,
      currency: provider.currency || 'PKR',
    });

    return res.status(200).json({
      success: true,
      message: `Top-up of PKR ${amount} via ${localWalletProvider} initiated and completed.`,
      data: {
        topUpId: topUp.id,
        amount: Decimal.formatMoney(topUp.amount),
        fee: Decimal.formatMoney(topUp.fee),
        netAmount: Decimal.formatMoney(topUp.netAmount),
        provider: topUp.localWalletProvider,
        status: topUp.status,
      },
    });
  } catch (err) {
    console.error('[initiateTopUp] Error:', err);
    if (err.code === 'P2025') {
      return res.status(404).json({ error: 'Provider not found' });
    }
    return res.status(500).json({
      error: 'Failed to process top-up',
      details: err.message,
    });
  }
}

module.exports = {
  completeJob,
  getWallet,
  initiateTopUp,
};