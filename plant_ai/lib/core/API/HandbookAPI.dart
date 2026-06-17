import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
// Import file kết nối database của ông để lấy biến db
import 'connection/MongoDB.dart'; 

class HandbookAPI {
  // Helper: Đảm bảo đã kết nối với MongoDB Atlas trước khi gọi lệnh
  static Future<void> _ensureConnected() async {
    if (MongoDatabase.db == null || !MongoDatabase.db!.isConnected) {
      await MongoDatabase.connect();
    }
  }

  // 1. Hàm lấy danh sách tất cả Cẩm nang (Sắp xếp: Ghim lên đầu -> Mới nhất lên đầu)
  static Future<List<Map<String, dynamic>>> getAllHandbooks() async {
    try {
      await _ensureConnected();
      
      // Trỏ thẳng vào collection 'handbooks' trong MongoDB Atlas của ông
      final collection = MongoDatabase.db!.collection('handbooks');
      
      // Kéo dữ liệu về, dùng .sortBy để sắp xếp y chang logic Backend Python cũ
      // -isPinned (giảm dần) -> Bài ghim (true) sẽ nổi lên trên
      // -publishDate (giảm dần) -> Bài mới nhất nổi lên trên
      final handbooks = await collection.find(
        where.sortBy('isPinned', descending: true)
             .sortBy('publishDate', descending: true)
      ).toList();

      // Ép kiểu ObjectId thành String để lúc đẩy sang màn hình khác không bị crash
      List<Map<String, dynamic>> safeData = handbooks.map((h) {
        var map = Map<String, dynamic>.from(h);
        if (map['_id'] is ObjectId) {
          map['id'] = (map['_id'] as ObjectId).toHexString();
          map['_id'] = (map['_id'] as ObjectId).toHexString();
        }
        
        // Format lại ngày tháng từ ISO String sang dạng dd/MM/yyyy (nếu cần)
        var rawDate = map['publishDate'];
        if (rawDate != null) {
          DateTime? date;
          if (rawDate is DateTime) {
            date = rawDate;
          } else if (rawDate is String) {
            try {
              date = DateTime.parse(rawDate);
            } catch (e) {
              date = null;
            }
          }

          if (date != null) {
            map['publishDate'] = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
          } else {
            map['publishDate'] = "Chưa rõ ngày";
          }
        } else {
          map['publishDate'] = "Chưa rõ ngày";
        }
        
        return map;
      }).toList();

      return safeData;
    } catch (e) {
      log("❌ Lỗi kéo dữ liệu Cẩm nang từ MongoDB: $e");
      return [];
    }
  }

  // 2. Hàm lấy chi tiết 1 bài Cẩm nang (Dùng cho trang ArticleDetailScreen)
  static Future<Map<String, dynamic>?> getHandbookById(String id) async {
    try {
      await _ensureConnected();
      
      final collection = MongoDatabase.db!.collection('handbooks');
      
      // Tìm duy nhất 1 bài dựa trên ObjectId
      var h = await collection.findOne(where.eq('_id', ObjectId.fromHexString(id)));
      
      if (h != null) {
        var map = Map<String, dynamic>.from(h);
        map['id'] = id;
        map['_id'] = id;

        // Ép kiểu Date giống hệt bên List
        var rawDate = map['publishDate'];
        if (rawDate != null) {
          DateTime? date;
          if (rawDate is DateTime) {
            date = rawDate;
          } else if (rawDate is String) {
            try {
              date = DateTime.parse(rawDate);
            } catch (e) {
              date = null;
            }
          }

          if (date != null) {
            map['publishDate'] = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
          } else {
            map['publishDate'] = "Chưa rõ ngày";
          }
        } else {
          map['publishDate'] = "Chưa rõ ngày";
        }
        return map;
      }
      return null;
    } catch (e) {
      log("❌ Lỗi lấy chi tiết bài Cẩm nang: $e");
      return null;
    }
  }
}