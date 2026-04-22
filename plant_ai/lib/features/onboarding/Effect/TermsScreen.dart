import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color mainColor = Color(0xFF8DAA5B);
  static const Color textColor = Color(0xFF2F2F2F);
  static const Color subTextColor = Color(0xFF6E6E6E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Điều Khoản Sử Dụng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTopBanner(),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: mainColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: mainColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: "Điều khoản sử dụng"),
                Tab(text: "Chính sách bảo mật"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTermsTab(),
                _buildPrivacyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: const BoxDecoration(
        color: mainColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2DA),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.assignment_turned_in_rounded,
              color: mainColor,
              size: 64,
            ),
            const SizedBox(height: 10),
            const Text(
              "Vui lòng đọc kỹ điều khoản và chính sách bảo mật trước khi sử dụng PlantAI",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            "1. Giới thiệu",
            "Chào mừng bạn đến với PlantAI – ứng dụng hỗ trợ nhận diện bệnh cây trồng bằng trí tuệ nhân tạo (AI). Bằng việc truy cập hoặc sử dụng ứng dụng, bạn đồng ý tuân thủ các điều khoản được quy định dưới đây.",
          ),
          _buildSection(
            "2. Dịch vụ cung cấp",
            "PlantAI cung cấp các chức năng như nhận diện bệnh cây trồng từ hình ảnh, hỏi đáp bằng AI, đề xuất phương pháp chăm sóc và xử lý, quản lý vườn và theo dõi tình trạng cây.",
            bullets: const [
              "Nhận diện bệnh cây trồng từ hình ảnh",
              "Hỏi đáp thông minh bằng AI",
              "Đề xuất phương pháp chăm sóc và xử lý",
              "Quản lý vườn và theo dõi tình trạng cây",
            ],
          ),
          _buildSection(
            "3. Quyền của PlantAI",
            "PlantAI có quyền cập nhật, thay đổi hoặc tạm ngưng một phần dịch vụ khi cần thiết để cải thiện trải nghiệm và hiệu suất hệ thống.",
            bullets: const [
              "Cập nhật, thay đổi hoặc ngừng dịch vụ",
              "Thu thập dữ liệu để cải thiện AI",
              "Hạn chế truy cập nếu phát hiện hành vi bất thường",
            ],
          ),
          _buildSection(
            "4. Trách nhiệm người dùng",
            "Người dùng có trách nhiệm cung cấp thông tin chính xác, sử dụng ứng dụng đúng mục đích và không đăng tải nội dung vi phạm pháp luật hoặc gây ảnh hưởng đến hệ thống.",
            bullets: const [
              "Cung cấp thông tin chính xác",
              "Bảo mật thông tin đăng nhập",
              "Chịu trách nhiệm với hoạt động trên tài khoản",
            ],
          ),
          _buildSection(
            "5. Giới hạn trách nhiệm",
            "Kết quả nhận diện bệnh được tạo ra từ AI chỉ mang tính chất tham khảo. PlantAI không chịu trách nhiệm đối với các quyết định kinh tế hoặc canh tác phát sinh từ việc phụ thuộc hoàn toàn vào kết quả AI.",
          ),
          
          // 🚀 NÚT ĐÃ XEM MỚI TẠI ĐÂY
          const SizedBox(height: 24),
          _buildActionButton(
            text: "Đã Xem",
            onPressed: () => Navigator.pop(context), // Nhấn là thoát trang luôn
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            "1. Thông tin thu thập",
            "PlantAI có thể thu thập một số dữ liệu cần thiết để hệ thống hoạt động hiệu quả và cải thiện trải nghiệm người dùng.",
            bullets: const [
              "Hình ảnh cây trồng",
              "Nội dung trò chuyện với AI",
              "Thông tin vườn như độ ẩm, nhiệt độ, loại cây",
              "Thông tin tài khoản cơ bản",
            ],
          ),
          _buildSection(
            "2. Mục đích sử dụng",
            "Dữ liệu được sử dụng để nâng cao độ chính xác của việc nhận diện bệnh, cá nhân hóa gợi ý chăm sóc và hỗ trợ cải thiện hệ thống AI.",
            bullets: const [
              "Nhận diện bệnh chính xác hơn",
              "Cá nhân hóa trải nghiệm",
              "Cải thiện mô hình AI",
              "Hỗ trợ người dùng hiệu quả hơn",
            ],
          ),
          _buildSection(
            "3. Bảo mật thông tin",
            "PlantAI cam kết áp dụng các biện pháp kỹ thuật cần thiết để bảo vệ dữ liệu người dùng khỏi truy cập trái phép, mất mát hoặc lạm dụng.",
          ),
          _buildSection(
            "4. Chia sẻ dữ liệu",
            "PlantAI không bán dữ liệu người dùng cho bên thứ ba. Dữ liệu chỉ có thể được chia sẻ khi có sự đồng ý của người dùng hoặc theo yêu cầu của cơ quan có thẩm quyền.",
          ),
          _buildSection(
            "5. Quyền của người dùng",
            "Người dùng có quyền xem, chỉnh sửa hoặc yêu cầu xóa dữ liệu cá nhân của mình theo phạm vi mà hệ thống hỗ trợ.",
            bullets: const [
              "Truy cập dữ liệu cá nhân",
              "Yêu cầu chỉnh sửa hoặc xóa dữ liệu",
              "Ngừng sử dụng dịch vụ bất cứ lúc nào",
            ],
          ),
          _buildSection(
            "6. Cookies & công nghệ theo dõi",
            "Ứng dụng có thể sử dụng các công nghệ tương tự nhằm cải thiện hiệu suất hệ thống, phân tích hành vi sử dụng và nâng cao trải nghiệm người dùng.",
          ),
          _buildSection(
            "7. Thay đổi chính sách",
            "Chính sách bảo mật có thể được cập nhật theo thời gian để phù hợp với hệ thống và quy định pháp luật hiện hành.",
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            text: "Đóng",
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content, {
    List<String> bullets = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: subTextColor,
              height: 1.7,
            ),
          ),
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: const BoxDecoration(
                        color: mainColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 15,
                          color: subTextColor,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}