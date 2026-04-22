import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
// --- ĐẢM BẢO CÁC IMPORT NÀY CHUẨN ---
import '../../../../core/API/connection/PostModel.dart';
import '../../../../core/API/CommunityAPI.dart';
import '../../Effect/CommentBottomSheet.dart';
import '../../../../core/API/UserAPI.dart'; 
import '../../Effect/CustomBottomNavBar.dart';
import '../../Effect/LikeButton.dart';
import '../../Community/AddPostScreen.dart';
import '../NotificationScreen.dart';
import '../../AI/ChatBotAIScreen.dart';

class PostManagerScreen extends StatefulWidget {
  const PostManagerScreen({Key? key}) : super(key: key);

  @override
  State<PostManagerScreen> createState() => _PostManagerScreenState();
}

class _PostManagerScreenState extends State<PostManagerScreen> {
  final Color colorGreenDark = const Color(0xFF80A252);
  final Color colorGreenLight = const Color(0xFFBFD1A8);
  
  late Future<List<PostModel>> _userPosts;
  int _selectedIndex = 4; 
  String userName = "Đang tải...";
  String? userAvatar;
  bool isLoading = true;
  String currentUserEmail = "";
  String currentUserId = "";

  @override
  void initState() {
    super.initState();
    _userPosts = Future.value([]); // Khởi tạo giá trị rỗng ban đầu
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('current_user_email');
    if (email != null && email.isNotEmpty) {
      setState(() {
        currentUserEmail = email;
        // Gán dữ liệu thật từ API
        _userPosts = CommunityAPI.getPostsByUser(email); 
      });
      await _fetchUserProfile();
    } else {
      setState(() { userName = "Khách"; isLoading = false; });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      var userMap = await UserAPI.getUserByEmail(currentUserEmail);
      if (mounted && userMap != null) {
        setState(() {
          // 🛑 4. LẤY ID CHUẨN 24 KÝ TỰ
          final dynamic rawId = userMap['_id'];
          if (rawId is mongo.ObjectId) {
            currentUserId = rawId.toHexString();
          } else {
            currentUserId = rawId.toString()
                .replaceAll('ObjectId("', '')
                .replaceAll('")', '');
          }

          userName = userMap['username'] ?? userMap['name'] ?? "User";
          userAvatar = userMap['avatar'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận xóa", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        content: const Text("Ông có chắc muốn xóa bài viết này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await CommunityAPI.deletePost(postId);
              if (success) {
                setState(() {
                  _userPosts = CommunityAPI.getPostsByUser(currentUserEmail);
                });
                
              }
            },
            child: const Text("Xóa ngay", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 🛑 FIXED: Dùng Column trực tiếp, không bọc SingleChildScrollView ở ngoài
      body: Column(
        children: [
          _buildHeader(),
          _buildStatusInput(),
          const Divider(thickness: 1, color: Colors.black12),
          
          // 🛑 FIXED: Expanded bọc FutureBuilder để ListView có không gian cuộn chuẩn
          Expanded(
            child: FutureBuilder<List<PostModel>>(
              future: _userPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF80A252)));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi tải dữ liệu"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Chưa có bài đăng nào!", style: GoogleFonts.roboto(color: Colors.grey)));
                }

                final posts = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: posts.length,
                  itemBuilder: (context, index) => _buildRealPostItem(posts[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  // --- ITEM BÀI VIẾT THẬT ---
  Widget _buildRealPostItem(PostModel post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(child: Container(width: 40, height: 40, child: _buildAvatarImage(post.author.avatar))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author.displayName, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                    Text("Vừa xong", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(post.content, style: GoogleFonts.roboto(fontSize: 15, height: 1.4)),
          const SizedBox(height: 12),
          _buildPostImage(post.imageUrl),
          const SizedBox(height: 15),
          Row(  
            children: [
              LikeButton(
                itemId: post.id,               // 🛑 Thay post bằng itemId
                likedBy: post.likedBy,
                currentUserId: currentUserId,
                currentUserEmail: currentUserEmail,
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Cho phép kéo trượt
                    backgroundColor: Colors.transparent, 
                    builder: (context) => CommentBottomSheet(
                      post: post, 
                      currentUserId: currentUserId, 
                      currentUserEmail: currentUserEmail,
                    ), 
                  ).then((_) {
                    // 🛑 Cập nhật con số: Khi vuốt đóng bảng comment, ép màn hình vẽ lại để hiện số mới
                    setState(() {});
                  });
                },
                child: _buildPostStat(Icons.chat_bubble_outline, post.commentsCount.toString()),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(post.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM UI HỖ TRỢ (GIỮ NGUYÊN) ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        gradient: LinearGradient(
          colors: [Colors.white, colorGreenLight, colorGreenDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // 1. Avatar
          Container(
            width: 50, height: 50, // Thu nhỏ avatar lại một chút cho thanh thoát
            decoration: BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
            ),
            child: ClipOval(child: _buildAvatarImage(userAvatar)),
          ),
          const SizedBox(width: 15),
          
          // 2. Tên User (🚀 Dùng Expanded để chiếm chỗ, tự động đẩy 2 cái nút kia sang phải)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLoading ? "Đang tải..." : userName,
                  style: GoogleFonts.roboto(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
          
          // 3. Cụm Icon góc phải
          GestureDetector(
            onTap: () {
              // Nối sang trang Chat AI 
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotAIScreen()));
            },
            child: _buildGlassIcon(Icons.smart_toy_outlined)
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
               // Nối sang NotificationScreen
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
            child: _buildNotificationIcon()
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.startsWith('http') 
          ? Image.network(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (c, e, s) => _errorImage())
          : Image.file(File(imageUrl.replaceFirst('file://', '').split('?')[0]), width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (c, e, s) => _errorImage()),
    );
  }

  Widget _errorImage() => Container(height: 200, width: double.infinity, color: Colors.grey[200], child: const Icon(Icons.broken_image_outlined, color: Colors.grey));

  Widget _buildAvatarImage(String? path) {
    if (path == null || path.isEmpty) return Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover);
    return path.startsWith('http') 
        ? Image.network(path, fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover))
        : Image.file(File(path.replaceFirst('file://', '')), fit: BoxFit.cover, errorBuilder: (c, e, s) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover));
  }


  Widget _buildGlassIcon(IconData icon) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 24));

  Widget _buildNotificationIcon() => Stack(children: [ _buildGlassIcon(Icons.notifications_none), Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Text("1", style: TextStyle(color: Colors.white, fontSize: 8))))]);

  Widget _buildStatusInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () async {
          // 1. Chuyển sang trang đăng bài và ĐỢI kết quả trả về
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(
                passedUserName: userName,
                passedUserEmail: currentUserEmail,
                passedUserAvatar: userAvatar,
              ),
            ),
          );

          // 2. Nếu đăng bài thành công (nhận về true), load lại danh sách bài viết
          if (result == true) {
            setState(() {
              _userPosts = CommunityAPI.getPostsByUser(currentUserEmail); // Cập nhật bài viết mới nhất
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: colorGreenDark,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              'Bạn đang nghĩ gì ?',
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostStat(IconData icon, String count) => Row(children: [Icon(icon, size: 20, color: Colors.black87), const SizedBox(width: 5), Text(count, style: GoogleFonts.roboto(color: Colors.grey))]);

  Widget _buildFAB() => Container(height: 64, width: 64, child: FloatingActionButton(onPressed: () {}, backgroundColor: Colors.white, elevation: 4, shape: const CircleBorder(), child: const Icon(Icons.qr_code_scanner, color: Colors.black54, size: 28)));
}