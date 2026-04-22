import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
// --- IMPORT MODEL VÀ API CỦA ÔNG ---
import '../../../core/API/connection/PostModel.dart';
import '../../../core/API/CommunityAPI.dart';

// 🛑 IMPORT NÚT TIM ĐA NĂNG
import '../Effect/LikeButton.dart'; 

class CommentBottomSheet extends StatefulWidget {
  final PostModel post;
  final String currentUserEmail;
  final String currentUserId; 

  const CommentBottomSheet({
    Key? key, 
    required this.post, 
    required this.currentUserEmail,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _replyingToUsername;
  String? _replyingToCommentId;

  late Future<List<CommentModel>> _futureComments;

  @override
  void initState() {
    super.initState();
    _futureComments = CommunityAPI.getCommentsByPost(widget.post.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSendComment() async {
    String text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_replyingToUsername != null) {
      text = "@$_replyingToUsername $text";
    }

    bool success = await CommunityAPI.createComment(
      postId: widget.post.id,
      authorEmail: widget.currentUserEmail, 
      text: text,
      replyToId: _replyingToCommentId, 
    );

    if (success) {
      widget.post.commentsCount++;
      _commentController.clear();
      setState(() {
        _replyingToUsername = null;
        _replyingToCommentId = null;
        _focusNode.unfocus(); 
        _futureComments = CommunityAPI.getCommentsByPost(widget.post.id);
      });
    }
  }

  String _getTimeAgo(DateTime createdAt) {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inDays > 0) return '${duration.inDays} ngày trước';
    if (duration.inHours > 0) return '${duration.inHours} giờ trước';
    if (duration.inMinutes > 0) return '${duration.inMinutes} phút trước';
    return 'Vừa xong';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<CommentModel>>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF80A252)));
                }
                
                final all = snapshot.data ?? [];
                final List<CommentModel> sortedList = [];
                
                // 1. Lọc ra các bình luận gốc (Cha)
                final parents = all.where((c) => c.replyToId == null || c.replyToId!.isEmpty).toList();
                
                for (var p in parents) {
                  sortedList.add(p);
                  // 2. Tìm các con của nó và xếp ngay bên dưới
                  final children = all.where((c) => c.replyToId == p.id).toList();
                  sortedList.addAll(children);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    final comment = sortedList[index];
                    // Kiểm tra xem đây có phải là bình luận trả lời không
                    bool isReply = comment.replyToId != null && comment.replyToId!.isNotEmpty;
                    return _buildCommentItem(comment, isReply);
                  },
                );
              }
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, bool isReply) {
    // 🛑 1. NHẬN DIỆN CHÍNH CHỦ: So sánh ID sạch (đã loại bỏ ObjectId("..."))
    final bool isMyComment = comment.author.id == widget.currentUserId; 

    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: isReply ? 45 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AVATAR: Nâng cấp khiên bảo vệ chống lỗi đỏ màn hình
          Container(
            width: isReply ? 28 : 36, 
            height: isReply ? 28 : 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 0.5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))
              ],
            ),
            child: ClipOval(child: _buildAvatar(comment.author.avatar)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TÊN NGƯỜI DÙNG: Ép kiểu nhận diện để không bao giờ bị "Ẩn danh"
                Row(
                  children: [
                    Text(
                      (comment.author.displayName == null || comment.author.displayName.isEmpty || comment.author.displayName == "Ẩn danh") 
                          ? "Người dùng" 
                          : comment.author.displayName, 
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold, 
                        fontSize: isReply ? 13 : 14,
                        color: Colors.black87
                      )
                    ),
                    const SizedBox(width: 8),
                    Text(_getTimeAgo(comment.createdAt), style: GoogleFonts.roboto(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                // NỘI DUNG BÌNH LUẬN
                _buildCommentText(comment.text),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    // NÚT TIM
                    LikeButton(
                      itemId: comment.id,
                      likedBy: comment.likedBy,
                      currentUserId: widget.currentUserId,
                      currentUserEmail: widget.currentUserEmail,
                      isComment: true,
                    ),
                    const SizedBox(width: 20),
                    
                    // NÚT TRẢ LỜI (Chỉ hiện cho bình luận cha)
                    if (!isReply)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _replyingToUsername = comment.author.displayName;
                            _replyingToCommentId = comment.id;
                          });
                          _focusNode.requestFocus(); // Bật bàn phím ngay lập tức
                        },
                        child: Text("Trả lời", style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)), 
                      ),
                    
                    // 2. NÚT XÓA: Đã kết nối với Backend thực tế
                    if (isMyComment) ...[
                      const Spacer(), 
                      InkWell(
                        onTap: () async {
                          // Gọi API xóa thực tế
                          bool deleted = await CommunityAPI.deleteComment(comment.id, widget.post.id);
                          if (deleted && mounted) {
                            widget.post.commentsCount--;
                            // Load lại danh sách để bình luận biến mất ngay lập tức
                            setState(() {
                              _futureComments = CommunityAPI.getCommentsByPost(widget.post.id);
                            });
                          }
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentText(String text) {
    if (text.startsWith('@') && text.contains(' ')) {
      final firstSpaceIndex = text.indexOf(' ');
      final taggedName = text.substring(0, firstSpaceIndex);
      final mainText = text.substring(firstSpaceIndex);
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: taggedName, style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF80A252))),
            TextSpan(text: mainText, style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87)),
          ],
        ),
      );
    }
    return Text(text, style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87));
  }

  Widget _buildInputArea() {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      padding: EdgeInsets.only(
        bottom: keyboardHeight > 0 ? keyboardHeight + 10 : safeBottom + 10, 
        left: 20, right: 10, top: 10
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingToUsername != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Đang trả lời @$_replyingToUsername", style: GoogleFonts.roboto(fontSize: 13, color: const Color(0xFF80A252), fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _replyingToUsername = null;
                        _replyingToCommentId = null;
                      });
                    },
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: _replyingToUsername != null ? "Viết câu trả lời..." : "Viết bình luận...",
                    hintStyle: GoogleFonts.roboto(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    fillColor: Colors.grey[100],
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF80A252)),
                onPressed: _handleSendComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text("Bình luận", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.trim().isEmpty) {
      return Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover); 
    }
    if (avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
      );
    }
    return Image.file(
      File(avatarUrl.replaceFirst('file://', '').split('?')[0]),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/Icon_user.png', fit: BoxFit.cover),
    );
  }
}