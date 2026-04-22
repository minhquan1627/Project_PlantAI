import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plant_ai/features/onboarding/User/LoginScreen.dart';

class PlantAIFlow extends StatefulWidget {
  const PlantAIFlow({super.key});

  @override
  State<PlantAIFlow> createState() => _PlantAIFlowState();
}

class _PlantAIFlowState extends State<PlantAIFlow> {
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  void _startFlow() {
    // --- THAY ĐỔI Ở ĐÂY ---
    // Tăng thời gian chờ từ 3s lên 5s
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _step = 1);
      
      // Hết 5s thì chuyển sang Step 1 (Welcome) và DỪNG LẠI.
      // Không có timer thứ 2, chờ bấm nút.
    });
  }

  // Hàm chuyển sang màn Login khi bấm nút
  void _goToLogin() {
    if (mounted) setState(() => _step = 2);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        transitionBuilder: (child, animation) {
          if (child is LoginScreen) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart),
              ),
              child: child,
            );
          }
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_step == 0) return const _IntroScreen(key: ValueKey(0));
    
    // Màn hình Welcome nhận hàm _goToLogin
    if (_step == 1) return _WelcomeScreen(
      key: const ValueKey(1), 
      onNext: _goToLogin, 
    );
    
    return const LoginScreen(key: ValueKey(2));
  }
}

// --- HÌNH 1: INTRO (Tự động chuyển sau 5s) ---
class _IntroScreen extends StatelessWidget {
  const _IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9EAD86), Color(0xFFF2F7F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: const Color(0xFF8DAA5B).withOpacity(0.8), 
            child: Transform.translate(
              offset: const Offset(16, 0), 
              child: Transform.scale(
                scale: 3.0, 
                child: Image.asset("assets/images/Logo_PlantAI.png", color: Colors.white, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("PlantAI", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text("Ứng dụng nhận diện bệnh cây trồng thông qua hình ảnh lá cây", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF5A5A5A))),
          ),
        ],
      ),
    );
  }
}

// --- HÌNH 2: WELCOME (Có nút Tiếp tục) ---
class _WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  
  const _WelcomeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9EAD86), Color(0xFFF2F7F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          CircleAvatar(
            radius: 80,
            backgroundColor: const Color(0xFF8DAA5B),
            child: Transform.translate(
              offset: const Offset(16, 0),
              child: Transform.scale(
                scale: 3.0, 
                child: Image.asset("assets/images/Logo_PlantAI.png", color: Colors.white, fit: BoxFit.contain),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          const Text(
            "Chào mừng bạn đến với PlantAI",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
          ),
          
          const SizedBox(height: 20),
          
          // Hình ảnh Cà phê
          Image.asset(
            "assets/images/coffee_bean.png", 
            height: 280, 
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 10),
          
          const Text(
            "Dễ dàng nhận diện bệnh trên cây trồng",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF5A5A5A)),
          ),

          const SizedBox(height: 30),

          // NÚT TIẾP TỤC
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8DAA5B), 
                minimumSize: const Size(double.infinity, 55), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              onPressed: onNext, // Bấm vào đây mới chuyển trang
              child: const Text(
                "Tiếp tục", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}