import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  static const Color primaryGreen = Color(0xFF8DAA5B);
  static const Color bgTagColor = Color(0xFFF1F5EB);
  static const Color bgNoteColor = Color(0xFFF4F6F0);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);
  static const Color bodyTextColor = Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          "Cẩm nang",
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TAG
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgTagColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Phòng trừ bệnh",
                style: GoogleFonts.roboto(
                  color: primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // TITLE
            Text(
              "Bí quyết phòng bệnh mùa mưa\ncho cây lúa và cây cà phê",
              style: GoogleFonts.roboto(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

            // DATE ONLY
            Text(
              "26/03/2026",
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: textGray,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),

            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 18),

            // INTRO
            Text(
              "Mùa mưa là thời điểm các loại nấm và vi khuẩn phát triển mạnh mẽ nhất. "
"Dưới đây là hướng dẫn phòng ngừa các loại bệnh phổ biến mà PlantAI có thể nhận diện.",
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: bodyTextColor,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),

            // SECTION 1
            Text(
              "1. Phòng bệnh cho cây lúa",
              style: GoogleFonts.roboto(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 18),

            _buildSimpleDiseaseItem(
              "Bệnh đạo ôn",
              [
                "Tránh bón thừa phân đạm vào mùa mưa.",
                "Giữ mực nước ổn định và xử lý ngay khi có dấu hiệu.",
              ],
            ),
            _buildSimpleDiseaseItem(
              "Bệnh đốm nâu",
              [
                "Cải thiện đất và bón phân cân đối.",
                "Vệ sinh đồng ruộng trước khi gieo.",
              ],
            ),
            _buildSimpleDiseaseItem(
              "Bọ gai hại lúa",
              [
                "Thường xuyên thăm đồng để phát hiện sớm.",
                "Dọn cỏ quanh ruộng.",
              ],
            ),
            _buildSimpleDiseaseItem(
              "Bệnh bỏng lá",
              [
                "Tăng cường khả năng thoát nước cho ruộng.",
                "Sử dụng giống có khả năng chống chịu tốt.",
              ],
            ),

            const SizedBox(height: 24),

            // SECTION 2
            Text(
              "2. Phòng bệnh cho cây cà phê",
              style: GoogleFonts.roboto(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 18),

            _buildSimpleDiseaseItem(
              "Sâu vẽ bùa",
              [
                "Tỉa cành để cây thông thoáng.",
                "Bảo vệ thiên địch tự nhiên trong vườn.",
              ],
            ),
            _buildSimpleDiseaseItem(
              "Bệnh Phoma",
              [
                "Kiểm soát mật độ cây trồng.",
                "Phun phòng bằng thuốc gốc đồng khi bắt đầu mùa mưa.",
              ],
            ),
            _buildSimpleDiseaseItem(
              "Rỉ sắt cà phê",
              [
                "Sử dụng giống kháng bệnh.",
                "Thu gom lá bệnh và xử lý định kỳ.",
              ],
            ),

            const SizedBox(height: 26),

            // NOTE BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: bgNoteColor,
borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mẹo từ PlantAI",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildBulletPoint(
                    "Sử dụng tính năng Scan mỗi 3 ngày để phát hiện sớm.",
                  ),
                  _buildBulletPoint(
                    "Lưu hình ảnh để theo dõi tiến triển.",
                  ),
                  _buildBulletPoint(
                    "Bón phân cân đối, tránh lạm dụng đạm.",
                  ),
                  _buildBulletPoint(
                    "Tham khảo ý kiến chuyên gia khi cần.",
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleDiseaseItem(String title, List<String> lines) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•  $title",
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(left: 26, bottom: 6),
              child: Text(
                line,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: bodyTextColor,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: bodyTextColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}