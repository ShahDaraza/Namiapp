// ===================================================================
// ServiceHub Backend — Karachi Seed Data
// Zenith Intercontinental LLC — Paymob Pakistan Marketplace
// -------------------------------------------------------------------
// Seeds realistic Karachi-market data:
//   - All amounts in PKR (Pakistani Rupees)
//   - Locations across Karachi districts (DHA, Clifton, Gulshan, Saddar)
//   - Payment methods: CASH, CREDIT_CARD (Paymob), MOBILE_WALLET (JazzCash/Easypaisa)
//   - Wallet debit model for cash jobs (15% commission deducted)
//   - Provider wallet at negative balance to demonstrate threshold system
//
// Run: npx prisma db seed
// ===================================================================

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// ── Karachi Locations ──
const KARACHI_LOCATIONS = {
  gulshan: { name: 'Gulshan-e-Iqbal Block 6, Karachi', lat: 24.9266, lng: 67.0802 },
  dha: { name: 'DHA Phase 5, Khayaban-e-Ittehad, Karachi', lat: 24.8607, lng: 67.0011 },
  clifton: { name: 'Clifton, Zamzama Street, Karachi', lat: 24.8108, lng: 67.0256 },
  saddar: { name: 'Saddar, MA Jinnah Road, Karachi', lat: 24.8740, lng: 67.0304 },
  nazimabad: { name: 'Nazimabad No. 1, Karachi', lat: 24.9056, lng: 67.0315 },
  korangi: { name: 'Korangi Crossing, Karachi', lat: 24.8333, lng: 67.1333 },
  shahfaisal: { name: 'Shah Faisal Colony, Karachi', lat: 24.8670, lng: 67.1370 },
  malir: { name: 'Malir Cantt, Karachi', lat: 24.9358, lng: 67.2057 },
  north: { name: 'North Nazimabad, Karachi', lat: 24.9194, lng: 67.0395 },
  landmark: { name: 'Landhi, Karachi', lat: 24.8576, lng: 67.2252 },
};

