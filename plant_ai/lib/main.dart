import 'dart:async'; // 🚀 Cần thêm cái này để dùng Timeout
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/onboarding/main_flow.dart'; 
import 'core/API/connection/MongoDB.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

Future<void> main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized(); 

  // --- GOOGLE MAPS ---
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    try {
      await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
      print(" Google Maps: Bộ dựng hình đã sẵn sàng!");
    } catch (e) {
      print(" Lỗi Google Maps: $e");
    }
  }

  // --- FIREBASE (Giới hạn đợi 5 giây) ---
  try {
    print(" Đang khởi tạo Firebase...");
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
    print(" Firebase: Khởi tạo thành công!");
  } catch (e) {
    print(" LỖI/TIMEOUT FIREBASE: $e");
  }

  // --- MongoDB (Giới hạn đợi 5 giây) ---
  try {
    print(" Đang kết nối MongoDB...");
    // 🚀 Nếu sau 5 giây không thấy phản hồi, nó sẽ tự nhảy xuống catch để chạy tiếp runApp
    await MongoDatabase.connect().timeout(const Duration(seconds: 5));
    print(" MongoDB: Kết nối thành công!");
  } catch (e) {
    print(" LỖI/TIMEOUT MONGODB: $e");
    print(" Gợi ý: Kiểm tra IP Whitelist trên Atlas hoặc đường truyền mạng.");
  }

  // --- CHỐT HẠ: Mở cửa cho App hiện lên ---
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlantAI',
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8DAA5B)),
        useMaterial3: true,
      ),
      home: const PlantAIFlow(), 
    );
  }
}







































































































































// By Minh Quân Đẹp Trai
// Quê Phan Thiết, Tỉnh Lâm Đồng
// Bố là Dược sĩ Chuyên Khoa 1