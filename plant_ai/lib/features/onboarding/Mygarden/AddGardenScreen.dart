import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Effect/CustomBottomNavBar.dart';
import 'MyGardenScreen.dart';
import 'TodoListScreen.dart';
import 'ScanHistoryScreen.dart';
import '../Effect/ScanTutorialScreen.dart'; 
import '../../../../core/services/Checkin/JWT.dart'; 
import '../../../core/API/GardenAPI.dart';
import '../../../core/API/connection/garden_model.dart'; 
import 'MapPickerScreen.dart';
import 'package:geolocator/geolocator.dart'; 

// 🚀 QUAN TRỌNG: Import cái LocationService của ông vào đây
import '../../../../core/services/LocationService.dart'; 

class AddGardenScreen extends StatefulWidget {
  const AddGardenScreen({super.key});

  @override
  State<AddGardenScreen> createState() => _AddGardenScreenState();
}

class _AddGardenScreenState extends State<AddGardenScreen> with SingleTickerProviderStateMixin {
  final Color plantGreen = const Color(0xFF8DAA5B);
  final Color inputBgColor = const Color(0xFFF3F4F6);
  final Color bgColor = const Color(0xFFF8F9F5);
  
  // 🚀 BIẾN LƯU TỌA ĐỘ GPS
  double? _currentLat;
  double? _currentLng;
  
  final List<String> _availablePlants = ['Cây cà phê', 'Cây lúa'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();
  String? _selectedSoilType = 'Đất phù sa';

  late AnimationController _animController;
  late Animation<Offset> _bottomBarSlideAnim;

  List<String> _addedCrops = [];
  bool _isLoading = false;
  bool _isLocating = false; // Trạng thái khi đang quét GPS

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bottomBarSlideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  // 1. HÀM MỞ BẢN ĐỒ ĐỂ "KÉO KÉO" (Đã cập nhật để nhận Tọa độ)
  void _handleOpenMap() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("Vui lòng bật GPS trên thiết bị");
      return;
    }

