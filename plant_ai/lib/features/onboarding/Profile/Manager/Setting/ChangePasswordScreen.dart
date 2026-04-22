import 'package:flutter/material.dart';
// Nhớ import đúng đường dẫn file OTPScreen của ông nhé
import '../../../User/OTPScreen.dart'; 

class ChangePasswordScreen extends StatefulWidget {
  final String email; 
  final String loginType; // 🛑 Nhận thêm biến loại tài khoản

  const ChangePasswordScreen({super.key, required this.email, required this.loginType});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Controller
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Trạng thái hiển thị mật khẩu
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Màu sắc chủ đạo (PlantAI)
  final Color _mainColor = const Color(0xFF8DAA5B);
  final Color _bgColor = const Color(0xFFFDFCF5);

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // --- HÀM KIỂM TRA MẬT KHẨU MẠNH ---
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  // Hàm hiển thị thông báo lỗi nhanh
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🛑 WIDGET NÚT BACK DÙNG CHUNG
  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 5, 
              offset: const Offset(0, 2)
            )
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🛑 KHIÊN BẢO VỆ TÀI KHOẢN GOOGLE/FACEBOOK
    if (widget.loginType == 'social') {
      return Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 10.0),
                  child: _buildBackButton(), // Gọi nút Back
                ),
              ),
              const Spacer(),
              const Icon(Icons.g_mobiledata_rounded, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Tài khoản liên kết", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Tài khoản của bạn đang được đăng nhập thông qua Google/Facebook. Bạn không cần và không thể đổi mật khẩu tại đây.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      );
    }

    // --- RENDER FORM ĐỔI MẬT KHẨU NẾU LÀ TÀI KHOẢN THƯỜNG ---
    return Scaffold(
      backgroundColor: _bgColor, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              _buildBackButton(), // Gọi nút Back

              const SizedBox(height: 25),
              const Text(
                "Đổi mật khẩu",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Vui lòng nhập mật khẩu hiện tại và mật khẩu mới để bảo mật tài khoản của bạn.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // --- INPUT MẬT KHẨU CŨ ---
              const Text("Mật khẩu hiện tại", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _oldPassController,
                hintText: "Nhập mật khẩu hiện tại",
                isPassword: true,
                isVisible: _isOldPasswordVisible,
                onVisibilityToggle: () => setState(() => _isOldPasswordVisible = !_isOldPasswordVisible),
              ),
              
              const SizedBox(height: 20),

              // --- INPUT MẬT KHẨU MỚI ---
              const Text("Mật khẩu mới", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _newPassController,
                hintText: "Nhập mật khẩu mới",
                isPassword: true,
                isVisible: _isNewPasswordVisible,
                onVisibilityToggle: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
              ),
              // Gợi ý mật khẩu nhỏ bên dưới
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 5),
                child: Text(
                  "* Mật khẩu cần: 8+ ký tự, Hoa, Số, Ký tự đặc biệt",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                ),
              ),

              const SizedBox(height: 15),

              // --- INPUT NHẬP LẠI MẬT KHẨU ---
              const Text("Nhập lại mật khẩu mới", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmPassController,
                hintText: "Xác nhận mật khẩu mới",
                isPassword: true,
                isVisible: _isConfirmPasswordVisible,
                onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),

              const SizedBox(height: 40),

              // --- NÚT GỬI MÃ OTP ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    String oldPass = _oldPassController.text;
                    String newPass = _newPassController.text;
                    String confirmPass = _confirmPassController.text;

                    // 1. KIỂM TRA TRỐNG
                    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                      _showError("Vui lòng điền đầy đủ các trường!");
                      return;
                    }

                    // 2. KIỂM TRA MẬT KHẨU MỚI TRÙNG KHỚP
                    if (newPass != confirmPass) {
                      _showError("Mật khẩu xác nhận không trùng khớp!");
                      return;
                    }

                    // 3. KIỂM TRA MẬT KHẨU CŨ VÀ MỚI (Không cho giống nhau)
                    if (oldPass == newPass) {
                      _showError("Mật khẩu mới phải khác mật khẩu hiện tại!");
                      return;
                    }

                    // 4. KIỂM TRA ĐỘ MẠNH MẬT KHẨU MỚI
                    if (!_isPasswordStrong(newPass)) {
                      _showError("Mật khẩu quá yếu! Cần ít nhất 8 ký tự, bao gồm chữ Hoa, Số và Ký tự đặc biệt.");
                      return;
                    }
                    
                    // 🛑 ĐÃ HỢP LỆ -> Gửi qua trang OTP
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Thông tin hợp lệ. Đang gửi mã OTP..."),
                        backgroundColor: _mainColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OTPScreen(
                          name: "",
                          email: widget.email, 
                          password: newPass, // Truyền mật khẩu mới sang để OTP update DB
                          isResetPassword: true, 
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Gửi mã xác nhận",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget TextField dùng chung
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.transparent, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _mainColor, width: 2),
        ),
        errorBorder: OutlineInputBorder( 
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                onPressed: onVisibilityToggle,
              )
            : (icon != null ? Icon(icon, color: Colors.grey) : null),
      ),
    );
  }
}