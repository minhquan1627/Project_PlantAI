import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoffeeMinerScreen extends StatefulWidget {
  const CoffeeMinerScreen({Key? key}) : super(key: key);

  @override
  State<CoffeeMinerScreen> createState() => _CoffeeMinerScreenState();
}

class _CoffeeMinerScreenState extends State<CoffeeMinerScreen> {
  // Trạng thái quản lý Tab hiện tại (0: Triệu chứng, 1: Nguyên nhân, 2: Phòng ngừa, 3: Điều trị)
  int _selectedTabIndex = 0;

  final List<String> _tabs = ["Triệu chứng", "Nguyên nhân", "Phòng ngừa", "Điều trị"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
                  const SizedBox(height: 40), 
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
        // Nhớ đổi tên ảnh này trong máy của ông cho đúng nhé
        Image.asset(
          'assets/Plant/Coffee-Miner-Disease.jpg', 
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
          // Xử lý lỗi nếu chưa có ảnh trong máy
          errorBuilder: (context, error, stackTrace) => Container(
            height: 320, width: double.infinity, color: Colors.grey[800],
            child: const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 50)),
          ),
        ),
        Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
        ),
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
                      "Sâu vẽ bùa",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Coffee Leaf Miner (Leucoptera coffeella)",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
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
            Expanded(child: _buildInfoCard(Icons.access_time, "Thời gian ủ bệnh", "14-20 ngày", const Color(0xFF8DAA5B))),
            const SizedBox(width: 15),
            Expanded(child: _buildInfoCard(Icons.adjust, "Cây bị ảnh hưởng", "Cà phê (Arabica)", const Color(0xFF8DAA5B))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildInfoCard(Icons.wb_sunny_outlined, "Mùa bùng phát", "Mùa khô", const Color(0xFF8DAA5B))),
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
            "Bệnh Miner, còn gọi là sâu đục lá cà phê, là một loại sâu hại phổ biến gây tổn thương trực tiếp trên lá cây. Ấu trùng của sâu sống và phát triển bên trong mô lá, tạo ra các đường đục hoặc các vết loang màu trắng bạc trên bề mặt lá. Những tổn thương này làm giảm diện tích quang hợp của lá, khiến cây sinh trưởng kém và ảnh hưởng đến năng suất cà phê. Bệnh thường phát triển mạnh trong điều kiện thời tiết nóng và khô, đặc biệt là vào mùa khô tại các vùng trồng cà phê.",
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
        color: const Color(0xFFF1F5F9), 
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
      iconBgColor: const Color(0xFFEDF7ED), 
      iconColor: const Color(0xFF5F8B48),
      bullets: [
        "Xuất hiện các đường vằn vện ngoằn ngoèo hoặc vết rộp màu nâu nhạt trên mặt trên của lá",
        "Khi xé lớp biểu bì chỗ rộp, có thể thấy sâu non màu trắng hoặc vàng nhạt bên trong",
        "Vết rộp dần khô lại, chuyển sang màu nâu sẫm và rất dễ rách",
        "Lá bị tấn công nhiều sẽ chuyển vàng, cháy sém và rụng sớm",
        "Trường hợp nặng, cây có thể bị rụng trụi lá, trơ cành và kiệt sức",
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
        "Do ấu trùng của loài bướm đêm (Leucoptera coffeella) đẻ trứng và nở ra trên lá",
        "Phát triển cực kỳ mạnh trong điều kiện thời tiết mùa khô, nhiệt độ cao và ít mưa",
        "Vườn cà phê thiếu cây che bóng mát, bị ánh nắng trực tiếp chiếu vào",
        "Bón thừa đạm (N) làm bộ lá quá mỏng và non, tạo điều kiện cho bướm đẻ trứng",
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
        "Trồng cây che bóng mát với mật độ hợp lý để giảm bớt nhiệt độ trong vườn",
        "Tưới nước đầy đủ, duy trì độ ẩm ổn định đặc biệt trong những tháng mùa khô",
        "Bón phân cân đối, tăng cường phân lân và kali giúp lá cứng cáp, kháng sâu bệnh",
        "Thường xuyên thăm vườn, cắt tỉa cành tăm để vườn cây luôn thông thoáng",
        "Bảo vệ các loài thiên địch tự nhiên như kiến vàng và ong ký sinh (chuyên tiêu diệt ấu trùng sâu)",
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
        "Ngắt bỏ và tiêu hủy ngay những lá có dấu hiệu bị rộp khi bệnh mới chớm xuất hiện",
        "Dùng thuốc BVTV có hoạt chất Abamectin, Cartap hoặc Diafenthiuron khi tỷ lệ lá hại vượt ngưỡng 15%",
        "Có thể sử dụng các chế phẩm sinh học (như nấm xanh Metarhizium) để phun phòng trừ an toàn",
        "Nên phun thuốc vào lúc sáng sớm hoặc chiều mát, chú ý phun ướt đều cả hai mặt lá",
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
              color: Color(0xFF8DAA5B), 
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