class Service {
  final String id;
  final String name;
  final String category;
  final String description;
  final String icon;
  final double basePrice;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.basePrice,
    this.isActive = true,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'icon': icon,
      'basePrice': basePrice,
      'isActive': isActive,
    };
  }
}

const List<String> SERVICE_CATEGORIES = [
  'Plumber',
  'Electrician',
  'Mechanic',
  'Carpenter',
  'Painter',
  'AC Technician',
  'Cleaning',
  'Home Repair',
  'Appliance Repair',
  'Locksmith',
];
