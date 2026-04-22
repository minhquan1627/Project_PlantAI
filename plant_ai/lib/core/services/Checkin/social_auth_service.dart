import 'dart:developer';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../API/UserAPI.dart'; // Đảm bảo đường dẫn đúng tới UserAPI

class SocialAuthService {
  
  // --- 1. XỬ LÝ GOOGLE ---
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Đăng xuất trước để đảm bảo người dùng luôn chọn được tài khoản 
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        log("📧 Google Email: ${googleUser.email}");
        
        // Gọi UserAPI để đồng bộ với MongoDB
        var user = await UserAPI.loginOrRegisterSocial(
          googleUser.email, 
          googleUser.displayName ?? "No Name"
        );
        
        return user; // Trả về thông tin user từ DB
      }
      return null; // Người dùng hủy đăng nhập
    } catch (e) {
      log("❌ Lỗi Google Service: $e");
      return null;
    }
  }

  // --- 2. XỬ LÝ FACEBOOK ---
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Lấy thông tin user từ Facebook
        final userData = await FacebookAuth.instance.getUserData();
        log("📘 FB Email: ${userData['email']}");

        // Gọi UserAPI để đồng bộ với MongoDB
        var user = await UserAPI.loginOrRegisterSocial(
          userData['email'], 
          userData['name'] ?? "Facebook User"
        );

        return user; // Trả về thông tin user từ DB
      } else {
        log("⚠️ FB Login Cancelled/Failed: ${result.status}");
        return null;
      }
    } catch (e) {
      log("❌ Lỗi Facebook Service: $e");
      return null;
    }
  }
  static Future<void> signOut() async {
    try {
      // 1. Đăng xuất Google
      final googleSignIn = GoogleSignIn();
      // Dùng disconnect() thay vì chỉ signOut() để ngắt hoàn toàn kết nối.
      // Lần sau đăng nhập nó sẽ bắt buộc hiện lại bảng chọn tài khoản.
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect(); 
        print("🚪 Đã đăng xuất Google");
      }

      // 2. Đăng xuất Facebook
      await FacebookAuth.instance.logOut();
      print("🚪 Đã đăng xuất Facebook");

    } catch (e) {
      print("❌ Lỗi khi đăng xuất Social: $e");
      // Dù lỗi mạng thì cũng kệ, vì Token ở máy (JWT) đã bị xóa rồi.
    }
  }
}