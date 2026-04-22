import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class  Diseasecontroldetailscreen extends StatelessWidget {
  const Diseasecontroldetailscreen ({super.key});

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
                    Icon(Icons.eco_outlined, size: 16, color: primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      "Kỹ thuật canh tác",
                      style: GoogleFonts.roboto(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 21),

              // 2. TIÊU ĐỀ
              Text(
                "Kỹ thuật bón phân hữu cơ hiệu quả giúp tăng năng suất và cải tạo đất",
                style: GoogleFonts.roboto(fontSize: 26, fontWeight: FontWeight.bold, color: textDark, height: 1.3),
              ),
              const SizedBox(height: 25),

              // 3. SAPO
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_stories_outlined, color: primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Bón phân hữu cơ không chỉ cung cấp dinh dưỡng thiết yếu mà còn giúp cải thiện độ tơi xốp và hệ vi sinh vật trong đất. Hãy cùng PlantAI tìm hiểu cách bón đúng kỹ thuật.",
                      style: GoogleFonts.roboto(fontSize: 15, color: const Color(0xFF334155), height: 1.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // 4. PHẦN 1: CÁC LOẠI PHÂN HỮU CƠ 💩
              Row(
                children: [
                  const Text("🪵", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text("1. Các loại phân hữu cơ phổ biến", 
                    style: GoogleFonts.roboto(fontSize: 19, fontWeight: FontWeight.bold, color: textDark)),
                ],
              ),
              const SizedBox(height: 21),
              
              _buildInfoCard(
                "Phân chuồng hoai mục",
                "Chứa đầy đủ các nguyên tố đa lượng. Cần được ủ hoai kỹ với nấm Trichoderma để tiêu diệt mầm bệnh trước khi bón.",
                Icons.pets_outlined,
              ),
              _buildInfoCard(
                "Phân xanh",
                "Sử dụng các loại cây họ đậu vùi trực tiếp vào đất. Giúp bổ sung lượng đạm tự nhiên cực lớn và giữ ẩm cho đất.",
                Icons.grass,
              ),
              _buildInfoCard(
                "Phân hữu cơ vi sinh",
                "Sản phẩm chế biến công nghiệp chứa các chủng vi sinh có lợi. Giúp phân giải các chất khó tan trong đất thành dạng dễ hấp thụ.",
                Icons.biotech_outlined,
              ),

              const SizedBox(height: 25),

              // 5. PHẦN 2: PHƯƠNG PHÁP BÓN 🛠️
              Row(
                children: [
                  const Text("🛠️", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text("2. Phương pháp bón đúng cách", 
                    style: GoogleFonts.roboto(fontSize: 19, fontWeight: FontWeight.bold, color: textDark)),
                ],
              ),
              const SizedBox(height: 21),

              _buildInfoCard(
                "Bón lót (Trước khi trồng)",
                "Trộn đều phân với đất ở tầng mặt hoặc bón xuống hố. Giúp cây có nguồn dinh dưỡng dự trữ ngay khi vừa bén rễ.",
                Icons.layers_outlined,
              ),
              _buildInfoCard(
                "Bón thúc (Trong quá trình lớn)",
                "Bón quanh gốc theo tán cây, sau đó xới nhẹ và lấp đất. Tránh bón trực tiếp vào sát gốc gây xót rễ.",
                Icons.trending_up_rounded,
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
                        Icon(Icons.lightbulb_outline, color: primaryGreen),
                        const SizedBox(width: 10),
                        Text("Lưu ý từ chuyên gia", 
                          style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                      ],
                    ),
                    const SizedBox(height: 21),
                    _buildBulletPoint("Nên bón phân hữu cơ vào sáng sớm hoặc chiều mát."),
                    _buildBulletPoint("Sau khi bón cần tưới nước nhẹ để phân tan và thấm vào đất."),
                    _buildBulletPoint("Không nên bón phân tươi chưa qua xử lý vì dễ gây nấm rễ."),
                    _buildBulletPoint("Kết hợp phân hữu cơ với phân vô cơ theo tỷ lệ hợp lý để đạt hiệu quả cao nhất.", isLast: true),
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
            child: Icon(icon, color: const Color(0xFF8DAA5B), size: 22), // Đã sửa lỗi viết hoa icon
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