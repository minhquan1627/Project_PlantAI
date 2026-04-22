import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ResultScreen.dart'; 
import '../../../core/services/ai_service.dart';
import '../ScanScreen.dart'; 

class LoadingAIScreen extends StatefulWidget {
  final String imagePath; // Nhận đường dẫn ảnh từ màn hình Camera truyền sang

  const LoadingAIScreen({super.key, required this.imagePath});

  @override
  State<LoadingAIScreen> createState() => _LoadingAIScreenState();
}

class _LoadingAIScreenState extends State<LoadingAIScreen> {
  // Biến quản lý trạng thái các bước (0: Bắt đầu, 1: Xong bước 1, 2: Xong bước 2, 3: Hoàn thành)
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _processAIAndShowUI();
  }

  // --- HÀM KẾT HỢP CHẠY AI VÀ HIỂN THỊ UX ---
  Future<void> _processAIAndShowUI() async {
    // 🚀 BƯỚC 0: KIỂM TRA VÀ NẠP MÔ HÌNH VÀO RAM NẾU CHƯA CÓ
    if (!AiPipelineService().isReady) {
      print("⏳ Đang nạp mô hình AI vào bộ nhớ...");
      await AiPipelineService().loadModels();
    }

    // 1. Kích hoạt AI chạy ngầm ngay lập tức
    Future<Map<String, dynamic>?> aiTask = AiPipelineService().processPipeline(widget.imagePath);

    // 2. Chạy hiệu ứng UX để lấp đầy thời gian chờ
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _currentStep = 1);

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) setState(() => _currentStep = 2);

    // 3. Chờ AI phân tích xong thật sự
    Map<String, dynamic>? result = await aiTask;

    if (mounted) setState(() => _currentStep = 3);
    await Future.delayed(const Duration(milliseconds: 2000)); 
    
    // 4. KIỂM TRA KẾT QUẢ VÀ CHUYỂN TRANG
    if (mounted) {
      if (result != null && result['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imagePath: widget.imagePath,
              aiResult: result, 
            ),
          ),
        );
      } else {
        _showErrorDialog(result?['message'] ?? "Lỗi phân tích hình ảnh. Vui lòng thử lại!");
      }
    }
  }

  // --- POPUP BÁO LỖI NẾU ẢNH HỎNG ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Chẩn đoán thất bại", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 166, 205, 112)),
            onPressed: () {
             Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanScreen()),
             ); // Quay lại trang Camera để chụp lại
            },
            child: const Text("Chụp lại ảnh", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Nền xám đen nhám chuẩn Apple
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. ẢNH PREVIEW BO GÓC ---
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 220,
                  height: 220,
                  color: Colors.grey[800],
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white54, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 2. TIÊU ĐỀ ---
              Text(
                "Đang quét dữ liệu",
                style: GoogleFonts.roboto(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "AI đang phân tích cây trồng của bạn...",
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),

              // --- 3. DANH SÁCH 3 BƯỚC XỬ LÝ ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepItem(
                      stepIndex: 0,
                      title: "Nhận diện vị trí lá cây",
                    ),
                    const SizedBox(height: 20),
                    _buildStepItem(
                      stepIndex: 1,
                      title: "Phân tích cấu trúc mầm bệnh",
                    ),
                    const SizedBox(height: 20),
                    _buildStepItem(
                      stepIndex: 2,
                      title: "Trích xuất kết quả chẩn đoán",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET VẼ TỪNG BƯỚC ---
  Widget _buildStepItem({required int stepIndex, required String title}) {
    // Trạng thái của bước hiện tại
    bool isCompleted = _currentStep > stepIndex;
    bool isActive = _currentStep == stepIndex;

    Color itemColor = (isActive || isCompleted) ? const Color.fromARGB(255, 166, 205, 112) : Colors.grey[600]!;

    return Row(
      children: [
        // Cột mốc Icon
        SizedBox(
          width: 24,
          height: 24,
          child: isCompleted
              // Xong rồi thì hiện dấu Tick
              ? const Icon(Icons.check_circle, color: Color.fromARGB(255, 166, 205, 112), size: 24)
              : isActive
                  // Đang xử lý thì hiện vòng quay
                  ? const CircularProgressIndicator(color: Color.fromARGB(255, 166, 205, 112), strokeWidth: 2.5)
                  // Chưa tới thì hiện vòng tròn xám rỗng
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey[700], size: 24),
        ),
        const SizedBox(width: 15),
        
        // Cột Chữ
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: (isActive || isCompleted) ? FontWeight.bold : FontWeight.normal,
            color: itemColor,
          ),
        ),
      ],
    );
  }
}