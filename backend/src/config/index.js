// ===================================================================
// ServiceHub Backend — Configuration
// Zenith Intercontinental LLC
// ===================================================================

require('dotenv').config();

const config = {
  port: parseInt(process.env.PORT, 10) || 4000,
  nodeEnv: process.env.NODE_ENV || 'development',
  isDev: (process.env.NODE_ENV || 'development') === 'development',

  // ── Firebase Auth ──
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
  },

  // ── Platform Commission ──
  commission: {
    rate: parseFloat(process.env.PLATFORM_COMMISSION_RATE) || 0.15,
    thresholds: {
      PKR: parseFloat(process.env.WALLET_DEBT_THRESHOLD_PKR) || -500,
      USD: parseFloat(process.env.WALLET_DEBT_THRESHOLD_USD) || -5,
      AED: parseFloat(process.env.WALLET_DEBT_THRESHOLD_AED) || -20,
    },
  },

  // ── Paymob (Pakistan Gateway) ──
  paymob: {
    apiKey: process.env.PAYMOB_API_KEY,
    hmacSecret: process.env.PAYMOB_HMAC_SECRET,
    merchantId: process.env.PAYMOB_MERCHANT_ID,
    iframeId: process.env.PAYMOB_IFRAME_ID,
    integrations: {
      card: process.env.PAYMOB_INTEGRATION_ID_CARD,
      easypaisa: process.env.PAYMOB_INTEGRATION_ID_EASYPAISA,
      jazzcash: process.env.PAYMOB_INTEGRATION_ID_JAZZCASH,
    },
  },

  // ── Airwallex (International — future) ──
  airwallex: {
    apiKey: process.env.AIRWALLEX_API_KEY,
    clientId: process.env.AIRWALLEX_CLIENT_ID,
    webhookSecret: process.env.AIRWALLEX_WEBHOOK_SECRET,
  },

  // ── Country → Gateway Mapping ──
  gatewayMap: {
    PK: 'paymob',      // Pakistan → Paymob
    US: 'airwallex',   // USA → Airwallex
    AE: 'airwallex',   // UAE → Airwallex
    GB: 'airwallex',   // UK → Airwallex
    CA: 'airwallex',   // Canada → Airwallex
    AU: 'airwallex',   // Australia → Airwallex
  },

  // ── Default Gateway ──
  getGatewayForCountry(countryCode) {
    return this.gatewayMap[countryCode] || 'paymob'; // fallback to Paymob
  },

  // ── Threshold for a currency ──
  getThreshold(currency) {
    return this.commission.thresholds[currency] || this.commission.thresholds.PKR;
  },
};

module.exports = config;