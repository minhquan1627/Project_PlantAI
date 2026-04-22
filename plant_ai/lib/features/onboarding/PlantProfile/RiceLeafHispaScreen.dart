import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiceHispaScreen extends StatefulWidget {
  const RiceHispaScreen({Key? key}) : super(key: key);

  @override
  State<RiceHispaScreen> createState() => _RiceHispaScreenState();
}

class _RiceHispaScreenState extends State<RiceHispaScreen> {
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
        // Ảnh nền Bọ gai (Ông nhớ thêm ảnh vào thư mục assets/Plant)
        Image.asset(
          'assets/Plant/rice-hispa-rice.jpg',
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
                      "Bọ gai hại lúa",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rice Hispa (Dicladispa armigera)",
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
            Expanded(child: _buildInfoCard(Icons.access_time, "Thời gian ủ trứng", "4-5 ngày", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.adjust, "Cây bị ảnh hưởng", "Cây lúa", const Color(0xFF8DAA5B))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.cloud_outlined, "Mùa bùng phát", "Mưa ẩm, đẻ nhánh", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.warning_amber_rounded, "Mức độ nguy hiểm", "Nghiêm trọng", const Color(0xFF8DAA5B))),
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
            "Bọ gai (Rice Hispa) là một loại côn trùng cánh cứng nhỏ, màu đen xanh có nhiều gai nhọn trên lưng. Cả bọ trưởng thành và ấu trùng (sâu non) đều gây hại nghiêm trọng cho cây lúa. Bọ trưởng thành gặm lớp biểu bì trên của lá tạo thành các sọc trắng dài, trong khi sâu non đục luồn ăn nhu mô bên trong tạo thành các vết phồng rộp. Nếu mật độ cao, bọ gai có thể làm toàn bộ ruộng lúa xơ xác, trắng xóa như bị cháy, cây lúa còi cọc, trỗ bông kém và giảm năng suất nặng nề.",
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
        "Trên lá xuất hiện nhiều đường sọc trắng song song với gân lá (do con trưởng thành gặm lớp biểu bì).",
        "Có các vết phồng rộp (vết sộp) màu trắng nhạt trên lá, khi bóc ra sẽ thấy sâu non hoặc nhộng bên trong.",
        "Nhìn từ xa, ruộng lúa bị hại nặng có màu trắng xơ xác, lá khô cháy, héo rũ.",
        "Cây lúa sinh trưởng kém, đẻ nhánh ít, thân còi cọc.",
        "Nếu bị tấn công vào giai đoạn lúa làm đòng, bông lúa sẽ bị trỗ nghẹn, hạt lép lửng rất nhiều.",
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
        "Do loài côn trùng cánh cứng có tên khoa học là Dicladispa armigera gây ra.",
        "Phát triển cực kỳ mạnh trong điều kiện thời tiết mưa nhiều, độ ẩm không khí cao (trên 80%).",
        "Ruộng lúa gieo sạ quá dày, bón thừa phân đạm tạo tán lá rậm rạp làm nơi trú ngụ lý tưởng.",
        "Xung quanh ruộng có nhiều cỏ dại (đặc biệt là cỏ lồng vực, cỏ môi) là ký chủ phụ cho bọ gai sinh sôi.",
        "Bọ trưởng thành có khả năng bay xa để tìm ruộng lúa non (đang đẻ nhánh) để đẻ trứng.",
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
        "Vệ sinh đồng ruộng sạch sẽ, dọn sạch cỏ dại ở bờ ruộng và các khu vực lân cận trước khi gieo sạ.",
        "Gieo sạ lúa với mật độ hợp lý, không gieo quá dày để ruộng được thông thoáng.",
        "Bón phân cân đối, đặc biệt không bón thừa đạm (Nitơ) ở giai đoạn lúa đẻ nhánh làm lá lúa non mềm.",
        "Có thể dùng vợt lưới để bắt bọ trưởng thành vào sáng sớm khi lúa mới bị hại nhẹ.",
        "Bảo vệ các loài thiên địch tự nhiên trong ruộng như ong ký sinh trứng, ong ký sinh sâu non và các loài nhện.",
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
        "Thường xuyên thăm đồng. Nếu phát hiện mật độ bọ trưởng thành cao (trên 2 con/khóm) thì cần phun thuốc ngay.",
        "Cắt bỏ phần ngọn lá lúa bị phồng rộp (chứa sâu non) đem đi tiêu hủy nếu diện tích nhỏ.",
        "Sử dụng các loại thuốc trừ sâu có tính nội hấp, lưu dẫn hoặc tiếp xúc vị độc mạnh.",
        "Các hoạt chất được khuyên dùng: Cartap (Padan), Abamectin, Fipronil (Regent) hoặc Chlorantraniliprole.",
        "Phun thuốc vào buổi sáng sớm hoặc chiều mát, phun đủ lượng nước để thuốc ngấm đều mặt lá, diệt được sâu non ẩn bên trong.",
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