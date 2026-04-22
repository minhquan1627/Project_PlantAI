import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// --- ĐẢM BẢO IMPORT ĐÚNG ĐƯỜNG DẪN CỦA ÔNG ---
import '../../../core/API/CommunityAPI.dart';

class AddPostScreen extends StatefulWidget {
  // 🛑 1. KHAI BÁO CÁC BIẾN SẼ NHẬN TỪ MÀN HÌNH TRƯỚC (Cộng đồng)
  final String passedUserName;
  final String? passedUserAvatar;
  final String passedUserEmail;

  const AddPostScreen({
    Key? key,
    required this.passedUserName,
    this.passedUserAvatar,
    required this.passedUserEmail,
  }) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final Color colorGreenDark = const Color(0xFF80A252); 
  final Color colorGreenLight = const Color(0xFFBFD1A8);

  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool isPosting = false;    // Chờ khi đang bấm Đăng bài

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // --- 2. LOGIC HIỂN THỊ AVATAR (Lấy từ tham số widget) ---
  Widget _buildAvatarImage() {
    final String? path = widget.passedUserAvatar; 

    if (path == null || path.trim().isEmpty) {
      return Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  // --- 3. LOGIC GỌI API ĐĂNG BÀI ---
  Future<void> _handlePost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung hoặc chọn ảnh!')));
      return;
    }

    if (widget.passedUserEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy thông tin định danh (Email)!')));
      return;
    }

    setState(() => isPosting = true); // Hiện vòng xoay loading

    // Lấy đường dẫn ảnh
    String? imageUrl = _selectedImage?.path; 

    // GỌI API ĐẨY LÊN MONGODB (Dùng email được truyền từ màn trước)
    String res = await CommunityAPI.createPost(
      authorEmail: widget.passedUserEmail,
      content: content,
      imageUrl: imageUrl, 
    );

    
    if (mounted) {
      setState(() => isPosting = false);
      if (res == "SUCCESS") {
        // Trả về true để trang CommunityScreen biết mà load lại Feed
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi từ Server: $res')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Thông tin người dùng ---
                  Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                        // GỌI HÀM VẼ AVATAR TRỰC TIẾP
                        child: _buildAvatarImage(),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          widget.passedUserName, // LẤY TÊN TỪ WIDGET HIỂN THỊ LUÔN
                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                        
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _contentController,
                    // 🛑 ĐÂY LÀ DÒNG QUAN TRỌNG NHẤT
                    keyboardType: TextInputType.multiline, 
                    autocorrect: false,
                    enableSuggestions: false,
                    
                    // 2. PHƯƠNG PHÁP ĐẶC TRỊ: 
                    // Thêm dòng này để ngăn chặn việc bộ gõ "gợi ý" đè lên chữ đang gõ
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[]')), // Một mẹo để reset bộ lọc
                    ],
                    onChanged: (value) {         
                    },
                    maxLines: 8,
                    minLines: 5,
                    style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Nội dung",
                      hintStyle: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[400]),
                      border: InputBorder.none, 
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Divider(color: Colors.black12, thickness: 1), 
                  const SizedBox(height: 10),

                  // _buildOptionRow(Icons.public, "Ai là người có thể xem bài đăng này ?"),
                  // const SizedBox(height: 15),
                  // _buildOptionRow(Icons.settings_outlined, "Tùy chọn bài đăng"),
                  // const SizedBox(height: 25),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // 🛑 KHIÊN BẢO VỆ 1: Check xem biến có null không VÀ file có còn trong máy không
                      child: (_selectedImage != null && _selectedImage!.existsSync())
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10), 
                              child: Image.file(
                                _selectedImage!, 
                                fit: BoxFit.cover, 
                                width: double.infinity,
                                // Phòng hờ thêm errorBuilder cho chắc cú
                                errorBuilder: (context, error, stackTrace) => _buildPickImagePlaceholder(),
                              ),
                            )
                          : _buildPickImagePlaceholder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- HAI NÚT BẤM CÓ LOADING ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isPosting ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text("Đăng sau", style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    // 🛑 KHÔNG CẦN CHỜ LOAD USER NỮA NÊN BỎ isLoadingUser ĐI
                    onPressed: isPosting ? null : _handlePost, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorGreenDark, 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: isPosting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Đăng bài", style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickImagePlaceholder() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.image_outlined, size: 40, color: Colors.black87),
      const SizedBox(height: 8),
      Text("Thêm hình ảnh", style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[400]))
    ],
  );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 10, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorGreenLight.withOpacity(0.5), Colors.white], 
          stops: const [0.0, 1.0],
        ),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
          Expanded(child: Text('Thêm Bài Đăng', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87), textAlign: TextAlign.center)),
          const SizedBox(width: 40), 
        ],
      ),
    );
  }

}