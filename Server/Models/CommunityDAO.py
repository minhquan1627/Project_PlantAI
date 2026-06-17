from Models import CommunityPost, Comment
from datetime import datetime
from bson import ObjectId

class CommunityDAO:
    @staticmethod
    def get_all_posts():
        try:
            posts = CommunityPost.objects()
            result = []
            
            # Import cả User và Admin vào để quét (Tránh circular import)
            from Models import User, Admin 
            
            for p in posts:
                author_name = "Người dùng Ẩn danh"
                
                if p.authorId:
                    try:
                        # 1. Thử tìm trong bảng Khách hàng (User) trước
                        user = User.objects(id=ObjectId(p.authorId)).first()
                        if user:
                            # Quét vét máng: Ưu tiên name -> username -> email
                            author_name = getattr(user, 'name', None) or getattr(user, 'username', None) or getattr(user, 'email', "Người dùng")
                        else:
                            # 2. Nếu không thấy, mò sang bảng Admin (Ban quản trị)
                            admin = Admin.objects(id=ObjectId(p.authorId)).first()
                            if admin:
                                author_name = getattr(admin, 'username', "Ban Quản Trị")
                    except Exception as ex:
                        print(f"⚠️ Không thể parse tác giả cho bài viết {p.id}: {ex}")

                result.append({
                    "_id": str(p.id),
                    "authorId": str(p.authorId),
                    "authorName": author_name,
                    "content": p.content,
                    "imageUrl": getattr(p, 'imageUrl', None),
                    "likes": getattr(p, 'likes', []),
                    "commentsCount": getattr(p, 'commentsCount', 0),
                    "sharesCount": getattr(p, 'sharesCount', 0),
                    "status": getattr(p, 'status', "Visible"),
                    "isPinned": getattr(p, 'isPinned', False),
                    "createdAt": getattr(p, 'createdAt', datetime.now().isoformat()) 
                })
            return result
        except Exception as e:
            import traceback
            print(f"❌ Lỗi DAO (get_all_posts): {traceback.format_exc()}")
            return []

    @staticmethod
    def save_admin_post(data):
        try:
            post_id = data.get('id') or data.get('_id')
            
            if post_id:
                post = CommunityPost.objects(id=ObjectId(post_id)).first()
                if post:
                    post.update(
                        content=data.get('content', post.content),
                        imageUrl=data.get('imageUrl', post.imageUrl),
                        status=data.get('status', post.status),
                        isPinned=data.get('isPinned', post.isPinned)
                    )
                    return True, "Cập nhật bài viết thành công!"
            else:
                new_post = CommunityPost(
                    authorId="ADMIN_ID",
                    authorName="Ban Quản Trị PlantAI",
                    content=data.get('content', ""),
                    imageUrl=data.get('imageUrl', None),
                    isPinned=True,  
                    status="Visible"
                )
                new_post.save()
                return True, "Đăng bài thông báo BQT thành công!"
                
            return False, "Không tìm thấy dữ liệu"
        except Exception as e:
            return False, str(e)

    @staticmethod
    def update_post_status(post_id, new_status):
        try:
            post = CommunityPost.objects(id=ObjectId(post_id)).first()
            if post:
                post.update(set__status=new_status)
                return True, "Cập nhật trạng thái thành công"
            return False, "Không tìm thấy bài viết"
        except Exception as e:
            return False, str(e)

    @staticmethod
    def delete_post(post_id):
        try:
            post = CommunityPost.objects(id=ObjectId(post_id)).first()
            if post:
                post.delete()
                # Xóa sạch comment liên quan
                Comment.objects(postId=str(post_id)).delete()
                return True, "Xóa bài viết và bình luận thành công!"
            return False, "Không tìm thấy bài viết!"
        except Exception as e:
            return False, str(e)

    # ==========================================
    # QUẢN LÝ BÌNH LUẬN (DB PHẲNG -> UI LỒNG NHAU)
    # ==========================================
    
    @staticmethod
    def get_comments_by_post(post_id):
        try:
            # Lấy tất cả comment của bài, sắp xếp theo thời gian
            comments = Comment.objects(postId=ObjectId(post_id)).order_by('createdAt')
            
            main_comments_map = {}
            replies_list = []
            
            for c in comments:
                # 1. Mở cái túi 'authorData' ra (Vì DB lưu cục này thay vì authorId rời)
                author_data = getattr(c, 'authorData', {})
                
                # 2. Bóc tách Tên (Fallback thông minh như App)
                author_name = author_data.get('displayName') or author_data.get('username') or author_data.get('name') or "Người dùng"
                
                # 3. Bóc tách ID nằm bên trong túi authorData (Có thể là '_id' hoặc 'id')
                raw_author_id = author_data.get('_id') or author_data.get('id') or ""
                author_id_str = str(raw_author_id) if raw_author_id else ""
                
                c_dict = {
                    "_id": str(c.id),
                    "authorId": author_id_str,   # 👉 ĐÃ FIX: Không gọi c.authorId nữa
                    "authorName": author_name,   # Tên bóc từ authorData
                    "content": getattr(c, 'text', ""), # Dùng 'text' theo chuẩn DB
                    "createdAt": getattr(c, 'createdAt', ""),
                    "replies": []
                }
                
                # 4. Phân loại Comment gốc và Reply
                if getattr(c, 'replyToId', None):
                    replies_list.append((str(c.replyToId), c_dict))
                else:
                    main_comments_map[str(c.id)] = c_dict
                    
            # 5. Gắn Reply vào đúng Comment gốc
            for parent_id, reply_dict in replies_list:
                if parent_id in main_comments_map:
                    main_comments_map[parent_id]['replies'].append(reply_dict)
                    
            result = list(main_comments_map.values())
            result.reverse() # Đảo ngược để comment mới nhất lên đầu
            
            return result
        except Exception as e:
            import traceback
            print(f"❌ Lỗi DAO (get_comments): {traceback.format_exc()}")
            return []
        
    
    @staticmethod
    def delete_comment_or_reply(comment_id):
        """
        Xóa bình luận trên Database phẳng (Rất dễ!)
        """
        try:
            target_comment = Comment.objects(id=ObjectId(comment_id)).first()
            if not target_comment:
                return False, "Không tìm thấy bình luận này!"
                
            post_id = target_comment.postId
            
            # 1. NẾU LÀ PHẢN HỒI (REPLY)
            if getattr(target_comment, 'replyToId', None):
                target_comment.delete()
                CommunityPost.objects(id=ObjectId(post_id)).update_one(dec__commentsCount=1)
                return True, "Đã xóa câu trả lời (Reply)!"
                
            # 2. NẾU LÀ BÌNH LUẬN GỐC
            else:
                # Tìm xem nó có bao nhiêu đứa reply bên dưới
                replies_count = Comment.objects(replyToId=comment_id).count()
                
                # Quét sạch cả nhà (Xóa Reply trước, xóa Gốc sau)
                Comment.objects(replyToId=comment_id).delete()
                target_comment.delete()
                
                # Cập nhật tổng đếm của bài viết
                total_deleted = 1 + replies_count
                CommunityPost.objects(id=ObjectId(post_id)).update_one(dec__commentsCount=total_deleted)
                
                return True, f"Đã xóa bình luận gốc và {replies_count} phản hồi!"
                
        except Exception as e:
            return False, str(e)