import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoffeeRustScreen extends StatefulWidget {
  const CoffeeRustScreen({Key? key}) : super(key: key);

  @override
  State<CoffeeRustScreen> createState() => _CoffeeRustScreenState();
}

class _CoffeeRustScreenState extends State<CoffeeRustScreen> {
  // Trạng thái quản lý Tab hiện tại (0: Triệu chứng, 1: Nguyên nhân, 2: Phòng ngừa, 3: Điều trị)
  int _selectedTabIndex = 0;

  final List<String> _tabs = ["Triệu chứng", "Nguyên nhân", "Phòng ngừa", "Điều trị"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // Mở rộng body lên trên AppBar để làm hiệu ứng ảnh tràn viền
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoGrid(),
                  const SizedBox(height: 25),
                  _buildOverviewSection(),
                  const SizedBox(height: 25),
                  _buildCustomTabBar(),
                  const SizedBox(height: 20),
                  _buildTabContent(),
                  const SizedBox(height: 40), // Spacing ở cuối trang
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER: ẢNH VÀ TIÊU ĐỀ ---
  Widget _buildHeaderImage() {
    return Stack(
      children: [
        // Ảnh nền (Thay URL bằng ảnh thực tế của ông hoặc AssetImage)
        // Đã chuyển thành Image.asset để load ảnh Offline
        Image.asset(
          'assets/Plant/coffee-leaf-rust.jpg',
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // Lớp phủ Gradient để đọc chữ dễ hơn
        Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),
        // Text tiêu đề nằm đè lên ảnh
        Positioned(
          bottom: 25,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bệnh rỉ sắt",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Coffee Leaf Rust",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 4 Ô THÔNG TIN (INFO GRID) ---
  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.access_time, "Thời gian lây lan", "5-7 ngày", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.adjust, "Cây bị ảnh hưởng", "Cà phê", const Color(0xFF8DAA5B))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.eco_outlined, "Mùa xuất hiện", "Mùa mưa", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.warning_amber_rounded, "Mức độ nguy hiểm", "Cao", const Color(0xFF8DAA5B))),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TỔNG QUAN ---
  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tổng quan",
            style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Text(
            "Bệnh đốm lá sắt là một trong những bệnh phổ biến và nguy hiểm nhất trên cây cà phê. Bệnh chủ yếu gây hại trên lá, làm giảm khả năng quang hợp của cây và dẫn đến rụng lá sớm. Khi bệnh phát triển mạnh, cây cà phê sẽ suy yếu và năng suất giảm đáng kể. Bệnh thường xuất hiện trong điều kiện thời tiết ẩm ướt, đặc biệt là vào mùa mưa khi độ ẩm không khí cao. Nếu không được phát hiện và xử lý kịp thời, bệnh có thể lây lan nhanh trong vườn cà phê và gây thiệt hại lớn cho sản xuất.",
            style: GoogleFonts.roboto(fontSize: 15, color: Colors.grey.shade600, height: 1.6),
          ),
        ],
      ),
    );
  }

  // --- THANH TAB BAR CUSTOM ---
  Widget _buildCustomTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Màu xám nhạt nền
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- HIỂN THỊ NỘI DUNG THEO TAB ĐANG CHỌN ---
  Widget _buildTabContent() {
    if (_selectedTabIndex == 0) return _buildSymptomsTab();
    if (_selectedTabIndex == 1) return _buildCausesTab();
    if (_selectedTabIndex == 2) return _buildPreventionTab();
    if (_selectedTabIndex == 3) return _buildTreatmentTab();
    return const SizedBox.shrink();
  }

  // 1. Tab Triệu chứng
  Widget _buildSymptomsTab() {
    return _buildContentCard(
      title: "Triệu chứng nhận biết",
      icon: Icons.error_outline,
      iconBgColor: const Color(0xFFEDF7ED), // Xanh lá rất nhạt
      iconColor: const Color(0xFF5F8B48),
      bullets: [
        "Xuất hiện các đốm nhỏ màu vàng nhạt ở mặt trên của lá.",
        "Mặt dưới của lá có lớp bột màu cam hoặc màu gỉ sắt.",
        "Các đốm bệnh lan rộng và hợp lại thành mảng lớn.",
        "Lá bị vàng và rụng sớm.",
        "Khi bệnh nặng có thể làm cây suy yếu và giảm năng suất từ 30-50%.",
      ],
    );
  }

  // 2. Tab Nguyên nhân (Demo trống)
  Widget _buildCausesTab() {
    return _buildContentCard(
      title: "Nguyên nhân gây bệnh",
      icon: Icons.bug_report_outlined,
      iconBgColor: const Color(0xFFFFF4E5), 
      iconColor: const Color(0xFFED6C02),
      bullets: [
        "Do nấm Hemileia vastatrix gây ra.",
        "Bào tử nấm phát tán qua gió, nước mưa và côn trùng.",
        "Bệnh phát triển mạnh trong điều kiện độ ẩm cao và nhiệt độ 20-28°C.",
        "Vườn cà phê trồng quá dày, thiếu ánh sáng dễ làm bệnh phát triển.",
      ],
    );
  }

  // 3. Tab Phòng ngừa
  Widget _buildPreventionTab() {
    return _buildContentCard(
      title: "Biện pháp phòng ngừa",
      icon: Icons.shield_outlined,
      iconBgColor: const Color(0xFFEDF7ED),
      iconColor: const Color(0xFF5F8B48),
      bullets: [
        "Trồng giống cà phê có khả năng kháng bệnh gỉ sắt.",
        "Tạo độ thông thoáng cho vườn cây bằng cách tỉa cành và trồng với khoảng cách hợp lý.",
        "Bón phân cân đối, tăng cường kali và lân để tăng sức đề kháng cho cây.",
        "Xử lý hạt giống bằng thuốc sát trùng trước khi gieo",
        "Thu gom và tiêu hủy lá bệnh để hạn chế nguồn lây lan",
      ],
    );
  }

  // 4. Tab Điều trị
  Widget _buildTreatmentTab() {
    return _buildContentCard(
      title: "Phương pháp điều trị",
      icon: Icons.local_florist_outlined,
      iconBgColor: const Color(0xFFEDF7ED),
      iconColor: const Color(0xFF5F8B48),
      bullets: [
        "Phun thuốc kháng sinh Streptomycin 200ppm khi phát hiện bệnh",
        "Sử dụng đồng oxychloride 50% với liều lượng 3g/lít nước",
        "Phun 2-3 lần cách nhau khoảng 10-14 ngày.",
        "Cắt bỏ phần lá bị bệnh nặng và tiêu hủy",
        "Tăng cường bón phân lân, kali để cây phục hồi nhanh",
      ],
    );
  }

  // --- HÀM TẠO CARD CHUNG CHO CÁC TAB ---
  Widget _buildContentCard({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required List<String> bullets,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Duyệt mảng data để tạo các gạch đầu dòng
          ...bullets.map((text) => _buildBulletPoint(text)).toList(),
        ],
      ),
    );
  }

  // --- HÀM TẠO 1 DÒNG BULLET POINT ---
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF8DAA5B), // Màu xanh dấu chấm
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded( 
            child: Text(
              text,
              style: GoogleFonts.roboto(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}