import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Profile/UserProfileScreen.dart';
import '../HomeScreen.dart';
import '../Mygarden/MyGardenScreen.dart';
import '../Community/CommunityScreen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // BottomAppBar tự động xử lý Safe Area (tai thỏ, vạch home ảo)
    return BottomAppBar(
      shape: const CircularNotchedRectangle(), // Tạo vết cắn hình tròn
      notchMargin: 8.0, // Khoảng cách giữa nút Scan và vết cắn
      clipBehavior: Clip.antiAlias, // Bo viền mượt mà
      color: Colors.white,
      elevation: 20, // Đổ bóng cho nổi lên
      surfaceTintColor: Colors.white, // Fix lỗi ám màu trên Android 12+
      shadowColor: Colors.black45,
      padding: EdgeInsets.zero, // Quan trọng: bỏ padding mặc định để căn đều
      
      child: SizedBox(
        height: 60, // Chiều cao cố định chuẩn
        child: Row(
          // 🚀 KHÔNG DÙNG spaceAround NỮA, ĐỂ Expanded TỰ CHIA TỶ LỆ 1:1:1:1
          children: [
            // --- TRÁI ---
            Expanded(child: _buildNavItem(context, Icons.home_outlined, "Trang chủ", 0)),
            Expanded(child: _buildNavItem(context, Icons.eco_outlined, "Vườn của tôi", 1)),

            // --- KHOẢNG TRỐNG CHO NÚT SCAN ---
            const SizedBox(width: 72), 

            // --- PHẢI ---
            Expanded(child: _buildNavItem(context, Icons.language, "Cộng đồng", 2)),
            Expanded(child: _buildNavItem(context, Icons.person_outline, "Tôi", 3)),
          ],
        ),
      ),
    );
  }

  // Widget con cho từng item
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;
    // Màu xanh chủ đạo của App
    final Color activeColor = const Color(0xFF80A252); 
    final Color inactiveColor = Colors.grey.shade400;

    return InkWell(
      onTap: () {
        // 🛑 BẢO VỆ LOGIC: Bấm tab đang đứng thì không làm gì cả
        if (selectedIndex == index) return;

        // --- DÙNG PUSH REPLACEMENT ĐỂ TỐI ƯU RAM ---
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), 
          );
        } 
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyGardenScreen()), 
          );
        } 
        else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CommunityScreen()), 
          );
        } 
        else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserProfileScreen()), 
          );
        } 
        else {
          onItemTapped(index);
        }
      },
      borderRadius: BorderRadius.circular(30), // Hiệu ứng ripple tròn
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}