async function main() {
  console.log('🌱 Seeding Karachi market data...\n');

  // ── Clean existing data ──
  await prisma.walletLedger.deleteMany();
  await prisma.walletTopUp.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.review.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.provider.deleteMany();
  await prisma.user.deleteMany();

  // ═══════════════════════════════════════════════════════════════
  // 1. CREATE USERS (Karachi Customers)
  // ═══════════════════════════════════════════════════════════════
  const user1 = await prisma.user.create({
    data: {
      id: 'user-khi-001',
      firebaseUid: 'fbu-khi-001',
      name: 'Hassan Ahmed',
      email: 'hassan.ahmed@gmail.com',
      phone: '+92 321 2345678',
      location: KARACHI_LOCATIONS.dha.name,
      city: 'Karachi',
      countryCode: 'PK',
      currency: 'PKR',
      rating: 4.7,
      totalReviews: 15,
    },
  });

  const user2 = await prisma.user.create({
    data: {
      id: 'user-khi-002',
      firebaseUid: 'fbu-khi-002',
      name: 'Fatima Zaidi',
      email: 'fatima.zaidi@outlook.com',
      phone: '+92 333 8765432',
      location: KARACHI_LOCATIONS.clifton.name,
      city: 'Karachi',
      countryCode: 'PK',
      currency: 'PKR',
      rating: 4.9,
      totalReviews: 22,
    },
  });

  console.log(`  ✅ Customers: ${user1.name} (${user1.id}), ${user2.name} (${user2.id})`);

  // ═══════════════════════════════════════════════════════════════
  // 2. CREATE PROVIDERS (Karachi Service Professionals)
  //    All amounts in PKR. Wallet balances show commission debt.
  // ═══════════════════════════════════════════════════════════════
  const provider1 = await prisma.provider.create({
    data: {
      id: 'prov-khi-001',
      firebaseUid: 'fbp-khi-001',
      name: 'Ahmed Plumbing & Electrical',
      email: 'ahmed.plumbing@example.com',
      phone: '+92 300 1112233',
      location: KARACHI_LOCATIONS.gulshan.name,
      city: 'Karachi',
      countryCode: 'PK',
      currency: 'PKR',
      services: ['Plumber', 'Electrician'],
      bio: 'Expert plumber and electrician serving Gulshan and surrounding areas. 15 years experience. Emergency callout available.',
      hourlyRate: 1500, // PKR per hour
      rating: 4.8,
      totalReviews: 34,
      totalJobs: 87,
      isApproved: true,
      isActive: true,
      // Wallet is negative from cash-job commission debts (-525 from previous job)
      walletBalance: -350.00,
      totalEarnings: 130500.00,
      totalCommission: 19575.00,
      walletLocked: false,
      walletThreshold: -500.00,
      documentsVerified: true,
      documentVerificationDate: new Date('2026-01-15'),
    },
  });

  const provider2 = await prisma.provider.create({
    data: {
      id: 'prov-khi-002',
      firebaseUid: 'fbp-khi-002',
      name: 'Zainab Premium Cleaning',
      email: 'zainab.cleaning@example.com',
      phone: '+92 333 5556667',
      location: KARACHI_LOCATIONS.clifton.name,
      city: 'Karachi',
      countryCode: 'PK',
      currency: 'PKR',
      services: ['Cleaning', 'Home Repair', 'Painter'],
      bio: 'Premium cleaning and home repair. Eco-friendly products. Serving Clifton, DHA, and Saddar areas.',
      hourlyRate: 1200, // PKR
      rating: 4.9,
      totalReviews: 56,
      totalJobs: 142,
      isApproved: true,
      isActive: true,
      // Positive wallet from digital payments (net deposit after commission)
      walletBalance: 1200.00,
      totalEarnings: 170400.00,
      totalCommission: 25560.00,
      walletLocked: false,
      walletThreshold: -500.00,
      documentsVerified: true,
      documentVerificationDate: new Date('2026-02-01'),
    },
  });

  const provider3 = await prisma.provider.create({
    data: {
      id: 'prov-khi-003',
      firebaseUid: 'fbp-khi-003',
      name: 'Imran Auto & AC Works',
      email: 'imran.auto@example.com',
      phone: '+92 345 7778889',
      location: KARACHI_LOCATIONS.saddar.name,
      city: 'Karachi',
      countryCode: 'PK',
      currency: 'PKR',
      services: ['Mechanic', 'AC Technician'],
      bio: 'AC Specialist and Auto Mechanic. 12 years experience. JazzCash payment accepted. Same-day service.',
      hourlyRate: 2000, // PKR
      rating: 4.7,
      totalReviews: 28,
      totalJobs: 63,
      isApproved: true,
      isActive: true,
      walletBalance: 0.00,
      totalEarnings: 126000.00,
      totalCommission: 18900.00,
      walletLocked: false,
      walletThreshold: -500.00,
      documentsVerified: true,
      documentVerificationDate: new Date('2026-01-20'),
    },
  });

  const provider4 = await prisma.provider.create({
    data: {
      id: 'prov-khi-004',
      firebaseUid: 'fbp-khi-004',
      name: 'Rashid Carpenter & Painter',
      email: 'rashid.carpenter@example.com',
      phone: '+92 321 4445566',
      location: KARACHI_LOCATIONS.nazimabad.name,
      city: 'Karachi',
      countryCode: 'PK',
      currency: 'PKR',
      services: ['Carpenter', 'Painter', 'Home Repair'],
      bio: 'Master carpenter with 20 years experience. Custom furniture, kitchen cabinets, and painting. Free estimates.',
      hourlyRate: 800, // PKR
      rating: 4.6,
      totalReviews: 41,
      totalJobs: 105,
      isApproved: true,
      isActive: true,
      walletBalance: -480.00, // Near threshold (Rs -500)
      totalEarnings: 84000.00,
      totalCommission: 12600.00,
      walletLocked: false,
      walletThreshold: -500.00,
      documentsVerified: true,
      documentVerificationDate: new Date('2026-03-10'),
    },
  });

  const provider5 = await prisma.provider.create({
    data: {
      id: 'prov-khi-005',
      firebaseUid: 'fbp-khi-005',
      name: 'Saima Home Appliances Repair',
      email: 'saima.repair@example.com',
      phone: '+92 300 9876543',
      location: KARACHI_LOCATIONS.north.name,
      city: 'Karachi',
      countryCode: 'PK',
      currency: 'PKR',
      services: ['Appliance Repair', 'Locksmith'],
      bio: 'Expert in washing machine, fridge, AC repair. Also 24/7 emergency locksmith. Easypaisa accepted.',
      hourlyRate: 1000, // PKR
      rating: 4.5,
      totalReviews: 19,
      totalJobs: 48,
      isApproved: true,
      isActive: true,
      walletBalance: -150.00,
      totalEarnings: 48000.00,
      totalCommission: 7200.00,
      walletLocked: false,
      walletThreshold: -500.00,
      documentsVerified: true,
      documentVerificationDate: new Date('2026-02-28'),
    },
  });

  console.log(`  ✅ Providers: ${provider1.name}, ${provider2.name}, ${provider3.name}, ${provider4.name}, ${provider5.name}`);

  // ═══════════════════════════════════════════════════════════════
  // 3. CREATE BOOKINGS (Real Karachi Service Jobs)
  // ═══════════════════════════════════════════════════════════════
  const booking1 = await prisma.booking.create({
    data: {
      id: 'bkg-khi-001',
      userId: user1.id,
      providerId: provider1.id,
      serviceType: 'Plumber',
      description: 'Bathroom faucet leaking — need urgent replacement. DHA Phase 5.',
      scheduledTime: new Date('2026-06-01T10:00:00+05:00'),
      estimatedCost: 3000,
      finalCost: 3500,
      status: 'COMPLETED',
      paymentMethod: 'CASH',
      location: KARACHI_LOCATIONS.dha.name,
      latitude: KARACHI_LOCATIONS.dha.lat,
      longitude: KARACHI_LOCATIONS.dha.lng,
      completedAt: new Date('2026-06-01T12:30:00+05:00'),
      createdAt: new Date('2026-05-28T09:00:00+05:00'),
    },
  });

  const booking2 = await prisma.booking.create({
    data: {
      id: 'bkg-khi-002',
      userId: user2.id,
      providerId: provider2.id,
      serviceType: 'Cleaning',
      description: 'Full 3-bedroom apartment deep clean. Clifton. Will pay via credit card.',
      scheduledTime: new Date('2026-06-03T14:00:00+05:00'),
      estimatedCost: 5000,
      finalCost: 4800,
      status: 'COMPLETED',
      paymentMethod: 'CREDIT_CARD',
      location: KARACHI_LOCATIONS.clifton.name,
      latitude: KARACHI_LOCATIONS.clifton.lat,
      longitude: KARACHI_LOCATIONS.clifton.lng,
      completedAt: new Date('2026-06-03T18:00:00+05:00'),
      createdAt: new Date('2026-05-29T11:00:00+05:00'),
    },
  });

  const booking3 = await prisma.booking.create({
    data: {
      id: 'bkg-khi-003',
      userId: user1.id,
      providerId: provider3.id,
      serviceType: 'AC Technician',
      description: 'Split AC not cooling properly — gas refill and full service required. Saddar office.',
      scheduledTime: new Date('2026-06-10T09:00:00+05:00'),
      estimatedCost: 4000,
      status: 'PENDING',
      location: KARACHI_LOCATIONS.saddar.name,
      latitude: KARACHI_LOCATIONS.saddar.lat,
      longitude: KARACHI_LOCATIONS.saddar.lng,
      createdAt: new Date('2026-05-30T08:00:00+05:00'),
    },
  });

  const booking4 = await prisma.booking.create({
    data: {
      id: 'bkg-khi-004',
      userId: user2.id,
      providerId: provider4.id,
      serviceType: 'Carpenter',
      description: 'Need custom wooden bookshelf for living room. 3 shelves, 6ft height, 4ft width.',
      scheduledTime: new Date('2026-06-15T10:00:00+05:00'),
      estimatedCost: 8000,
      status: 'ACCEPTED',
      location: KARACHI_LOCATIONS.clifton.name,
      latitude: KARACHI_LOCATIONS.clifton.lat,
      longitude: KARACHI_LOCATIONS.clifton.lng,
      createdAt: new Date('2026-05-28T12:00:00+05:00'),
    },
  });

  const booking5 = await prisma.booking.create({
    data: {
      id: 'bkg-khi-005',
      userId: user1.id,
      providerId: provider5.id,
      serviceType: 'Appliance Repair',
      description: 'Washing machine not spinning. Samsung 7kg front load. Gulshan location.',
      scheduledTime: new Date('2026-06-12T16:00:00+05:00'),
      estimatedCost: 2000,
      finalCost: 2500,
      status: 'IN_PROGRESS',
      location: KARACHI_LOCATIONS.gulshan.name,
      latitude: KARACHI_LOCATIONS.gulshan.lat,
      longitude: KARACHI_LOCATIONS.gulshan.lng,
      createdAt: new Date('2026-05-29T14:00:00+05:00'),
    },
  });

  console.log(`  ✅ Bookings: 5 Karachi service jobs created`);

  // ═══════════════════════════════════════════════════════════════
  // 4. CREATE PAYMENT RECORDS (Paymob PK Marketplace transactions)
  // ═══════════════════════════════════════════════════════════════
  const payment1 = await prisma.payment.create({
    data: {
      id: 'pay-khi-001',
      bookingId: booking1.id,
      userId: user1.id,
      providerId: provider1.id,
      grossAmount: 3500.00,
      commissionFee: 525.00,    // 15% of 3500
      netAmount: 2975.00,
      currency: 'PKR',
      method: 'CASH',
      status: 'COMPLETED',
      gatewayReference: null,   // Cash — no Paymob reference
      completedAt: new Date('2026-06-01T12:30:00+05:00'),
    },
  });

  const payment2 = await prisma.payment.create({
    data: {
      id: 'pay-khi-002',
      bookingId: booking2.id,
      userId: user2.id,
      providerId: provider2.id,
      grossAmount: 4800.00,
      commissionFee: 720.00,    // 15% of 4800
      netAmount: 4080.00,
      currency: 'PKR',
      method: 'CREDIT_CARD',
      status: 'COMPLETED',
      gatewayReference: 'paymob-iframe-txn-20260603-a8f2c1', // Paymob PK transaction ref
      completedAt: new Date('2026-06-03T18:00:00+05:00'),
    },
  });

  console.log(`  ✅ Payments: Cash (PKR 3500) + Credit Card via Paymob (PKR 4800)`);

  // ═══════════════════════════════════════════════════════════════
  // 5. CREATE WALLET LEDGER (Commission tracking)
  // ═══════════════════════════════════════════════════════════════
  // Cash job: Provider Ahmed receives cash, wallet debited by Rs 525 commission
  // Balance went from Rs 175 to Rs -350
  await prisma.walletLedger.create({
    data: {
      providerId: provider1.id,
      entryType: 'COMMISSION_DEBIT',
      amount: -525.00,
      balanceBefore: 175.00,
      balanceAfter: -350.00,
      referenceType: 'BOOKING',
      referenceId: booking1.id,
      currency: 'PKR',
      description: 'Cash job PKR 3,500 (DHA, Karachi): 15% commission PKR 525 debited from provider wallet. Customer paid cash on-site.',
      createdAt: new Date('2026-06-01T12:30:00+05:00'),
    },
  });

  // Digital payment: Provider Zainab receives net Rs 4,080 after Paymob split
  // Balance went from Rs -2,880 to Rs 1,200
  await prisma.walletLedger.create({
    data: {
      providerId: provider2.id,
      entryType: 'EARNINGS_CREDIT',
      amount: 4080.00,
      balanceBefore: -2880.00,
      balanceAfter: 1200.00,
      referenceType: 'BOOKING',
      referenceId: booking2.id,
      currency: 'PKR',
      description: 'Paymob CREDIT_CARD payment PKR 4,800 (Clifton, Karachi): 15% commission PKR 720 deducted. Net PKR 4,080 credited to wallet.',
      createdAt: new Date('2026-06-03T18:00:00+05:00'),
    },
  });

  // Commission debit for a previous cash job for provider4 (near threshold)
  await prisma.walletLedger.create({
    data: {
      providerId: provider4.id,
      entryType: 'COMMISSION_DEBIT',
      amount: -120.00,
      balanceBefore: -360.00,
      balanceAfter: -480.00,
      referenceType: 'BOOKING',
      referenceId: 'bkg-prev-cash-001',
      currency: 'PKR',
      description: 'Cash job PKR 800 (Nazimabad, Karachi): 15% commission PKR 120 debited. Wallet balance: -480. Only Rs 20 away from threshold lock!',
      createdAt: new Date('2026-06-02T15:00:00+05:00'),
    },
  });

  console.log(`  ✅ Ledger: 3 immutable commission entries created`);

  // ═══════════════════════════════════════════════════════════════
  // 6. CREATE REVIEWS
  // ═══════════════════════════════════════════════════════════════
  const review1 = await prisma.review.create({
    data: {
      id: 'rev-khi-001',
      bookingId: booking1.id,
      userId: user1.id,
      providerId: provider1.id,
      rating: 5,
      comment: 'Ahmed bhai did an excellent job fixing our bathroom faucet. Came on time, fixed it quickly, very reasonable price. Highly recommend!',
      createdAt: new Date('2026-06-02T10:00:00+05:00'),
    },
  });

  const review2 = await prisma.review.create({
    data: {
      id: 'rev-khi-002',
      bookingId: booking2.id,
      userId: user2.id,
      providerId: provider2.id,
      rating: 5,
      comment: 'Best cleaning service in Clifton! Zainab and her team were thorough, professional, and used eco-friendly products. Paid via credit card — very convenient.',
      createdAt: new Date('2026-06-04T11:00:00+05:00'),
    },
  });

  console.log(`  ✅ Reviews: ${review1.id}, ${review2.id}`);

  // ═══════════════════════════════════════════════════════════════
  // SUMMARY
  // ═══════════════════════════════════════════════════════════════
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('  🏙️  KARACHI MARKET DATA SEEDED SUCCESSFULLY');
  console.log('═══════════════════════════════════════════════════════');
  console.log('  Users:      2 (Hassan, Fatima)');
  console.log('  Providers:  5 (Ahmed, Zainab, Imran, Rashid, Saima)');
  console.log('  Bookings:   5 (1 CASH, 1 CARD, 3 active)');
  console.log('  Payments:   2 (CASH PKR 3,500 + CARD PKR 4,800)');
  console.log('  Commissions: PKR 525 + PKR 720 = PKR 1,245 to Zenith LLC');
  console.log('  Threshold:   -500 PKR (Rashid at -480 — near lock)');
  console.log('  Wallet:      Ahmed -350, Zainab +1200, Imran 0');
  console.log('  Gateway:     Paymob PK (Credit Card + Easypaisa + JazzCash)');
  console.log('═══════════════════════════════════════════════════════\n');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });