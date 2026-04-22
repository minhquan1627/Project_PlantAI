import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'OTPScreen.dart'; 
import '../../../../core/services/network_manager.dart';
import '../../../../core/services/Checkin/social_auth_service.dart';
import '../Effect/TermsScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Key để quản lý Form
  final _formKey = GlobalKey<FormState>();

  // 2. Các Controller để lấy dữ liệu nhập vào
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Biến ẩn/hiện mật khẩu
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Biến checkbox điều khoản
  bool _isCheckedTerms = false;
  // Biến lưu lỗi của Checkbox (vì Checkbox không có validator sẵn như TextField)
  String? _termsError;
  // BIẾN TRẠNG THÁI (Mạng & Loading)
  bool _isOffline = false;
  bool _isLoading = false;

  // Hàm giải phóng bộ nhớ khi tắt màn hình
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupNetworkListener(); // Lắng nghe mạng ngay khi mở màn hình
  }

  void _setupNetworkListener() async {
    bool currentStatus = await NetworkManager().isOffline();
    if (mounted) setState(() => _isOffline = currentStatus);

    NetworkManager().onStatusChange.listen((isOffline) {
      if (mounted) {
        setState(() => _isOffline = isOffline);
      }
    });
  }

  // --- HÀM KIỂM TRA MẬT KHẨU MẠNH ---
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải trên 8 ký tự';
    }
    // Regex kiểm tra chữ in hoa
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Phải có ít nhất 1 chữ cái in hoa';
    }
    // Regex kiểm tra chữ số
    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
      return 'Phải có ít nhất 1 chữ số';
    }
    // Regex kiểm tra ký tự đặc biệt (!@#...)
    if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(value)) {
      return 'Phải có ít nhất 1 ký tự đặc biệt (!@#\$&*~)';
    }
    return null; // Hợp lệ
  }

  // --- HÀM XỬ LÝ KHI BẤM ĐĂNG KÝ ---
  void _submitForm() {
    setState(() => _termsError = null);
    bool isFormValid = _formKey.currentState!.validate();

    if (!_isCheckedTerms) {
      setState(() => _termsError = "Bạn chưa đồng ý với điều khoản");
      isFormValid = false;
    }

    // Nếu tất cả điều kiện OK
    if (isFormValid) {
      print("Đăng ký thành công! Chuyển sang OTP...");
      
      // --- THÊM ĐOẠN NÀY ĐỂ CHUYỂN TRANG ---
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            name: _nameController.text.trim(),
            // Bạn có thể truyền Email qua đây để hiển thị nếu muốn
            email: _emailController.text.trim(), 
            // TRUYỀN MẬT KHẨU SANG ĐỂ GIỮ TẠM
            password: _passController.text.trim(),
          ),
        ),
      );
    }
  }

  void _handleGoogleSignIn() async {
    if (_isOffline) {
      _showMsg("Cần có mạng để đăng ký bằng Google");
      return;
    }

    setState(() => _isLoading = true);
    
    // Gọi Service
    var user = await SocialAuthService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
        _showMsg("Xin chào, ${user['name']}!");
        // TODO: Chuyển hướng sang HomeScreen
      }
    }
  }

  // --- 5. HÀM XỬ LÝ FACEBOOK (Dùng SocialAuthService) ---
  void _handleFacebookSignIn() async {
    if (_isOffline) {
      _showMsg("Cần có mạng để đăng ký bằng Facebook");
      return;
    }

    setState(() => _isLoading = true);

    // Gọi Service
    var user = await SocialAuthService.signInWithFacebook();

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
        _showMsg("Xin chào, ${user['name']}!");
        // TODO: Chuyển hướng sang HomeScreen
      }
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form( // Bọc toàn bộ trong Form
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Đăng ký",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text(
                "Chào mừng bạn đến với PlantAI",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // 0. Ô nhập Tên người dùng
              _buildLabel("Tên người dùng"),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: _inputDecoration("Nhập tên của bạn"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người dùng';
                  }
                  if (value.length < 2 || value.length > 30) {
                    return 'Tên người dùng phải trong khoảng từ 2-30 ký tự ';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9À-ỹ ]+$').hasMatch(value)) {
                    return 'Tên không được chứa ký tự đặc biệt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // 1. Ô nhập Email
              _buildLabel("Email"),
              TextFormField( // Đổi TextField thành TextFormField
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Nhập email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ (thiếu @)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Ô nhập Mật khẩu
              _buildLabel("Mật khẩu"),
              TextFormField(
                controller: _passController,
                obscureText: !_isPasswordVisible,
                decoration: _inputDecoration("Nhập mật khẩu").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                validator: _validatePassword, // Gọi hàm kiểm tra mật khẩu mạnh
              ),
              const SizedBox(height: 20),

              // 3. Ô nhập lại mật khẩu
              _buildLabel("Nhập lại mật khẩu"),
              TextFormField(
                controller: _confirmPassController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: _inputDecoration("Nhập lại mật khẩu").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập lại mật khẩu';
                  }
                  if (value != _passController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 4. Checkbox Điều khoản
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isCheckedTerms,
                      activeColor: const Color(0xFF8DAA5B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (value) => setState(() => _isCheckedTerms = value ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Tôi đồng ý với ",
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Điều khoản và điều kiện",
                            style: const TextStyle(
                              color: Color(0xFF8DAA5B), 
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline
                            ),
                            // 🚀 ĐOẠN NÀY LÀ MẤU CHỐT ĐỂ NHẤN ĐƯỢC
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TermsScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Hiển thị lỗi Checkbox nếu có
              if (_termsError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_termsError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                  ),
                ),

              const SizedBox(height: 30),

              // 5. Nút Đăng ký
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8DAA5B),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitForm, // Gọi hàm kiểm tra
                child: const Text("Đăng ký", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 30),

              // 6. Phân cách "Hoặc"
              if (!_isOffline) ...[
              const Row(children: [
                Expanded(child: Divider()), 
                Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Hoặc")), 
                Expanded(child: Divider())
              ]),
              
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF8DAA5B))
              // 7. Mạng xã hội
              else
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // NÚT GOOGLE
                    GestureDetector(
                      onTap: _handleGoogleSignIn, // <--- Gọi hàm xử lý
                      child: _SocialBtn(
                        child: Image.asset("assets/images/google_icon.png", height: 30, width: 30),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // NÚT FACEBOOK
                    GestureDetector(
                      onTap: _handleFacebookSignIn, // <--- Gọi hàm xử lý
                      child: const _SocialBtn(
                        child: Icon(Icons.facebook, color: Colors.blue, size: 30),
                      ),
                    ),
                  ]),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper tạo Style cho Input để code gọn hơn
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      // Tự động đổi màu viền đỏ khi có lỗi
      errorStyle: const TextStyle(height: 0.8), 
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final Widget child;
  const _SocialBtn({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: child, 
    );
  }
}