from datetime import datetime, timedelta
from utils.db import get_db
from .Models import User, Admin
from bson import ObjectId

class UserDAO:

    @staticmethod
    def get_all_users():
        """Lấy danh sách người dùng cho Table (CN.083)"""
        try:
            db = get_db()
            # Lấy tất cả, bỏ password để bảo mật
            cursor = db.users.find({}, {"password": 0})
            users = []
            for doc in cursor:
                doc['_id'] = str(doc['_id'])
                # Xử lý fallback dữ liệu rỗng
                doc['location'] = doc.get('location', "Chưa cập nhật")
                doc['avatar'] = doc.get('avatar', "")
                doc['status'] = doc.get('status', "Active")
                doc['is_locked'] = doc.get('is_locked', False)
                # Format ngày tháng cho đẹp
                created_at = doc.get('createdAt')
                if created_at:
                    if isinstance(created_at, datetime):
                        # Nếu là object datetime xịn
                        doc['joinDate'] = created_at.strftime("%d/%m/%Y")
                    elif isinstance(created_at, str):
                        try:
                            # Nếu là String dạng ISO (2026-03-28T...)
                            # Cắt lấy 10 ký tự đầu YYYY-MM-DD
                            date_part = created_at.split('T')[0] 
                            y, m, d = date_part.split('-')
                            doc['joinDate'] = f"{d}/{m}/{y}"
                        except:
                            doc['joinDate'] = "Định dạng lỗi"
                    else:
                        doc['joinDate'] = "Chưa rõ"
                else:
                    doc['joinDate'] = "Chưa rõ"
                # ------------------------------------
                
                users.append(doc)
            return users
        except Exception as e:
            print(f" Lỗi DAO (get_all_users): {e}")
            return []

    @staticmethod
    def toggle_lock_user(user_id):
        """Nhiệm vụ 1: Khóa/Mở khóa tài khoản (CN.087)"""
        try:
            db = get_db()
            user = db.users.find_one({"_id": ObjectId(user_id)})
            if not user: return False, "Không tìm thấy user"
            
            new_lock_status = not user.get("is_locked", False)
            db.users.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": {
                    "is_locked": new_lock_status,
                    "status": "Locked" if new_lock_status else "Active"
                }}
            )
            return True, ("Đã khóa" if new_lock_status else "Đã mở khóa")
        except Exception as e:
            return False, str(e)

    @staticmethod
    def delete_user(user_id):
        """Nhiệm vụ 2: Xóa tài khoản vĩnh viễn (CN.088)"""
        try:
            db = get_db()
            result = db.users.delete_one({"_id": ObjectId(user_id)})
            return result.deleted_count > 0, "Đã xóa người dùng"
        except Exception as e:
            return False, str(e)

    
    @staticmethod
    def get_user_full_history(user_id):
        """Lấy dữ liệu từ 3 collection thực tế của Quân"""
        try:
            db = get_db()
            u_id = str(user_id) # Tùy vào việc ông lưu user_id là String hay ObjectId
            
            # 1. Quét bệnh (Khớp với scan_history)
            scans = list(db.scan_history.find({"user_id": u_id}).sort("time", -1))
            
            # 2. Bài đăng (Khớp với posts)
            posts = list(db.posts.find({"author_id": u_id}).sort("time", -1))
            
            # 3. Chat AI (Khớp với chat_history)
            ai_chats = list(db.chat_history.find({"user_id": u_id}).sort("time", -1))
            
            return {
                "scans": scans,
                "posts": posts,
                "ai": ai_chats # Đặt là 'ai' cho khớp với state bên React nhé
            }
        except Exception as e:
            print(f"❌ Lỗi lấy lịch sử: {e}")
            return {"scans": [], "posts": [], "ai": []}
        
    @staticmethod
    def get_comments_by_post(post_id):
        try:
            db = get_db()
            # 1. Tạo danh sách vét cạn ID (vì Hình 2 PostID là ObjectId màu cam)
            query_ids = []
            if post_id:
                query_ids.append(post_id)
                if ObjectId.is_valid(post_id):
                    query_ids.append(ObjectId(post_id))
            
            # 2. Tìm đúng trường 'postId' như trong ảnh Atlas
            cursor = db.comments.find({"postId": {"$in": query_ids}}).sort("createdAt", -1)
            return list(cursor)
        except Exception as e:
            print(f"❌ Lỗi lấy bình luận: {e}")
            return []

    @staticmethod
    def get_user_scans(user_id):
        try:
            db = get_db()
            # Vét mọi kiểu string quái gở nhất mà ông từng lưu
            query_ids = [
                user_id,                        # "69c73b..."
                f'ObjectId("{user_id}")',       # "ObjectId("69c73b...")" (Khớp Hình 3)
                f"ObjectId('{user_id}')",       # "ObjectId('69c73b...')"
                f"ObjectId({user_id})"          # "ObjectId(69c73b...)"
            ]
            
            # Cẩn thận: Chỉ ép kiểu nếu ID hợp lệ để không bị sập Web
            if ObjectId.is_valid(user_id):
                query_ids.append(ObjectId(user_id)) # Khớp Hình 2
                
            match_query = {"$in": query_ids}
            return list(db.scan_history.find({"user_id": match_query}).sort("created_at", -1))
        except Exception as e:
            print(f"❌ Lỗi Scans: {e}")
            return []

    @staticmethod
    def get_user_posts(user_id):
        try:
            db = get_db()
            # Dùng cơ chế vét cạn để tránh lỗi ID lệch kiểu
            query_ids = [user_id, f"ObjectId('{user_id}')", f'ObjectId("{user_id}")']
            if ObjectId.is_valid(user_id):
                query_ids.append(ObjectId(user_id))
                
            # ĐẢM BẢO TRƯỜNG LÀ 'authorId' (Giống hệt ảnh Compass ông chụp)
            return list(db.posts.find({"authorId": {"$in": query_ids}}).sort("createdAt", -1))
        except Exception as e:
            print(f"❌ Lỗi DAO Posts: {e}")
            return []

    @staticmethod
    def get_user_ai_chats(user_id):
        try:
            db = get_db()
            query_ids = [
                user_id, f'ObjectId("{user_id}")', f"ObjectId('{user_id}')", f"ObjectId({user_id})"
            ]
            if ObjectId.is_valid(user_id):
                query_ids.append(ObjectId(user_id))
                
            match_query = {"$in": query_ids}
            return list(db.chat_history.find({"userId": match_query}).sort("updatedAt", -1)) # Khớp Hình 1
        except Exception as e:
            print(f"❌ Lỗi AI: {e}")
            return []

    
    @staticmethod
    def delete_comment(comment_id):
        """Admin xóa bình luận vi phạm"""
        try:
            db = get_db()
            result = db.comments.delete_one({"_id": ObjectId(comment_id)})
            return result.deleted_count > 0, "Đã xóa bình luận thành công"
        except Exception as e:
            return False, str(e)

    @staticmethod
    def get_analytics(time_filter):
        db = User._get_collection().database
        now = datetime.now()

        # Logic tính start_date và date_format (giữ nguyên như cũ)
        if time_filter == 'month':
            start_date = now - timedelta(days=30)
            date_format = "%U"
            label_prefix = "Tuần "
        elif time_filter == 'quarter':
            start_date = now - timedelta(days=90)
            date_format = "%m"
            label_prefix = "Tháng "
        else: # year
            start_date = now - timedelta(days=365)
            date_format = "%m"
            label_prefix = "T"

        def count_stats(coll_name, date_field):
            pipeline = [
                # 1. Bước quan trọng nhất: Ép kiểu từ String sang Date để so sánh được
                {
                    "$addFields": {
                        "converted_date": {
                            "$dateFromString": { "dateString": f"${date_field}" }
                        }
                    }
                },
                # 2. Bây giờ mới so sánh cái 'converted_date' với start_date
                {"$match": {"converted_date": {"$gte": start_date}}},
                # 3. Gom nhóm theo cái ngày đã convert
                {"$group": {
                    "_id": {"$dateToString": {"format": date_format, "date": "$converted_date"}},
                    "count": {"$sum": 1}
                }},
                {"$sort": {"_id": 1}}
            ]
            return {item['_id']: item['count'] for item in db[coll_name].aggregate(pipeline)}

        # Bốc dữ liệu
        users = count_stats('users', 'createdAt')
        scan_counts = count_stats('scan_history', 'created_at') 
        post_counts = count_stats('posts', 'createdAt')
        comment_counts = count_stats('comments', 'createdAt')

        all_keys = sorted(list(set(users.keys()) | set(scan_counts.keys()) | set(post_counts.keys()) | set(comment_counts.keys())))
        
        final_data = []
        for k in all_keys:
            final_data.append({
                "name": f"{label_prefix}{k}",
                "customers": users.get(k, 0),
                "scans": scan_counts.get(k, 0),
                "posts": post_counts.get(k, 0),
                "comments": comment_counts.get(k, 0)
            })

        # 🎯 Nếu data thật trống (vì DB 2026 chưa có data), gọi hàm dummy bên dưới
        if not final_data:
            return UserDAO.get_dummy_data(time_filter)

        return final_data

   
    @staticmethod
    def get_dummy_data(time_filter):
        if time_filter == 'year' or time_filter == 'quarter':
            # Trả về 12 tháng mẫu
            return [{"name": f"T{i}", "customers": i*2, "scans": i*5, "posts": i, "comments": i+2} for i in range(1, 13)]
        
        # Mặc định trả về 4 tuần mẫu cho Tháng
        return [
            {"name": "Tuần 1", "customers": 10, "scans": 25, "posts": 5, "comments": 12},
            {"name": "Tuần 2", "customers": 25, "scans": 45, "posts": 15, "comments": 30},
            {"name": "Tuần 3", "customers": 18, "scans": 30, "posts": 8, "comments": 22},
            {"name": "Tuần 4", "customers": 35, "scans": 60, "posts": 20, "comments": 45}
        ]
    
    @staticmethod
    def get_dashboard_summary():
        try:
            # 1. Đếm tổng số khách hàng (User)
            total_users = User.objects.count()
            
            # 2. Đếm yêu cầu hỗ trợ (Admin chưa duyệt)
            pending_admins = Admin.objects(check_account=False).count()

            return {
                "totalUsers": total_users,
                "supportRequests": pending_admins
            }
        except Exception as e:
            print(f"❌ Lỗi lấy thống kê: {e}")
            return {"totalUsers": 0, "supportRequests": 0}