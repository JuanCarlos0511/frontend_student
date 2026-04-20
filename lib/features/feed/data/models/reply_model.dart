/// Model representing a reply to a post.
class ReplyModel {
  final int id;
  final int postId;
  final int studentId;
  final String studentName;
  final String? studentPhotoUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReplyModel({
    required this.id,
    required this.postId,
    required this.studentId,
    required this.studentName,
    this.studentPhotoUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'],
      postId: json['post_id'],
      studentId: json['student_id'],
      studentName:
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      studentPhotoUrl: json['profile_photo_path'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
