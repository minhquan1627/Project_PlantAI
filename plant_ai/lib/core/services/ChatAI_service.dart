import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatAPI {
  // ⚠️ NHỚ DÁN LẠI KEY GEMINI VÀO ĐÂY NHÉ (AIzaSy...)
  static const String _apiKey = 'AIzaSyA63YuIHg2CAQBwMTI4L8d6LDWWAEoljbg'; 
  
  // 🚀 ĐỔI SANG DÙNG gemini-pro TIÊU CHUẨN (Bao chạy 100%)
  static const String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

  static Future<String> getAIResponse(List<Map<String, dynamic>> chatHistory) async {
    try {
      List<Map<String, dynamic>> formattedContents = [];

      // 🚀 BÍ QUYẾT: Mớm lời trực tiếp vào đoạn chat để ép vai trò
      formattedContents.add({
        "role": "user",
        "parts": [{"text": "Từ bây giờ, bạn là PlantAI - một kỹ sư nông nghiệp xuất sắc tại Việt Nam. Bạn chuyên tư vấn cho nông dân về các loại bệnh trên cây trồng (đặc biệt là cà phê, lúa), phân bón, tưới nước. Trả lời ngắn gọn, thân thiện và tiếng Việt chuẩn. Hãy xác nhận bạn đã hiểu."}]
      });
      formattedContents.add({
        "role": "model",
        "parts": [{"text": "Chào bạn, tôi là PlantAI - chuyên gia nông nghiệp của bạn. Tôi đã sẵn sàng lắng nghe và hỗ trợ vườn cây của bạn!"}]
      });

      // Đẩy lịch sử chat thực tế của người dùng vào
      for (var msg in chatHistory) {
        String role = msg["role"] == "ai" ? "model" : "user";
        formattedContents.add({
          "role": role,
          "parts": [{"text": msg["content"]}]
        });
      }

      // Bắn Request lên Google
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': formattedContents,
        }),
      );

      // Bắt kết quả
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print("❌ Lỗi API Gemini: ${response.statusCode} - ${response.body}");
        return "Xin lỗi, chuyên gia AI đang bận. Vui lòng thử lại sau vài giây nhé!";
      }
    } catch (e) {
      print("❌ Lỗi System: $e");
      return "Không thể kết nối mạng. Hãy kiểm tra lại 4G/Wifi nhé!";
    }
  }
}