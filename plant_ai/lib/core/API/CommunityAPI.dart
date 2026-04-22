  import 'dart:developer';
  import 'dart:convert';
  import 'package:mongo_dart/mongo_dart.dart';
  import 'package:mongo_dart/mongo_dart.dart' as mongo;
  import 'connection/MongoDB.dart'; 
  import 'connection/PostModel.dart'; 
import 'package:http/http.dart' as http;
  class CommunityAPI {
    
    // Helper: Đảm bảo kết nối DB
    static Future<void> _ensureConnected() async {
      if (MongoDatabase.db == null || !MongoDatabase.db!.isConnected) {
        await MongoDatabase.connect();
      }
    }

    // --- 1. LẤY DANH SÁCH BÀI VIẾT (FEED) ---
    static Future<List<PostModel>> getPosts() async {
      try {
        await _ensureConnected();
        final postCollection = MongoDatabase.db!.collection('posts');

        final pipeline = [
          { r'$sort': { 'createdAt': -1 } }, 
          {
            r'$lookup': {
              'from': 'users',
              'localField': 'authorId',
              'foreignField': '_id',
              'as': 'authorData'
            }
          },
          {
            r'$unwind': {
              'path': r'$authorData',
              'preserveNullAndEmptyArrays': true
            }
          }
        ];

        final postsCursor = await postCollection.aggregateToStream(pipeline).toList();
        return postsCursor.map((json) => PostModel.fromJson(json)).toList();

      } catch (e) {
        log('❌ CommunityAPI Error (GetPosts): $e');
        return <PostModel>[];
      }
    }

    // --- 2. TẠO BÀI ĐĂNG MỚI ---
    // --- 2. TẠO BÀI ĐĂNG MỚI (ĐÃ TÍCH HỢP CLOUDINARY) ---
    static Future<String> createPost({
      required String authorEmail, 
      required String content,
      String? imageUrl,
    }) async {
      try {
        await _ensureConnected();
        final postCollection = MongoDatabase.db!.collection('posts');

        final user = await MongoDatabase.userCollection!.findOne({'email': authorEmail});
        if (user == null) return "USER_NOT_FOUND";

        ObjectId authorId = user['_id'];
        String? finalImageUrl; // Biến lưu link mây sau khi upload

        // 🚀 1. KIỂM TRA & UPLOAD ẢNH LÊN CLOUDINARY (NẾU CÓ)
        if (imageUrl != null && imageUrl.isNotEmpty) {
          if (!imageUrl.startsWith('http')) {
            // Nếu là đường dẫn cục bộ -> Bắn lên Cloudinary
            log('📦 Phát hiện ảnh đính kèm, đang upload lên Cloud...');

            // THAY THÔNG SỐ CỦA ÔNG VÀO ĐÂY
            String cloudName = "dmxpgpq01"; 
            String uploadPreset = "plant_ai_preset"; 
            
            var request = http.MultipartRequest(
              'POST', 
              Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload')
            );

            request.fields['upload_preset'] = uploadPreset;
            request.files.add(await http.MultipartFile.fromPath('file', imageUrl));

            var response = await request.send();
            
            if (response.statusCode == 200) {
              var responseData = await response.stream.bytesToString();
              var jsonResult = json.decode(responseData);
              
              finalImageUrl = jsonResult['secure_url']; // Lấy link xịn
              log('✅ Upload Cloudinary bài viết thành công: $finalImageUrl');
            } else {
              log('❌ Lỗi upload Cloudinary: Mã ${response.statusCode}');
              return "ERROR_UPLOAD_IMAGE"; // Báo lỗi nếu rớt mạng giữa chừng
            }
          } else {
            // Nếu chẳng may ảnh đã là link http từ trước thì giữ nguyên
            finalImageUrl = imageUrl;
          }
        }

        // 🚀 2. TẠO OBJECT BÀI VIẾT & LƯU VÀO MONGODB
        var newPost = {
          "_id": ObjectId(),
          "authorId": authorId, 
          "content": content,
          // Lưu link Cloudinary, nếu không có ảnh thì lưu null
          "imageUrl": finalImageUrl, 
          "likes": [], 
          "commentsCount": 0,
          "sharesCount": 0,
          "createdAt": DateTime.now().toIso8601String(),
        };

        await postCollection.insert(newPost);
        return "SUCCESS";

      } catch (e) {
        log('❌ CommunityAPI Error (CreatePost): $e');
        return "ERROR";
      }
    }

    // --- 3. LẤY DANH SÁCH BÌNH LUẬN (FIXED TÊN HÀM) ---
    static Future<List<CommentModel>> getCommentsByPost(String postId) async {
      try {
        await _ensureConnected();
        final pId = mongo.ObjectId.fromHexString(postId);

        // 🛑 LẤY DỮ LIỆU TRỰC TIẾP: Cực nhanh, không dùng $lookup nữa!
        final comments = await MongoDatabase.db!
            .collection('comments')
            .find(mongo.where.eq('postId', pId)) // Lấy thẳng từ DB ra
            .toList();

        return comments.map((json) => CommentModel.fromJson(json)).toList();
      } catch (e) {
        print("❌ Lỗi load comments: $e");
        return [];
      }
    }

    // --- 3.1. TẠO BÌNH LUẬN MỚI ---
    // Hàm này giúp lưu bình luận và tự động tăng số lượng comment trong bài viết
    static Future<bool> createComment({
    required String postId,
    required String authorEmail,
    required String text,
    String? replyToId,
  }) async {
    try {
      await _ensureConnected();
      final commentCollection = MongoDatabase.db!.collection('comments');
      final postCollection = MongoDatabase.db!.collection('posts');

      // Tìm user để lấy thông tin
      final user = await MongoDatabase.userCollection!.findOne({'email': authorEmail});
      if (user == null) return false;

      final pId = ObjectId.fromHexString(postId);

      // 🛑 CHỈ TẠO 1 OBJECT DUY NHẤT VÀ LƯU 1 LẦN
      final newComment = {
        "_id": ObjectId(),
        'postId': pId,
        'text': text,
        'authorData': {
          '_id': user['_id'],
          // Logic: Ưu tiên lấy username, nếu không có lấy name, cuối cùng lấy email
          'name': user['username'] ?? user['name'] ?? authorEmail, 
          'displayName': user['username'] ?? user['name'] ?? authorEmail,
          'avatar': user['avatar'] ?? "", 
        },
        'likes': [], 
        'createdAt': DateTime.now().toIso8601String(),
        'replyToId': replyToId != null ? ObjectId.fromHexString(replyToId) : null,
      };
      
      // ✅ THỰC HIỆN LƯU VÀO DATABASE (CHỈ 1 DÒNG NÀY)
      await commentCollection.insert(newComment);

      // Cập nhật số lượng comment trong bài viết
      await postCollection.updateOne(
        where.eq('_id', pId),
        modify.inc('commentsCount', 1)
      );

      return true;
    } catch (e) {
      print('❌ CommunityAPI Error (CreateComment): $e');
      return false;
    }
  }


    // Thêm hàm này vào cuối class CommunityAPI trong file CommunityAPI.dart
  static Future<String> toggleLikeComment(String commentId, String userEmail) async {
    try {
      await _ensureConnected();
      final commentCollection = MongoDatabase.db!.collection('comments');
      final user = await MongoDatabase.userCollection!.findOne({'email': userEmail});
      if (user == null) return "USER_NOT_FOUND";
      
      final userId = user['_id'] as ObjectId;
      final cId = ObjectId.fromHexString(commentId);

      // Dùng $addToSet và $pull để đảm bảo không bị nhảy số +2
      final comment = await commentCollection.findOne({'_id': cId});
      List<dynamic> currentLikes = comment?['likes'] ?? [];
      bool isAlreadyLiked = currentLikes.any((id) => id.toString() == userId.toString());

      if (isAlreadyLiked) {
        await commentCollection.updateOne(where.eq('_id', cId), modify.pull('likes', userId));
      } else {
        await commentCollection.updateOne(where.eq('_id', cId), modify.addToSet('likes', userId));
      }
      return "SUCCESS";
    } catch (e) {
      return "ERROR";
    }
  }


  static Future<bool> deleteComment(String commentId, String postId) async {
    try {
      await _ensureConnected();
      
      // Đảm bảo dùng đúng prefix mongo. nếu ông có đặt alias ở đầu file
      final cId = mongo.ObjectId.fromHexString(commentId);
      final pId = mongo.ObjectId.fromHexString(postId);
      
      final commentCollection = MongoDatabase.db!.collection('comments');
      final postCollection = MongoDatabase.db!.collection('posts');

      // 🛑 SỬA LỖI ĐỎ: Dùng kiểu nối chuỗi .or() thay vì truyền mảng []
      // Logic: Xóa comment có _id này HOẶC có replyToId này (xóa cả con)
      await commentCollection.remove(
        mongo.where.eq('_id', cId).or(mongo.where.eq('replyToId', cId))
      );

      // Giảm số lượng commentsCount trong bài viết xuống 1
      await postCollection.updateOne(
        mongo.where.eq('_id', pId),
        mongo.modify.inc('commentsCount', -1)
      );

      return true;
    } catch (e) {
      print("❌ Lỗi xóa comment: $e");
      return false;
    }
  }

    // --- 4. THẢ TIM bài Post / BỎ THẢ TIM Post (TOGGLE LIKE) ---
    static Future<String> toggleLikePost(String postId, String userEmail) async {
    try {
      await _ensureConnected();
      final postCollection = MongoDatabase.db!.collection('posts');

      final user = await MongoDatabase.userCollection!.findOne({'email': userEmail});
      if (user == null) return "USER_NOT_FOUND";
      
      final userId = user['_id'] as ObjectId; 
      final pId = ObjectId.fromHexString(postId);

      final post = await postCollection.findOne({'_id': pId});
      if (post == null) return "POST_NOT_FOUND";

      List<dynamic> currentLikes = post['likes'] ?? [];
      
      // So sánh chuẩn ID
      bool isAlreadyLiked = currentLikes.any((id) => id.toString() == userId.toString());

      if (isAlreadyLiked) {
        // Bỏ thích: Xóa ID ra khỏi mảng
        await postCollection.updateOne(where.eq('_id', pId), modify.pull('likes', userId));
      } else {
        // Thích: Chỉ thêm vào nếu chưa tồn tại ($addToSet giúp chống trùng lặp)
        await postCollection.updateOne(where.eq('_id', pId), modify.addToSet('likes', userId));
      }

      return "SUCCESS";
    } catch (e) {
      log('❌ CommunityAPI Error: $e');
      return "ERROR";
    }
  }

    // --- 5. LẤY DANH SÁCH BÀI VIẾT CỦA RIÊNG MỘT USER ---
    static Future<List<PostModel>> getPostsByUser(String email) async {
      try {
        await _ensureConnected();
        final postCollection = MongoDatabase.db!.collection('posts');

        final user = await MongoDatabase.userCollection!.findOne({'email': email});
        if (user == null) return <PostModel>[];
        ObjectId authorId = user['_id'];

        final pipeline = [
          { r'$match': { 'authorId': authorId } },
          { r'$sort': { 'createdAt': -1 } }, 
          {
            r'$lookup': {
              'from': 'users', 
              'localField': 'authorId', 
              'foreignField': '_id', 
              'as': 'authorData' 
            }
          },
          {
            r'$unwind': {
              'path': r'$authorData',
              'preserveNullAndEmptyArrays': true 
            }
          }
        ];

        final postsCursor = await postCollection.aggregateToStream(pipeline).toList();
        return postsCursor.map((json) => PostModel.fromJson(json)).toList();

      } catch (e) {
        log('❌ CommunityAPI Error (GetPostsByUser): $e');
        return <PostModel>[];
      }
    }

    // --- 6. XÓA BÀI VIẾT THEO ID ---
    static Future<bool> deletePost(String postId) async {
      try {
        await _ensureConnected();
        final postCollection = MongoDatabase.db!.collection('posts');

        final result = await postCollection.deleteOne({
          '_id': ObjectId.fromHexString(postId)
        });

        return result.nRemoved > 0;

      } catch (e) {
        log('❌ CommunityAPI Error (DeletePost): $e');
        return false;
      }
    }
  } // 🛑 PHẢI CÓ DẤU NGOẶC KẾT THÚC Ở ĐÂY!