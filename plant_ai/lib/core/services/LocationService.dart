import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Map<String, String>> getCurrentAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Kiểm tra dịch vụ định vị có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Dịch vụ định vị bị tắt.');

    // 2. Kiểm tra quyền truy cập
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Quyền truy cập vị trí bị từ chối.');
    }

    try {
      await setLocaleIdentifier("vi_VN"); 
    } catch (e) {
      print("⚠️ Không set được Locale, sẽ dùng mặc định hệ thống.");
    }

    // 3. Lấy tọa độ hiện tại
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // 4. Reverse Geocoding: Dịch tọa độ sang địa chỉ tiếng Việt
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, 
      position.longitude,
       // 🇻🇳 Ép lấy địa chỉ tiếng Việt
    );

    Placemark place = placemarks[0];

    // Trả về map thông tin chi tiết
    return {
      "lat": position.latitude.toString(),
      "lng": position.longitude.toString(),
      "ward": place.subLocality ?? "",        // Phường/Xã
      "district": place.subAdministrativeArea ?? "", // Quận/Huyện
      "province": place.administrativeArea ?? "",   // Tỉnh/Thành phố
      "country": place.country ?? "",         // Quốc gia
      "full_address": "${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}",
    };
  }
}