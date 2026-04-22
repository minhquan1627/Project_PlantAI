import 'package:flutter/material.dart';

class PlantLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const PlantLoader({
    super.key, 
    this.size = 50.0, // Kích thước mặc định
    this.color,       // Màu sắc tùy chọn (nếu null sẽ lấy màu mặc định)
  });

  @override
  Widget build(BuildContext context) {
    // Màu chủ đạo PlantAI
    final Color primaryColor = const Color(0xFF8DAA5B); 
    // Màu thực tế sẽ dùng (ưu tiên màu truyền vào, nếu không thì dùng màu chủ đạo)
    final Color effectiveColor = color ?? primaryColor; 

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Vòng tròn xoay bên ngoài
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.5, // Độ dày nét vẽ
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              backgroundColor: effectiveColor.withOpacity(0.2), // Màu nền mờ phía sau
            ),
          ),
          
          // 2. Biểu tượng chiếc lá đứng yên ở giữa (Tạo điểm nhấn thương hiệu)
          Icon(
            Icons.eco, // Icon chiếc lá
            color: effectiveColor,
            size: size * 0.5, // Kích thước icon bằng 50% vòng tròn
          ),
        ],
      ),
    );
  }
}