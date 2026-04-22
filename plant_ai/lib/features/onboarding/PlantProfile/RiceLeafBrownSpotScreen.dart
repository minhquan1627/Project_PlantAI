import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiceBrownSpotScreen extends StatefulWidget {
  const RiceBrownSpotScreen({Key? key}) : super(key: key);

  @override
  State<RiceBrownSpotScreen> createState() => _RiceBrownSpotScreenState();
}

class _RiceBrownSpotScreenState extends State<RiceBrownSpotScreen> {
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
        // Ảnh nền Đốm Nâu (Ông nhớ thêm ảnh vào thư mục assets/Plant)
        Image.asset(
          'assets/Plant/RiceLeaf_BrownSpot1.jpg', // 🚀 ĐỔI TÊN ẢNH CHO ĐÚNG BỆNH ĐỐM NÂU NHÉ
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
                      "Bệnh đốm nâu",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Brown Spot (Bipolaris oryzae)",
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
            Expanded(child: _buildInfoCard(Icons.grass_outlined, "Giai đoạn hại", "Mọi giai đoạn", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.adjust, "Cây bị ảnh hưởng", "Cây lúa", const Color(0xFF8DAA5B))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.water_drop_outlined, "Điều kiện", "Đất khô, phèn", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.warning_amber_rounded, "Nguyên nhân", "Nấm bệnh", const Color(0xFF8DAA5B))),
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
            "Bệnh đốm nâu (Brown Spot) do nấm Bipolaris oryzae gây ra, được coi là căn bệnh đặc trưng của 'sự nghèo đói' trên cây lúa. Bệnh thường bùng phát cực kỳ mạnh ở những vùng đất xấu, đất phèn, đất nghèo dinh dưỡng (đặc biệt thiếu Kali và Silic) hoặc khi ruộng lúa bị khô hạn, thiếu nước. Nấm bệnh có thể tấn công ở mọi giai đoạn sinh trưởng của lúa từ khi gieo mạ đến khi trỗ chín, làm lá khô cháy, hạt lép lửng và giảm năng suất cũng như chất lượng gạo nghiêm trọng.",
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
    return Column(
      children: [
        _buildContentCard(
          title: "Triệu chứng nhận biết",
          icon: Icons.search_rounded,
          iconBgColor: const Color(0xFFEDF7ED), // Xanh lá rất nhạt
          iconColor: const Color(0xFF5F8B48),
          bullets: [
            "Vết bệnh ban đầu là những chấm nhỏ li ti màu nâu nhạt.",
            "Sau đó vết bệnh phát triển to ra thành hình bầu dục (như hạt vừng), kích thước bằng cỡ nửa hạt gạo.",
            "Vết bệnh điển hình có tâm màu xám trắng, viền ngoài màu nâu đỏ đậm, và xung quanh có quầng màu vàng nhạt bao quanh.",
            "Khi bị nhiễm nặng, nhiều đốm kết hợp lại với nhau làm cho toàn bộ lá bị cháy khô từ chóp lá xuống.",
            "Trên hạt lúa, vết bệnh lây sang vỏ trấu tạo thành những đốm màu nâu hoặc đen, làm hạt bị lem lép, giảm tỷ lệ nảy mầm và chất lượng gạo đục.",
          ],
        ),
      ],
    );
  }

  // 2. Tab Nguyên nhân
  Widget _buildCausesTab() {
    return _buildContentCard(
      title: "Nguyên nhân gây hại",
      icon: Icons.bug_report_outlined,
      iconBgColor: const Color(0xFFFFF4E5), 
      iconColor: const Color(0xFFED6C02),
      bullets: [
        "Tác nhân chính là do nấm Bipolaris oryzae (tên gọi cũ là Helminthosporium oryzae) xâm nhiễm vào tế bào cây.",
        "Bào tử nấm thường truyền qua hạt giống bị nhiễm bệnh từ vụ trước hoặc lây lan qua gió và nước.",
        "Ruộng lúa bị khô hạn, thiếu nước làm rễ bị suy yếu, rễ thâm đen không hút được chất dinh dưỡng.",
        "Đất trồng là đất xám, đất phèn chua, đất cát nghèo chất hữu cơ, đặc biệt là thiếu hụt vi lượng Kali (K) và Silic (Si).",
        "Nhiệt độ tối ưu để bệnh phát sinh mạnh nhất là từ 20°C đến 30°C với độ ẩm không khí cao.",
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
        "Dùng hạt giống sạch bệnh, hạt giống xác nhận. Trước khi gieo ngâm ủ hạt giống qua nước ấm 54°C trong 10 phút.",
        "Xử lý đất kỹ trước khi sạ: cày ải phơi đất, bón lót vôi bột để hạ phèn và khử chua.",
        "Cung cấp đủ nước cho ruộng, tuyệt đối không để ruộng bị khô hạn nứt nẻ dài ngày.",
        "Bón phân cân đối N-P-K. Hạn chế bón lai rai dư đạm, cần tăng cường bón phân hữu cơ và bổ sung phân Kali, Silic, Canxi giúp vách tế bào cứng cáp.",
        "Vệ sinh đồng ruộng sạch sẽ, dọn dẹp cỏ dại và cày vùi rơm rạ ngay sau vụ thu hoạch để diệt mầm bệnh tồn dư.",
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
        "Khi ruộng mới chớm bệnh và phát hiện ruộng khô nước, cần cấp nước ngay lập tức vào ruộng.",
        "Ngưng bón phân Đạm. Phun bổ sung các loại phân bón qua lá giàu vi lượng (Kali, Kẽm, Canxi, Silic) để cây lúa nhanh chóng phục hồi bộ rễ.",
        "Sử dụng các loại thuốc bảo vệ thực vật trừ nấm có chứa các hoạt chất: Propiconazole, Difenoconazole, Tebuconazole hoặc Mancozeb.",
        "Nên phun thuốc vào buổi chiều mát hoặc sáng sớm lúc lá lúa đã ráo sương.",
        "Phun đúng liều lượng chỉ định trên bao bì và có thể phun lặp lại lần 2 cách nhau khoảng 7 ngày nếu bệnh quá nặng.",
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