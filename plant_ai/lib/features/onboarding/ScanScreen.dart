import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // 🚀 THƯ VIỆN CAMERA
import 'package:image_picker/image_picker.dart'; // 🚀 THƯ VIỆN CHỌN ẢNH
import 'Effect/ScanTutorialScreen.dart';
import 'AI/LoadingAIScreen.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Lắng nghe trạng thái app (ẩn/hiện)
    _initCamera();
  }

  // --- HÀM KHỞI TẠO CAMERA THẬT ---
  Future<void> _initCamera() async {
    try {
      // Lấy danh sách camera trên máy
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Ưu tiên chọn Camera sau (Back camera)
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.max, // Độ phân giải cao nhất
        enableAudio: false,   // Quét ảnh nên không cần thu âm
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print("Lỗi khởi tạo Camera: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose(); // 🚀 Rất quan trọng: Tắt camera khi thoát trang để tránh hao pin
    super.dispose();
  }

  // Xử lý khi app bị ẩn xuống nền (background) hoặc bật lên lại
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // --- HÀM XỬ LÝ CHỤP ẢNH ---
  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    if (_cameraController!.value.isTakingPicture) return;

    try {
      // 1. Chụp ảnh
      XFile picture = await _cameraController!.takePicture();
      print("Tạch! Đã chụp thành công: ${picture.path}");
      
      // 2. Tắt Flash ngay sau khi chụp nếu đang bật
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      }

      // TODO: Ở ĐÂY LÀ CHỖ CHUYỂN FILE ẢNH ĐẾN TRANG KẾT QUẢ AI ĐỂ XỬ LÝ
      // File ảnh nằm ở biến: File(picture.path)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoadingAIScreen(imagePath: picture.path)), // Truyền đường dẫn ảnh qua
      );

    } catch (e) {
      print("Lỗi chụp ảnh: $e");
    }
  }

  // --- HÀM MỞ THƯ VIỆN ẢNH ---
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        // 🚀 Đẩy ảnh từ thư viện thẳng sang màn hình Loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingAIScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      print("Lỗi mở thư viện: $e");
    }
  }

  // --- HÀM BẬT TẮT ĐÈN FLASH ---
  void _toggleFlash() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch); // Bật sáng liên tục như đèn pin
        setState(() => _isFlashOn = true);
      }
    } catch (e) {
      print("Lỗi bật flash: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // =======================================================
          // 1. LỚP NỀN: CAMERA PREVIEW THẬT SỰ
          // =======================================================
          if (_isCameraInitialized)
            SizedBox.expand( // Kéo giãn Camera ra toàn màn hình
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Color(0xFF80A252))), // Quay quay chờ khởi tạo Camera

          // =======================================================
          // 2. LỚP LẤY NÉT: KHUNG VỊ TRÍ Ở GIỮA MÀN HÌNH
          // =======================================================
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: FocusFramePainter(),
              ),
            ),
          ),

          // =======================================================
          // 3. NÚT ĐIỀU HƯỚNG: TRÊN CÙNG
          // =======================================================
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanTutorialScreen()));
              },
              child: _buildTopButton(Icons.question_mark_rounded),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: _buildTopButton(Icons.close_rounded),
            ),
          ),

          // =======================================================
          // 4. THANH CÔNG CỤ DƯỚI ĐÁY (Frosted Glass)
          // =======================================================
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  height: 160,
                  color: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nút: Mở Thư viện ảnh
                      GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 1.5),
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          child: const Icon(Icons.photo_library, color: Colors.white, size: 24),
                        ),
                      ),

                      // Nút: Chụp ảnh (Shutter)
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80, height: 80,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),

                      // Nút: Bật/Tắt Flash
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isFlashOn ? Colors.white : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isFlashOn ? Colors.black : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, color: Colors.black87, size: 22),
    );
  }
}

// Khung lấy nét vẽ tay giữ nguyên
class FocusFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8)..strokeWidth = 6.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final double lineLength = 45.0; 
    final double cornerRadius = 24.0;
    var path = Path()..moveTo(0, lineLength)..lineTo(0, cornerRadius)..quadraticBezierTo(0, 0, cornerRadius, 0)..lineTo(lineLength, 0); canvas.drawPath(path, paint);
    path = Path()..moveTo(size.width - lineLength, 0)..lineTo(size.width - cornerRadius, 0)..quadraticBezierTo(size.width, 0, size.width, cornerRadius)..lineTo(size.width, lineLength); canvas.drawPath(path, paint);
    path = Path()..moveTo(0, size.height - lineLength)..lineTo(0, size.height - cornerRadius)..quadraticBezierTo(0, size.height, cornerRadius, size.height)..lineTo(lineLength, size.height); canvas.drawPath(path, paint);
    path = Path()..moveTo(size.width - lineLength, size.height)..lineTo(size.width - cornerRadius, size.height)..quadraticBezierTo(size.width, size.height, size.width, size.height - cornerRadius)..lineTo(size.width, size.height - lineLength); canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
