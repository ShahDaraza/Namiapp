// ===================================================================
// ServiceHub Backend — Paymob Pakistan Marketplace Gateway
// Zenith Intercontinental LLC
// -------------------------------------------------------------------
// PRIMARY GATEWAY: Paymob Pakistan (Karachi, PKR)
//   - Credit/Debit Cards (Visa, Mastercard)
//   - Easypaisa (Telenor Microfinance Bank)
//   - JazzCash (Mobilink Microfinance Bank)
//   - Paymob Marketplace Split: 85% provider / 15% platform
//
// FUTURE GATEWAY: Airwallex (for international expansion)
//   - Activated when provider.countryCode !== 'PK'
// ===================================================================

const https = require('https');
const config = require('../config');
const Decimal = require('../lib/decimal');

// ──────────────────────────────────────────────────────────────
// PAYMOB PAKISTAN — REAL API INTEGRATION
// ──────────────────────────────────────────────────────────────

/**
 * Get Paymob API authentication token.
 * POST https://accept.paymob.com/api/auth/tokens
 */
async function getPaymobAuthToken() {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ api_key: config.paymob.apiKey });

    const req = https.request({
      hostname: 'accept.paymob.com',
      path: '/api/auth/tokens',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
      },
    }, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(body);
          if (parsed.token) {
            resolve(parsed.token);
          } else {
            reject(new Error(`Paymob auth failed: ${JSON.stringify(parsed)}`));
          }
        } catch (e) {
          reject(new Error(`Paymob auth parse error: ${e.message}`));
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

/**
 * Create Paymob Marketplace Order.
 * POST https://accept.paymob.com/api/ecommerce/orders
 *
 * Paymob marketplace order with merchant_id split.
 * Amount in cents (paise) — Paymob uses the smallest currency unit.
 * 1 PKR = 100 paise. So Rs 1500 = 150000 paise.
 */
async function createPaymobOrder({ amountPkr, merchantOrderId, shippingData }) {
  const token = await getPaymobAuthToken();
  const amountCents = Math.round(Decimal.mul(amountPkr, 100)); // PKR → paise

  return new Promise((resolve, reject) => {
    const orderData = {
      auth_token: token,
      delivery_needed: 'false',
      amount_cents: amountCents,
      currency: 'PKR',
      merchant_order_id: merchantOrderId,
      items: [],
      shipping_data: shippingData || {
        first_name: 'Customer',
        last_name: 'ServiceHub',
        phone_number: '+923001234567',
        city: 'Karachi',
        country: 'PK',
        email: 'customer@servicehub.pk',
      },
    };

    const body = JSON.stringify(orderData);

    const req = https.request({
      hostname: 'accept.paymob.com',
      path: '/api/ecommerce/orders',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    }, (res) => {
      let response = '';
      res.on('data', (chunk) => response += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(response));
        } catch (e) {
          reject(new Error(`Paymob order parse error: ${e.message}`));
        }
      });
    });

    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

/**
 * Generate Paymob Payment Key for an order.
 * POST https://accept.paymob.com/api/acceptance/payment_keys
 *
 * The payment_key is sent to the frontend to tokenize card/wallet
 * details via Paymob's iframe or hosted page.
 *
 * For marketplace split, we set the merchant_id in the payload
 * so Paymob knows to split 85/15 between provider and platform.
 */
async function generatePaymentKey({
  orderId,
  amountCents,
  integrationId,
  billingData,
  merchantId,
}) {
  const token = await getPaymobAuthToken();

  return new Promise((resolve, reject) => {
    const keyData = {
      auth_token: token,
      amount_cents: amountCents,
      expiration: 3600,
      order_id: orderId,
      billing_data: billingData || {
        first_name: 'Customer',
        last_name: 'ServiceHub',
        phone_number: '+923001234567',
        city: 'Karachi',
        country: 'PK',
        email: 'customer@servicehub.pk',
        apartment: 'N/A',
        floor: 'N/A',
        street: 'Main Street',
        building: 'N/A',
        shipping_method: 'PKG',
        postal_code: '75500',
        state: 'Sindh',
      },
      currency: 'PKR',
      integration_id: parseInt(integrationId, 10),
      lock_order_when_paid: 'true',
      // ── Marketplace split configuration ──
      // If merchant_id is set, Paymob routes funds:
      //   85% → provider's sub-merchant account
      //   15% → Zenith Intercontinental LLC (platform)
      ...(merchantId ? { merchant_id: merchantId } : {}),
    };

    const body = JSON.stringify(keyData);

    const req = https.request({
      hostname: 'accept.paymob.com',
      path: '/api/acceptance/payment_keys',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    }, (res) => {
      let response = '';
      res.on('data', (chunk) => response += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(response));
        } catch (e) {
          reject(new Error(`Paymob payment key parse error: ${e.message}`));
        }
      });
    });

    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

/**
 * Verify Paymob webhook HMAC signature.
 * Paymob sends a POST to our webhook with `hmac` header.
 * We validate against config.paymob.hmacSecret to confirm authenticity.
 */
function verifyPaymobWebhook(body, hmacHeader) {
  const crypto = require('crypto');
  const calculated = crypto
    .createHmac('SHA512', config.paymob.hmacSecret)
    .update(body)
    .digest('hex');

  return calculated === hmacHeader;
}

/**
 * Process a payment through Paymob Pakistan Marketplace.
 *
 * Returns a payment_key HTML that can be embedded in an iframe
 * or used for Paymob's hosted checkout page.
 */
async function processPaymobPayment({ amountPkr, method, metadata }) {
  try {
    // ── Step 1: Select integration ID by payment method ──
    let integrationId;
    switch (method) {
      case 'CREDIT_CARD':
        integrationId = config.paymob.integrations.card;
        break;
      case 'MOBILE_WALLET':
        if (metadata?.walletProvider === 'EASYPAISA') {
          integrationId = config.paymob.integrations.easypaisa;
        } else if (metadata?.walletProvider === 'JAZZCASH') {
          integrationId = config.paymob.integrations.jazzcash;
        } else {
          // Default to Easypaisa for MOBILE_WALLET
          integrationId = config.paymob.integrations.easypaisa;
        }
        break;
      default:
        integrationId = config.paymob.integrations.card;
    }

    if (!integrationId) {
      throw new Error(`Missing Paymob integration ID for method: ${method}`);
    }

    // ── Step 2: Amount in paise (cents) ──
    const amountCents = Math.round(Decimal.mul(amountPkr, 100));

    // ── Step 3: Create Paymob order ──
    const merchantOrderId = `SH-${metadata?.bookingId || Date.now()}-${Date.now()}`;

    console.log(`[Paymob PK] Creating order: PKR ${amountPkr} (${amountCents} paise), ref: ${merchantOrderId}`);

    const order = await createPaymobOrder({
      amountPkr,
      merchantOrderId,
      shippingData: {
        first_name: metadata?.customerName?.split(' ')[0] || 'Customer',
        last_name: metadata?.customerName?.split(' ').slice(1).join(' ') || 'ServiceHub',
        phone_number: metadata?.customerPhone || '+923001234567',
        city: 'Karachi',
        country: 'PK',
        email: metadata?.customerEmail || 'customer@servicehub.pk',
      },
    });

    if (!order || !order.id) {
      throw new Error(`Paymob order creation failed: ${JSON.stringify(order)}`);
    }

    console.log(`[Paymob PK] Order created: #${order.id}`);

    // ── Step 4: Generate payment key ──
    const paymentKeyResult = await generatePaymentKey({
      orderId: order.id,
      amountCents,
      integrationId,
      billingData: {
        first_name: metadata?.customerName?.split(' ')[0] || 'Customer',
        last_name: metadata?.customerName?.split(' ').slice(1).join(' ') || 'ServiceHub',
        phone_number: metadata?.customerPhone || '+923001234567',
        city: 'Karachi',
        country: 'PK',
        email: metadata?.customerEmail || 'customer@servicehub.pk',
        apartment: 'N/A',
        floor: 'N/A',
        street: metadata?.customerAddress || 'Main Street',
        building: 'N/A',
        shipping_method: 'PKG',
        postal_code: '75500',
        state: 'Sindh',
      },
      merchantId: config.paymob.merchantId || undefined,
    });

    if (!paymentKeyResult || !paymentKeyResult.token) {
      throw new Error(`Paymob payment key generation failed: ${JSON.stringify(paymentKeyResult)}`);
    }

    console.log(`[Paymob PK] Payment key generated: ${paymentKeyResult.token.substring(0, 20)}...`);

    // ── Step 5: Marketplace split calculation ──
    const commissionRate = config.commission.rate;
    const commissionPaise = Decimal.mul(amountCents, commissionRate);
    const providerPaise = Decimal.sub(amountCents, commissionPaise);

    console.log(`[Paymob PK] Marketplace split: Provider ${providerPaise}p, Commission ${commissionPaise}p`);

    return {
      success: true,
      gatewayRef: paymentKeyResult.token,
      paymentKey: paymentKeyResult.token,
      iframeId: config.paymob.iframeId,
      orderId: order.id,
      integrationId,
      amountCents,
      commissionPaise: Math.round(commissionPaise),
      providerPaise: Math.round(providerPaise),
      checkoutUrl: `https://accept.paymob.com/api/acceptance/iframes/${config.paymob.iframeId}?payment_token=${paymentKeyResult.token}`,
      error: null,
    };
  } catch (err) {
    console.error('[Paymob PK] Processing error:', err.message);
    return {
      success: false,
      gatewayRef: null,
      paymentKey: null,
      error: `Paymob: ${err.message}`,
    };
  }
}

/**
 * Process a Kash (local cash) settlement.
 * For CASH jobs: provider receives cash from customer.
 * Platform debits 15% from digital wallet.
 * No Paymob call needed — just ledger entry.
 */
async function processCashSettlement({ amountPkr }) {
  const commissionRate = config.commission.rate;
  const commissionFee = Decimal.mul(amountPkr, commissionRate);
  const netAmount = Decimal.sub(amountPkr, commissionFee);

  console.log(`[CASH KHI] Settlement: PKR ${amountPkr} cash received by provider. Commission PKR ${commissionFee} debited from wallet.`);

  return {
    success: true,
    gatewayRef: `CASH-${Date.now()}`,
    commissionFee,
    netAmount,
    error: null,
  };
}

// ──────────────────────────────────────────────────────────────
// AIRWALLEX (International — Future Expansion)
// ──────────────────────────────────────────────────────────────

/**
 * Process an international payment via Airwallex.
 * NOT ACTIVE for Karachi launch. Placeholder for US/AE/GB expansion.
 */
async function processAirwallexPayment({ amount, currency, method, metadata }) {
  console.log(`[Airwallex] ⏩ Not active for Karachi launch. Would process ${currency} ${amount} via ${method}.`);

  // ── Future implementation: Airwallex PaymentIntent API ──
  // const intent = await airwallexClient.paymentIntents.create({
  //   amount: Math.round(amount * 100), // cents
  //   currency: currency.toLowerCase(),
  //   merchant_order_id: metadata?.bookingId,
  //   payment_method_options: { ... },
  // });

  return {
    success: true,
    gatewayRef: `airwallex-intent-${Date.now()}`,
    error: null,
    note: 'Airwallex integration placeholder — not active for Karachi launch',
  };
}

// ──────────────────────────────────────────────────────────────
// MAIN GATEWAY DISPATCH
// ──────────────────────────────────────────────────────────────

/**
 * Route payment to the correct processor based on country and method.
 *
 * For Karachi (PK):
 *   - CASH           → processCashSettlement (no gateway)
 *   - CREDIT_CARD    → processPaymobPayment (via Paymob PK)
 *   - MOBILE_WALLET  → processPaymobPayment (Easypaisa/JazzCash)
 *
 * For International (future):
 *   - routes to Airwallex when providers expand beyond PK
 */
async function processPayment({ amount, currency, countryCode, method, metadata = {} }) {
  // ── All amounts are in PKR for Karachi launch ──
  const effectiveCurrency = currency || 'PKR';
  const effectiveCountry = countryCode || 'PK';

  // Karachi-first routing
  if (effectiveCountry === 'PK') {
    if (method === 'CASH') {
      return processCashSettlement({ amountPkr: amount });
    }
    // CREDIT_CARD or MOBILE_WALLET → Paymob Pakistan
    return processPaymobPayment({
      amountPkr: amount,
      method,
      metadata: {
        ...metadata,
        currency: effectiveCurrency,
        countryCode: effectiveCountry,
      },
    });
  }

  // International (future expansion)
  console.log(`[Gateway] International payment detected: ${effectiveCountry}/${effectiveCurrency}/${method}`);
  return processAirwallexPayment({
    amount,
    currency: effectiveCurrency,
    method,
    metadata,
  });
}

module.exports = {
  processPayment,
  processPaymobPayment,
  processCashSettlement,
  processAirwallexPayment,
  getPaymobAuthToken,
  createPaymobOrder,
  generatePaymentKey,
  verifyPaymobWebhook,
};