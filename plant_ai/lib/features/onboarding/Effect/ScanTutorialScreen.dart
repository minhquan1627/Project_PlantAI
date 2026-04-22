import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ScanScreen.dart'; // 🚀 ĐÃ THÊM IMPORT VÀO ĐÂY (Chỉnh lại đường dẫn nếu file ở vị trí khác nhé)

class ScanTutorialScreen extends StatelessWidget {
  const ScanTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 🚀 NÚT BACK Ở TRÊN CÙNG ĐỂ NGƯỜI DÙNG QUAY LẠI NẾU ĐỔI Ý
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Hướng dẫn quét bệnh",
          style: GoogleFonts.roboto(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lời dẫn nhập chuyên nghiệp
                  Text(
                    "Cách để chụp ảnh nhận diện chính xác nhất",
                    style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF80A252)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Để hệ thống chuẩn đoán chính xác nhất, vui lòng tuân thủ 5 nguyên tắc chụp ảnh tiêu chuẩn dưới đây.",
                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700], height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // 🚀 BƯỚC 1: CÁCH LY
                  _buildGuideStepCard(
                    stepNumber: "1",
                    title: "NGUYÊN TẮC CÁCH LY NỀN",
                    description: "Chỉ chụp một lá duy nhất. Vui lòng lót bàn tay, giấy trắng hoặc vật liệu trơn màu ngay phía sau lá để AI không phân tích nhầm cỏ dại làm hậu cảnh.",
                    illustration: _buildStep1Illustration(), 
                  ),
                  const SizedBox(height: 20),

                  // 🚀 BƯỚC 2: ÁNH SÁNG DỊU
                  _buildGuideStepCard(
                    stepNumber: "2",
                    title: "KIỂM SOÁT ÁNH SÁNG",
                    description: "Tránh chụp dưới nắng gắt gây lóa ảnh hoặc khu vực quá tối. Hãy dùng cơ thể che nắng để tạo bóng râm dịu nhẹ lên mặt lá trước khi chụp.",
                    illustration: _buildStep2Illustration(), 
                  ),
                  const SizedBox(height: 20),

                  // 🚀 BƯỚC 3: MẶT PHẲNG
                  _buildGuideStepCard(
                    stepNumber: "3",
                    title: "CHỤP SONG SONG VỚI MẶT LÁ",
                    description: "Trải phẳng chiếc lá bị bệnh. Đặt ống kính camera song song với bề mặt lá, tuyệt đối không chụp hất từ dưới lên hoặc chụp góc nghiêng.",
                    illustration: _buildStep3Illustration(), 
                  ),
                  const SizedBox(height: 20),

                  // 🚀 BƯỚC 4: LẤY NÉT
                  _buildGuideStepCard(
                    stepNumber: "4",
                    title: "LẤY NÉT THỦ CÔNG BẰNG ĐIỆN THOẠI",
                    description: "Hình ảnh rung nhòe sẽ làm giảm độ chính xác của AI. Hãy giữ chắc tay, chạm vào vết bệnh trên màn hình để camera lấy nét rõ ràng trước khi bấm chụp.",
                    illustration: _buildStep4Illustration(), 
                  ),
                  const SizedBox(height: 20),

                  // 🚀 BƯỚC 5: ZOOM GẦN
                  _buildGuideStepCard(
                    stepNumber: "5",
                    title: "ĐẢM BẢO TỶ LỆ KHUNG HÌNH",
                    description: "Đưa camera lại gần vật thể. Hãy đảm bảo phần lá bị bệnh chiếm từ 50% đến 70% toàn bộ khung hình, không chụp toàn cảnh từ xa.",
                    illustration: _buildStep5Illustration(), 
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Nút Mở Camera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80A252),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // 🚀 CHUYỂN THẲNG SANG MÀN HÌNH CAMERA THAY VÌ LÙI LẠI
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ScanScreen()),
                    );
                  }, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, color: Colors.white),
                      const SizedBox(width: 10),
                      Text("Đã nắm rõ nguyên tắc", style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ===========================================================================
  // CÁC HÀM TỰ VẼ HÌNH MINH HỌA (WIDGET ILLUSTRATION)
  // ===========================================================================

  Widget _buildStep1Illustration() {
    return Container(
      height: 140, width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 20, left: 20, child: Icon(Icons.grass, color: Colors.green[200], size: 40)),
          Positioned(bottom: 20, right: 30, child: Icon(Icons.grass, color: Colors.green[200], size: 50)),
          Container(width: 120, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)])),
          const Icon(Icons.eco, size: 80, color: Color(0xFF2E7D32)),
          Positioned(top: 50, right: 140, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle))),
        ],
      ),
    );
  }

  Widget _buildStep2Illustration() {
    return Container(
      height: 140, width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(top: 20, left: 100, child: Icon(Icons.wb_sunny, size: 60, color: Color(0xFFFFB300))),
          const Positioned(top: 40, left: 130, child: Icon(Icons.cloud, size: 70, color: Colors.white)),
          const Positioned(bottom: 20, child: Icon(Icons.eco, size: 70, color: Color(0xFF66BB6A))),
        ],
      ),
    );
  }

  Widget _buildStep3Illustration() {
    return Container(
      height: 140, width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 180, height: 30, decoration: BoxDecoration(color: const Color(0xFF81C784), borderRadius: BorderRadius.circular(15))),
          Positioned(top: 60, left: 160, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle))),
          const Positioned(
            top: 20,
            child: Icon(Icons.stay_current_landscape, size: 80, color: Color(0xFF1976D2)),
          ),
          Positioned(top: 50, child: Container(width: 120, height: 2, color: Colors.blueAccent.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildStep4Illustration() {
    return Container(
      height: 140, width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.eco, size: 90, color: Color(0xFFA5D6A7)),
          Container(width: 60, height: 60, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFFFCA28), width: 3), borderRadius: BorderRadius.circular(8))),
          const Positioned(top: 60, left: 180, child: Icon(Icons.touch_app, size: 50, color: Color(0xFF8E24AA))),
        ],
      ),
    );
  }

  Widget _buildStep5Illustration() {
    return Container(
      height: 140, width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: -20, bottom: -20, left: 80, right: 80,
            child: Icon(Icons.eco, size: 160, color: Color(0xFFFFB74D)),
          ),
          Positioned(top: 50, left: 160, child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle))),
          Positioned(top: 70, left: 180, child: Container(width: 15, height: 15, decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle))),
          const Positioned(top: 10, right: 10, child: Icon(Icons.crop, size: 30, color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildGuideStepCard({required String stepNumber, required String title, required String description, required Widget illustration}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: const BoxDecoration(color: Color(0xFF80A252), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(stepNumber, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: GoogleFonts.roboto(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87))),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: illustration,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(description, style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700], height: 1.5)),
          ),
        ],
      ),
    );
  }
}