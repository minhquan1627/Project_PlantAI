import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// --- BỎ IMPORT PostModel ĐI VÌ MÌNH KHÔNG CẦN NÓ NỮA ---
import '../../../core/API/CommunityAPI.dart';

class LikeButton extends StatefulWidget {
  final String itemId; // ID của Bài viết HOẶC Bình luận
  final List<String> likedBy; // Danh sách ID người đã thả tim
  final String currentUserId;
  final String currentUserEmail;
  final bool isComment; // 🛑 Cờ hiệu: true = Bình luận, false = Bài viết
  final Function(bool isLiked)? onToggle;

  const LikeButton({
    Key? key,
    required this.itemId,
    required this.likedBy,
    required this.currentUserId,
    required this.currentUserEmail,
    this.isComment = false, // Mặc định là nút tim cho Bài viết
    this.onToggle,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem ID của tôi có trong danh sách thích không
    bool isLiked = widget.likedBy.contains(widget.currentUserId);

    return InkWell(
      onTap: _handleLike,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hiệu ứng "nổ" tim
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1.0, end: isLiked ? 1.2 : 1.0),
            curve: Curves.bounceOut,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  // Nếu là bình luận thì icon xám/đỏ và nhỏ hơn xíu (16), bài viết thì đen/đỏ (22)
                  color: isLiked ? Colors.red : (widget.isComment ? Colors.grey : Colors.black87),
                  size: widget.isComment ? 16 : 22, 
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          
          // Hiệu ứng số nhảy
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              // Nếu là comment và chưa ai like thì hiện chữ "Thích", có người like thì hiện số
              widget.isComment && widget.likedBy.isEmpty 
                  ? "Thích" 
                  : widget.likedBy.length.toString(),
              key: ValueKey<String>("${widget.likedBy.length}_$isLiked"),
              style: GoogleFonts.roboto(
                fontSize: widget.isComment ? 12 : 14, 
                color: isLiked ? Colors.red : (widget.isComment ? Colors.grey : Colors.black54),
                fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike() {
    if (widget.currentUserId.isEmpty) return;

    setState(() {
      // 🛑 OPTIMISTIC UI: Cập nhật ngay tại chỗ
      if (widget.likedBy.contains(widget.currentUserId)) {
        widget.likedBy.remove(widget.currentUserId);
      } else {
        widget.likedBy.add(widget.currentUserId);
      }
    });

    if (widget.onToggle != null) {
      widget.onToggle!(widget.likedBy.contains(widget.currentUserId));
    }

    // 🛑 PHÂN LUỒNG API: Xem nó là Tim bài viết hay Tim bình luận
    if (widget.isComment) {
      CommunityAPI.toggleLikeComment(widget.itemId, widget.currentUserEmail);
    } else {
      CommunityAPI.toggleLikePost(widget.itemId, widget.currentUserEmail);
    }
  }
}