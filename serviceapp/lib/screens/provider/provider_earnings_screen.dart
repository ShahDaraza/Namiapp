import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({Key? key}) : super(key: key);

  @override
  State<ProviderEarningsScreen> createState() =>
      _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> {
  late PaymentService _paymentService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: const Color(0xFF667EEA),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Earnings Card
            FutureBuilder<double>(
              future: _paymentService.getProviderEarnings(user.uid),
              builder: (context, snapshot) {
                final earnings = snapshot.data ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: const Color(0xFF667EEA),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Total Earnings',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$${earnings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Payment History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Payment>>(
              future: _paymentService.getUserPayments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No payment history'),
                  );
                }

                final payments = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking: ${payment.bookingId.substring(0, 8)}...',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${payment.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF667EEA),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                  decoration: BoxDecoration(
                                    color: payment.status ==
                                            PaymentStatus.completed
                                        ? Colors.green
                                        : Colors.orange,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    payment.status
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