    // 🚀 Đổi kiểu dữ liệu nhận về thành Map<String, dynamic>?
    final Map<String, dynamic>? pickedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    // 🚀 Bóc tách dữ liệu nếu người dùng có bấm "Xác nhận"
    if (pickedData != null && mounted) {
      setState(() {
        _locationController.text = pickedData['address'];
        _currentLat = pickedData['lat']; // Lấy tọa độ từ Map
        _currentLng = pickedData['lng']; // Lấy tọa độ từ Map
      });
      _showSnackBar("📍 Đã lấy vị trí từ bản đồ!");
    }
  }

  // 🚀 2. HÀM TỰ ĐỘNG LẤY GPS (DÙNG LOCATION SERVICE CỦA ÔNG)
  void _handleGetLocation() async {
    setState(() => _isLocating = true);
    try {
      final locData = await LocationService.getCurrentAddress();
      
      setState(() {
        // Điền chuỗi địa chỉ đẹp vào Textfield
        _locationController.text = locData['full_address'] ?? "";
        
        // Hứng 2 cái tọa độ quý giá vào biến
        _currentLat = double.tryParse(locData['lat'] ?? "");
        _currentLng = double.tryParse(locData['lng'] ?? "");
      });
      _showSnackBar("📍 Đã lấy vị trí thành công!");
    } catch (e) {
      _showSnackBar("❌ Lỗi vị trí: $e");
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // 3. HÀM LƯU VƯỜN
  void _saveGarden() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      _showSnackBar("Vui lòng nhập tên và vị trí vườn");
      return;
    }

    setState(() => _isLoading = true);
    String? userId = await JWTService.getUserId();

    // ĐÓNG GÓI MODEL (CÓ TỌA ĐỘ)
    final garden = GardenModel(
      userId: userId ?? "GUEST_USER",
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      area: double.tryParse(_areaController.text) ?? 0.0,
      soilType: _selectedSoilType ?? "Đất phù sa",
      crops: _addedCrops,
      createdAt: DateTime.now(),
      // 🚀 NHÉT TỌA ĐỘ VÀO ĐÂY (NẾU CÓ)
      latitude: _currentLat,
      longitude: _currentLng,
    );

    bool isSuccess = await GardenAPI.addGarden(garden);
    setState(() => _isLoading = false);

    if (isSuccess && mounted) {
      _showSnackBar(" Đã thêm vườn thành công!");
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyGardenScreen()));
    }
  }

  void _showSnackBar(String msg) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 110,
        left: 20, right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF323232),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF8DAA5B), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    msg, 
                    style: GoogleFonts.roboto(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: plantGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("Thêm Vườn", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onSelected: (value) {
              if (value == "info") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyGardenScreen()));
              if (value == "task") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
              if (value == "history") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScanHistoryScreen()));
            },
            itemBuilder: (context) => [
              _buildPopupItem("Thông tin vườn", Icons.info_outline, "info"),
              _buildPopupItem("Công việc", Icons.assignment_outlined, "task"),
              _buildPopupItem("Lịch sử", Icons.history, "history"),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Thêm Đất Canh Tác", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              _buildLabel("Tên vườn/thửa"),
              _buildTextField(_nameController, "Ví dụ: Vườn rau sạch A"),

              _buildLabel("Vị trí"),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _locationController, 
                      "Địa chỉ...", 
                      icon: Icons.location_on_outlined
                    )
                  ),
                  const SizedBox(width: 8),
              
                  // NÚT CHỌN TRÊN BẢN ĐỒ
                  _buildActionSquareButton(Icons.map_outlined, _handleOpenMap),
                ],
              ),

              _buildLabel("Diện tích (m²)"),
              _buildTextField(_areaController, "500", isNumber: true),

              _buildLabel("Loại đất"),
              _buildDropdownField(),

              _buildLabel("Cây trồng"),
              if (_addedCrops.isNotEmpty) _buildCropTags(),
              const SizedBox(height: 8),
              _buildCropDropdown(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveGarden,
                style: ElevatedButton.styleFrom(
                  backgroundColor: plantGreen,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Thêm đất canh tác', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SlideTransition(
        position: _bottomBarSlideAnim,
        child: FloatingActionButton(
            heroTag: "scanBtnAdd",
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
        child: CustomBottomNavBar(selectedIndex: 1, onItemTapped: (index) {}),
      ),
    );
  }

  // --- WIDGET HỖ TRỢ NÚT VUÔNG ĐỒNG BỘ ---
  Widget _buildActionSquareButton(IconData icon, VoidCallback? onTap, {bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52, width: 52,
        decoration: BoxDecoration(
          color: plantGreen, 
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: plantGreen.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: isLoading 
          ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCropDropdown() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: inputBgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        hint: Text("Chọn loại cây trồng", style: GoogleFonts.roboto(fontSize: 14)),
        isExpanded: true,
        items: _availablePlants.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              if (!_addedCrops.contains(newValue)) {
                _addedCrops.add(newValue);
              } else {
                _showSnackBar("Cây này đã có trong danh sách!");
              }
            });
          }
        },
      ),
    ),
  );
}

  Widget _buildCropTags() {
    return Wrap(spacing: 8, children: _addedCrops.map((crop) => Chip(label: Text(crop, style: const TextStyle(fontSize: 12)), onDeleted: () => setState(() => _addedCrops.remove(crop)), backgroundColor: plantGreen.withOpacity(0.1), deleteIconColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))).toList());
  }

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, String value) {
    return PopupMenuItem<String>(value: value, child: Row(children: [Icon(icon, color: plantGreen, size: 20), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))]));
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0, top: 16.0), child: Text(text, style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon, bool isNumber = false}) {
    return TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: InputDecoration(hintText: hint, prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null, filled: true, fillColor: inputBgColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }

  Widget _buildDropdownField() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedSoilType, isExpanded: true, items: <String>['Đất phù sa', 'Đất đỏ Bazan', 'Đất thịt', 'Đất cát'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (val) => setState(() => _selectedSoilType = val))));
  }
}