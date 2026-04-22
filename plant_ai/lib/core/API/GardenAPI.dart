import 'package:mongo_dart/mongo_dart.dart';
import 'connection/MongoDB.dart';
import 'connection/garden_model.dart';

class GardenAPI {
  static Future<DbCollection> _getCollection() async {
    if (MongoDatabase.db == null || !MongoDatabase.db!.isConnected) {
      await MongoDatabase.connect();
    }
    return MongoDatabase.db!.collection("user_gardens");
  }

  // 🚀 Lưu vườn mới
  static Future<bool> addGarden(GardenModel garden) async {
    try {
      final collection = await _getCollection();
      await collection.insertOne(garden.toMap());
      print("✅ GardenAPI: Đã thêm vườn ${garden.name}");
      return true;
    } catch (e) {
      print("❌ GardenAPI: Lỗi thêm vườn - $e");
      return false;
    }
  }

  // 🚀 Lấy danh sách vườn của một User
  static Future<List<GardenModel>> fetchUserGardens(String userId) async {
    try {
      final collection = await _getCollection();
      final results = await collection.find(where.eq('user_id', userId)).toList();
      return results.map((e) => GardenModel.fromMap(e)).toList();
    } catch (e) {
      print("❌ GardenAPI: Lỗi lấy danh sách vườn - $e");
      return [];
    }
  }

  static Future<String?> fetchGardenNameById(String gardenId) async {
    try {
      final collection = await _getCollection();
      
      // 1. Gọt sạch ID (Tận dụng logic xóa của ông)
      String cleanId = gardenId.contains('ObjectId("') 
          ? gardenId.replaceAll('ObjectId("', '').replaceAll('")', '') 
          : gardenId;

      // 2. Tìm đúng vườn đó
      final result = await collection.findOne(where.id(ObjectId.fromHexString(cleanId)));
      
      // 3. Trả về cái tên
      return result?['name']; 
    } catch (e) {
      print("❌ GardenAPI: Lỗi lấy tên vườn - $e");
      return null;
    }
  }

  static Future<bool> deleteGarden(String gardenId) async {
    try {
      final collection = await _getCollection();
      // Đảm bảo gọt sạch ID trước khi xóa
      String cleanId = gardenId.contains('ObjectId("') 
          ? gardenId.replaceAll('ObjectId("', '').replaceAll('")', '') 
          : gardenId;

      await collection.remove(where.id(ObjectId.fromHexString(cleanId)));
      print("🗑️ GardenAPI: Đã xóa vườn $cleanId");
      return true;
    } catch (e) {
      print("❌ GardenAPI: Lỗi khi xóa vườn - $e");
      return false;
    }
  }
}