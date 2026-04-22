import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiceBlastScreen extends StatefulWidget {
  const RiceBlastScreen({Key? key}) : super(key: key);

  @override
  State<RiceBlastScreen> createState() => _RiceBlastScreenState();
}

class _RiceBlastScreenState extends State<RiceBlastScreen> {
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
        Image.asset(
          'assets/Plant/RiceBlast2.jpg',
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 320, width: double.infinity, color: Colors.grey[800],
            child: const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 50)),
          ),
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
                      "Bệnh đạo ôn",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rice Blast (Pyricularia oryzae)",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
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
            Expanded(child: _buildInfoCard(Icons.access_time, "Thời gian ủ bệnh", "3-5 ngày", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.adjust, "Cây bị ảnh hưởng", "Cây lúa", const Color(0xFF8DAA5B))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.cloud_outlined, "Mùa xuất hiện", "Sương mù, ẩm cao", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.warning_amber_rounded, "Mức độ nguy hiểm", "Cấp tính", const Color(0xFF8DAA5B))),
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
                  style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
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
            "Bệnh đạo ôn (Rice Blast) được coi là một trong những loại bệnh nguy hiểm nhất đối với cây lúa trên toàn thế giới. Bệnh do nấm gây ra, có thể tấn công hầu hết các bộ phận của cây lúa từ lá, đốt thân, cổ bông cho đến hạt. Trong điều kiện thời tiết thuận lợi (sương mù, ẩm ướt, chênh lệch nhiệt độ ngày đêm cao), bệnh lây lan như một trận dịch, làm cháy trụi cả cánh đồng (đạo ôn lá) hoặc gây gãy cổ bông, lép hạt (đạo ôn cổ bông), dẫn đến mất trắng năng suất.",
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
      icon: Icons.search_rounded,
      iconBgColor: const Color(0xFFEDF7ED), // Xanh lá rất nhạt
      iconColor: const Color(0xFF5F8B48),
      bullets: [
        "Trên lá (Đạo ôn lá): Vết bệnh ban đầu là những chấm nhỏ bằng đầu kim màu xám xanh.",
        "Sau đó, đốm lớn dần có hình thoi (mắt én), tâm màu xám trắng, viền màu nâu đậm.",
        "Các vết bệnh nối liền nhau làm lá bị cháy khô (bệnh sụp mặt én).",
        "Trên cổ bông (Đạo ôn cổ bông): Cổ bông lúa bị thối khô, chuyển màu nâu xám, dễ gãy gập.",
        "Bông lúa không thụ phấn được, hạt bị lép trắng hoàn toàn nếu nhiễm bệnh sớm.",
      ],
    );
  }

  // 2. Tab Nguyên nhân
  Widget _buildCausesTab() {
    return _buildContentCard(
      title: "Nguyên nhân gây bệnh",
      icon: Icons.bug_report_outlined,
      iconBgColor: const Color(0xFFFFF4E5), 
      iconColor: const Color(0xFFED6C02),
      bullets: [
        "Do nấm Pyricularia oryzae (hoặc Magnaporthe oryzae) xâm nhập và phá hủy tế bào cây.",
        "Bào tử nấm lây lan rất nhanh qua gió và nước.",
        "Bệnh phát triển mạnh nhất khi trời âm u, ít nắng, có sương mù dày, mưa phùn rải rác.",
        "Bón thừa phân Đạm (Nitơ) làm lá lúa mềm mỏng, tạo điều kiện thuận lợi cho nấm bệnh xâm nhập.",
        "Mật độ gieo sạ quá dày khiến nương lúa thiếu độ thông thoáng.",
      ],
    );
  }

  // 3. Tab Phòng ngừa
  Widget _buildPreventionTab() {
    return _buildContentCard(
      title: "Biện pháp phòng ngừa",
      icon: Icons.shield_outlined,
      iconBgColor: const Color(0xFFE3F2FD), // Xanh dương nhạt
      iconColor: const Color(0xFF1976D2),
      bullets: [
        "Sử dụng các giống lúa có khả năng kháng bệnh đạo ôn cao.",
        "Gieo sạ với mật độ vừa phải (100 - 120 kg lúa giống/ha) để ruộng thông thoáng.",
        "Bón phân N-P-K cân đối, không bón thừa đạm, đặc biệt bón rước đòng đúng thời điểm.",
        "Vệ sinh đồng ruộng sạch sẽ, dọn sạch tàn dư rơm rạ và cỏ dại mang mầm bệnh từ vụ trước.",
        "Thường xuyên thăm đồng, đặc biệt vào những ngày thời tiết âm u, có sương mù.",
      ],
    );
  }

  // 4. Tab Điều trị
  Widget _buildTreatmentTab() {
    return _buildContentCard(
      title: "Phương pháp điều trị",
      icon: Icons.medical_services_outlined,
      iconBgColor: const Color(0xFFFFEBEE), // Đỏ nhạt
      iconColor: const Color(0xFFD32F2F),
      bullets: [
        "Ngừng ngay việc bón phân đạm và không phun phân bón lá khi phát hiện vết bệnh đầu tiên.",
        "Giữ mực nước trong ruộng ổn định (khoảng 3-5cm) để cây lúa không bị suy yếu thêm.",
        "Phun thuốc đặc trị có hoạt chất Tricyclazole, Isoprothiolane, hoặc Fenoxanil.",
        "Nên phun thuốc vào buổi sáng sớm (khi lá đã ráo sương) hoặc chiều mát.",
        "Nếu bệnh nặng, phun lặp lại lần 2 sau 5-7 ngày. Đối với đạo ôn cổ bông, cần phun phòng lúc lúa trổ lác đác (5%) và trổ đều.",
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