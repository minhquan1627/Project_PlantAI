// core/API/TaskAPI.dart
import 'package:mongo_dart/mongo_dart.dart';
import 'connection/MongoDB.dart';
import 'connection/task_model.dart';
import 'package:intl/intl.dart';

class TaskAPI {
  static Future<DbCollection> _getCollection() async {
    return MongoDatabase.db!.collection("garden_tasks");
  }

  // 🚀 Lấy task theo UserId và Ngày cụ thể
  static Future<List<TaskModel>> fetchDailyTasks(String userId, DateTime date, {String? gardenId}) async {
  try {
    final collection = await _getCollection();
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    // 🚀 LOGIC MỚI: 
    // Nếu gardenId null -> Tìm chính xác những task có ID "24 số 0" (Việc chung)
    // Nếu gardenId có giá trị -> Tìm chính xác task của vườn đó
    String targetGardenId = gardenId ?? "000000000000000000000000";

    final query = where
        .eq('user_id', userId)
        .match('date', dateKey)
        .eq('garden_id', targetGardenId); // Ép lọc chính xác ID

    final results = await collection.find(query).toList();
    return results.map((e) => TaskModel.fromMap(e)).toList();
  } catch (e) {
    print("❌ TaskAPI Error: $e");
    return [];
  }
}

  // 🚀 Lưu task mới
  static Future<void> addTask(TaskModel task) async {
    final collection = await _getCollection();
    await collection.insertOne(task.toMap());
  }

  static Future<void> deleteTask(String id) async {
    try {
      final collection = await _getCollection();
      // Chuyển String ID sang ObjectId của Mongo
      await collection.remove(where.id(ObjectId.fromHexString(id)));
    } catch (e) {
      print("❌ Lỗi xóa Task: $e");
    }
  }

  static Future<void> deleteAllTasksByGarden(String gardenId) async {
    final collection = await _getCollection();
    await collection.remove(where.eq('garden_id', gardenId));
  }
}