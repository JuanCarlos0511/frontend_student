/// Model for a marketplace product.
class MarketProductModel {
  final int id;
  final int studentId;
  final String title;
  final String? description;
  final double price;
  final String? location;
  final String? schedule;
  final String category;
  final String? imageUrl;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoPath;
  final DateTime createdAt;

  MarketProductModel({
    required this.id,
    required this.studentId,
    required this.title,
    this.description,
    required this.price,
    this.location,
    this.schedule,
    required this.category,
    this.imageUrl,
    this.firstName,
    this.lastName,
    this.profilePhotoPath,
    required this.createdAt,
  });

  factory MarketProductModel.fromJson(Map<String, dynamic> json) {
    return MarketProductModel(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location'],
      schedule: json['schedule'],
      category: json['category'] ?? 'Otros',
      imageUrl: json['image_url'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePhotoPath: json['profile_photo_path'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get sellerName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
