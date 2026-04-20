/// Model representing a post/publication.
class PostModel {
  final int id;
  final int studentId;
  final String studentName;
  final String? studentPhotoUrl;
  final String content;
  final String? imageUrl;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentPhotoUrl,
    required this.content,
    this.imageUrl,
    this.replyCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      studentId: json['student_id'],
      studentName:
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      studentPhotoUrl: json['profile_photo_path'],
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      replyCount: json['reply_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

