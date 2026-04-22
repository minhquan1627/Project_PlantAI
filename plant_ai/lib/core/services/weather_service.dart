import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // =======================================================================
  // 🚀 HÀM 1: GỌI THỜI TIẾT TRỰC TIẾP TỪ TỌA ĐỘ GPS (DÙNG CHO VƯỜN MỚI)
  // =======================================================================
  static Future<Map<String, double>?> getWeatherFromGPS(double lat, double lng) async {
    try {
      print("🛰️ Đang chọc lên vệ tinh Open-Meteo tại tọa độ: [$lat, $lng]");
      
      // Link API Open-Meteo miễn phí 100%
      final weatherUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,relative_humidity_2m');
      
      final response = await http.get(weatherUrl);
      
      if (response.statusCode == 200) {
        final weatherData = json.decode(response.body);
        double temp = weatherData['current']['temperature_2m'].toDouble();
        double humidity = weatherData['current']['relative_humidity_2m'].toDouble();
        
        print("✅ Thành công! Lụm data thực tế từ GPS: $temp°C - Ẩm $humidity%"); 
        return {'temp': temp, 'humidity': humidity};
      } else {
        print("❌ Lỗi API Vệ tinh: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi mạng WeatherService: $e");
      return null;
    }
  }

  // =======================================================================
  // 🛡️ HÀM 2: GỌI TỪ ĐỊA CHỈ (DÙNG LÀM DỰ PHÒNG CHO VƯỜN CŨ KHÔNG CÓ GPS)
  // =======================================================================
  static String normalizeLocation(String str) {
    str = str.replaceAll(RegExp(r'Tỉnh |Thành phố |TP\. |TP |Huyện |Quận |Xã |Phường '), '');
    str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp(r'[đ]'), 'd');
    str = str.replaceAll(RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'), 'A');
    str = str.replaceAll(RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'), 'E');
    str = str.replaceAll(RegExp(r'[ÌÍỊỈĨ]'), 'I');
    str = str.replaceAll(RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'), 'O');
    str = str.replaceAll(RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'), 'U');
    str = str.replaceAll(RegExp(r'[ỲÝỴỶỸ]'), 'Y');
    str = str.replaceAll(RegExp(r'[Đ]'), 'D');
    return str.trim();
  }

  static Future<Map<String, double>?> getWeather(String location) async {
    try {
      List<String> parts = location.split(',').map((e) => e.trim()).toList();
      List<String> searchCandidates = [];

      for (int i = parts.length - 1; i >= 0; i--) {
        String part = normalizeLocation(parts[i]);
        if (part.toLowerCase().contains('ho chi minh')) part = 'Ho Chi Minh';
        if (part.isNotEmpty) {
          searchCandidates.add(part);
        }
      }

      double? targetLat;
      double? targetLon;

      for (String candidate in searchCandidates) {
        String encodedCity = Uri.encodeComponent(candidate);
        final geoUrl = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$encodedCity&count=1&language=vi&format=json');
        
        print("📍 Đang dò tọa độ GPS ngầm cho vườn cũ: [$candidate]");
        final geoResponse = await http.get(geoUrl);

        if (geoResponse.statusCode == 200) {
          final geoData = json.decode(geoResponse.body);
          if (geoData.containsKey('results') && geoData['results'] != null && geoData['results'].isNotEmpty) {
            targetLat = geoData['results'][0]['latitude'];
            targetLon = geoData['results'][0]['longitude'];
            break; 
          }
        }
      }

      if (targetLat != null && targetLon != null) {
        return await getWeatherFromGPS(targetLat, targetLon); // Tận dụng luôn hàm trên cho gọn
      }

      print("⚠️ CẢNH BÁO: Kích hoạt khiên bảo vệ cho vườn cũ!");
      return {'temp': 27.5, 'humidity': 78.0};

    } catch (e) {
      print("❌ Lỗi sập nguồn WeatherService: $e");
      return {'temp': 26.0, 'humidity': 80.0}; 
    }
  }
}