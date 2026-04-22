import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/network_manager.dart';
import '../../../../core/services/Checkin/social_auth_service.dart';
import '../../../../core/API/UserAPI.dart';  
import '../../../../core/services/Checkin/JWT.dart'; // Import Service vừa tạo
import 'RegisterScreen.dart';
import 'ForgotpasswordScreen.dart';
import '../HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Biến trạng thái
  bool _isOffline = false; 
  bool _isPasswordVisible = false;
  bool _rememberPassword = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin(); // <--- 1. GỌI HÀM KIỂM TRA ĐĂNG NHẬP TỰ ĐỘNG ĐẦU TIÊN
    _setupNetworkListener(); 
    _loadUserCredentials(); 
  }

  // --- HÀM TỰ ĐỘNG ĐĂNG NHẬP (AUTO LOGIN) ---
  void _checkAutoLogin() async {
    bool isLogged = await JWTService.isLoggedIn();

    if (isLogged && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _setupNetworkListener() async {
    bool currentStatus = await NetworkManager().isOffline();
    if (mounted) {
      setState(() => _isOffline = currentStatus);
    }

    NetworkManager().onStatusChange.listen((isOffline) {
      if (mounted) {
        setState(() {
          _isOffline = isOffline;
        });
        print("📡 LoginScreen nhận tin: ${isOffline ? 'Đã mất mạng' : 'Đã có mạng'}");
      }
    });
  }

  void _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool('remember_me') ?? false;

    if (mounted) {
      setState(() {
        _rememberPassword = remember;
      });
    }

    if (remember) {
      String? savedEmail = prefs.getString('saved_email');
      String? savedPass = prefs.getString('saved_pass');
      
      if (mounted) {
        setState(() {
          _emailController.text = savedEmail ?? "";
          _passwordController.text = savedPass ?? "";
        });
      }
    }
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMsg("Vui lòng nhập đầy đủ Email và Mật khẩu");
      return;
    }

    setState(() => _isLoading = true);

    var user = await UserAPI.loginUser(
      _emailController.text.trim(), 
      _passwordController.text.trim()
    );

    setState(() => _isLoading = false);

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();

      // [QUAN TRỌNG] Lưu Token phiên đăng nhập
      // Giả sử API của ông trả về một trường 'token', nếu không có thì tạm tạo 1 chuỗi giả để test
      String userId = user['_id']?.toString() ?? ""; 
      await prefs.setString('current_user_id', userId);
  
      String sessionToken = user['token'] ?? "plant_ai_token_${DateTime.now().millisecondsSinceEpoch}";
      await prefs.setString('auth_token', sessionToken); 
      await prefs.setString('current_user_email', _emailController.text.trim());

      // Xử lý Ghi nhớ mật khẩu (Cái này là tiện ích gõ phím, KHÔNG liên quan đến phiên đăng nhập)
      if (_rememberPassword) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_pass', _passwordController.text.trim());
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_email');
        await prefs.remove('saved_pass');
      }
      
      if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
      }
    } else {
      _showMsg("Sai Email hoặc Mật khẩu, hoặc lỗi kết nối!");
    }
  }
  
  // --- XỬ LÝ ĐĂNG NHẬP GOOGLE ---
  void _handleGoogleSignIn() async {
    if (_isOffline) {
      _showMsg("Cần có mạng để đăng nhập Google");
      return;
    }
    setState(() => _isLoading = true);
    var user = await SocialAuthService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
        
        
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('current_user_id', user['_id'] ?? user['id'] ?? "");
        // [QUAN TRỌNG] Lưu Token cho tài khoản Google
        String sessionToken = user['token'] ?? "google_token_${DateTime.now().millisecondsSinceEpoch}";
        await prefs.setString('auth_token', sessionToken);
        await prefs.setString('current_user_email', user['email'] ?? "");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showMsg("Đã hủy đăng nhập Google.");
      }
    }
  }

  // --- XỬ LÝ ĐĂNG NHẬP FACEBOOK ---
  void _handleFacebookSignIn() async {
    if (_isOffline) {
      _showMsg("Cần có mạng để đăng nhập Facebook");
      return;
    }

    setState(() => _isLoading = true);

    var user = await SocialAuthService.signInWithFacebook();

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
         
         
         // LƯU TRẠNG THÁI ĐĂNG NHẬP TƯƠNG TỰ GOOGLE
         final prefs = await SharedPreferences.getInstance();
         await prefs.setBool('is_logged_in', true);
         await prefs.setString('current_user_email', user['email'] ?? "");

         Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
         );
      }
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Padding(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Text("Đăng nhập", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Chào mừng bạn đến với PlantAI"),
              const SizedBox(height: 40),

            if (_isOffline)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange)
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.deepOrange),
                    SizedBox(width: 10),
                    Expanded(child: Text("Không có kết nối mạng. Đã chuyển sang chế độ Offline.", style: TextStyle(color: Colors.deepOrange, fontSize: 13))),
                  ],
                ),
              ),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email", 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
              )
            ),
            
            const SizedBox(height: 20),
            
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, 
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: GestureDetector(
                  onTapDown: (_) => setState(() => _isPasswordVisible = true),
                  onTapUp: (_) => setState(() => _isPasswordVisible = false),
                  onTapCancel: () => setState(() => _isPasswordVisible = false),
                  child: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberPassword,
                        activeColor: const Color(0xFF8DAA5B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (bool? value) {
                          setState(() => _rememberPassword = value ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _rememberPassword = !_rememberPassword),
                      child: const Text("Lưu mật khẩu", style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  }, 
                  child: const Text(
                    "Quên mật khẩu?", 
                    style: TextStyle(color: Color(0xFF8DAA5B), fontWeight: FontWeight.bold)
                  )
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOffline ? Colors.orange : const Color(0xFF8DAA5B), 
                minimumSize: const Size(double.infinity, 55), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                shadowColor: const Color(0xFF8DAA5B).withOpacity(0.4),
              ),
              onPressed: () {
                if (_isOffline) {
                  print("🛠 Chế độ Offline: Mở Camera/Thư viện ngay!");
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => OfflineScanScreen()));
                } else {
                  if (!_isLoading) {
                        _handleLogin();
                  }
                }
              }, 
              child: _isLoading 
                  ? const SizedBox(
                      height: 25, 
                      width: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isOffline ? Icons.camera_alt : Icons.login, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        _isOffline ? "Chẩn đoán Offline ngay" : "Đăng nhập", 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  )
            ),
            
            const SizedBox(height: 30),

            if (!_isOffline) ...[
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Hoặc")), Expanded(child: Divider())]),
              const SizedBox(height: 20),
              
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // --- NÚT GOOGLE ---
                  GestureDetector(
                    onTap: _handleGoogleSignIn,
                    child: _SocialBtn(
                      child: Image.asset(
                        "assets/images/google_icon.png",
                        height: 30, width: 30,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.red),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // --- NÚT FACEBOOK ---
                  GestureDetector(
                    onTap: _handleFacebookSignIn, 
                    child: const _SocialBtn(
                      child: Icon(Icons.facebook, color: Colors.blue, size: 30),
                    ),
                  ),
                ]),
              
              const SizedBox(height: 30),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bạn chưa có tài khoản? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Đăng ký",
                    style: TextStyle(
                      color: Color(0xFF8DAA5B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            ],
            
            const SizedBox(height: 50),
          ],
        ),
        )),
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