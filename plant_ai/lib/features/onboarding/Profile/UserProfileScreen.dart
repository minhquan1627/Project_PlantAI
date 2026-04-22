import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Đảm bảo đường dẫn này khớp với project của ông
import '../Effect/CustomBottomNavBar.dart'; 
import '../../../core/API/UserAPI.dart'; // Import API để lấy thông tin User
import '../../../../core/services/Checkin/social_auth_service.dart';
import '../../../../core/services/Checkin/JWT.dart';
import 'Accout/AccoutDetailScreen.dart';
import '../User/LoginScreen.dart';
import 'Manager/PostManagerScreen.dart';
import 'Manager/SettingScreen.dart';
import '../Effect/ScanTutorialScreen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Tab hiện tại đang chọn là "Tôi" (Index = 3)
  int _selectedIndex = 3;

  // --- DATA VARIABLES ---
  String userName = "Đang tải...";
  String? userAvatar; // Biến lưu link ảnh mạng (nếu có)
  bool isLoading = true;
  // Dùng chung email test (hoặc lấy từ SharedPreferences trong thực tế)
  
  // KHÔNG GÁN CỨNG NỮA, CHÚNG TA SẼ LẤY NÓ TỪ ĐIỆN THOẠI LÊN
  String currentUserEmail = "";

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchUser();
  }


  void _handleLogout() async {
    // 1. Chỉ gọi đúng 1 dòng này để xóa sạch Token & Email
    await JWTService.clearToken();
    
    // 2. Nếu dùng SocialAuth thì SignOut
    try {
      await SocialAuthService.signOut(); 
    } catch (e) {
      print("Lỗi Social Logout: $e");
    }

    // 3. Đẩy về LoginScreen
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, 
      );
    }
  }
  
  
  

  Future<void> _loadEmailAndFetchUser() async {
    try {
      // 1. Mở két sắt SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('current_user_email'); // Lấy email ông đã lưu lúc Login

      // 2. Kiểm tra xem có lấy được không
      if (savedEmail != null && savedEmail.isNotEmpty) {
        currentUserEmail = savedEmail; // Gán vào biến của màn hình
        
        // 3. Có email rồi thì mới gọi API lấy thông tin MongoDB
        await _fetchUserProfile(); 
      } else {
        // Trường hợp lỗi (không tìm thấy email đăng nhập)
        if (mounted) {
          setState(() {
            userName = "Lỗi: Khách vãng lai";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi khi đọc SharedPreferences: $e");
    }
  }
  // --- HÀM LẤY THÔNG TIN USER (Giống HomeScreen) ---
  Future<void> _fetchUserProfile() async {
    try {
      var userMap = await UserAPI.getUserByEmail(currentUserEmail);

      if (mounted) {
        setState(() {
          if (userMap != null) {
            // Lấy tên ưu tiên: username -> name -> email -> "User"
            String? fetchedName = userMap['username'] ?? userMap['name'];
            String? fetchedEmail = userMap['email'];

            if (fetchedName != null && fetchedName.trim().isNotEmpty) {
              userName = fetchedName;
            } else if (fetchedEmail != null && fetchedEmail.trim().isNotEmpty) {
              userName = fetchedEmail;
            } else {
              userName = "User";
            }

            // Lấy link avatar từ DB (Giả sử key là 'avatar')
            userAvatar = userMap['avatar'];
          } else {
            userName = "User";
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = "Lỗi kết nối";
          isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // Lưu ý: Logic chuyển trang ở BottomBar đã được xử lý trong CustomBottomNavBar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- NỘI DUNG CHÍNH ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), 
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildThickDivider(),
            _buildMenu(),
          ],
        ),
      ),

      // --- NÚT SCAN (FAB) ---
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
      
      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // ==========================================
  // 1. PHẦN HEADER (ẢNH BÌA + AVATAR OVERLAP)
  // ==========================================
  
  Widget _buildHeader() {
    return SizedBox(
      height: 320, // Tăng chiều cao tổng thể để có thêm không gian "đẩy" xuống
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1.1 Ảnh bìa - Thu ngắn lại một chút để phần trắng rộng hơn
          Container(
            height: 200, 
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1448375240586-882707db888b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 1.2 Avatar - Đẩy xuống thấp hơn (giảm bottom từ 15 xuống 10 hoặc 5)
          Positioned(
              bottom: 40, // Đẩy xuống sâu hơn vào vùng trắng
              left: 20,
              child: Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(4), // Đây chính là khoảng cách tạo ra cái viền trắng
                decoration: const BoxDecoration(
                  color: Colors.white, // Màu nền trắng của viền ngoài
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white, // Đảm bảo nền phía sau ảnh cũng là màu trắng
                  child: ClipOval(
                    child: SizedBox.expand( // Giúp ảnh lấp đầy toàn bộ vòng tròn
                      child: _buildAvatarImage(), // Gọi hàm logic ưu tiên DB của ông
                    ),
                  ),
                ),
              ),
            ),

          // 1.3 KHỐI THÔNG TIN - Hạ thấp xuống để thoát khỏi vùng ảnh
          Positioned(
            bottom: 55, // Hạ thấp xuống cùng với Avatar
            left: 135, 
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLoading ? "Đang kết nối..." : userName,
                  style: GoogleFonts.roboto(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Màu đen rõ ràng trên nền trắng
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM XỬ LÝ AVATAR THÔNG MINH ---
  Widget _buildAvatarImage() {
    String? url = userAvatar; 

    // Kiểm tra rỗng, null hoặc chỉ có khoảng trắng
    if (url == null || url.trim().isEmpty) {
      return Image.asset(
        'assets/images/Icon_user.png', // <-- ĐƯỜNG DẪN MẶC ĐỊNH CỦA CAPTAIN
        fit: BoxFit.cover,
      );
    }

    // Nếu có link thì thử tải ảnh mạng
    if (userAvatar!.startsWith('http')) {
      return Image.network(
        userAvatar!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
      );
    } else {
      return Image.file(
        File(userAvatar!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
      );
    }
  }

  // ==========================================
  // 2. PHẦN THANH PHÂN CÁCH DÀY
  // ==========================================
  Widget _buildThickDivider() {
    return Container(
      height: 8,
      width: double.infinity,
      color: Colors.grey[200], 
    );
  }

  // ==========================================
  // 3. PHẦN MENU DANH SÁCH CHỨC NĂNG
  // ==========================================
  Widget _buildMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: "Thông tin tài khoản", // Đã sửa lỗi chính tả "khoảng" -> "khoản" cho ông luôn nhé 😂
            onTap: () {
              // Lệnh chuyển sang trang chi tiết và truyền email qua
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountDetailScreen(
                    userEmail: currentUserEmail, // Truyền email đang lưu trong UserProfileScreen sang
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          _buildMenuItem(
            icon: Icons.people_outline,
            title: "Quản lý bài đăng",
            onTap: () {
              // 🛑 Lệnh điều hướng sang trang PostManagerScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostManagerScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
         _buildMenuItem(
            icon: Icons.settings_outlined,
            title: "Cài đặt",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          _buildMenuItem(
            icon: Icons.logout, 
            title: "Đăng xuất",
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  // --- Widget con tạo từng dòng Menu ---
  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black54),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  } 
}
