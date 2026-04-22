import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:google_fonts/google_fonts.dart';
import '../PlantProfile/CoffeeMinerScreen.dart';
import '../PlantProfile/CoffeePhomaScreen.dart';
import '../PlantProfile/CoffeeRustScreen.dart';
import '../PlantProfile/RiceLeafBlastScreen.dart';
import '../PlantProfile/RiceLeafBrownSpotScreen.dart';
import '../PlantProfile/RiceLeafHispaScreen.dart';
import '../PlantProfile/RiceLeafScaldScreen.dart';
import '../ScanScreen.dart'; 
import '../../../core/API/RecordAPI.dart'; 
import '../../../core/API/connection/scan_record.dart';
import 'ChatBotAIScreen.dart';

class ResultScreen extends StatefulWidget { // Đã chuyển sang StatefulWidget
  final String imagePath;
  final Map<String, dynamic> aiResult;

  const ResultScreen({super.key, required this.imagePath, required this.aiResult});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Color primaryGreen = const Color(0xFF80A252);
  

  @override
  void initState() {
    super.initState();
    // CHỐT HẠ: Tự động gọi hàm lưu ngay khi vừa mở trang kết quả
    _handleAutoSave();
  }

  Future<void> _handleAutoSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? realUserId = prefs.getString('current_user_id');

      // BƯỚC 1: ĐẨY ẢNH LÊN CLOUDINARY TRƯỚC
      print("Đang tải ảnh chẩn đoán lên Cloudinary...");
      
      String cloudName = "dmxpgpq01"; 
      String uploadPreset = "plant_ai_preset"; 
      
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload')
      );

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', widget.imagePath));

      var response = await request.send();
      String finalImagePath = widget.imagePath; // Mặc định dùng local nếu lỗi

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = json.decode(responseData);
        finalImagePath = jsonResult['secure_url']; //  ĐÂY LÀ LINK HTTPS XỊN!
        print(" Upload Cloud thành công: $finalImagePath");
      } else {
        print(" Lỗi upload Cloudinary: ${response.statusCode}. Lưu tạm link local.");
      }
      
      // BƯỚC 2: ĐÓNG GÓI DỮ LIỆU VỚI LINK HTTPS
      String enName = widget.aiResult['en_name'] ?? "Unknown Disease";
      String extractedPlantName = "Cây trồng"; // Giá trị mặc định phòng hờ

      // Thuật toán tìm và cắt chữ nằm trong dấu ngoặc (...)
      int startIndex = enName.indexOf('(');
      int endIndex = enName.indexOf(')');
      
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        // Cắt lấy phần chữ ở giữa 2 dấu ngoặc
        extractedPlantName = enName.substring(startIndex + 1, endIndex); 
      }

      final record = ScanRecord(
        userId: realUserId ?? "GUEST_USER", 
        plantName: extractedPlantName, 
        diseaseVi: widget.aiResult['vi_name'] ?? "Bệnh không xác định",
        diseaseEn: widget.aiResult['en_name'] ?? "Unknown Disease",
        confidence: widget.aiResult['confidence'] ?? 0.0,
        imagePath: finalImagePath, // ⚡ LƯU LINK CLOUD VÀO MONGODB
        createdAt: DateTime.now(),
      );

      // BƯỚC 3: GỌI API LƯU VÀO DATABASE
      await RecordAPI.saveHistory(record);
      print(" Đã lưu lịch sử vĩnh viễn cho User: $realUserId");

    } catch (e) {
      print("Lỗi hệ thống khi tự động lưu: $e");
    }
  }

