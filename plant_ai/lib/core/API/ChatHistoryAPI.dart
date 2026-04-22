import 'package:mongo_dart/mongo_dart.dart';
import 'connection/chat_session_model.dart';
// 🚀 QUAN TRỌNG: Import cái file kết nối dùng chung của ông vào
import 'connection/MongoDB.dart'; 

class ChatHistoryAPI {
  static const String collectionName = "chat_history";

  // Hàm Helper: Mượn kết nối từ MongoDatabase xịn của ông
  static Future<void> _ensureConnected() async {
    if (MongoDatabase.db == null || !MongoDatabase.db!.isConnected) {
      await MongoDatabase.connect();
    }
  }

  // 1. LƯU PHIÊN CHAT
  static Future<String?> saveSession(String? sessionId, ChatSessionModel session) async {
    try {
      await _ensureConnected(); // Đảm bảo dùng chung kết nối đang chạy
      final coll = MongoDatabase.db!.collection(collectionName);

      if (sessionId == null) {
        final newId = ObjectId();
        var data = session.toJson();
        data['_id'] = newId;
        await coll.insert(data);
        return newId.toHexString();
      } else {
        await coll.updateOne(
          where.eq('_id', ObjectId.fromHexString(sessionId)),
          modify.set('messages', session.messages).set('updatedAt', DateTime.now().toIso8601String())
        );
        return sessionId;
      }
    } catch (e) {
      print("❌ ChatHistory Error: $e");
      return null;
    }
  }

  // 2. LẤY LỊCH SỬ
  static Future<List<ChatSessionModel>> getHistory(String userId) async {
    try {
      await _ensureConnected();
      final coll = MongoDatabase.db!.collection(collectionName);

      final result = await coll.find(
        where.eq('userId', userId).sortBy('updatedAt', descending: true)
      ).toList();

      return result.map((e) {
        var json = Map<String, dynamic>.from(e);
        json['_id'] = (json['_id'] as ObjectId).toHexString();
        return ChatSessionModel.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }
  // 3. XÓA VĨNH VIỄN PHIÊN CHAT (Dùng chung kết nối xịn)
  static Future<bool> deleteSession(String sessionId) async {
    try {
      // Đảm bảo máy đã thông mạng với MongoDB
      await _ensureConnected(); 
      
      final coll = MongoDatabase.db!.collection(collectionName);

      // Thực hiện lệnh xóa dựa trên ID (Phải convert sang ObjectId mới xóa được)
      final result = await coll.remove(
        where.eq('_id', ObjectId.fromHexString(sessionId))
      );

      // Trả về true nếu số lượng bản ghi bị xóa lớn hơn 0
      return true; 
    } catch (e) {
      print("❌ Lỗi xóa chat trực tiếp: $e");
      return false;
    }
  }
}