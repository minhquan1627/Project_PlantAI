import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async'; 
import 'dart:io'; //  Thêm để đọc ảnh từ file
import 'package:shared_preferences/shared_preferences.dart'; //  Thêm để lấy ID người dùng

import '../Effect/CustomBottomNavBar.dart';
import '../Effect/ScanTutorialScreen.dart';
import '../../../core/API/RecordAPI.dart'; //  Import API thật
import '../../../core/API/connection/scan_record.dart'; //  Import Model thật
import '../../../core/API/GardenAPI.dart';
import 'MyGardenScreen.dart';
import 'TodoListScreen.dart';
import 'AddGardenScreen.dart';

class ScanHistoryScreen extends StatefulWidget {
  final String? gardenId;  
  final String? gardenName;
  const ScanHistoryScreen({super.key, this.gardenId, this.gardenName});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> with SingleTickerProviderStateMixin {
  final Color plantGreen = const Color(0xFF8DAA5B);
  final Color bgColor = const Color(0xFFF8F9F5);

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // --- 🚀 BACKEND DATA VARIABLES ---
  List<ScanRecord> _allRecords = []; // Chứa toàn bộ lịch sử từ DB
  bool _isLoading = true; // Trạng thái đợi tải dữ liệu

  late AnimationController _animController;
  late Animation<Offset> _bottomBarSlideAnim;

  @override
  void initState() {
    super.initState();
    _fetchHistoryData(); // 🚀 Gọi dữ liệu ngay khi mở trang
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bottomBarSlideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  // --- 🚀 HÀM LẤY DỮ LIỆU TỪ MONGODB ---
  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      // Lấy ID người dùng thật (nếu ko có dùng ID mặc định để test)
      String userId = prefs.getString('current_user_id') ?? "69a0ffcd2723a2399fc03eb3"; 
      
      final data = await RecordAPI.fetchHistory(userId);
      for (var record in data) {
      if (record.gardenId != null && record.gardenId!.isNotEmpty) {
        // Gọi hàm mình vừa viết ở Bước 1
        String? name = await GardenAPI.fetchGardenNameById(record.gardenId!);
        
        record.gardenName = name; 
      }
    }
      setState(() {
        _allRecords = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Lỗi load history: $e");
    }
  }

  Widget _buildDynamicImage(String path) {
  const double size = 65.0;

  // ☁️ TRƯỜNG HỢP 1: ẢNH TRÊN CLOUD (Link Cloudinary)
  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: size, height: size, fit: BoxFit.cover,
      // Hiệu ứng đợi tải ảnh cho pro
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: size, height: size, color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (c, e, s) => _buildErrorIcon(),
    );
  } 
  
  // 📱 TRƯỜNG HỢP 2: ẢNH CỤC BỘ (Link /data/user/0/...)
  else {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, width: size, height: size, fit: BoxFit.cover);
    } else {
      // Nếu file đã bị xóa (do flutter clean/gỡ app)
      return _buildErrorIcon();
    }
  }
}

