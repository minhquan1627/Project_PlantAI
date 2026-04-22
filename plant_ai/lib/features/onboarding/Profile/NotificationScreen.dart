import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/API/NotificationAPI.dart';
// 🚀 QUAN TRỌNG: Phải import cái Model này vào!
import '../../../core/API/connection/notification_model.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  final Color plantGreen = const Color(0xFF8DAA5B);
  late TabController _tabController;

  // ✅ BƯỚC 1: Đổi từ List<Map> sang List<NotificationModel>
  List<NotificationModel> _notifications = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await NotificationAPI.fetchNotifications();
      setState(() {
        // ✅ BƯỚC 2: Lúc này data và _notifications đã cùng "hệ" Model nên hết đỏ
        _notifications = data; 
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi tải thông báo: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Thông báo",
          style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // ✅ BƯỚC 3: Cập nhật đọc hết trên DB rồi load lại
              await NotificationAPI.markAllAsRead();
              _loadNotifications();
            },
            child: Text("Đọc hết", style: TextStyle(color: plantGreen, fontWeight: FontWeight.bold)),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: plantGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: plantGreen,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Tất cả"),
            Tab(text: "Cảnh báo"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(filterWarning: false),
              _buildNotificationList(filterWarning: true),
            ],
          ),
    );
  }

  Widget _buildNotificationList({required bool filterWarning}) {
    final filtered = filterWarning 
        ? _notifications.where((n) => n.type == 'warning').toList()
        : _notifications;

    if (filtered.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Dismissible(
          key: Key(item.id ?? index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.redAccent,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) async {
            if (item.id != null) {
              await NotificationAPI.deleteNotification(item.id!);
              setState(() => _notifications.removeWhere((n) => n.id == item.id));
            }
          },
          child: _buildNotificationItem(item),
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel item) {
    IconData icon;
    Color iconColor;

    // ✅ BƯỚC 4: Dùng dấu chấm (.) để truy cập thuộc tính của Model
    switch (item.type) {
      case 'warning': icon = Icons.warning_amber_rounded; iconColor = Colors.orange; break;
      case 'success': icon = Icons.check_circle_outline; iconColor = Colors.green; break;
      default: icon = Icons.notifications_none_rounded; iconColor = plantGreen;
    }

    String timeStr = DateFormat('HH:mm dd/MM').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : plantGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.isRead ? Colors.transparent : plantGreen.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.roboto(
            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.body, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 8),
            Text(timeStr, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
        onTap: () async {
          if (!item.isRead && item.id != null) {
            await NotificationAPI.markAsRead(item.id!); 
            _loadNotifications();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Không có thông báo nào", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }
}