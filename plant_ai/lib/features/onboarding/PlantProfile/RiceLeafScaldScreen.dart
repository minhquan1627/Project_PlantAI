import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiceLeafScaldScreen extends StatefulWidget {
  const RiceLeafScaldScreen({Key? key}) : super(key: key);

  @override
  State<RiceLeafScaldScreen> createState() => _RiceLeafScaldScreenState();
}

class _RiceLeafScaldScreenState extends State<RiceLeafScaldScreen> {
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
        // Ảnh nền bệnh Vàng Còi/Cháy Bìa (Ông nhớ thêm ảnh vào thư mục assets/Plant)
        Image.asset(
          'assets/Plant/RiceLeaf_Scald1.jpg', // 🚀 ĐỔI TÊN ẢNH CHO ĐÚNG BỆNH NHÉ
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
                      "Bệnh Bỏng Lá Lúa",
                      style: GoogleFonts.roboto(
                        fontSize: 26, // Giảm xíu cho vừa chữ
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Leaf Scald (Monographella albescens)",
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
            Expanded(child: _buildInfoCard(Icons.grass_outlined, "Giai đoạn hại", "Làm đòng - Trỗ", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.adjust, "Bộ phận hại", "Chóp và mép lá", const Color(0xFF8DAA5B))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.cloud_outlined, "Điều kiện", "Mưa dầm, sương mù", const Color(0xFF8DAA5B))),
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
            "Bệnh Leaf Scald (thường gọi là Vàng còi hay Cháy bìa lá do nấm) là một trong những bệnh hại lá phổ biến ở lúa mùa mưa. Bệnh do nấm Monographella albescens gây ra, biểu hiện đặc trưng là những vùng lá bị cháy khô từ chóp hoặc mép lá lan dần vào trong, với các đường vân đồng tâm rất đẹp (nhưng cực kỳ độc hại). Bệnh làm giảm diện tích quang hợp của lá, nếu bị nặng vào giai đoạn lúa làm đòng hoặc trỗ sẽ làm hạt lép lửng, chất lượng gạo kém và giảm năng suất từ 15-30%.",
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
            "Vết bệnh ban đầu xuất hiện ở chóp lá hoặc mép lá với những đốm úng nước.",
            "Vết bệnh lan dần xuống dưới và vào trong phiến lá, tạo thành các vệt hình mũi tên hoặc hình nêm (bán nguyệt).",
            "Đặc trưng nhất: Bên trong vết bệnh khô cháy có các dải màu đồng tâm luân phiên giữa sáng và tối (giống vân gỗ).",
            "Viền của vết bệnh tiếp giáp với phần lá xanh thường có quầng màu vàng nhạt hoặc nâu đỏ.",
            "Khi bệnh nặng, các vết cháy liên kết lại với nhau làm toàn bộ phiến lá bị khô héo, tàn lụi nhanh chóng.",
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
        "Do nấm Monographella albescens (giai đoạn vô tính gọi là Microdochium oryzae) xâm nhiễm vào gân và biểu bì lá.",
        "Mầm bệnh tồn tại chủ yếu trên hạt giống (truyền từ vụ trước) và rơm rạ, cỏ dại mục nát trên đồng.",
        "Bào tử nấm lây lan rất mạnh qua giọt nước mưa, nước tưới và gió sương.",
        "Bệnh thường bùng phát thành dịch ở những diện tích lúa bón thừa phân Đạm (Nitơ) làm lá lúa rậm rạp, mềm mỏng.",
        "Thời tiết lý tưởng cho bệnh phát triển là khi trời nhiều mây, mưa dầm liên tục, độ ẩm cao và có sương mù buổi sáng.",
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
        "Sử dụng hạt giống sạch bệnh, đã qua xử lý ngâm ủ với thuốc trừ nấm trước khi gieo sạ.",
        "Dọn sạch tàn dư thực vật (rơm rạ, lúa chét) và diệt cỏ dại quanh bờ ruộng sau thu hoạch.",
        "Gieo sạ lúa với mật độ thưa hợp lý để ánh sáng lọt vào tận gốc lúa, giúp ruộng khô ráo nhanh sau mưa.",
        "Bón phân cân đối N-P-K theo nguyên tắc 'nặng đầu, nhẹ cuối'. Tuyệt đối không bón đón đòng bằng phân đạm đơn rải tay.",
        "Tăng cường bón lót phân có chứa Canxi và Silic để làm cứng vách tế bào lá, ngăn chặn nấm đâm xuyên qua.",
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
        "Ngay khi phát hiện vết bệnh hình mũi tên trên chóp lá, phải lập tức ngưng mọi hình thức bón phân đạm hoặc phun phân bón lá.",
        "Mở bờ cho thoát nước cạn để giảm độ ẩm trong gốc lúa, giúp cây cứng cáp lại.",
        "Sử dụng các loại thuốc trừ nấm phổ rộng có chứa hoạt chất: Difenoconazole, Propiconazole, Azoxystrobin hoặc Validamycin.",
        "Pha thuốc đúng liều lượng khuyến cáo. Nên phun ướt đẫm đều cả hai mặt lá và phun vào lúc chiều mát khi lá đã ráo nước.",
        "Nếu gặp đợt mưa kéo dài, cần tranh thủ phun lại lần 2 sau khoảng 5-7 ngày để cắt đứt nguồn bào tử nấm.",
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