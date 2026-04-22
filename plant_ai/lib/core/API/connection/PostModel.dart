import 'package:mongo_dart/mongo_dart.dart';
// --- Lớp chứa thông tin Người dùng (Nằm gọn bên trong Bài viết) ---
class UserModel {
  final String id;
  final String displayName; // Tên hiển thị cuối cùng lên màn hình
  final String avatar;

  UserModel({
    required this.id, 
    required this.displayName, 
    required this.avatar
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 🛑 LOGIC THÔNG MINH: Tên -> Email -> Ẩn danh
    String nameToDisplay = 'Ẩn danh'; // Mặc định
    
    if (json['displayName'] != null && json['displayName'].toString().trim().isNotEmpty) {
      nameToDisplay = json['displayName'];
    } else if (json['username'] != null && json['username'].toString().trim().isNotEmpty) {
      nameToDisplay = json['username'];
    } else if (json['name'] != null && json['name'].toString().trim().isNotEmpty) {
      nameToDisplay = json['name'];
    } else if (json['email'] != null && json['email'].toString().trim().isNotEmpty) {
      nameToDisplay = json['email'];
    }

    return UserModel(
      id: json['_id'] is ObjectId 
          ? (json['_id'] as ObjectId).toHexString() 
          : json['_id']?.toString() ?? '',
      displayName: nameToDisplay, 
      avatar: json['avatar'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
    );
  }
}

class CommentModel {
  final String id;
  final String postId;
  final UserModel author;
  final List<String> likedBy; // OOP: Chứa thông tin người bình luận
  final String text;
  final String? replyToId;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.author,
    required this.likedBy,
    required this.text,
    required this.createdAt,
    this.replyToId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] is ObjectId ? (json['_id'] as ObjectId).toHexString() : json['_id'].toString(),
      postId: json['postId'] is ObjectId ? (json['postId'] as ObjectId).toHexString() : json['postId'].toString(),
      author: UserModel.fromJson(json['authorData'] ?? {}), // Lấy từ $lookup của MongoDB
      text: json['text'] ?? '',
      likedBy: List<String>.from(json['likes']?.map((e) {
        return e.toString().replaceAll('ObjectId("', '').replaceAll('")', '');
      }) ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      replyToId: json['replyToId']?.toString().replaceAll('ObjectId("', '').replaceAll('")', ''),
    );
  }
}

// --- Lớp chứa thông tin Bài viết (Đối tượng chính) ---
class PostModel {
  final String id;
  final UserModel author; // 🛑 CHUẨN OOP: Chứa trọn vẹn đối tượng UserModel bên trong
  final String content;
  final String? imageUrl;
  final List<String> likedBy; // Danh sách ID những người đã thả tim
  int commentsCount;
  final int sharesCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.likedBy,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'] is ObjectId ? (json['_id'] as ObjectId).toHexString() : json['_id'].toString(),
      // MongoDB gửi cục 'authorData' về sau khi dùng $lookup, ta quăng nó vào UserModel xử lý
      author: UserModel.fromJson(json['authorData'] ?? {}), 
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      // Chuyển đổi mảng từ MongoDB sang mảng chuỗi String chuẩn của Dart
      likedBy: List<String>.from(json['likes']?.map((e) => 
          e is ObjectId ? e.toHexString() : e.toString()
      ) ?? []),
      
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  // Tiện ích: Kiểm tra xem User hiện tại (ID) đã Like bài này chưa để bôi xanh nút trái tim
  bool isLikedByMe(String myUserId) {
    return likedBy.contains(myUserId);
  }
}