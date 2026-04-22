import 'package:shared_preferences/shared_preferences.dart';

class JWTService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'current_user_email';
  static const String _idKey = 'current_user_id';

  // 1. LƯU TOKEN VÀ EMAIL (Gọi khi Đăng nhập thành công)
  static Future<void> saveToken(String token, String email, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_idKey, id);
    print("🔑 JWTService: Đã lưu phiên đăng nhập cho $email (ID: $id)");
  }

  // 2. KIỂM TRA ĐĂNG NHẬP (Dành cho Auto Login ở Màn hình Login)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    // Nếu có token và token không rỗng -> Đã đăng nhập
    return token != null && token.isNotEmpty;
  }

  // 3. LẤY TOKEN (Dành cho việc gắn vào Header gọi API sau này)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_idKey);
  }

  // 4. LẤY EMAIL (Dành cho HomeScreen để biết ai đang dùng)
  static Future<String?> getCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // 5. XÓA TOKEN (Gọi khi Đăng xuất)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_idKey);
    print("🚪 Đã xóa phiên đăng nhập (Token)");
  }
}