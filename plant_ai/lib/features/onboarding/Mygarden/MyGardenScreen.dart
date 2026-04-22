import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AddGardenScreen.dart';
import 'TodoListScreen.dart';
import 'ScanHistoryScreen.dart';
import '../Effect/CustomBottomNavBar.dart'; 
import '../Effect/ScanTutorialScreen.dart';

// --- 🚀 IMPORT BACKEND ---
import '../../../../core/services/Checkin/JWT.dart';
import '../../../core/API/GardenAPI.dart';
import '../../../core/API/connection/garden_model.dart';
import '../../../core/API/NotificationAPI.dart';
import '../../../core/API/TaskAPI.dart';
import '../../../../core/services/weather_service.dart'; 

// 🚀 CLASS GỌI API THỜI TIẾT TÍCH HỢP (Có thể tách ra file riêng sau KLTN)
class WeatherAPI {
  // ⚠️ DÁN API KEY CỦA OPENWEATHERMAP VÀO ĐÂY:
  static const String _apiKey = '9d1e6f9c610523912f8220f058a4afdf'; 

  static Future<Map<String, double>?> getWeatherByCity(String location) async {
    try {
      // Mẹo: Cắt chuỗi lấy Tên Tỉnh/Thành phố ở cuối cùng (Ví dụ: "..., Hồ Chí Minh" -> "Hồ Chí Minh")
      List<String> parts = location.split(',');
      String city = parts.isNotEmpty ? parts.last.trim() : location;

      final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric&lang=vi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temp': data['main']['temp'].toDouble(),
          'humidity': data['main']['humidity'].toDouble(),
        };
      }
      return null;
    } catch (e) {
      print("❌ Lỗi gọi Thời tiết: $e");
      return null;
    }
  }
}

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> with SingleTickerProviderStateMixin {
  final int _selectedIndex = 1;
  late AnimationController _navController;
  late Animation<Offset> _bottomBarSlideAnim;

  final Color plantGreen = const Color(0xFF8DAA5B);
  final Color bgColor = const Color(0xFFF8F9F5);

  List<GardenModel> _userGardens = [];
  bool _isLoading = true;

  // 🚀 BIẾN LƯU TRỮ THỜI TIẾT THỰC TẾ (Key là ID vườn)
  Map<String, Map<String, double>> _realWeather = {};

  @override
  void initState() {
    super.initState();
    _loadGardens();
    _navController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bottomBarSlideAnim = Tween<Offset>(begin: const Offset(0, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _navController, curve: Curves.easeOut));
    _navController.forward();
  }

  Future<void> _loadGardens() async {
    setState(() => _isLoading = true);
    try {
      String? userId = await JWTService.getUserId();
      final gardens = await GardenAPI.fetchUserGardens(userId ?? "");
      
      setState(() {
        _userGardens = gardens;
        _isLoading = false;
      });

      // 🚀 SAU KHI TẢI VƯỜN XONG, GỌI API THỜI TIẾT CHẠY NGẦM
      _fetchWeatherForGardens(gardens);

    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Lỗi tải danh sách vườn: $e");
    }
  }

  //  HÀM QUÉT THỜI TIẾT LIVE CHO TẤT CẢ CÁC VƯỜN ĐANG HIỂN THỊ
  Future<void> _fetchWeatherForGardens(List<GardenModel> gardens) async {
    print("QUÉT THỜI TIẾT SONG SONG CHO ${gardens.length}");
    
    // 1. Tạo một danh sách các "Nhiệm vụ" (Futures)
    List<Future<void>> tasks = gardens.map((garden) async {
      if (garden.id != null) {
        Map<String, double>? weather;

        // Ưu tiên GPS, không có thì dùng địa chỉ chữ
        if (garden.latitude != null && garden.longitude != null) {
          weather = await WeatherService.getWeatherFromGPS(garden.latitude!, garden.longitude!);
        } else if (garden.location.isNotEmpty) {
          weather = await WeatherService.getWeather(garden.location);
        }

        if (weather != null && mounted) {
          setState(() {
            _realWeather[garden.id!] = weather!;
          });
        }
      }
    }).toList();

    // 2. Kích nổ: Chạy tất cả cùng lúc!
    await Future.wait(tasks);
    
    print("ĐÃ HOÀN TẤT TẤT CẢ CÁC LUỒNG THỜI TIẾT.");
  }

  void _confirmDelete(GardenModel garden) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa vườn '${garden.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (garden.id != null) {
                // 🚀 BƯỚC 1: XÓA SẠCH ĐÀN EM TRƯỚC
                await Future.wait([
                  TaskAPI.deleteAllTasksByGarden(garden.id!),
                  NotificationAPI.deleteAllNotificationsByGarden(garden.id!),
                  // Nếu có thêm ảnh hay gì đó thì bỏ vào đây luôn
                ]);

                // 🚀 BƯỚC 2: XÓA ÔNG TRÙM (VƯỜN)
                bool success = await GardenAPI.deleteGarden(garden.id!);
                
                if (success && mounted) {
                  Navigator.pop(context);
                  _loadGardens();
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Đã giải tán vườn và các dữ liệu liên quan!"),
                      behavior: SnackBarBehavior.floating, // Biến thành dạng nổi
                      backgroundColor: Colors.black87, // Đổi màu nền nếu thích
                      margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20), // Đẩy nó cao lên trên nút Scan
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bo góc cho chuẩn UX hiện đại
                      ),
                      duration: const Duration(seconds: 3), // Tự tắt sau 3 giây
                    )
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: plantGreen,
        automaticallyImplyLeading: false,
        title: const Text('Vườn của tôi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadGardens),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onSelected: (value) {
              if (value == "add") Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGardenScreen()));
              if (value == "task") Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
              if (value == "history") Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanHistoryScreen()));
            },
            itemBuilder: (context) => [
              _buildPopupItem("Thông tin vườn", Icons.info_outline, "info"),
              _buildPopupItem("Thêm vườn", Icons.add_circle_outline, "add"),
              _buildPopupItem("Công việc", Icons.assignment_outlined, "task"),
              _buildPopupItem("Lịch sử", Icons.history, "history"),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _userGardens.isEmpty 
          ? _buildEmptyState() 
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ..._userGardens.map((garden) => _buildGardenCard(garden)).toList(),
                  const SizedBox(height: 120), 
                ],
              ),
            ),
      floatingActionButton: SlideTransition(
        position: _bottomBarSlideAnim,
        child: FloatingActionButton(
            heroTag: "scanBtnGarden",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanTutorialScreen()));
            },
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
      bottomNavigationBar: SlideTransition(
        position: _bottomBarSlideAnim,
        child: CustomBottomNavBar(selectedIndex: _selectedIndex, onItemTapped: (index) {}),
      ),
    );
  }

  Widget _buildGardenCard(GardenModel garden) {
    // 🚀 ĐỒNG BỘ HIỂN THỊ DỮ LIỆU THỜI TIẾT
    String tempDisplay = '--°C';
    String humDisplay = '--%';

    // Nếu API đã lấy được thời tiết thì lấy ra xài
    if (_realWeather.containsKey(garden.id)) {
      tempDisplay = '${_realWeather[garden.id]!['temp']!.toStringAsFixed(1)}°C';
      humDisplay = '${_realWeather[garden.id]!['humidity']!.toInt()}%';
    } else {
      // Nếu API lỗi hoặc đang load, lấy tạm data trong MongoDB (từ code trước)
      if (garden.temperature > 0) tempDisplay = '${garden.temperature}°C';
      if (garden.humidity > 0) humDisplay = '${garden.humidity}%';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(
                height: 140, width: double.infinity,
                color: plantGreen.withOpacity(0.1),
                child: Center(child: Icon(Icons.yard_outlined, size: 50, color: plantGreen)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          garden.name, 
                          style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 26),
                        onPressed: () => _confirmDelete(garden),
                        padding: EdgeInsets.zero, 
                        constraints: const BoxConstraints(), 
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(garden.location, style: TextStyle(color: Colors.grey[600], fontSize: 14), overflow: TextOverflow.ellipsis),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 🚀 LƯỚI THÔNG SỐ SỬ DỤNG DATA REAL-TIME
                  GridView.count(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, 
                    mainAxisSpacing: 10, 
                    crossAxisSpacing: 10, 
                    childAspectRatio: 2.5,
                    children: [
                      _buildMetricTile('Diện tích', '${garden.area} m²', Icons.square_foot),
                      _buildMetricTile('Loại đất', garden.soilType, Icons.layers),
                      // Hiển thị data thật
                      _buildMetricTile('Độ ẩm', humDisplay, Icons.water_drop),
                      _buildMetricTile('Nhiệt độ', tempDisplay, Icons.thermostat),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: _buildNewActionButton(
                            "Thêm việc", 
                            Icons.add_task, 
                            Colors.white, 
                            plantGreen, 
                            () {
                              // 🚀 TRUYỀN DỮ LIỆU THẬT SANG ĐÂY NÈ QUÂN:
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (_) => TaskListScreen(
                                    // Giả sử 'garden' là biến chứa thông tin vườn hiện tại của ông
                                    gardenId: garden.id, 
                                    gardenName: garden.name, 
                                  )
                                )
                              );
                            }
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNewActionButton(
                          "Nhật ký quét", Icons.history, plantGreen, plantGreen.withOpacity(0.1), 
                          () {
                            // 🚀 ĐÃ SỬA: Truyền ID và Tên vườn sang để lọc & cho phép tích xanh
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (_) => ScanHistoryScreen(
                                  gardenId: garden.id, 
                                  gardenName: garden.name,
                                )
                              )
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewActionButton(String title, IconData icon, Color textColor, Color bgColor, VoidCallback onTap) {
    return Container(
      height: 52,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: plantGreen.withOpacity(0.5))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, size: 18, color: plantGreen),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _buildCropTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: plantGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Text(name, style: TextStyle(color: plantGreen, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Icon(Icons.yard_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          "Bạn chưa thêm khu vườn nào", 
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddGardenScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text("Thêm vườn ngay"),
          style: ElevatedButton.styleFrom(
            backgroundColor: plantGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ), 
      ], 
    ), 
  ); 
}

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, String value) {
    return PopupMenuItem<String>(value: value, child: Row(children: [Icon(icon, color: plantGreen, size: 20), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))]));
  }
}