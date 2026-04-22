import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Effect/CustomBottomNavBar.dart';
import 'Setting/ChangePasswordScreen.dart';
import '../../Effect/ScanTutorialScreen.dart';
import '../../../../core/API/UserAPI.dart';
import '../../User/LoginScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);
  
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  bool _isLanguageExpanded = false; 
  bool _isDeleteAccountExpanded = false;
  String _selectedLanguage = "Tiếng Việt"; 
  String currentUserEmail = "";
  String currentUserLoginType = "";
  final Color colorGreenDark = const Color(0xFF80A252); 
  final Color colorGreenLight = const Color(0xFFBFD1A8);

  late AnimationController _controller;
  late Animation<Offset> _headerSlideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerSlideAnim = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showDeleteConfirmationDialog() {
    int countdown = 5;
    bool canDelete = false;
    Timer? authTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Khởi tạo timer chỉ 1 lần
            authTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (countdown > 0) {
                setDialogState(() => countdown--);
              } else {
                setDialogState(() => canDelete = true);
                timer.cancel();
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text("Xác nhận cuối cùng", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text("Bạn có thực sự muốn xóa sạch mọi dữ liệu? Hành động này không thể hoàn tác."),
              actions: [
                TextButton(
                  onPressed: () {
                    authTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: Text("Hủy", style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canDelete ? Colors.redAccent : Colors.grey[300],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: canDelete ? () async {
                    authTimer?.cancel();
                    // Hiển thị loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white))
                    );

                    final prefs = await SharedPreferences.getInstance();
                    String? userId = prefs.getString('current_user_id');

                    if (userId != null && currentUserEmail.isNotEmpty) {
                      String status = await UserAPI.deleteUserFullData(userId, currentUserEmail);
                      if (status == "SUCCESS" && mounted) {
                        await prefs.clear();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()), // 👈 Mở thẳng file này
                          (Route<dynamic> route) => false, // 👈 Xóa sạch các trang cũ (Vườn, Task, Setting...)
                        );
                      } else {
                        Navigator.pop(context); // Tắt loading
                        log("Lỗi xóa tài khoản");
                      }
                    }
                  } : null,
                  child: Text(canDelete ? "Xóa vĩnh viễn" : "Chờ $countdown s..."),
                ),
              ],
            );
          },
        );
      },
    );
  }

  

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Lấy email đã lưu lúc đăng nhập
    String? email = prefs.getString('current_user_email'); 

    if (email != null && email.isNotEmpty) {
      // Giả sử ông có hàm UserAPI để lấy thông tin từ MongoDB
      // var user = await UserAPI.getUserByEmail(email); 
      
      setState(() {
        currentUserEmail = email;
        // Tạm thời test: Nếu loginType lấy từ DB về là 'social' thì nó sẽ chặn
        // currentUserLoginType = user['loginType'] ?? 'email';
        currentUserLoginType = 'email'; // Để 'email' để ông test form trước
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FDEB),
      body: Column(
        children: [
          _buildCompactHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // _buildSettingItem("Cài đặt chat", () => print("Chat")),
                  // _buildSettingItem("Cài đặt thông báo", () => print("Notify")),
                  _buildExpandableDeleteAccountItem( "Xóa tài khoản", Icons.delete_forever, () {
                    _showDeleteConfirmationDialog();
                  }, isDestructive: true),
                 _buildSettingItem("Sửa mật khẩu", () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => ChangePasswordScreen(
                          email: currentUserEmail,
                          loginType: currentUserLoginType,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          // Cấu hình hướng từ TRÊN (Offset(0, -1)) xuống DƯỚI (Offset.zero)
                          const begin = Offset(0.0, -1.0); 
                          const end = Offset.zero;
                          const curve = Curves.easeInOut; // Hiệu ứng mượt ở hai đầu

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 500), // Tốc độ trượt (0.5 giây)
                      ),
                    );
                  }),
                  
                  // 🛑 SỬA LỖI Ở ĐÂY: Gọi trực tiếp hàm build Widget chứ không qua _buildSettingItem
                  _buildExpandableLanguageItem(), 
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildCompactHeader() {
    return SlideTransition(
      position: _headerSlideAnim,
      child: Container(
        padding: const EdgeInsets.only(top: 50, left: 10, right: 20, bottom: 25),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.58, 1.0],
            colors: [Colors.white, colorGreenLight, colorGreenDark],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Cài đặt',
              style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 🛑 HÀM XỬ LÝ LOGIC XỔ XUỐNG NGÔN NGỮ
  Widget _buildExpandableLanguageItem() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isLanguageExpanded = !_isLanguageExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ngôn ngữ",
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                ),
                Icon(
                  _isLanguageExpanded ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios,
                  size: _isLanguageExpanded ? 24 : 16,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        
        // PHẦN HIỂN THỊ CÁC LỰA CHỌN
        if (_isLanguageExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSubLanguageOption("Tiếng Việt"),
              ],
            ),
          ),
        const Divider(color: Colors.black12, thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildSubLanguageOption(String lang) {
    bool isSelected = _selectedLanguage == lang;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 40, right: 20),
      title: Text(
        lang,
        style: GoogleFonts.roboto(
          fontSize: 15,
          color: isSelected ? colorGreenDark : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: colorGreenDark, size: 20) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = lang;
          _isLanguageExpanded = false; 
        });
      },
    );
  }

  Widget _buildSettingItem(String title, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
              ],
            ),
          ),
        ),
        const Divider(color: Colors.black12, thickness: 1, height: 1),
      ],
    );
  }

  // 🛑 HÀM XỬ LÝ LOGIC XỔ XUỐNG XÓA TÀI KHOẢN
Widget _buildExpandableDeleteAccountItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
  return Column(
    children: [
      InkWell(
        onTap: () {
          setState(() {
            _isDeleteAccountExpanded = !_isDeleteAccountExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Xóa tài khoản",
                style: GoogleFonts.roboto(
                  fontSize: 16, 
                  color: _isDeleteAccountExpanded ? Colors.redAccent : Colors.black87,
                  fontWeight: _isDeleteAccountExpanded ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Icon(
                _isDeleteAccountExpanded ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios,
                size: _isDeleteAccountExpanded ? 24 : 16,
                color: _isDeleteAccountExpanded ? Colors.redAccent : Colors.black54,
              ),
            ],
          ),
        ),
      ),
      
      // PHẦN HIỂN THỊ CẢNH BÁO VÀ NÚT XÓA
      if (_isDeleteAccountExpanded)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 15, left: 8, right: 8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lưu ý: Hành động này không thể hoàn tác. Mọi dữ liệu về vườn, lịch trình và lịch sử quét cây của bạn sẽ bị xóa vĩnh viễn.",
                style: GoogleFonts.roboto(fontSize: 13, color: Colors.red[700], height: 1.5),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showDeleteConfirmationDialog(),
                  child: Text("Xác nhận xóa vĩnh viễn", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      const Divider(color: Colors.black12, thickness: 1, height: 1),
    ],
  );
}



  Widget _buildFAB() {
    return Container(
      height: 64, width: 64,
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
    );
  }
}