import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
// Đảm bảo import file constants chứa URL
import 'constants.dart'; 

class MongoDatabase {
  // Biến giữ kết nối (static để dùng chung toàn App)
  static Db? db;
  static DbCollection? userCollection;

  // Hàm kết nối
  static Future<void> connect() async {
    try {
      // Nếu đã kết nối rồi thì thôi, không connect lại
      if (db != null && db!.isConnected) return;

      // Khởi tạo và mở kết nối
      db = await Db.create(MONGO_CONN_URL);
      await db!.open();
      
      inspect(db);
      
      // Gán collection vào biến static để UserAPI dùng
      userCollection = db!.collection(COLLECTION_NAME);
      
      log('✅ MongoDB: Kết nối thành công!');
    } catch (e) {
      log('❌ MongoDB: Lỗi kết nối - $e');
    }
  }

  // Hàm đóng kết nối
  static void close() {
    if (db != null) {
      db!.close();
      log('🔒 MongoDB: Đã đóng kết nối.');
    }
  }
}