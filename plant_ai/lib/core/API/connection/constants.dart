import 'package:envied/envied.dart'; // Để dùng kReleaseMode

part 'constants.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  // varName phải khớp 100% với file .env
  @EnviedField(varName: 'MONGO_URI', obfuscate: true)
  static final String mongoUri = _Env.mongoUri;

  @EnviedField(varName: 'GMAIL_USER', obfuscate: true)
  static final String gmailUser = _Env.gmailUser;

  // 3. Gmail Pass (Thêm vào)
  @EnviedField(varName: 'GMAIL_PASS', obfuscate: true)
  static final String gmailPass = _Env.gmailPass;
} 

// --- CẦU NỐI THÔNG MINH ---
// Logic: Dù Dev hay Release đều lấy từ file đã mã hóa -> Code thống nhất
final String GMAIL_EMAIL = Env.gmailUser;    // Biến cho CheckOTP dùng
final String GMAIL_PASSWORD = Env.gmailPass;
final String MONGO_CONN_URL = Env.mongoUri;

const String COLLECTION_NAME = "users";