import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/API/HandbookAPI.dart'; // Đổi lại đường dẫn UserAPI của ông cho đúng nhé

class ArticleDetailScreen extends StatefulWidget {
  final String id; // Nhận đúng cái ID từ HomeScreen

  const ArticleDetailScreen({super.key, required this.id});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  static const Color primaryGreen = Color(0xFF8DAA5B);
  static const Color bgTagColor = Color(0xFFF1F5EB);
  static const Color bgNoteColor = Color(0xFFF4F6F0);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGray = Color(0xFF64748B);
  static const Color bodyTextColor = Color(0xFF334155);

  bool _isLoading = true;
  Map<String, dynamic>? _handbookData;

  @override
  void initState() {
    super.initState();
    _fetchHandbookDetail(); // Vừa vào màn hình là gọi API luôn
  }

  Future<void> _fetchHandbookDetail() async {
    var data = await HandbookAPI.getHandbookById(widget.id); // Lấy data theo ID
    if (mounted) {
      setState(() {
        _handbookData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đang tải dữ liệu -> Hiện vòng xoay
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFDFDFD),
        body: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }

    // Lỗi không có dữ liệu
    if (_handbookData == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Không thể tải bài viết này!")),
      );
    }

    // --- BÓC TÁCH DỮ LIỆU ---
    final String title = _handbookData!['title'] ?? '';
    final String category = _handbookData!['category'] ?? '';
    final String date = _handbookData!['publishDate'] ?? '';
    final String contentJson = _handbookData!['content'] ?? '';

    // Giải mã cục JSON Content
    Map<String, dynamic> contentMap = {};
    try {
      if (contentJson.isNotEmpty) {
        contentMap = jsonDecode(contentJson);
      }
    } catch (e) {
      debugPrint("Lỗi parse JSON: $e");
    }

    String intro = contentMap['intro'] ?? '';
    List<dynamic> sections = contentMap['sections'] ?? [];
    List<String> tipsList = List<String>.from(contentMap['tips'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text("Cẩm nang", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TAG
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: bgTagColor, borderRadius: BorderRadius.circular(20)),
              child: Text(category, style: GoogleFonts.roboto(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 20),

            // TIÊU ĐỀ
            Text(title, style: GoogleFonts.roboto(fontSize: 26, fontWeight: FontWeight.bold, color: textDark, height: 1.25)),
            const SizedBox(height: 14),

            // NGÀY
            Text(date, style: GoogleFonts.roboto(fontSize: 14, color: textGray)),
            const SizedBox(height: 20),

            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 18),

            // ĐOẠN INTRO
            if (intro.isNotEmpty) ...[
              Text(intro, style: GoogleFonts.roboto(fontSize: 15, color: bodyTextColor, height: 1.7)),
              const SizedBox(height: 28),
            ],

            // CÁC MỤC (SECTIONS)
            ...sections.map((sec) {
              String sectionTitle = sec['sectionTitle'] ?? '';
              List<dynamic> diseases = sec['diseases'] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sectionTitle.isNotEmpty) ...[
                    Text(sectionTitle, style: GoogleFonts.roboto(fontSize: 19, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 18),
                  ],
                  ...diseases.map((dis) {
                    String diseaseName = dis['diseaseName'] ?? '';
                    List<String> lines = List<String>.from(dis['lines'] ?? []);
                    return _buildSimpleDiseaseItem(diseaseName, lines);
                  }).toList(),
                  const SizedBox(height: 6),
                ],
              );
            }).toList(),

            const SizedBox(height: 18),

            // BOX MẸO
            if (tipsList.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: bgNoteColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mẹo từ PlantAI", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 18),
                    ...tipsList.asMap().entries.map((entry) {
                      return _buildBulletPoint(entry.value, isLast: entry.key == tipsList.length - 1);
                    }).toList(),
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
          Text("•  $title", style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700, color: primaryGreen)),
          const SizedBox(height: 8),
          ...lines.map((line) => Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 6),
            child: Text(line, style: GoogleFonts.roboto(fontSize: 15, color: bodyTextColor, height: 1.6)),
          )),
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
          Container(margin: const EdgeInsets.only(top: 8), width: 7, height: 7, decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.roboto(fontSize: 15, color: bodyTextColor, height: 1.6))),
        ],
      ),
    );
  }
}