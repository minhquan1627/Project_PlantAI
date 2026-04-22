import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:convert';
import '../../../core/API/connection/constants.dart';

class OTPService {
  // Singleton: Giúp lưu trữ mã OTP trong bộ nhớ suốt quá trình App chạy
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  // Biến lưu mã OTP (Private)
  String? _currentOTP;

  // --- CẤU HÌNH GMAIL (BẠN CẦN THAY THÔNG TIN CỦA BẠN VÀO ĐÂY) ---
  final String _senderEmail = GMAIL_EMAIL;
  // Lưu ý: Đây phải là Mật khẩu ứng dụng (App Password) 16 ký tự, KHÔNG phải mật khẩu đăng nhập Gmail
  final String _senderPassword = base64.encode(utf8.encode(GMAIL_PASSWORD)) ;

  String get _decodedPassword {
    // Giải mã Base64 về lại text thường
    List<int> bytes = base64.decode(_senderPassword);
    return utf8.decode(bytes);
  }

  // 1. Hàm Sinh mã & Gửi Email
  Future<bool> sendOTP(String recipientEmail) async {
    // A. Sinh mã ngẫu nhiên 4 số (từ 1000 đến 9999)
    var rng = Random();
    _currentOTP = (1000 + rng.nextInt(9000)).toString();
    print("LOG SYSTEM: Mã OTP thực tế là: $_currentOTP"); // In ra để bạn test nếu không nhận được mail

    // B. Cấu hình SMTP Server (Gmail)
    final smtpServer = gmail(_senderEmail, _decodedPassword);

    // C. Soạn nội dung Email
    final message = Message()
      ..from = Address(_senderEmail, 'PlantAI Security')
      ..recipients.add(recipientEmail)
      ..subject = '[PlantAI] Mã xác thực đăng ký'
      ..html = """
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
          <h2 style="color: #8DAA5B;">Mã Xác Thực PlantAI</h2>
          <p>Xin chào,</p>
          <p>Mã OTP của bạn là:</p>
          <h1 style="color: #2c3e50; letter-spacing: 5px;">$_currentOTP</h1>
          <p style="color: grey; font-size: 12px;">Mã này có hiệu lực trong vòng 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai.</p>
        </div>
      """;

    try {
      // D. Gửi mail
      final sendReport = await send(message, smtpServer);
      print('Email sent: ' + sendReport.toString());
      return true; // Gửi thành công (True)
    } catch (e) {
      print('Email failed: ' + e.toString());
      return false; // Gửi thất bại (False)
    }
  }

  // 2. Hàm Kiểm tra mã (Logic trả về True/False như bạn yêu cầu)
  bool verifyOTP(String inputOTP) {
    if (_currentOTP == null) return false; // Chưa có mã nào được sinh ra
    return inputOTP == _currentOTP; // So sánh mã nhập vào với mã đã lưu
  }
}