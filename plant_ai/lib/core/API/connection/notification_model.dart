import 'package:mongo_dart/mongo_dart.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;
  final String type; // 'warning', 'info', 'success'

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.type = 'info',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['_id'] != null ? (map['_id'] as ObjectId).toHexString() : null,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      isRead: map['is_read'] ?? false,
      type: map['type'] ?? 'info',
    );
  }
}