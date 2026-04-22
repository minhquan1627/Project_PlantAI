class ChatSessionModel {
  final String? id; // ID của phiên chat (MongoDB tự tạo)
  final String userId;
  final String title; // Tên hiển thị trên Sidebar (ví dụ: "Cách trị rỉ sắt")
  final DateTime updatedAt;
  final List<Map<String, dynamic>> messages;

  ChatSessionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.updatedAt,
    required this.messages,
  });

  // Chuyển từ JSON (MongoDB) sang Dart
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['_id'],
      userId: json['userId'] ?? '',
      title: json['title'] ?? 'Đoạn chat mới',
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      messages: List<Map<String, dynamic>>.from(json['messages'] ?? []),
    );
  }

  // Chuyển từ Dart sang JSON để gửi lên Backend
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages,
    };
  }
}