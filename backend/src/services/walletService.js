// ===================================================================
// ServiceHub Backend — Wallet Engine
// Zenith Intercontinental LLC
// -------------------------------------------------------------------
// Handles all wallet balance mutations, ledger logging, threshold
// enforcement, and top-up processing for the hybrid cash/digital
// architecture used in Karachi, Pakistan.
// ===================================================================

const prisma = require('../lib/prisma');
const config = require('../config');
const Decimal = require('../lib/decimal');

/**
 * Debit a provider's wallet by the platform commission fee.
 *
 * For CASH jobs: the provider receives cash from the customer physically;
 * the platform debits 15% from the provider's digital wallet (creating
 * a negative balance if needed). This is the "hybrid" model.
 *
 * For DIGITAL jobs: the gross amount is credited, then immediately
 * debited by commission, so net flows to provider.
 *
 * @param {Object} params
 * @param {string} params.providerId
 * @param {number} params.grossAmount — total job price
 * @param {number} params.commissionFee — 15% of gross
 * @param {number} params.netAmount — gross - commission (negative for cash)
 * @param {string} params.bookingId
 * @param {string} params.currency — "PKR", "USD", "AED"
 * @param {string} params.method — "CASH" | "MOBILE_WALLET" | "CREDIT_CARD"
 * @param {boolean} params.isCashPayment — if true, only commission is debited
 * @returns {Promise<Object>} { provider, ledgerEntry }
 */
async function processWalletDebit({
  providerId,
  grossAmount,
  commissionFee,
  netAmount,
  bookingId,
  currency = 'PKR',
  method,
  isCashPayment,
}) {
  const provider = await prisma.provider.findUniqueOrThrow({
    where: { id: providerId },
  });

  // ── Calculate new balance ──
  let balanceDelta;

  if (isCashPayment) {
    // CASH: Customer pays provider in cash.
    // Platform debits ONLY the 15% commission from digital wallet.
    // netAmount here is negative (e.g. -150 for a 1000 job with 150 commission)
    balanceDelta = Decimal.sub(0, commissionFee); // e.g. -150
  } else {
    // DIGITAL: Payment flows through platform.
    // Provider gets gross amount credited, commission debited.
    balanceDelta = Decimal.sub(grossAmount, commissionFee); // netAmount
  }

  const balanceBefore = provider.walletBalance;
  const balanceAfter = Decimal.add(balanceBefore, balanceDelta);

  // ── Update provider wallet ──
  const updatedProvider = await prisma.provider.update({
    where: { id: providerId },
    data: {
      walletBalance: Decimal.formatMoney(balanceAfter),
      totalEarnings: Decimal.add(provider.totalEarnings, grossAmount),
      totalCommission: Decimal.add(provider.totalCommission, commissionFee),
      totalJobs: provider.totalJobs + 1,
    },
  });

  // ── Write immutable ledger entry ──
  const ledgerEntry = await prisma.walletLedger.create({
    data: {
      providerId,
      entryType: 'COMMISSION_DEBIT',
      amount: Decimal.formatMoney(balanceDelta),
      balanceBefore: Decimal.formatMoney(balanceBefore),
      balanceAfter: Decimal.formatMoney(balanceAfter),
      referenceType: 'BOOKING',
      referenceId: bookingId,
      currency,
      description: isCashPayment
        ? `Cash job PKR ${grossAmount}: 15% commission (PKR ${commissionFee}) debited from wallet`
        : `Digital payment PKR ${grossAmount}: net PKR ${netAmount} after commission`,
    },
  });

  // ── Enforce threshold: lock provider if balance too negative ──
  await enforceWalletThreshold(updatedProvider);

  return { provider: updatedProvider, ledgerEntry };
}

/**
 * Credit a provider's wallet (for non-commission reasons like top-up or refund).
 * @param {Object} params
 * @returns {Promise<Object>}
 */
async function processWalletCredit({
  providerId,
  amount,
  currency = 'PKR',
  referenceType,
  referenceId,
  description,
  entryType = 'TOP_UP',
}) {
  const provider = await prisma.provider.findUniqueOrThrow({
    where: { id: providerId },
  });

  const balanceBefore = provider.walletBalance;
  const balanceAfter = Decimal.add(balanceBefore, amount);

  const updatedProvider = await prisma.provider.update({
    where: { id: providerId },
    data: {
      walletBalance: Decimal.formatMoney(balanceAfter),
    },
  });

  const ledgerEntry = await prisma.walletLedger.create({
    data: {
      providerId,
      entryType,
      amount: Decimal.formatMoney(amount),
      balanceBefore: Decimal.formatMoney(balanceBefore),
      balanceAfter: Decimal.formatMoney(balanceAfter),
      referenceType,
      referenceId,
      currency,
      description: description || `Wallet credit: ${amount} ${currency}`,
    },
  });

  // If threshold was breached, check if we've recovered
  if (updatedProvider.walletLocked) {
    await enforceWalletThreshold(updatedProvider);
  }

  return { provider: updatedProvider, ledgerEntry };
}

