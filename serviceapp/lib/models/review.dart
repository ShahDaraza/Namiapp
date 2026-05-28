class Review {
  final String id;
  final String bookingId;
  final String userId;
  final String providerId;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      providerId: json['providerId'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'providerId': providerId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