void _navigateToDetailScreen(BuildContext context, String diseaseEn) {
  Widget targetScreen;
  
  // Đưa tất cả về chữ thường để dễ so sánh, không lo viết hoa viết thường
  String searchName = diseaseEn.toLowerCase();

  // DÙNG TUYỆT CHIÊU "BẮT TỪ KHÓA" (Chỉ cần có chữ đó là auto mở đúng trang)
  if (searchName.contains("miner")) {
    targetScreen = const CoffeeMinerScreen();
  } else if (searchName.contains("phoma") || searchName.contains("đốm đen")) {
    targetScreen = const CoffeePhomaScreen();
  } else if (searchName.contains("rust") || searchName.contains("rỉ sắt")) {
    targetScreen = const CoffeeRustScreen();
  } else if (searchName.contains("blast") || searchName.contains("đạo ôn")) {
    targetScreen = const RiceBlastScreen();
  } else if (searchName.contains("brown spot") || searchName.contains("đốm nâu")) {
    targetScreen = const RiceBrownSpotScreen();
  } else if (searchName.contains("hispa")) {
    targetScreen = const RiceHispaScreen();
  } else if (searchName.contains("scald") || searchName.contains("cháy lá")) {
    targetScreen = const RiceLeafScaldScreen();
  } else {
    // Trường hợp không tìm thấy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hiện chưa có hướng dẫn chi tiết cho mục này.")),
    );
    return;
  }

  // Thực hiện chuyển trang
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => targetScreen),
  );
}

void _navigateToAIChat(BuildContext context, String diseaseVi, String diseaseEn) {
  // 1. Tự động cắt lấy tên cây từ tiếng Anh (Giống hệt lúc lưu Database)
  String extractedPlantName = "cây trồng"; // Mặc định
  int startIndex = diseaseEn.indexOf('(');
  int endIndex = diseaseEn.indexOf(')');
  
  if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
    extractedPlantName = diseaseEn.substring(startIndex + 1, endIndex); 
  }

  // 2. 🚀 NÂNG CẤP CÂU LỆNH: Ghép hẳn tên cây vào cho AI khỏi hỏi lằng nhằng
  String prompt = "Thông tin về $diseaseVi trên $extractedPlantName đang gặp phải và cách chữa trị:";
  
  print("🤖 Đang chuyển sang Chat AI với câu hỏi: $prompt");

  // 3. Chuyển sang trang Chat
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatBotAIScreen(
        initialMessage: prompt, 
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // 🚀 LẤY DỮ LIỆU ĐỘNG TỪ DICTIONARY (ai_service.dart đã dịch sẵn)
    
    String viName = widget.aiResult['vi_name'] ?? "Bệnh không xác định";
    String enName = widget.aiResult['en_name'] ?? "Unknown Disease";
    double confidence = widget.aiResult['confidence'] ?? 0.0;
    String confidenceText = "${(confidence * 100).toStringAsFixed(1)}%";
    bool isHealthy = enName.toLowerCase().contains("healthy") || 
                 enName.toLowerCase().contains("nodisease");
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Kết quả chẩn đoán",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.black87, size: 20),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), 
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'scanned_image',
              child: Container(
                width: 220, 
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32), 
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Text("Phân tích hoàn tất", style: GoogleFonts.inter(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Text(
                    viName, 
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    enName,
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[500]),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)), 
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Độ tin cậy của AI", style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      Text(
                        confidenceText, 
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: confidence, 
                      backgroundColor: const Color(0xFFF2F2F7),
                      color: primaryGreen,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            if (!isHealthy) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0, 
                  ),
                  onPressed: () {
                    _navigateToDetailScreen(context, enName);
                  },
                  child: Text(
                    "Xem hướng dẫn điều trị",
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12), // Khoảng cách chỉ hiện khi có nút trên
            ],
            SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9), // Màu xanh lá rất nhạt
                foregroundColor: primaryGreen,
                side: BorderSide(color: primaryGreen, width: 1.5), // Viền xanh đậm
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0, 
              ),
              onPressed: () {
                // 🚀 CHỖ NÀY ĐỂ MỞ TRANG CHAT AI
                _navigateToAIChat(context, viName, enName);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: primaryGreen, size: 20), // Icon AI xịn sò
                  const SizedBox(width: 8),
                  Text(
                    "Hỏi đáp chuyên sâu với AI",
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen.withOpacity(0.1), 
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, color: primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Text("Chụp lại ảnh khác", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryGreen)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), 
          ],
        ),
      ),
    );
  }
}