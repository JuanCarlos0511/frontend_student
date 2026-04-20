/// Model for a chat room.
class ChatRoomModel {
  final int id;
  final int studentAId;
  final int studentBId;
  final int? productId;
  final String? otherName;
  final String? otherPhoto;
  final String? productTitle;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  ChatRoomModel({
    required this.id,
    required this.studentAId,
    required this.studentBId,
    this.productId,
    this.otherName,
    this.otherPhoto,
    this.productTitle,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? 0,
      studentAId: json['student_a_id'] ?? 0,
      studentBId: json['student_b_id'] ?? 0,
      productId: json['product_id'],
      otherName: json['other_name'],
      otherPhoto: json['other_photo'],
      productTitle: json['product_title'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Model for a chat message.
class ChatMessageModel {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String message;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoPath;
  final int? referencedProductId;
  final String? referencedProductTitle;
  final String? referencedProductDescription;
  final String? referencedProductImageUrl;
  final double? referencedProductPrice;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    this.firstName,
    this.lastName,
    this.profilePhotoPath,
    this.referencedProductId,
    this.referencedProductTitle,
    this.referencedProductDescription,
    this.referencedProductImageUrl,
    this.referencedProductPrice,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      chatRoomId: json['chat_room_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      message: json['message'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePhotoPath: json['profile_photo_path'],
      referencedProductId: json['referenced_product_id'],
      referencedProductTitle: json['referenced_product_title'],
      referencedProductDescription: json['referenced_product_description'],
      referencedProductImageUrl: json['referenced_product_image_url'],
      referencedProductPrice: json['referenced_product_price'] != null
          ? double.tryParse(json['referenced_product_price'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get senderName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
