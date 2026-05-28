class ServiceProvider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String location;
  final List<String> services;
  final String bio;
  final double hourlyRate;
  final double rating;
  final int totalReviews;
  final int totalJobs;
  final List<String> skills;
  final List<String> availability;
  final bool isApproved;
  final bool isActive;
  final double totalEarnings;
  final DateTime createdAt;
  final DateTime? documentVerificationDate;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    required this.location,
    required this.services,
    this.bio = '',
    required this.hourlyRate,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalJobs = 0,
    this.skills = const [],
    this.availability = const [],
    this.isApproved = false,
    this.isActive = true,
    this.totalEarnings = 0.0,
    required this.createdAt,
    this.documentVerificationDate,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImage: json['profileImage'] as String? ?? '',
      location: json['location'] as String,
      services: List<String>.from(json['services'] as List? ?? []),
      bio: json['bio'] as String? ?? '',
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalJobs: json['totalJobs'] as int? ?? 0,
      skills: List<String>.from(json['skills'] as List? ?? []),
      availability: List<String>.from(json['availability'] as List? ?? []),
      isApproved: json['isApproved'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      documentVerificationDate: json['documentVerificationDate'] != null
          ? DateTime.parse(json['documentVerificationDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'location': location,
      'services': services,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalJobs': totalJobs,
      'skills': skills,
      'availability': availability,
      'isApproved': isApproved,
      'isActive': isActive,
      'totalEarnings': totalEarnings,
      'createdAt': createdAt.toIso8601String(),
      'documentVerificationDate': documentVerificationDate?.toIso8601String(),
    };
  }
}
