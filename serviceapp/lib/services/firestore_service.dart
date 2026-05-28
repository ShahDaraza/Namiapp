import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../models/service_provider.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // ========== BOOKING OPERATIONS ==========
  
  // Create booking
  Future<String> createBooking({
    required String userId,
    required String providerId,
    required String serviceType,
    required String description,
    required DateTime scheduledTime,
    required double estimatedCost,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final bookingId = uuid.v4();
      final booking = Booking(
        id: bookingId,
        userId: userId,
        providerId: providerId,
        serviceType: serviceType,
        description: description,
        scheduledTime: scheduledTime,
        estimatedCost: estimatedCost,
        status: BookingStatus.pending,
        location: location,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('bookings').doc(bookingId).set(booking.toJson());
      return bookingId;
    } catch (e) {
      print('Create booking error: $e');
      rethrow;
    }
  }

  // Get booking
  Future<Booking?> getBooking(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      print('Get booking error: $e');
      return null;
    }
  }

  // Get user bookings
  Stream<List<Booking>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromJson(doc.data()))
            .toList());
  }

  // Get provider bookings
  Stream<List<Booking>> getProviderBookings(String providerId) {
    return _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromJson(doc.data()))
            .toList());
  }

  // Get pending bookings for provider
  Stream<List<Booking>> getPendingBookings(String providerId) {
    return _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromJson(doc.data()))
            .toList());
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
      };

      if (status == BookingStatus.completed) {
        updateData['completedAt'] = DateTime.now().toIso8601String();
      }

      await _firestore.collection('bookings').doc(bookingId).update(updateData);
    } catch (e) {
      print('Update booking status error: $e');
      rethrow;
    }
  }

  // Update final cost
  Future<void> updateFinalCost(String bookingId, double finalCost) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'finalCost': finalCost,
      });
    } catch (e) {
      print('Update final cost error: $e');
      rethrow;
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
      });
    } catch (e) {
      print('Cancel booking error: $e');
      rethrow;
    }
  }

  // ========== PROVIDER OPERATIONS ==========

  // Get available providers by service
  Future<List<ServiceProvider>> getProvidersByService(String serviceType) async {
    try {
      final snapshot = await _firestore
          .collection('providers')
          .where('services', arrayContains: serviceType)
          .where('isApproved', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceProvider.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Get providers by service error: $e');
      return [];
    }
  }

  // Get providers by location
  Future<List<ServiceProvider>> getNearbyProviders({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // This is a simplified implementation
      // In production, use Geoflutterfire or similar
      final snapshot = await _firestore
          .collection('providers')
          .where('isApproved', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceProvider.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Get nearby providers error: $e');
      return [];
    }
  }

  // Search providers
  Future<List<ServiceProvider>> searchProviders(String query) async {
    try {
      final snapshot = await _firestore
          .collection('providers')
          .where('isApproved', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceProvider.fromJson(doc.data()))
          .where((provider) =>
              provider.name.toLowerCase().contains(query.toLowerCase()) ||
              provider.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Search providers error: $e');
      return [];
    }
  }

  // Get top-rated providers
  Stream<List<ServiceProvider>> getTopProviders({int limit = 10}) {
    return _firestore
        .collection('providers')
        .where('isApproved', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceProvider.fromJson(doc.data()))
            .toList());
  }

  // ========== REVIEW OPERATIONS ==========

  // Create review
  Future<String> createReview({
    required String bookingId,
    required String userId,
    required String providerId,
    required double rating,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      final reviewId = uuid.v4();
      final review = Review(
        id: reviewId,
        bookingId: bookingId,
        userId: userId,
        providerId: providerId,
        rating: rating,
        comment: comment,
        images: images,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('reviews').doc(reviewId).set(review.toJson());

      // Update provider rating
      await _updateProviderRating(providerId);

      return reviewId;
    } catch (e) {
      print('Create review error: $e');
      rethrow;
    }
  }

  // Get reviews for provider
  Stream<List<Review>> getProviderReviews(String providerId) {
    return _firestore
        .collection('reviews')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromJson(doc.data()))
            .toList());
  }

  // Get review for booking
  Future<Review?> getBookingReview(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Review.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Get booking review error: $e');
      return null;
    }
  }

  // ========== HELPER FUNCTIONS ==========

  Future<void> _updateProviderRating(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('providerId', isEqualTo: providerId)
          .get();

      if (snapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += (doc['rating'] as num).toDouble();
      }

      final averageRating = totalRating / snapshot.docs.length;

      await _firestore.collection('providers').doc(providerId).update({
        'rating': averageRating,
        'totalReviews': snapshot.docs.length,
      });
    } catch (e) {
      print('Update provider rating error: $e');
    }
  }

  // Get all unapproved providers (for admin)
  Future<List<ServiceProvider>> getUnapprovedProviders() async {
    try {
      final snapshot = await _firestore
          .collection('providers')
          .where('isApproved', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) => ServiceProvider.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Get unapproved providers error: $e');
      return [];
    }
  }

  // Approve provider (admin)
  Future<void> approveProvider(String providerId) async {
    try {
      await _firestore.collection('providers').doc(providerId).update({
        'isApproved': true,
        'documentVerificationDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Approve provider error: $e');
      rethrow;
    }
  }

  // Reject provider (admin)
  Future<void> rejectProvider(String providerId) async {
    try {
      await _firestore.collection('providers').doc(providerId).delete();
    } catch (e) {
      print('Reject provider error: $e');
      rethrow;
    }
  }
}
