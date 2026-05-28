import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum PaymentMethod { creditCard, debitCard, upi, wallet, cash }

enum PaymentStatus { pending, completed, failed, refunded }

class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final String providerId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? errorMessage;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.errorMessage,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      providerId: json['providerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['method']}',
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      transactionId: json['transactionId'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'providerId': providerId,
      'amount': amount,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'errorMessage': errorMessage,
    };
  }
}

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Dummy payment - used for localhost testing
  Future<Payment> processDummyPayment({
    required String bookingId,
    required String userId,
    required String providerId,
    required double amount,
    required PaymentMethod method,
  }) async {
    try {
      final paymentId = uuid.v4();
      final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // For demo, we'll make 95% of payments succeed
      final isSuccess = DateTime.now().millisecond % 100 > 5;

      final payment = Payment(
        id: paymentId,
        bookingId: bookingId,
        userId: userId,
        providerId: providerId,
        amount: amount,
        method: method,
        status: isSuccess ? PaymentStatus.completed : PaymentStatus.failed,
        createdAt: DateTime.now(),
        completedAt: isSuccess ? DateTime.now() : null,
        transactionId: isSuccess ? transactionId : null,
        errorMessage: isSuccess ? null : 'Payment declined. Please try again.',
      );

      // Save to Firestore
      await _firestore.collection('payments').doc(paymentId).set(payment.toJson());

      return payment;
    } catch (e) {
      print('Payment processing error: $e');
      rethrow;
    }
  }

  // Get payment by booking
  Future<Payment?> getPaymentByBooking(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Payment.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Get payment error: $e');
      return null;
    }
  }

  // Get user payments
  Future<List<Payment>> getUserPayments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Payment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Get user payments error: $e');
      return [];
    }
  }

  // Get provider earnings
  Future<double> getProviderEarnings(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalEarnings = 0;
      for (var doc in snapshot.docs) {
        totalEarnings += (doc['amount'] as num).toDouble();
      }

      return totalEarnings;
    } catch (e) {
      print('Get provider earnings error: $e');
      return 0.0;
    }
  }

  // Refund payment
  Future<void> refundPayment(String paymentId, String reason) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'refunded',
        'refundReason': reason,
        'refundedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Refund payment error: $e');
      rethrow;
    }
  }
}
