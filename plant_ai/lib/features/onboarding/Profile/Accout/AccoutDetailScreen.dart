import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Effect/CustomBottomNavBar.dart';
import '../../../../core/API/UserAPI.dart';
import 'EditAccoutScreen.dart';
import '../../Effect/ScanTutorialScreen.dart';

class AccountDetailScreen extends StatefulWidget {
  // Biến chứa email của người dùng đang đăng nhập
  final String userEmail;

  const AccountDetailScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  // Biến quản lý trạng thái của Bottom Navigation Bar (Tab "Tôi" mặc định là index 3)
  int _selectedIndex = 3; 

  // Hàm gọi API lấy dữ liệu thực tế từ MongoDB
  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      // Gọi hàm getUserByEmail từ UserAPI của ông (Nhớ mở comment dòng import phía trên)
      final user = await UserAPI.getUserByEmail(widget.userEmail);
      
      // MOCK DATA TẠM THỜI ĐỂ TEST UI (Khi nào nối API xong ông xóa đoạn này đi)
      
      
      
      if (user != null) {
        return user;
      }
      return {};
      
    } catch (e) {
      print("❌ Lỗi khi lấy thông tin user trên UI: $e");
      return {};
    }
  }

  // Hàm tiện ích để kiểm tra chuỗi rỗng hoặc null
  String checkEmpty(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Hãy cập nhập';
    }
    return value.toString();
  }

  // Hàm chuyển tab cho Bottom Nav Bar
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // Logic điều hướng thực tế đã được ông code sẵn trong CustomBottomNavBar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F9F0),
      
      // ==========================================
      // 1. NỘI DUNG CHÍNH (BODY)
      // ==========================================
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFA1C083)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Không tìm thấy thông tin tài khoản!"),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Quay lại"),
                  )
                ],
              ),
            );
          }

          final userData = snapshot.data!;
          String userName = checkEmpty(userData['name']);
          String userEmail = checkEmpty(userData['email']);
          String userLocation = checkEmpty(userData['location']);
          String userPassword = (userData['password'] == null || userData['password'].toString().isEmpty) 
              ? 'Hãy cập nhập' 
              : '••••••••••••';
          String avatarPath = userData['avatar']?.toString() ?? "";
          ImageProvider avatarImage;

          if (avatarPath.isEmpty) {
            // Trường hợp không có ảnh -> Dùng ảnh mặc định
            avatarImage = const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png');
          } else if (avatarPath.startsWith('http')) {
            // Trường hợp là link mạng (Cloudinary, Imgur...)
            avatarImage = NetworkImage(avatarPath);
          } else {
            // Trường hợp là đường dẫn file trong máy (ImagePicker path)
            avatarImage = FileImage(File(avatarPath));
          }

          return Stack(
            children: [
              // LỚP 1: BACKGROUND HEADER
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF2F9F0), Color(0xFFA1C083)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),

              // LỚP 2: NỘI DUNG CHÍNH
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                            onPressed: () => Navigator.pop(context), // Nút quay lại
                          ),
                          const Text(
                            'THÔNG TIN TÀI KHOẢN',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () {
                              // Chuyển sang màn hình EditAccountScreen và truyền dữ liệu user hiện tại qua
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditAccountScreen(userData: userData),
                                ),
                              );
                            },
                            child: const Text(
                              'EDIT',
                              style: TextStyle(
                                color: Colors.black87, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarImage, // <--- SỬ DỤNG BIẾN avatarImage Ở ĐÂY
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            _buildInfoItem(icon: Icons.eco_outlined, label: 'Tên Tài Khoản', value: userName),
                            const SizedBox(height: 24),
                            _buildInfoItem(icon: Icons.alternate_email, label: 'Email', value: userEmail),
                            const SizedBox(height: 24),
                            _buildInfoItem(icon: Icons.lock_outline, label: 'Mật khẩu', value: userPassword),
                            const SizedBox(height: 24),
                            _buildInfoItem(icon: Icons.location_on_outlined, label: 'Địa Điểm', value: userLocation),
                            
                            // Đẩy phần nội dung lên một chút để không bị che bởi Bottom Nav Bar
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // ==========================================
      // 2. NÚT SCAN (FAB)
      // ==========================================
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: () => 
          Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ScanTutorialScreen()),
          ),
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, color: Colors.black54, size: 28),
              Text("Scan", style: GoogleFonts.roboto(fontSize: 9, color: Colors.black54))
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // ==========================================
      // 3. BOTTOM NAVIGATION BAR
      // ==========================================
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Hàm hỗ trợ build từng dòng thông tin
  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    bool isMissing = value == 'Hãy cập nhập';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: isMissing ? Colors.redAccent : Colors.black87,
            fontWeight: isMissing ? FontWeight.normal : FontWeight.w500,
            fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.black26, thickness: 1, height: 1),
      ],
    );
  }
}