// Widget hiện icon lỗi khi không tìm thấy ảnh
Widget _buildErrorIcon() {
  return Container(
    width: 65, height: 65, 
    color: Colors.grey[200], 
    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20)
  );
}

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getDayKey(DateTime day) => DateFormat('yyyy-MM-dd').format(day);

  Future<void> _jumpToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: plantGreen)),
        child: child!,
      ),
    );
    if (picked != null) setState(() { _focusedDay = picked; _selectedDay = picked; });
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 THUẬT TOÁN: Lọc dữ liệu theo ngày đang chọn trên Calendar
    List<ScanRecord> dailyRecords = _allRecords.where((record) {
      return isSameDay(record.createdAt, _selectedDay);
    }).toList();

    // Sắp xếp thời gian mới nhất lên trên
    dailyRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: plantGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.gardenName != null ? "Lịch sử: ${widget.gardenName}" : "Lịch Sử Quét Bệnh", 
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white), 
            onPressed: _fetchHistoryData // Nút làm mới dữ liệu
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == "info") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyGardenScreen()));
              if (value == "task") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
              if (value == "add") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AddGardenScreen()));
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
      body: Column(
        children: [
          _buildTimelineHeader(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) // Hiện vòng xoay khi đang tải
              : dailyRecords.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 20, bottom: 100),
                    itemCount: dailyRecords.length,
                    itemBuilder: (context, index) => _buildHistoryTimelineRow(dailyRecords[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: SlideTransition(
        position: _bottomBarSlideAnim,
        child: SizedBox(
          height: 64, width: 64,
          child: FloatingActionButton(
            heroTag: "scanBtnHistory",
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SlideTransition(
        position: _bottomBarSlideAnim,
        child: CustomBottomNavBar(selectedIndex: 1, onItemTapped: (i) {}),
      ),
    );
  }

  Widget _buildTimelineHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: plantGreen, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
      child: Column(
        children: [
          InkWell(
            onTap: _jumpToDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat('MMMM yyyy', 'vi_VN').format(_focusedDay).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
          TableCalendar(
            locale: 'vi_VN', firstDay: DateTime.utc(2024, 1, 1), lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay, calendarFormat: _calendarFormat, headerVisible: false,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) => setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              selectedTextStyle: TextStyle(color: plantGreen, fontWeight: FontWeight.bold),
              todayDecoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(color: Colors.white70), weekendStyle: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // --- 🚀 HIỂN THỊ DÒNG TIMELINE VỚI GIỜ:PHÚT THẬT ---
  Widget _buildHistoryTimelineRow(ScanRecord record) {
    // Lấy giờ và phút chính xác từ trường createdAt
    String exactTime = DateFormat('HH:mm').format(record.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 50, 
              child: Text(exactTime, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))
            ),
            Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, color: Colors.grey[300]),
            Expanded(child: _buildScanResultCard(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResultCard(ScanRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Row(
        children: [
          // 📸 HIỂN THỊ ẢNH THẬT TỪ imagePath
          ClipRRect(
            borderRadius: BorderRadius.circular(12), 
            child: _buildDynamicImage(record.imagePath),
          ),
          const SizedBox(width: 12),
          
          // 📝 PHẦN CHỮ (Tên cây, Bệnh, và Tên vườn)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(record.plantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), 
                const SizedBox(height: 4), 
                Text(
                  record.diseaseVi, 
                  style: TextStyle(
                    color: record.diseaseVi == "Cây khỏe mạnh" ? plantGreen : Colors.redAccent, 
                    fontSize: 13
                  )
                ),
                
                // 🚀 HIỂN THỊ LABEL "THUỘC VƯỜN" NẾU ĐANG Ở TRANG TỔNG (Không có gardenId)
                if (widget.gardenId == null && record.gardenId != null && record.gardenId!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          "Đã gán vào ${record.gardenName}", // Nếu db của ông có lưu tên vườn thì thay bằng: record.gardenName
                          style: GoogleFonts.roboto(color: Colors.orange[700], fontSize: 11, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ]
            )
          ),

          // 🚀 CỤM NÚT BẤM (Gồm Tích Xanh + Nút Xóa)
          Row(
            mainAxisSize: MainAxisSize.min, // Gom 2 nút lại sát nhau
            children: [
              // 1. NÚT TÍCH XANH (CHỈ HIỆN KHI ĐANG MỞ TỪ 1 VƯỜN CỤ THỂ)
              if (widget.gardenId != null)
              //  ĐIỀU KIỆN XỬ LÝ NÚT THÊM VÀO VƯỜN:
                if (record.gardenId == null || record.gardenId == widget.gardenId)
                  IconButton(
                    icon: Icon(
                      record.gardenId == widget.gardenId ? Icons.check_circle : Icons.add_circle_outline,
                      color: record.gardenId == widget.gardenId ? plantGreen : Colors.grey,
                      size: 26,
                    ),
                    tooltip: record.gardenId == widget.gardenId ? "Gỡ khỏi vườn" : "Thêm vào vườn",
                    onPressed: () async {
                      if (record.gardenId == widget.gardenId) {
                        // Đã có -> Bấm để gỡ ra (Set null)
                        await RecordAPI.assignToGarden(record.id!, null);
                      } else {
                        // Chưa có -> Bấm để gắn vào vườn này
                        await RecordAPI.assignToGarden(record.id!, widget.gardenId);
                      }
                      _fetchHistoryData(); // Reload lại để cập nhật UI
                    },
                  ),

              // 2. NÚT XÓA (LUÔN LUÔN HIỆN NHƯ ÔNG MUỐN)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 26), 
                tooltip: "Xóa vĩnh viễn",
                onPressed: () => _confirmDelete(record)
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ScanRecord record) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteTimerDialog(onConfirm: () async {
        if (record.id != null) {
          // Gọi API xóa thật trên MongoDB
          await RecordAPI.deleteHistory(record.id!);
          // Sau khi xóa xong thì load lại dữ liệu
          _fetchHistoryData();
        }
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.manage_search, size: 80, color: Colors.grey[300]), const SizedBox(height: 16), Text("Ngày hôm nay không quét cây bệnh", style: TextStyle(color: Colors.grey[500]))]));
  }

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, String value) {
    return PopupMenuItem<String>(value: value, child: Row(children: [Icon(icon, color: plantGreen, size: 20), const SizedBox(width: 12), Text(title)]));
  }
}

// --- CLASS DIALOG RIÊNG BIỆT (Giữ nguyên logic 5s của ông) ---
class DeleteTimerDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  const DeleteTimerDialog({super.key, required this.onConfirm});

  @override
  State<DeleteTimerDialog> createState() => _DeleteTimerDialogState();
}

class _DeleteTimerDialogState extends State<DeleteTimerDialog> {
  int _counter = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) { setState(() => _counter--); } else { _timer?.cancel(); }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Xác nhận xóa"),
      content: const Text("Dữ liệu sẽ bị mất vĩnh viễn. Vui lòng chờ để xác nhận."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: _counter == 0 ? () { widget.onConfirm(); Navigator.pop(context); } : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, disabledBackgroundColor: Colors.grey[300]),
          child: Text(_counter > 0 ? "Chờ ($_counter s)" : "Xác nhận xóa", style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}