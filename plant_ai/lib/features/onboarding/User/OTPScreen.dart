import 'dart:async';
import 'package:flutter/material.dart';

// 1. IMPORT ĐÚNG ĐƯỜNG DẪN FILE LOGIN (Cùng cấp thư mục User)
import 'LoginScreen.dart';

// 2. IMPORT ĐÚNG ĐƯỜNG DẪN FILE CHECK OTP (Đi lùi 2 cấp thư mục)

import '../../../core/services/Checkin/CheckOTP.dart';
import '../../../../core/API/UserAPI.dart';
import '../Profile/UserProfileScreen.dart';

class OTPScreen extends StatefulWidget {
  final String name;
  final String email; // Nhận Email từ màn hình Đăng ký truyền sang
  final String password;
  final bool isResetPassword;
  final bool isForgotPassword;

  const OTPScreen(
      {super.key,
      required this.name,
      required this.email,
      required this.password,
      this.isResetPassword = false,
      this.isForgotPassword = false,});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // Logic đếm ngược
  int _secondsRemaining = 30;
  bool _canResend = false;
  Timer? _timer;

  // Quản lý 4 ô nhập số
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isSending = false; // Trạng thái đang gửi mail (để hiện loading)

  @override
  void initState() {
    super.initState();
    // Tự động gửi OTP ngay khi mở màn hình này
    _sendOTPAction();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  // --- HÀM GỌI SANG FILE CheckOTP.dart ---
  void _sendOTPAction() async {
    setState(() => _isSending = true);

    // Lấy email (Nếu null thì dùng email test)
    String emailNhan = widget.email;

    // Gọi hàm sendOTP -> Trả về True/False
    bool ketQuaGui = await OTPService().sendOTP(emailNhan);

    if (mounted) {
      setState(() => _isSending = false);

      if (ketQuaGui) {
        _startTimer(); // Gửi thành công thì mới đếm ngược
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Mã OTP đã được gửi về Email!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("❌ Lỗi gửi mail. Kiểm tra lại Email hoặc Mạng.")),
        );
      }
    }
  }

  // Logic đếm ngược 30s
  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        if (mounted) setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  // Nút "Gửi lại mã"
  void _resendCode() {
    if (_canResend) {
      // Xóa các ô nhập cũ
      for (var c in _controllers) c.clear();
      FocusScope.of(context).requestFocus(_focusNodes[0]);

      // Gửi lại
      _sendOTPAction();
    }
  }

  // --- HÀM XÁC NHẬN (Kiểm tra True/False) ---
  void _submitOTP() async {
    String codeNhapVao = _controllers.map((e) => e.text).join();

    if (codeNhapVao.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đủ 4 số")));
      return;
    }

    bool isCorrect = OTPService().verifyOTP(codeNhapVao);

    if (isCorrect) {
      // Hiện loading
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFF8DAA5B))));

      String result = "";
      if (widget.isResetPassword) {
        result = await UserAPI.resetPassword(widget.email, widget.password);
      } else {
        result = await UserAPI.registerUser(widget.name ,widget.email, widget.password);
      }

      if (mounted) Navigator.pop(context); // Tắt loading

      // --- LOGIC ĐIỀU HƯỚNG SAU KHI CÓ KẾT QUẢ ---
      if (result == "SUCCESS") {
        if (mounted) {
          if (widget.isResetPassword) {
            
            // 🚀 RẼ NHÁNH 1: NẾU LÀ QUÊN MẬT KHẨU -> VỀ TRANG ĐĂNG NHẬP
            if (widget.isForgotPassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🎉 Khôi phục mật khẩu thành công! Hãy đăng nhập lại."), backgroundColor: Color(0xFF8DAA5B)),
              );
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              });
            } 
            // 🚀 RẼ NHÁNH 2: NẾU LÀ ĐỔI MẬT KHẨU TỪ PROFILE -> VỀ LẠI PROFILE
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🎉 Đổi mật khẩu thành công!"), backgroundColor: Color(0xFF8DAA5B)),
              );
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                  (route) => route.isFirst,
                );
              });
            }

          } else {
            // 🚀 RẼ NHÁNH 3: ĐĂNG KÝ TÀI KHOẢN MỚI -> VỀ TRANG ĐĂNG NHẬP
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🎉 Đăng ký thành công! Đang tới trang đăng nhập..."), backgroundColor: Color(0xFF8DAA5B)),
            );
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            });
          }
        }
      } else if (result == "EMAIL_EXISTED") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⛔ Email này đã được sử dụng!"), backgroundColor: Colors.orange),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⛔ Lỗi hệ thống. Vui lòng thử lại."), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // OTP SAI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⛔ Mã OTP không đúng."), backgroundColor: Colors.redAccent),
      );
      for (var c in _controllers) c.clear();
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        // Canh giữa toàn bộ nội dung
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Xác thực OTP",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Text.rich(
                TextSpan(
                    text: "Mã OTP đã được gửi về Email:\n",
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87, height: 1.5),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8DAA5B)),
                      )
                    ]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Nếu đang gửi mail thì hiện vòng quay loading
              if (_isSending)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF8DAA5B)),
                    SizedBox(height: 20),
                    Text("Đang gửi mã OTP...",
                        style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 20),
                  ],
                ),

              // 4 ô nhập OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOTPBox(index)),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8DAA5B),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitOTP, // Nút Xác nhận
                child: const Text("Xác nhận",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _resendCode,
                    child: Text(
                      "Gửi lại mã",
                      style: TextStyle(
                        color:
                            _canResend ? const Color(0xFF8DAA5B) : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: _canResend
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  if (!_canResend)
                    Text(" (${_secondsRemaining}s)",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black45)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF8DAA5B), width: 2)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3)
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            else {
              FocusScope.of(context).unfocus();
              _submitOTP();
            }
          } else {
            if (index > 0)
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }
}
