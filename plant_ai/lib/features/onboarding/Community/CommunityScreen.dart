import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// --- IMPORT CÁC FILE CỦA CAPTAIN ---
import '../Effect/CustomBottomNavBar.dart'; 
import '../../../core/API/CommunityAPI.dart';
import '../../../core/API/UserAPI.dart'; // Sửa đường dẫn API
import '../../../core/API/connection/PostModel.dart';  // Sửa đường dẫn Model
import '../Effect/CommentBottomSheet.dart';
import '../Effect/ScanTutorialScreen.dart';   
import 'AddPostScreen.dart';
import '../Effect/LikeButton.dart'; // Sửa đường dẫn file BottomSheet

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedIndex = 2;
  String userName = "Đang tải...";
  String currentUserEmail = "";
  String? userAvatar;
  String currentUserId = "";

  final Color colorGreenDark = const Color(0xFF80A252); 
  final Color colorGreenLight = const Color(0xFFBFD1A8);

  // 1. BIẾN CHỨA DỮ LIỆU TỪ SERVER
  late Future<List<PostModel>> _futurePosts;

  @override
  void initState() {
    super.initState();
    // Gọi API lấy bài viết ngay khi vừa mở trang
    _futurePosts = CommunityAPI.getPosts();
    _loadUser();
  }

  void _showDeletePostDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text("Xóa bài viết", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          "Bạn có chắc chắn muốn xóa bài viết này khỏi cộng đồng? Hành động này không thể hoàn tác.",
          style: GoogleFonts.roboto(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy", style: GoogleFonts.roboto(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              // Đóng dialog xác nhận
              Navigator.pop(context); 

              // Hiện vòng xoay Loading (để người dùng không bấm lung tung)
              showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white))
              );

              // 🚀 Gọi API thần thánh mà ông đã viết
              bool isDeleted = await CommunityAPI.deletePost(postId); 

              // Tắt vòng xoay Loading
              if (mounted) Navigator.pop(context);

              if (isDeleted && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa bài viết khỏi cộng đồng!")),
                );
                // 🚀 QUAN TRỌNG: Gọi lại API load bài để làm mới bảng tin
                setState(() {
                  _futurePosts = CommunityAPI.getPosts();
                });
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lỗi: Không thể xóa bài viết lúc này.")),
                );
              }
            },
            child: Text("Xóa ngay", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  

  // --- HÀM TIỆN ÍCH: TÍNH THỜI GIAN ĐĂNG BÀI ---
  String _getTimeAgo(DateTime createdAt) {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inDays > 0) return '${duration.inDays} ngày trước';
    if (duration.inHours > 0) return '${duration.inHours} giờ trước';
    if (duration.inMinutes > 0) return '${duration.inMinutes} phút trước';
    return 'Vừa xong';
  }
  // Tương tác nút tim
  
  
  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('current_user_email'); 
      print("📧 [DEBUG] Email từ bộ nhớ: $email"); 
      
      if (email != null && email.isNotEmpty) {
        setState(() => currentUserEmail = email);
        
        // Gọi API lấy thông tin chi tiết từ MongoDB
        var userMap = await UserAPI.getUserByEmail(email);
        print("👤 [DEBUG] Dữ liệu MongoDB trả về: $userMap"); 
        
        if (mounted) {
          setState(() {
            if (userMap != null) {
              // 🛑 FIX XUNG ĐỘT: Dùng mongo.ObjectId để Flutter không bị nhầm lẫn
              final dynamic rawId = userMap['_id'];
              
              if (rawId is mongo.ObjectId) {
                // Nếu là đối tượng ObjectId chuẩn, dùng toHexString()
                currentUserId = rawId.toHexString(); 
              } else {
                // Nếu là chuỗi đã dính chữ ObjectId("..."), ta lọc bỏ nó
                currentUserId = rawId.toString()
                    .replaceAll('ObjectId("', '')
                    .replaceAll('")', ''); 
              }

              String? fetchedName = userMap['username'] ?? userMap['name'];
              userAvatar = userMap['avatar'];
              
              if (fetchedName != null && fetchedName.trim().isNotEmpty) {
                userName = fetchedName; 
              } else {
                userName = email; 
              }
            } else {
              userName = "Lỗi: Không tìm thấy User DB"; 
            }
          });
        }
      } else {
        if (mounted) setState(() => userName = "Khách");
      }
    } catch (e) {
      print("❌ [DEBUG] Lỗi ở _loadUser Community: $e");
      if (mounted) setState(() => userName = "Lỗi kết nối");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),

              // 2. DÙNG FUTURE BUILDER ĐỂ HIỂN THỊ DỮ LIỆU THẬT
              Expanded(
                child: FutureBuilder<List<PostModel>>(
                  future: _futurePosts,
                  builder: (context, snapshot) {
                    // Đang tải dữ liệu
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF80A252)));
                    } 
                    // Nếu có lỗi
                    else if (snapshot.hasError) {
                      return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}", style: GoogleFonts.roboto()));
                    } 
                    // Nếu DB trống
                    else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("Chưa có bài viết nào trong cộng đồng.", style: GoogleFonts.roboto(color: Colors.grey)));
                    }

                    // Lấy danh sách đổ lên UI
                    final posts = snapshot.data!;

                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 10, bottom: 100), 
                      itemCount: posts.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.black12, thickness: 1, height: 1),
                      itemBuilder: (context, index) {
                        return _buildPostItem(posts[index]); // Truyền nguyên Object PostModel vào
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: "addPostBtn", 
              // 🛑 Chỉ liên kết sang trang AddPostScreen, không chờ kết quả
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPostScreen(
                      passedUserName: userName, // (Biến lấy từ trang Home/Community của ông)
                      passedUserEmail: currentUserEmail, 
                      passedUserAvatar: userAvatar,)),
                );
              },
              backgroundColor: colorGreenDark,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildScanFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildHeader() {
    return Container(
      // Giảm padding left/right xuống 0 vì không còn vật cản nào nữa
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorGreenLight.withOpacity(0.5), Colors.white], 
          stops: const [0.0, 1.0],
        ),
      ),
      child: Row(
        // 🛑 ĐÂY LÀ DÒNG QUYẾT ĐỊNH: Đẩy mọi thứ trong hàng vào giữa
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Text(
            'Cộng đồng',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BÀI VIẾT TỪ DỮ LIỆU THẬT ---
Widget _buildPostItem(PostModel post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thông tin người đăng & NÚT XÓA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Đẩy mọi thứ lên ngang hàng
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,                
                  backgroundImage: (post.author.avatar != null && post.author.avatar.isNotEmpty)
                      ? (post.author.avatar.startsWith('http') 
                          ? NetworkImage(post.author.avatar) 
                          : FileImage(File(post.author.avatar.replaceFirst('file://', ''))) as ImageProvider)
                      : null,
                  child: (post.author.avatar == null || post.author.avatar.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey, size: 20)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // 🚀 Gói tên và thời gian vào Expanded để đẩy nút Xóa sát lề phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.displayName,
                      style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTimeAgo(post.createdAt),
                      style: GoogleFonts.roboto(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              
              // 🛑 KIỂM TRA CHÍNH CHỦ: Chỉ hiện nút thùng rác nếu bài này của người đang đăng nhập
              if (post.author.id == currentUserId)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(), // Xóa khoảng trắng thừa của icon
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  onPressed: () => _showDeletePostDialog(post.id),
                ),
            ],
          ),
          
          const SizedBox(height: 15),

          // 2. Nội dung text
          Text(
            post.content,
            style: GoogleFonts.roboto(fontSize: 15, color: Colors.black87, height: 1.4),
          ),

          // 3. Hình ảnh đính kèm (Nếu có)
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.imageUrl!.startsWith('http') 
                ? Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImageErrorWidget(),
                  )
                : Builder(
                    builder: (context) {
                      String cleanPath = post.imageUrl!.replaceFirst('file://', '');
                      File imgFile = File(cleanPath);
                      if (!imgFile.existsSync()) {
                        return _buildImageErrorWidget();
                      }
                      return Image.file(
                        imgFile,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImageErrorWidget(),
                      );
                    },
                  ),
            ),
          ],

          const SizedBox(height: 15),
          
          // 4. Các nút tương tác
          Row(
            children: [
              LikeButton(
                itemId: post.id,
                likedBy: post.likedBy,
                currentUserId: currentUserId,
                currentUserEmail: currentUserEmail,
              ),
              const SizedBox(width: 25),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent, 
                    builder: (context) => CommentBottomSheet(
                      post: post, 
                      currentUserId: currentUserId, 
                      currentUserEmail: currentUserEmail,
                    ),
                  ).then((_) {
                    setState(() {}); // Load lại số comment khi đóng bảng
                  });
                },
                child: _buildInteractionIcon(Icons.chat_bubble_outline, post.commentsCount.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildImageErrorWidget() {
  return Container(
    height: 200,
    width: double.infinity,
    color: Colors.grey[100],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
        const SizedBox(height: 8),
        Text("Ảnh không còn tồn tại trên thiết bị", 
             style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
      ],
    ),
  );
}

  Widget _buildInteractionIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        const SizedBox(width: 6),
        Text(
          count,
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildScanFAB() {
    return Container(
      height: 64, width: 64,
      child: FloatingActionButton(
        heroTag: "scanBtn",
        onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ScanTutorialScreen()),
              );
            },
        backgroundColor: Colors.white, 
        elevation: 4, 
        shape: const CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            
            const Icon(Icons.qr_code_scanner, color: Colors.black54, size: 28),
            Text("Scan", style: GoogleFonts.roboto(fontSize: 9, color: Colors.black54))
          ]
        ),
      ),
    );
  }
}