// ===================================================================
// ServiceHub Backend — Express Server Entry Point
// Zenith Intercontinental LLC
// ===================================================================

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const config = require('./config');
const prisma = require('./lib/prisma');

const app = express();

// ── Middleware ──
app.use(helmet());
app.use(cors({
  origin: config.isDev ? '*' : ['https://servicehub.app', 'https://admin.servicehub.app'],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Request logging ──
if (config.isDev) {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// ── Health Check ──
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: config.nodeEnv,
    version: '2.0.0',
    company: 'Zenith Intercontinental LLC',
  });
});

// ── Routes ──
const paymentRoutes = require('./routes/paymentRoutes');
app.use('/api/payments', paymentRoutes);

// ── 404 Handler ──
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.originalUrl} not found`,
  });
});

// ── Global Error Handler ──
app.use((err, req, res, _next) => {
  console.error('[Unhandled Error]', err);
  res.status(err.status || 500).json({
    error: 'Internal Server Error',
    message: config.isDev ? err.message : 'Something went wrong',
  });
});

// ── Start Server ──
async function start() {
  try {
    // Verify database connection
    await prisma.$connect();
    console.log('[DB] Connected to database');

    app.listen(config.port, () => {
      console.log('╔══════════════════════════════════════════════════════════╗');
      console.log('║         ServiceHub Backend — Zenith Intercontinental LLC       ║');
      console.log(`║  Server running on http://localhost:${config.port}                ║`);
      console.log(`║  Environment: ${config.nodeEnv.padEnd(39)}║`);
      console.log(`║  Version: 2.0.0                                            ║`);
      console.log('╚══════════════════════════════════════════════════════════╝');
    });
  } catch (err) {
    console.error('[FATAL] Failed to start server:', err);
    process.exit(1);
  }
}

// ── Graceful Shutdown ──
process.on('SIGINT', async () => {
  console.log('\n[Server] Shutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('\n[Server] SIGTERM received. Shutting down...');
  await prisma.$disconnect();
  process.exit(0);
});

start();