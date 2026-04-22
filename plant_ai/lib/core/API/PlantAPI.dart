import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'connection/MongoDB.dart'; // Import file kết nối cũ của ông

class PlantAPI {
  
  // Hàm tìm kiếm cây trồng theo từ khóa
  static Future<List<Map<String, dynamic>>> searchPlants(String keyword) async {
    try {
      // 1. Đảm bảo kết nối
      if (MongoDatabase.db == null || !MongoDatabase.db!.isConnected) {
        await MongoDatabase.connect();
      }

      // 2. Trỏ đúng vào Database "admin" và Collection "Leaf_information"
      // Lưu ý: Db tạo từ connection string thường mặc định vào 1 db. 
      // Nếu user hiện tại có quyền, ta có thể switch sang db khác hoặc gọi trực tiếp collection.
      // Ở đây tôi giả định ông dùng chung connection, ta sẽ gọi collection từ Db hiện tại.
      
      // Nếu cấu trúc DB của ông là: Cluster -> admin -> Leaf_information
      var collection = MongoDatabase.db!.collection('Leaf_information');

      // 3. Tạo Query Regex (Tìm kiếm gần đúng, không phân biệt hoa thường)
      // Ví dụ: Nhập "cà" sẽ ra "Cà phê", "Cà chua"
      final selector = where.match('plant_name', keyword, caseInsensitive: true)
                            .limit(20); // Giới hạn 20 kết quả để đỡ lag

      // 4. Thực thi
      final plants = await collection.find(selector).toList();
      
      return plants;
      
    } catch (e) {
      log('❌ PlantAPI Error: $e');
      return [];
    }
  }
}