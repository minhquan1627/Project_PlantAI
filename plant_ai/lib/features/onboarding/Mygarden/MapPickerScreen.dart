import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _currentCenter = const LatLng(10.762622, 106.660172); // Mặc định HCM
  String _address = "Đang xác định vị trí...";
  GoogleMapController? _mapController;
  bool _isInitialLoading = true; // Biến để hiện vòng xoay lúc mới vào

  @override
  void initState() {
    super.initState();
    // 🚀 Vừa vào trang là đi xin quyền và bật GPS luôn
    _checkPermissionAndGetLocation();
  }

  // 🚀 HÀM QUAN TRỌNG: Kiểm tra toàn diện GPS và Quyền
  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Kiểm tra xem máy đã bật GPS chưa
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Vui lòng bật GPS trên thiết bị để tiếp tục");
      setState(() => _isInitialLoading = false);
      return;
    }

    // 2. Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Bạn cần cho phép quyền truy cập vị trí");
        setState(() => _isInitialLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Quyền vị trí bị chặn. Vui lòng mở cài đặt để bật.");
      setState(() => _isInitialLoading = false);
      return;
    }

    // 3. Nếu mọi thứ OK, lấy vị trí hiện tại
    _goToUserLocation();
  }

  Future<void> _goToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      LatLng userLatLng = LatLng(position.latitude, position.longitude);
      
      _currentCenter = userLatLng;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 17));
      await _getAddressFromLatLng(userLatLng);
      
      setState(() => _isInitialLoading = false);
    } catch (e) {
      _showError("Lỗi khi lấy vị trí: $e");
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // 🚀 CHIÊU MỚI: Chỉ lấy những trường có dữ liệu
        List<String> parts = [];
        
        // Kiểm tra từng món, cái nào có thì mới thêm vào danh sách
        if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) parts.add(place.subAdministrativeArea!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) parts.add(place.administrativeArea!);

        setState(() {
          // Nối các phần lại bằng dấu phẩy, tự động bỏ qua các phần rỗng
          _address = parts.join(", "); 
          if (_address.isEmpty) _address = "Vị trí không xác định";
        });
      }
    } catch (e) {
      setState(() => _address = "Vị trí chưa xác định");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn vị trí vườn", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8DAA5B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Bản đồ Google
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentCenter, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) => _currentCenter = position.target,
            onCameraIdle: () => _getAddressFromLatLng(_currentCenter),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          
          // 2. Tâm đỏ cố định (Giúp người dùng ngắm cho chuẩn)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(Icons.location_on, color: Colors.red, size: 45),
            ),
          ),

          // 3. Nút GPS "Tâm điểm" (Xanh lá - Đúng yêu cầu của ông)
          Positioned(
            bottom: 200,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToUserLocation,
              backgroundColor: const Color(0xFF8DAA5B),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // 4. Panel thông tin địa chỉ
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_address, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    // 🚀 ĐỔI LẠI CHỖ NÀY: Trả về Map chứa cả Address và Tọa độ
                    onPressed: () {
                      Navigator.pop(context, {
                        'address': _address,
                        'lat': _currentCenter.latitude,
                        'lng': _currentCenter.longitude,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8DAA5B),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Xác nhận vị trí này", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          // 5. Màn hình Loading khi đang lấy GPS lần đầu
          if (_isInitialLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF8DAA5B)),
              ),
            ),
        ],
      ),
    );
  }
}