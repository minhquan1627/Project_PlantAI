import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantSearchOverlay extends StatefulWidget {
  final String? initialKeyword;
  const PlantSearchOverlay({super.key, this.initialKeyword});

  @override
  State<PlantSearchOverlay> createState() => _PlantSearchOverlayState();
}

class _PlantSearchOverlayState extends State<PlantSearchOverlay> {
  late TextEditingController _controller;
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;
  bool _hasInput = false;

  // 🚀 TỪ ĐIỂN DATA: Gom toàn bộ dữ liệu cây và bệnh vào đây để tìm kiếm siêu tốc
  final List<Map<String, String>> _allData = [
    {"title": "Bệnh bỏng lá lúa", "type": "Cây lúa"},
    {"title": "Bệnh đạo ôn", "type": "Cây lúa"},
    {"title": "Bọ gai hại lúa", "type": "Cây lúa"},
    {"title": "Bệnh Đốm Nâu", "type": "Cây lúa"},
    {"title": "Miner", "type": "Cây cà phê"},
    {"title": "Rỉ sắt cà phê", "type": "Cây cà phê"},
    {"title": "Bệnh Phoma", "type": "Cây cà phê"},
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKeyword ?? "");
    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
       _onSearchChanged(widget.initialKeyword!);
    }
  }

  // 💡 HÀM CHUYỂN TIẾNG VIỆT (ĐÃ ĐƯỢC SỬA LỖI CHIỀU DÀI CHUỖI 100% CHÍNH XÁC)
  String _removeAccents(String str) {
    const withDia = 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴĐ';
    const withoutDia = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str.toLowerCase();
  }

  // --- LOGIC TÌM KIẾM ĐA CHIỀU ---
  void _onSearchChanged(String query) {
    setState(() {
      _hasInput = query.trim().isNotEmpty;
    });

    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    // Chuẩn hóa từ khóa người dùng nhập (Cắt khoảng trắng, bỏ dấu, in thường)
    String normalizedQuery = _removeAccents(query.trim());

    // Bộ lọc: Tìm trong tên bệnh (title) HOẶC tên cây (type)
    List<Map<String, String>> results = _allData.where((item) {
      String title = _removeAccents(item['title']!);
      String type = _removeAccents(item['type']!);

      // Nếu từ khóa xuất hiện trong Tên bệnh hoặc Tên loại cây -> Lấy!
      return title.contains(normalizedQuery) || type.contains(normalizedQuery);
    }).toList();

    // Giả lập độ trễ 0.2s cho mượt mà UX
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      }
    });
  }

  void _selectItem(String value) {
    Navigator.pop(context, value); // Trả về tên bệnh khi được chọn
  }

  void _cancelSearch() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Thanh tìm kiếm
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                  color: const Color(0xFFF2FDEB).withOpacity(0.9), 
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFF80A252), width: 1),
                          ),
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: _onSearchChanged,
                            style: GoogleFonts.roboto(color: Colors.black87, fontSize: 14), 
                            decoration: InputDecoration(
                              hintText: "Tìm kiếm loại bệnh",
                              hintStyle: GoogleFonts.roboto(color: Colors.grey[400], fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF80A252), size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                      onPressed: () {
                                        _controller.clear();
                                        _onSearchChanged("");
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _cancelSearch,
                        child: Text(
                          "Hủy",
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF80A252),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // Danh sách kết quả
                Expanded(
                  child: !_hasInput
                      ? const SizedBox() 
                      : Container(
                          color: Colors.white, 
                          width: double.infinity,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator(color: Color(0xFF80A252)))
                              : _suggestions.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.search_off, size: 40, color: Colors.grey),
                                          const SizedBox(height: 10),
                                          Text("Không tìm thấy kết quả phù hợp", style: GoogleFonts.roboto(color: Colors.grey)),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      itemCount: _suggestions.length,
                                      separatorBuilder: (ctx, index) => const Divider(height: 1, indent: 60, endIndent: 20, color: Color(0xFFEEEEEE)),
                                      itemBuilder: (ctx, index) {
                                        final item = _suggestions[index];
                                        final plantName = item['title']!;
                                        final plantType = item['type']!;
                                        
                                        IconData leadIcon = plantType == "Cây cà phê" ? Icons.coffee : Icons.grass;

                                        return ListTile(
                                          onTap: () => _selectItem(plantName),
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2FDEB),
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Icon(leadIcon, color: const Color(0xFF80A252), size: 20),
                                          ),
                                          // 🚀 THÊM .trim() VÀO ĐÂY ĐỂ NGĂN LỖI HIỂN THỊ KHI GÕ KHOẢNG TRẮNG
                                          title: _buildBoldText(plantName, _controller.text.trim()),
                                          subtitle: Text(plantType, style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                                          trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
                                        );
                                      },
                                    ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Giữ nguyên hàm bôi đậm từ khóa
  Widget _buildBoldText(String fullText, String query) {
    if (query.isEmpty) return Text(fullText, style: GoogleFonts.roboto(color: Colors.black87, fontWeight: FontWeight.w500));
    final List<TextSpan> spans = [];
    final String lowerFullText = _removeAccents(fullText);
    final String lowerQuery = _removeAccents(query);
    int start = 0;
    int indexOfHighlight;
    
    while ((indexOfHighlight = lowerFullText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: fullText.substring(start, indexOfHighlight), style: GoogleFonts.roboto(color: Colors.black87, fontWeight: FontWeight.w500)));
      }
      spans.add(TextSpan(text: fullText.substring(indexOfHighlight, indexOfHighlight + query.length), style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: const Color(0xFF80A252)))); 
      start = indexOfHighlight + query.length;
    }
    if (start < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(start), style: GoogleFonts.roboto(color: Colors.black87, fontWeight: FontWeight.w500)));
    }
    return RichText(text: TextSpan(children: spans));
  }
}