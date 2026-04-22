import 'package:mongo_dart/mongo_dart.dart';
import 'connection/MongoDB.dart';
import 'connection/scan_record.dart';

class RecordAPI {
  // 🚀 Lấy Collection "scan_history" (Hệ thống sẽ tự tạo nếu chưa có)
  static Future<DbCollection> _getCollection() async {
    // Nếu db chưa khởi tạo hoặc bị mất kết nối, phải gọi connect lại ngay
    if (MongoDatabase.db == null || !MongoDatabase.db!.isConnected) {
      print(" RecordAPI: Kết nối đang đóng, đang tiến hành mở lại...");
      await MongoDatabase.connect(); 
    }
    return MongoDatabase.db!.collection("scan_history");
  }

  // 1. Lưu kết quả quét
  static Future<void> saveHistory(ScanRecord record) async {
    try {
      final collection = await _getCollection(); // Đợi kết nối xong mới lấy collection
      await collection.insertOne(record.toMap());
      print(" PlantAPI: Đã lưu lịch sử cho User ${record.userId}");
    } catch (e) {
      print("❌ PlantAPI: Lỗi khi lưu - $e");
    }
  }

  // 2. Lấy danh sách lịch sử theo UserId
  static Future<List<ScanRecord>> fetchHistory(String userId) async {
    
    try {
      final collection = await _getCollection(); // 🛡️ Đợi kết nối xong mới lấy collection
      
      final results = await collection
          .find(where.eq('user_id', userId).sortBy('created_at', descending: true))
          .toList();
      return results.map((e) => ScanRecord.fromMap(e)).toList();
    } catch (e) {
      print("❌ PlantAPI: Lỗi khi lấy dữ liệu - $e");
      return [];
    }
  }

  // 3. Xóa một bản ghi lịch sử
  static Future<void> deleteHistory(String recordId) async {
    try {
    final collection = await _getCollection();
    // 🛡️ GIA CỐ: Nếu recordId lỡ bị dính chữ 'ObjectId("...")' thì cắt bỏ nó đi
    String cleanId = recordId;
    if (recordId.contains('ObjectId("')) {
      cleanId = recordId.replaceAll('ObjectId("', '').replaceAll('")', '');
    }

    await collection.remove(where.id(ObjectId.fromHexString(cleanId)));
    print("RecordAPI: Đã xóa bản ghi sạch $cleanId");
  } catch (e) {
    print("❌ RecordAPI: Lỗi khi xóa - $e");
  }
  }

  // HÀM GẮN/GỠ LỊCH SỬ VÀO VƯỜN
  static Future<bool> assignToGarden(String recordId, String? gardenId) async {
    try {
      // 1. Lấy đúng collection "scan_history" từ hàm _getCollection của ông
      final collection = await _getCollection(); 

      // 2. 🛡️ GIA CỐ: Làm sạch recordId giống hệt hàm deleteHistory
      String cleanId = recordId;
      if (recordId.contains('ObjectId("')) {
        cleanId = recordId.replaceAll('ObjectId("', '').replaceAll('")', '');
      }

      // 3. Cập nhật dữ liệu
      await collection.updateOne(
        where.id(ObjectId.fromHexString(cleanId)),
        gardenId == null 
            ? modify.unset('garden_id') // Nếu gardenId là null -> Gỡ bỏ khỏi vườn
            : modify.set('garden_id', gardenId) // Có gardenId -> Gắn vào vườn
      );
      
      print("✅ RecordAPI: Đã ${gardenId == null ? 'gỡ' : 'gắn'} lịch sử $cleanId với vườn $gardenId");
      return true;
    } catch (e) {
      print("❌ Lỗi assignToGarden: $e");
      return false;
    }
  }
}