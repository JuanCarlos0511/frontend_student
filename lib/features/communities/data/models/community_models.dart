/// Model for a community.
class CommunityModel {
  final int id;
  final String name;
  final int creatorId;
  final String category;
  final int membersCount;
  final String? coverImage;
  final String? description;
  final String? creatorName;
  final bool? isMember;
  final DateTime createdAt;

  CommunityModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.category,
    required this.membersCount,
    this.coverImage,
    this.description,
    this.creatorName,
    this.isMember,
    required this.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      creatorId: json['creator_id'] ?? 0,
      category: json['category'] ?? 'General',
      membersCount: json['members_count'] ?? 0,
      coverImage: json['cover_image'],
      description: json['description'],
      creatorName: json['creator_name'],
      isMember: json['is_member'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Model for a community post.
class CommunityPostModel {
  final int id;
  final int communityId;
  final int studentId;
  final String content;
  final String? imageUrl;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoPath;
  final DateTime createdAt;

  CommunityPostModel({
    required this.id,
    required this.communityId,
    required this.studentId,
    required this.content,
    this.imageUrl,
    this.firstName,
    this.lastName,
    this.profilePhotoPath,
    required this.createdAt,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] ?? 0,
      communityId: json['community_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePhotoPath: json['profile_photo_path'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get authorName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

class CommunityMemberModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? profilePhotoPath;

  CommunityMemberModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoPath,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePhotoPath: json['profile_photo_path'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
