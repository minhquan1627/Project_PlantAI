// core/API/connection/task_model.dart
import 'package:mongo_dart/mongo_dart.dart';

class TaskModel {
  final String? id;
  final String userId;
  final String gardenId;
  final String title;
  final DateTime date; // Chỉ lưu ngày: yyyy-MM-dd
  final int hour;      // Lưu giờ: 0 - 23

  TaskModel({
    this.id,
    required this.userId,
    required this.gardenId,
    required this.title,
    required this.date,
    required this.hour,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'garden_id': gardenId,
      'title': title,
      'date': date.toIso8601String(),
      'hour': hour,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['_id'] != null ? (map['_id'] as ObjectId).toHexString() : null,
      userId: map['user_id'] ?? '',
      gardenId: map['garden_id'] ?? '',
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      hour: map['hour'] ?? 0,
    );
  }
}