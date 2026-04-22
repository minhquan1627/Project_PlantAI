import 'dart:developer';
import 'dart:convert'; 
import 'package:mongo_dart/mongo_dart.dart';
// Import file kết nối để lấy biến userCollection
import 'connection/MongoDB.dart'; 
import 'package:http/http.dart' as http;
class UserAPI {
  
  // Helper: Đảm bảo đã kết nối trước khi gọi lệnh
  static Future<void> _ensureConnected() async {
    if (MongoDatabase.userCollection == null || !MongoDatabase.db!.isConnected) {
      await MongoDatabase.connect();
    }
  }

  // 1. ĐĂNG NHẬP
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      await _ensureConnected();
      
      final user = await MongoDatabase.userCollection!.findOne({
        'email': email,
        'password': password
      });
      return user;
    } catch (e) {
      log('❌ UserAPI Error (Login): $e');
      return null;
    }
  }

  // 2. ĐĂNG KÝ
  static Future<String> registerUser(String name ,String email, String password) async {
    try {
      await _ensureConnected();

      var u = await MongoDatabase.userCollection!.findOne({"email": email});
      if (u != null) {
        return "EMAIL_EXISTED";
      }

      var id = ObjectId();
      await MongoDatabase.userCollection!.insert({
        "_id": id,
        "name": name,
        "email": email,
        "password": password,
        "createdAt": DateTime.now().toIso8601String(),
      });

      return "SUCCESS";
    } catch (e) {
      log('❌ UserAPI Error (Register): $e');
      return "ERROR";
    }
  }

  // 3. ĐỔI MẬT KHẨU (RESET PASSWORD)
  static Future<String> resetPassword(String email, String newPassword) async {
    try {
      await _ensureConnected();

      var u = await MongoDatabase.userCollection!.findOne({"email": email});
      if (u == null) {
        return "EMAIL_NOT_FOUND";
      }

      await MongoDatabase.userCollection!.update(
        where.eq('email', email), 
        modify.set('password', newPassword)
      );

      return "SUCCESS";
    } catch (e) {
      log('❌ UserAPI Error (ResetPass): $e');
      return "ERROR";
    }
  }

  // 6. CẬP NHẬT THÔNG TIN NGƯỜI DÙNG (Cập nhật hoặc thêm mới các trường)
  static Future<String> updateUserProfile(String email, Map<String, dynamic> updateData) async {
    try {
      await _ensureConnected();

      // --- 1. XỬ LÝ ẢNH BẰNG CLOUDINARY (CHỈ KHI CÓ ẢNH MỚI) ---
      String? currentAvatar = updateData['avatar'];
      
      // Nếu có ảnh và nó KHÔNG phải là link mạng (tức là file cục bộ trong điện thoại)
      if (currentAvatar != null && currentAvatar.isNotEmpty && !currentAvatar.startsWith('http')) {
        log('📦 Phát hiện ảnh mới, đang upload lên Cloudinary...');
        
        // THAY BẰNG THÔNG TIN CLOUDINARY CỦA ÔNG
        String cloudName = "dmxpgpq01"; // Ví dụ: dxyz123abc
        String uploadPreset = "plant_ai_preset"; // Xem hướng dẫn tạo Upload Preset ở dưới
        
        var request = http.MultipartRequest(
          'POST', 
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload')
        );

        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', currentAvatar));

        var response = await request.send();
        
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonResult = json.decode(responseData);
          // Lấy cái link xịn sò về
          String secureUrl = jsonResult['secure_url']; 
          
          log('✅ Upload Cloudinary thành công: $secureUrl');
          // Cập nhật lại cái link xịn vào mảng dữ liệu để chuẩn bị lưu vô MongoDB
          updateData['avatar'] = secureUrl; 
        } else {
          log('❌ Lỗi upload Cloudinary: Mã ${response.statusCode}');
          return "ERROR_UPLOAD_IMAGE";
        }
      }

      // --- 2. LƯU VÀO MONGODB NHƯ BÌNH THƯỜNG ---
      // Loại bỏ các trường không được phép sửa
      updateData.remove('email');
      updateData.remove('_id');

      var modifier = modify;
      updateData.forEach((key, value) {
        modifier = modifier.set(key, value);
      });

      final result = await MongoDatabase.userCollection!.updateOne(
        where.eq('email', email),
        modifier
      );

      print("🔧 LOG TỪ MONGODB: ${result.document}"); 

      if (result.isSuccess && result.nMatched > 0) {
        return "SUCCESS";
      } else if (result.isSuccess && result.nMatched == 0) {
        log('⚠️ Không tìm thấy User với email: $email');
        return "NOT_FOUND";
      } else {
        return "Lỗi DB: ${result.writeError?.errmsg ?? 'Không xác định'}";
      }

    } catch (e) {
      print("🔥 LỖI CATCH MONGODB/CLOUDINARY: $e");
      return "Lỗi ngoại lệ: $e";
    }
  }

  // 4. ĐĂNG NHẬP / ĐĂNG KÝ GOOGLE & FACEBOOK
  static Future<Map<String, dynamic>?> loginOrRegisterSocial(String email, String name) async {
    try {
      await _ensureConnected();

      var user = await MongoDatabase.userCollection!.findOne({'email': email});

      if (user != null) {
        return user; // Đã có -> Đăng nhập
      } else {
        // Chưa có -> Tạo mới
        var id = ObjectId();
        var newUser = {
          "_id": id,
          "email": email,
          "name": name,
          "password": "SOCIAL_${DateTime.now().millisecondsSinceEpoch}",
          "loginType": "social",
          "createdAt": DateTime.now().toIso8601String(),
        };

        await MongoDatabase.userCollection!.insert(newUser);
        return newUser;
      }
    } catch (e) {
      log('❌ UserAPI Error (Social): $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      await _ensureConnected();

      // Tìm user dựa theo email
      final user = await MongoDatabase.userCollection!.findOne({
        'email': email
      });
      
      return user;
    } catch (e) {
      log('❌ UserAPI Error (GetProfile): $e');
      return null;
    }
  }

  // 🚀 HÀM "THẦN HỦY DIỆT": XÓA SẠCH DẤU VẾT NGƯỜI DÙNG
  static Future<String> deleteUserFullData(String userId, String email) async {
    try {
      await _ensureConnected();
      final db = MongoDatabase.db!;

      // Danh sách các Collection cần quét sạch
      final collectionsToClean = [
        'gardens',      // Khu vườn
        'tasks',        // Công việc/Lịch trình
        'posts',        // Bài đăng cộng đồng
        'comments',     // Bình luận
        'likes',        // Lượt thích
        'scan_history', // Lịch sử quét bệnh cây
        'ai_chats',     // Lịch sử chat với AI
      ];

      log('⚠️ Bắt đầu dọn dẹp dữ liệu cho User: $email');

      // Chuyển String ID sang ObjectId của Mongo để xóa cho chuẩn
      var uId = ObjectId.fromHexString(userId);
      
      for (var colName in collectionsToClean) {
        var col = db.collection(colName);
        // Xóa tất cả record có chứa user_id của người này
        await col.remove(where.eq('user_id', uId));
        log('✅ Đã dọn dẹp Collection: $colName');
      }

      // Cuối cùng mới xóa chính tài khoản User
      final result = await MongoDatabase.userCollection!.remove(where.eq('email', email));

      if (result['n'] > 0) {
        log('🔥 THÀNH CÔNG: Tài khoản $email đã bay màu hoàn toàn!');
        return "SUCCESS";
      } else {
        return "USER_NOT_FOUND";
      }
    } catch (e) {
      log('❌ Lỗi Cascade Delete: $e');
      return "ERROR";
    }
  }
}