import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/API/GardenAPI.dart';
import '../../../core/API/connection/garden_model.dart';

class GardenDetailScreen extends StatefulWidget {
  final GardenModel garden;
  const GardenDetailScreen({super.key, required this.garden});

  @override
  State<GardenDetailScreen> createState() => _GardenDetailScreenState();
}

class _GardenDetailScreenState extends State<GardenDetailScreen> {
  final Color plantGreen = const Color(0xFF8DAA5B);

  // 🚀 Hàm xử lý xóa vườn
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa khu vườn '${widget.garden.name}' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (widget.garden.id != null) {
                bool success = await GardenAPI.deleteGarden(widget.garden.id!);
                if (success && mounted) {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pop(context, true); // Quay về trang danh sách và báo hiệu đã xóa
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Đã xóa vườn")));
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: CustomScrollView(
        slivers: [
          // 1. Header với hiệu ứng Parallax và nút Back
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: plantGreen,
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white), onPressed: _confirmDelete),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [plantGreen, plantGreen.withOpacity(0.6)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                ),
                child: Center(child: Icon(Icons.yard_outlined, size: 80, color: Colors.white.withOpacity(0.5))),
              ),
            ),
          ),

          // 2. Nội dung chi tiết
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.garden.name, style: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.location_on, size: 18, color: plantGreen),
                    const SizedBox(width: 4),
                    Text(widget.garden.location, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  // Grid thông số
                  Text("Chỉ số vườn", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildInfoCard("Diện tích", "${widget.garden.area} m²", Icons.square_foot, Colors.orange),
                      _buildInfoCard("Loại đất", widget.garden.soilType, Icons.layers, Colors.brown),
                      _buildInfoCard("Độ ẩm", "65%", Icons.water_drop, Colors.blue),
                      _buildInfoCard("Nhiệt độ", "28°C", Icons.thermostat, Colors.redAccent),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Danh sách cây trồng
                  Text("Cây trồng đang canh tác", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  widget.garden.crops.isEmpty 
                    ? const Text("Chưa có cây trồng nào")
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.garden.crops.map((crop) => _buildCropItem(crop)).toList(),
                      ),

                  const SizedBox(height: 40),

                  // Nút hành động
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton("Thêm công việc", Icons.add_task, Colors.white, plantGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton("Nhật ký quét", Icons.history, plantGreen, plantGreen.withOpacity(0.1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCropItem(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: plantGreen.withOpacity(0.2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, color: plantGreen, size: 18),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color textColor, Color bgColor) {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: plantGreen)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}