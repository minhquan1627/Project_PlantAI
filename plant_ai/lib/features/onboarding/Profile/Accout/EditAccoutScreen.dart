  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:image_picker/image_picker.dart';

  import '../../Effect/CustomBottomNavBar.dart';
  import '../../../../core/API/UserAPI.dart';
  import '../../Effect/ScanTutorialScreen.dart';

  class EditAccountScreen extends StatefulWidget {
    final Map<String, dynamic> userData;
    const EditAccountScreen({Key? key, required this.userData}) : super(key: key);
    
    @override
    State<EditAccountScreen> createState() => _EditAccountScreenState();
  }

  class _EditAccountScreenState extends State<EditAccountScreen> {
    int _selectedIndex = 3;
    late TextEditingController _nameController;
    late TextEditingController _locationController;
    
    String? _currentAvatar;
    final ImagePicker _picker = ImagePicker();

    bool _isLoading = false;
    @override
    void initState() {
      super.initState();
      // Khởi tạo dữ liệu từ trang Chi tiết truyền sang
      _nameController = TextEditingController(text: widget.userData['name'] ?? "");
      _locationController = TextEditingController(text: widget.userData['location'] ?? "");
      _currentAvatar = widget.userData['avatar'];
    }

    @override
    void dispose() {
      _nameController.dispose();
      _locationController.dispose();
      super.dispose();
    }

    // --- HÀM CHỌN ẢNH TỪ THƯ VIỆN ---
    Future<void> _pickAvatar() async {
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (image != null) {
          setState(() => _currentAvatar = image.path);
          _showFloatingSnackBar("Đã chọn ảnh mới!", isError: false);
        }
      } catch (e) {
        _showFloatingSnackBar("Không thể chọn ảnh.");
      }
    }

    // --- HÀM HIỆN THÔNG BÁO (FIX LỖI ĐÈ BOTTOMBAR) ---
    void _showFloatingSnackBar(String message, {bool isError = true}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message, style: GoogleFonts.roboto(color: Colors.white))),
            ],
          ),
          behavior: SnackBarBehavior.floating, 
          backgroundColor: isError ? Colors.black87 : const Color(0xFF8DAA5B),
          margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20), // Đẩy lên trên BottomBar
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F9F0),
        body: Stack(
          children: [
            // 1. BACKGROUND HEADER (GIỮ NGUYÊN BỐ CỤC CŨ)
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF2F9F0), Color(0xFFA1C083)],
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'CHỈNH SỬA TÀI KHOẢN',
                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 48), // Khoảng trống cân bằng
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // AVATAR CÓ THỂ CHỈNH SỬA
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white,
                            backgroundImage: (_currentAvatar == null || _currentAvatar!.trim().isEmpty)
                              ? const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png')
                              : (_currentAvatar!.startsWith('http') || _currentAvatar!.startsWith('https')
                                  ? NetworkImage(_currentAvatar!)
                                  : FileImage(File(_currentAvatar!)) as ImageProvider),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  
                  // DANH SÁCH Ô NHẬP LIỆU
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildEditItem(icon: Icons.eco_outlined, label: 'Tên Tài Khoản', controller: _nameController),
                          const SizedBox(height: 24),
                          _buildEditItem(icon: Icons.location_on_outlined, label: 'Địa Điểm', controller: _locationController),
                          const SizedBox(height: 40),
                          
                          
          

                          // NÚT CẬP NHẬT
                          ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              setState(() => _isLoading = true);

                              final String? userEmail = widget.userData['email'];
                              if (userEmail == null || userEmail.isEmpty) {
                                _showFloatingSnackBar("Lỗi: Không tìm thấy Email định danh!");
                                return;
                              }

                              String finalAvatar = _currentAvatar ?? ""; 

                              if (finalAvatar.isEmpty || finalAvatar.contains("pinimg.com") || finalAvatar == "null") {
                                  finalAvatar = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
                              }

                              // 🛑 TRIM dữ liệu để tránh lỗi khoảng trắng trong NCKH
                              Map<String, dynamic> updateData = {
                                'name': _nameController.text.trim(),
                                'location': _locationController.text.trim(),
                                'avatar': finalAvatar,
                                'updatedAt': DateTime.now().toIso8601String(),
                              };

                              print("📦 Đang lưu dữ liệu: $updateData");

                              String res = await UserAPI.updateUserProfile(userEmail, updateData);
                              
                              if (res.trim().toUpperCase() == "SUCCESS" || res.contains("SUCCESS")) {
                                _showFloatingSnackBar("Cập nhật thành công!", isError: false);
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) Navigator.pop(context, true); 
                                });
                              } else {
                                setState(() => _isLoading = false);
                                // Nếu vẫn báo ERROR nhưng thực tế lưu được, hãy kiểm tra lại file UserAPI.dart nhé!
                                _showFloatingSnackBar("Lỗi từ Server: $res");
                                print("LỖI THỰC SỰ LÀ: '$res'");
                                
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8DAA5B),
                              minimumSize: const Size(220, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Cập nhật',
                              style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // BOTTOM BAR & SCAN
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) => setState(() => _selectedIndex = index),
        ),
      );
    }

    // --- WIDGET Ô NHẬP LIỆU (DỰA TRÊN BỐ CỤC CŨ) ---
    Widget _buildEditItem({required IconData icon, required String label, required TextEditingController controller}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Colors.black87),
              const SizedBox(width: 12),
              Text(label, style: GoogleFonts.roboto(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
            ],
          ),
          TextField(
            controller: controller,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const Divider(color: Colors.black26, thickness: 1, height: 1),
        ],
      );
    }

    Widget _buildFAB() {
      return Container(
        height: 64, width: 64,
        child: FloatingActionButton(
          onPressed: () => 
          Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ScanTutorialScreen()),
          ), backgroundColor: Colors.white, elevation: 4, shape: const CircleBorder(),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.qr_code_scanner, color: Colors.black54),
            Text("Scan", style: GoogleFonts.roboto(fontSize: 9, color: Colors.black54))
          ]),
        ),
      );
    }
  }