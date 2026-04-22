// test_connection.dart
import 'package:mongo_dart/mongo_dart.dart';

// --- CẤU HÌNH ---
// Hãy dán chuỗi kết nối của bạn vào đây.
// Lưu ý: Nhớ thêm tên database vào sau ".net/" nếu dùng mongodb+srv
// Ví dụ: ...mongodb.net/test?retryWrites=true...
const String MONGO_URL = "mongodb+srv://minhquan1627:162727@cluster0.nmibq.mongodb.net/customer?retryWrites=true&w=majority&appName=Cluster0";
const String COLLECTION_NAME = "users"; 

void main() async {
  print("🔄 Đang bắt đầu kiểm tra kết nối...");
  
  Db? db;
  
  try {
    // 1. Thử tạo đối tượng DB
    db = await Db.create(MONGO_URL);
    print("✅ Bước 1: Tạo đối tượng Db thành công.");

    // 2. Thử mở kết nối
    print("⏳ Bước 2: Đang mở kết nối tới Server (Vui lòng đợi)...");
    await db.open();
    print("✅ Bước 2: Kết nối Server THÀNH CÔNG!");
    
    // 3. Kiểm tra trạng thái
    print("📊 Trạng thái kết nối: ${db.state}");

    // 4. Thử thao tác đọc dữ liệu (Ping thử collection)
    print("⏳ Bước 3: Đang thử đọc dữ liệu từ collection '$COLLECTION_NAME'...");
    var collection = db.collection(COLLECTION_NAME);
    var count = await collection.count();
    print("✅ Bước 3: Đọc thành công! Hiện có $count tài khoản trong Database.");

    // 5. Thử tìm kiếm 1 user bất kỳ
    var user = await collection.findOne();
    if (user != null) {
      print("📝 Dữ liệu mẫu tìm thấy: ${user['email']}");
    } else {
      print("📝 Collection đang trống.");
    }

    print("\n🎉 CHÚC MỪNG! KẾT NỐI CỦA BẠN HOÀN TOÀN ỔN ĐỊNH.");

  } catch (e) {
    print("\n❌ KẾT NỐI THẤT BẠI!");
    print("================ LỖI CHI TIẾT ================");
    print(e);
    print("==============================================");
    print("👉 Gợi ý sửa lỗi:");
    if (e.toString().contains("SocketException")) {
      print("- Kiểm tra lại Internet.");
      print("- Vào MongoDB Atlas > Network Access > Thêm IP 0.0.0.0/0 (Cho phép tất cả).");
      print("- Nếu đang dùng Wifi công ty/trường học, có thể port 27017 bị chặn.");
    } else if (e.toString().contains("Authentication failed")) {
      print("- Sai Username hoặc Password trong chuỗi kết nối.");
    } else if (e.toString().contains("SCRAM-SHA-1")) {
      print("- Chuỗi kết nối thiếu tên Database (ví dụ: /test).");
    } else {
      print("- Hãy thử đổi sang chuỗi kết nối dạng dài (mongodb://...) thay vì srv.");
    }
  } finally {
    if (db != null) {
      await db.close();
      print("🔒 Đã đóng kết nối test.");
    }
  }
}