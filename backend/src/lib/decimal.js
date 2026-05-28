// ===================================================================
// ServiceHub Backend — Safe Decimal Arithmetic
// Zenith Intercontinental LLC
// -------------------------------------------------------------------
// All monetary calculations route through this layer to prevent
// JavaScript floating-point errors (0.1 + 0.2 !== 0.3).
// ===================================================================

const Decimal = require('decimal.js');

// Default precision: 28 significant digits, round half-up
Decimal.set({ precision: 28, rounding: Decimal.ROUND_HALF_UP });

/**
 * Create a Decimal from any numeric value.
 * @param {number|string|Decimal} value
 * @returns {Decimal}
 */
function D(value) {
  if (value instanceof Decimal) return value;
  return new Decimal(value);
}

/**
 * Multiply two numbers: a * b
 * @param {number|string} a
 * @param {number|string} b
 * @returns {number} — fixed to 2 decimal places
 */
function mul(a, b) {
  return D(a).times(D(b)).toNumber();
}

/**
 * Divide two numbers: a / b
 * @param {number|string} a
 * @param {number|string} b
 * @returns {number} — fixed to 2 decimal places
 */
function div(a, b) {
  if (D(b).isZero()) throw new Error('Division by zero');
  return D(a).dividedBy(D(b)).toNumber();
}

/**
 * Add two numbers: a + b
 * @param {number|string} a
 * @param {number|string} b
 * @returns {number}
 */
function add(a, b) {
  return D(a).plus(D(b)).toNumber();
}

/**
 * Subtract: a - b
 * @param {number|string} a
 * @param {number|string} b
 * @returns {number}
 */
function sub(a, b) {
  return D(a).minus(D(b)).toNumber();
}

/**
 * Calculate commission: grossAmount × rate
 * @param {number} grossAmount
 * @param {number} rate — e.g. 0.15 for 15%
 * @returns {number} the commission fee, fixed to 2 decimals
 */
function calculateCommission(grossAmount, rate = 0.15) {
  return mul(grossAmount, rate);
}

/**
 * Calculate net amount after commission: grossAmount - commissionFee
 * For cash jobs, this yields a negative value which debits the wallet.
 * @param {number} grossAmount
 * @param {number} commissionFee
 * @returns {number}
 */
function calculateNet(grossAmount, commissionFee) {
  return sub(grossAmount, commissionFee);
}

/**
 * Format a number to 2 decimal places as a string (safe for DB).
 * @param {number} value
 * @returns {string} — e.g. "150.00"
 */
function formatMoney(value) {
  return D(value).toFixed(2);
}

/**
 * Check if wallet balance has breached the negative threshold.
 * @param {number} balance — current wallet balance (can be negative)
 * @param {number} threshold — e.g. -500 for PKR
 * @returns {boolean} — true if balance <= threshold
 */
function isBelowThreshold(balance, threshold) {
  return D(balance).lte(D(threshold));
}

module.exports = {
  D,
  add,
  sub,
  mul,
  div,
  calculateCommission,
  calculateNet,
  formatMoney,
  isBelowThreshold,
};