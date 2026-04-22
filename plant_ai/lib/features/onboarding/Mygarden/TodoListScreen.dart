import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Effect/CustomBottomNavBar.dart';
import 'MyGardenScreen.dart';
import 'AddGardenScreen.dart';
import 'ScanHistoryScreen.dart';
import '../../../core/API/TaskAPI.dart';
import '../../../core/API/connection/task_model.dart';

class TaskListScreen extends StatefulWidget {
  final String? gardenId;  
  final String? gardenName;
  const TaskListScreen({super.key, this.gardenId, this.gardenName});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  final Color plantGreen = const Color(0xFF8DAA5B);
  final Color bgColor = const Color(0xFFF8F9F5);

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  List<TaskModel> _serverTasks = [];
  bool _isSyncing = false;

  late AnimationController _animController;
  late Animation<Offset> _bottomBarSlideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bottomBarSlideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _syncTasks();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _syncTasks() async {
    if (!mounted) return;
    setState(() => _isSyncing = true);
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('current_user_id') ?? "69a0ffcd2723a2399fc03eb3";
    
    final data = await TaskAPI.fetchDailyTasks(
      userId, 
      _selectedDay!, 
      gardenId: widget.gardenId
    );

    if (mounted) {
      setState(() {
        _serverTasks = data;
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: plantGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0, // Ép về 0 để căn giữa chuẩn
        centerTitle: true,
        title: Text(
          widget.gardenName ?? "Lịch Trình Chung", 
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == "info") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyGardenScreen()));
              if (value == "add") Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGardenScreen()));
              if (value == "history") Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanHistoryScreen()));
              if (value == "task") _syncTasks(); // Refresh trang hiện tại
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
          _buildCalendarHeader(),
          Expanded(
            child: _isSyncing 
              ? Center(child: CircularProgressIndicator(color: plantGreen))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 100),
                  itemCount: 24,
                  itemBuilder: (context, index) => _buildTimeRow(index),
                ),
          ),
        ],
      ),
      floatingActionButton: SlideTransition(
        position: _bottomBarSlideAnim,
        child: SizedBox(
          height: 64, width: 64,
          child: FloatingActionButton(
            heroTag: "scanBtn",
            onPressed: () {},
            backgroundColor: Colors.white,
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

  Widget _buildCalendarHeader() {
    return Container(
      decoration: BoxDecoration(
        color: plantGreen,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: TableCalendar(
        locale: 'vi_VN',
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _syncTasks();
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          formatButtonTextStyle: TextStyle(color: Colors.white),
          formatButtonDecoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.white)), borderRadius: BorderRadius.all(Radius.circular(12))),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.white70),
          weekendTextStyle: const TextStyle(color: Colors.orangeAccent),
          selectedDecoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          selectedTextStyle: TextStyle(color: plantGreen, fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
        ),
      ),
    );
  }

  // LOGIC HIỂN THỊ NHIỀU TASK TRONG 1 GIỜ
  Widget _buildTimeRow(int hour) {
    List<TaskModel> tasksAtHour = _serverTasks.where((t) => t.hour == hour).toList();
    String timeLabel = "${hour.toString().padLeft(2, '0')}:00";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 50, child: Text(timeLabel, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.grey[600]))),
          Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, color: Colors.grey[300], height: tasksAtHour.isEmpty ? 60 : null),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render danh sách công việc
                ...tasksAtHour.map((task) => _buildTaskCard(task)),
                
                // Nút thêm (Chỉ hiện nếu chưa đủ 5 việc)
                if (tasksAtHour.length < 5)
                  InkWell(
                    onTap: () => _showAddTaskDialog(hour),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        tasksAtHour.isEmpty ? "Trống - Chạm để thêm" : "+ Thêm việc khác (${tasksAtHour.length}/5)", 
                        style: GoogleFonts.roboto(color: Colors.grey[400], fontSize: 13, fontStyle: FontStyle.italic)
                      ),
                    ),
                  )
                else 
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(" Đã đạt giới hạn 5 việc", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 WIDGET HIỂN THỊ TỪNG CÔNG VIỆC CÓ NÚT XÓA
  Widget _buildTaskCard(TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: plantGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: plantGreen.withOpacity(0.3))
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(widget.gardenId == null ? Icons.push_pin : Icons.location_on, size: 12, color: widget.gardenId == null ? Colors.orange : plantGreen),
                    const SizedBox(width: 4),
                    Text(
                      widget.gardenId == null ? "Công việc chung" : "${widget.gardenName}",
                      style: TextStyle(fontSize: 11, color: widget.gardenId == null ? Colors.orange : plantGreen, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //  NÚT XÓA
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            onPressed: () async {
              if (task.id != null) {
                await TaskAPI.deleteTask(task.id!);
                _syncTasks();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(int hour) {
    // Check lại lần nữa cho chắc
    int count = _serverTasks.where((t) => t.hour == hour).length;
    if (count >= 5) return;

    TextEditingController taskCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thêm việc lúc ${hour}:00"),
        content: TextField(controller: taskCtrl, autofocus: true, decoration: const InputDecoration(hintText: "Nhập công việc...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: plantGreen),
            onPressed: () async {
              if (taskCtrl.text.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                String userId = prefs.getString('current_user_id') ?? "69a0ffcd2723a2399fc03eb3";
                final newTask = TaskModel(
                  userId: userId,
                  gardenId: widget.gardenId ?? "000000000000000000000000", 
                  title: taskCtrl.text,
                  date: _selectedDay!,
                  hour: hour,
                );
                await TaskAPI.addTask(newTask);
                await _syncTasks();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã lưu vào: ${widget.gardenName ?? 'Lịch trình chung'}"),
                      backgroundColor: plantGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(children: [Icon(icon, color: plantGreen, size: 20), const SizedBox(width: 12), Text(title)]),
    );
  }
}