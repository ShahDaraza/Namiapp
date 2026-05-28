enum BookingStatus { pending, accepted, inProgress, completed, cancelled }

class Booking {
  final String id;
  final String userId;
  final String providerId;
  final String serviceType;
  final String description;
  final DateTime scheduledTime;
  final double estimatedCost;
  final double finalCost;
  final BookingStatus status;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? cancellationReason;
  final Map<String, dynamic> paymentDetails;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceType,
    required this.description,
    required this.scheduledTime,
    required this.estimatedCost,
    this.finalCost = 0.0,
    this.status = BookingStatus.pending,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.completedAt,
    this.cancellationReason,
    this.paymentDetails = const {},
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      providerId: json['providerId'] as String,
      serviceType: json['serviceType'] as String,
      description: json['description'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      finalCost: (json['finalCost'] as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.pending,
      ),
      location: json['location'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      paymentDetails:
          Map<String, dynamic>.from(json['paymentDetails'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'serviceType': serviceType,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
      'estimatedCost': estimatedCost,
      'finalCost': finalCost,
      'status': status.toString().split('.').last,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'paymentDetails': paymentDetails,
    };
  }
}
