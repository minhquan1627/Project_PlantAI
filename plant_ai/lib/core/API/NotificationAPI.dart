import 'package:mongo_dart/mongo_dart.dart';
import 'connection/MongoDB.dart';
import 'connection/notification_model.dart';

class NotificationAPI {
  static Future<DbCollection> _getCollection() async {
    return MongoDatabase.db!.collection("user_notifications");
  }

  // 🚀 Lấy danh sách thông báo (Mới nhất lên đầu)
  static Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final collection = await _getCollection();
      final results = await collection.find(where.sortBy('created_at', descending: true)).toList();
      return results.map((e) => NotificationModel.fromMap(e)).toList();
    } catch (e) {
      print("❌ NotificationAPI Error: $e");
      return [];
    }
  }

  // 🚀 Đánh dấu đã đọc
  static Future<void> markAsRead(String id) async {
    final collection = await _getCollection();
    await collection.update(where.id(ObjectId.fromHexString(id)), modify.set('is_read', true));
  }

  static Future<void> markAllAsRead() async {
    try {
      final collection = await _getCollection();
      // Update tất cả những thông báo đang là false thành true
      await collection.update(
        where.eq('is_read', false), 
        modify.set('is_read', true),
        multiUpdate: true // 🚀 Quan trọng: Phải có cái này mới update hết cả list được
      );
      print("✅ Đã đánh dấu đọc tất cả");
    } catch (e) {
      print("❌ Lỗi markAllAsRead: $e");
    }
  }

  static Future<void> deleteNotification(String id) async {
    try {
      final collection = await _getCollection();
      // Chuyển String ID sang ObjectId của Mongo để xóa cho đúng
      await collection.remove(where.id(ObjectId.fromHexString(id)));
      print("🗑️ Đã xóa thông báo: $id");
    } catch (e) {
      print("❌ Lỗi deleteNotification: $e");
    }
  }
  static Future<void> deleteAllNotificationsByGarden(String gardenId) async {
    final collection = await _getCollection();
    // Xóa các thông báo liên quan đến vườn này
    await collection.remove(where.match('body', gardenId)); // Hoặc theo cấu trúc data của ông
  }
}