/**
 * Check wallet balance against threshold and toggle provider active/locked.
 * @param {Object} provider — from DB (must have walletBalance, walletThreshold, currency)
 * @returns {Promise<void>}
 */
async function enforceWalletThreshold(provider) {
  const threshold = config.getThreshold(provider.currency || 'PKR');
  const isLocked = Decimal.isBelowThreshold(provider.walletBalance, threshold);

  if (isLocked !== provider.walletLocked) {
    await prisma.provider.update({
      where: { id: provider.id },
      data: {
        walletLocked: isLocked,
        isActive: !isLocked, // deactivate if locked
      },
    });
  }
}

/**
 * Process a provider wallet top-up (clears negative balance).
 *
 * In Karachi, providers top up via local mobile wallets (JazzCash, Easypaisa).
 * This endpoint records the initiation; a webhook or manual verification
 * marks it COMPLETED.
 *
 * @param {Object} params
 * @returns {Promise<Object>}
 */
async function initiateTopUp({
  providerId,
  amount,
  localWalletProvider,
  currency = 'PKR',
}) {
  const provider = await prisma.provider.findUniqueOrThrow({
    where: { id: providerId },
  });

  // Fee for processing (e.g. 2% for mobile wallet)
  const feeRate = 0.02;
  const fee = Decimal.mul(amount, feeRate);
  const netAmount = Decimal.sub(amount, fee);

  const topUp = await prisma.walletTopUp.create({
    data: {
      providerId,
      amount: Decimal.formatMoney(amount),
      fee: Decimal.formatMoney(fee),
      netAmount: Decimal.formatMoney(netAmount),
      localWalletProvider,
      status: 'INITIATED',
      currency,
    },
  });

  // ── Mock integration: In production, redirect to JazzCash/Easypaisa ──
  // For demo, auto-complete the top-up after "payment"
  await completeTopUp(topUp.id);

  return topUp;
}

/**
 * Complete a pending top-up: credit the provider's wallet.
 * Called by webhook in production.
 * @param {string} topUpId
 * @returns {Promise<Object>}
 */
async function completeTopUp(topUpId) {
  const topUp = await prisma.walletTopUp.findUniqueOrThrow({
    where: { id: topUpId },
  });

  if (topUp.status !== 'INITIATED') {
    throw new Error(`TopUp ${topUpId} already ${topUp.status}`);
  }

  // Credit the wallet
  const result = await processWalletCredit({
    providerId: topUp.providerId,
    amount: topUp.netAmount,
    currency: topUp.currency,
    referenceType: 'TOP_UP',
    referenceId: topUp.id,
    description: `Top-up via ${topUp.localWalletProvider || 'mobile wallet'}: PKR ${topUp.amount}`,
    entryType: 'TOP_UP',
  });

  // Mark top-up as completed
  await prisma.walletTopUp.update({
    where: { id: topUpId },
    data: {
      status: 'COMPLETED',
      completedAt: new Date(),
      gatewayRef: `TXN${Date.now()}`,
    },
  });

  return result;
}

/**
 * Get provider wallet summary with recent ledger history.
 * @param {string} providerId
 * @returns {Promise<Object>}
 */
async function getWalletSummary(providerId) {
  const provider = await prisma.provider.findUniqueOrThrow({
    where: { id: providerId },
    select: {
      id: true,
      name: true,
      walletBalance: true,
      totalEarnings: true,
      totalCommission: true,
      walletLocked: true,
      isActive: true,
      currency: true,
      walletThreshold: true,
    },
  });

  const recentLedger = await prisma.walletLedger.findMany({
    where: { providerId },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });

  const pendingTopUps = await prisma.walletTopUp.findMany({
    where: { providerId, status: 'INITIATED' },
    orderBy: { createdAt: 'desc' },
    take: 10,
  });

  return {
    ...provider,
    walletBalance: Decimal.formatMoney(provider.walletBalance),
    totalEarnings: Decimal.formatMoney(provider.totalEarnings),
    totalCommission: Decimal.formatMoney(provider.totalCommission),
    recentTransactions: recentLedger.map((entry) => ({
      id: entry.id,
      type: entry.entryType,
      amount: Decimal.formatMoney(entry.amount),
      balanceBefore: Decimal.formatMoney(entry.balanceBefore),
      balanceAfter: Decimal.formatMoney(entry.balanceAfter),
      description: entry.description,
      createdAt: entry.createdAt,
    })),
    pendingTopUps: pendingTopUps.map((t) => ({
      id: t.id,
      amount: Decimal.formatMoney(t.amount),
      fee: Decimal.formatMoney(t.fee),
      status: t.status,
      provider: t.localWalletProvider,
      createdAt: t.createdAt,
    })),
  };
}

module.exports = {
  processWalletDebit,
  processWalletCredit,
  enforceWalletThreshold,
  initiateTopUp,
  completeTopUp,
  getWalletSummary,
};