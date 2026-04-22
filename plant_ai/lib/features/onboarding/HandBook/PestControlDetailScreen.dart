import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PestControlDetailScreen extends StatelessWidget {
  const PestControlDetailScreen({super.key});

  final Color primaryGreen = const Color(0xFF8DAA5B);
  final Color bgTagColor = const Color(0xFFF1F5EB); 
  final Color bgNoteColor = const Color(0xFFF4F6F0); 
  final Color textDark = const Color(0xFF1E293B);
  final Color textGray = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TAG PHÂN LOẠI
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bgTagColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_rounded, size: 16, color: primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      "Kiến thức nông nghiệp",
                      style: GoogleFonts.roboto(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 21),

              // 2. TIÊU ĐỀ
              Text(
                "Làm sao để nhận biết sớm sâu bệnh trước khi quá muộn?",
                style: GoogleFonts.roboto(fontSize: 26, fontWeight: FontWeight.bold, color: textDark, height: 1.3),
              ),
              const SizedBox(height: 25),

              // 3. SAPO
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.biotech_outlined, color: primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Việc phát hiện sớm các dấu hiệu bất thường trên cây trồng giúp giảm 80% chi phí điều trị và bảo vệ năng suất. Hãy rèn luyện đôi mắt 'nhạy bén' cùng PlantAI.",
                      style: GoogleFonts.roboto(fontSize: 15, color: const Color(0xFF334155), height: 1.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // 4. PHẦN 1: DẤU HIỆU TRÊN LÁ 🌿
              Row(
                children: [
                  const Text("🌿", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text("1. Các dấu hiệu trên lá", 
                    style: GoogleFonts.roboto(fontSize: 19, fontWeight: FontWeight.bold, color: textDark)),
                ],
              ),
              const SizedBox(height: 21),
              
              _buildInfoCard(
                "Biến màu (Discoloration)",
                "Lá chuyển sang màu vàng (úa), bạc trắng hoặc có các đường gân xanh đen bất thường. Đây thường là dấu hiệu của thiếu dinh dưỡng hoặc nấm xâm nhập.",
                Icons.palette_outlined,
              ),
              _buildInfoCard(
                "Vết đốm và loét (Spots)",
                "Xuất hiện các chấm nhỏ màu nâu, đen hoặc có quầng vàng xung quanh. Nếu vết bệnh có hình thoi, hãy cẩn thận với bệnh Đạo ôn.",
                Icons.grain_outlined,
              ),
              _buildInfoCard(
                "Biến dạng lá (Deformation)",
                "Lá bị xoăn tít, co rúm hoặc nhỏ lại bất thường. Đây là dấu hiệu điển hình khi bị các loại côn trùng chích hút như rầy, rệp tấn công.",
                Icons.architecture_outlined,
              ),

              const SizedBox(height: 25),

              // 5. PHẦN 2: QUAN SÁT TỔNG THỂ 🔬
              Row(
                children: [
                  const Text("🔬", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text("2. Kiểm tra thân và rễ", 
                    style: GoogleFonts.roboto(fontSize: 19, fontWeight: FontWeight.bold, color: textDark)),
                ],
              ),
              const SizedBox(height: 21),

              _buildInfoCard(
                "Vết loét trên thân",
                "Thân cây xuất hiện các vết nứt chảy nhựa hoặc có màu tối khác thường. Cần kiểm tra ngay vì bệnh nấm thân lan rất nhanh.",
                Icons.warning_amber_rounded,
              ),
              _buildInfoCard(
                "Hiện tượng héo rũ",
                "Cây bị héo đột ngột vào ban ngày nhưng tươi lại vào ban đêm. Đây có thể là dấu hiệu rễ đang bị thối hoặc bị tuyến trùng tấn công.",
                Icons.sledding_outlined,
              ),

              const SizedBox(height: 15),

              // 6. KHỐI LƯU Ý
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: bgNoteColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryGreen.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined, color: primaryGreen),
                        const SizedBox(width: 10),
                        Text("Mẹo quan sát", 
                          style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                      ],
                    ),
                    const SizedBox(height: 21),
                    _buildBulletPoint("Nên kiểm tra vườn vào sáng sớm, lúc ánh sáng rõ nhất để thấy màu sắc lá thật."),
                    _buildBulletPoint("Luôn lật mặt dưới của lá vì đó là nơi cư trú ưa thích của sâu non và trứng côn trùng."),
                    _buildBulletPoint("Sử dụng tính năng Scan của PlantAI ngay khi thấy một vết đốm lạ dù là nhỏ nhất."),
                    _buildBulletPoint("Dùng kính lúp nếu cần thiết để soi kỹ các kẽ lá và ngọn non.", isLast: true),
                  ],
                ),
              ),
              
              const SizedBox(height: 45),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 21),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgTagColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF8DAA5B), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF8DAA5B))),
                const SizedBox(height: 8),
                Text(content, style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF334155), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8, height: 8,
            decoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF334155), height: 1.5))),
        ],
      ),
    );
  }
}