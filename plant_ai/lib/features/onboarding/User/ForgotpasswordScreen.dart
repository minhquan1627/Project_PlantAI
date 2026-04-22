import 'package:flutter/material.dart';
import 'OTPScreen.dart'; // Đảm bảo file này cùng cấp thư mục

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Trạng thái hiển thị mật khẩu
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Màu sắc chủ đạo (PlantAI)
  final Color _mainColor = const Color(0xFF8DAA5B);
  final Color _bgColor = const Color(0xFFFDFCF5);

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // --- HÀM KIỂM TRA MẬT KHẨU MẠNH ---
  bool _isPasswordStrong(String password) {
    // 1. Ít nhất 8 ký tự
    if (password.length < 8) return false;
    // 2. Có chữ in hoa
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    // 3. Có chữ số
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    // 4. Có ký tự đặc biệt (!@#$...)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor, // Sửa lại: Dùng backgroundColor cho Scaffold luôn
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Quên mật khẩu?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Vui lòng nhập email xác nhận và mật khẩu mới của bạn.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // --- INPUT EMAIL ---
            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hintText: "Nhập email của bạn",
              icon: Icons.email_outlined,
            ),
            
            const SizedBox(height: 20),

            // --- INPUT MẬT KHẨU MỚI ---
            const Text("Mật khẩu mới", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passController,
              hintText: "Nhập mật khẩu mới",
              isPassword: true,
              isVisible: _isPasswordVisible,
              onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
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
            const Text("Nhập lại mật khẩu", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _confirmPassController,
              hintText: "Xác nhận mật khẩu mới",
              isPassword: true,
              isVisible: _isConfirmPasswordVisible,
              onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),

            const SizedBox(height: 40),

            // --- NÚT GỬI MÃ ---
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
                  String email = _emailController.text.trim();
                  String pass = _passController.text;
                  String confirmPass = _confirmPassController.text;

                  // 1. KIỂM TRA EMAIL
                  if (email.isEmpty) {
                    _showError("Vui lòng nhập Email!");
                    return;
                  }
                  // Phải có '@' và dấu '.'
                  if (!email.contains('@') || !email.contains('.')) {
                    _showError("Email không hợp lệ (cần có '@' và '.')");
                    return;
                  }

                  // 2. KIỂM TRA MẬT KHẨU TRÙNG KHỚP
                  if (pass != confirmPass) {
                    _showError("Mật khẩu xác nhận không trùng khớp!");
                    return;
                  }

                  // 3. KIỂM TRA ĐỘ MẠNH MẬT KHẨU
                  if (!_isPasswordStrong(pass)) {
                    _showError("Mật khẩu quá yếu! Cần ít nhất 8 ký tự, bao gồm chữ Hoa, Số và Ký tự đặc biệt.");
                    return;
                  }
                  
                  // 4. THÀNH CÔNG -> Chuyển màn hình
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
                      builder: (context) => OTPScreen(name: "",email: email, password: pass, isResetPassword: true, isForgotPassword: true,),
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
        fillColor: Colors.transparent, // Nền trong suốt
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
        errorBorder: OutlineInputBorder( // Viền đỏ khi lỗi (nếu dùng validate tự động)
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