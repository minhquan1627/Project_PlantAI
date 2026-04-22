from datetime import datetime, timedelta
import random
import string
from utils.db import get_db
from .Models import Admin
from werkzeug.security import generate_password_hash, check_password_hash
from utils.mailer import send_otp_email
from bson import ObjectId

class AdminDAO:
    @staticmethod
    def generate_otp():
        return ''.join(random.choices(string.digits, k=6))

    @staticmethod
    def get_admin_by_id(admin_id):
        """Lấy thông tin Admin theo ID để làm Profile"""
        try:    
            
            # Ở đây ta gọi trực tiếp từ class Model Admin (Document)
            # MongoEngine sẽ tự hiểu id là ObjectId
            return Admin.objects(pk=admin_id).first()
        except Exception as e:
            print(f" Lỗi DAO (get_admin_by_id): {e}")
            return None

    @staticmethod
    def register_admin_temp(email, username, password):
        """Bước 1: Lưu vào bảng tạm và gửi OTP"""
        db = get_db()
        
        # Kiểm tra xem đã tồn tại ở bảng chính chưa
        if db.admins.find_one({"$or": [{"email": email}]}):
            return {"status": "error", "message": "Tài khoản đã tồn tại!"}
        
        otp = AdminDAO.generate_otp()
        hashed_password = generate_password_hash(password)
        
        # Dữ liệu lưu vào bảng tạm (pending_admins)
        temp_data = {
            "username": username,
            "email": email,
            "password": hashed_password,
            "otp": otp,
            "otp_exp": datetime.now() + timedelta(minutes=5), # Hết hạn sau 5p
            "created_at": datetime.now()
        }
        
        # Lưu vào bảng tạm, ghi đè nếu email đã tồn tại trong bảng tạm này
        db.pending_admins.update_one({"email": email}, {"$set": temp_data}, upsert=True)
        
        from app import send_otp_email
        send_otp_email(email, otp)

        # LƯU Ý: Ở đây ông gọi hàm send_otp_email(email, otp) từ app.py
        # Để test nhanh, tôi vẫn trả về otp_test
        return {"status": "success", "message": "Mã OTP đã được gửi!", "otp_test": otp}

    @staticmethod
    def verify_otp_and_promote(email, user_otp):
        """Bước 2: Kiểm tra OTP ở bảng tạm, nếu đúng thì chuyển sang bảng chính"""
        db = get_db()
        pending_data = db.pending_admins.find_one({"email": email})
        
        if not pending_data:
            return {"status": "error", "message": "Yêu cầu đăng ký không tồn tại hoặc đã bị hủy!"}
        
        # Kiểm tra mã và thời hạn
        if pending_data.get("otp") == user_otp:
            if datetime.now() < pending_data.get("otp_exp"):
                # CHUYỂN DỮ LIỆU SANG BẢNG CHÍNH
                new_admin = {
                    "username": pending_data['username'],
                    "email": pending_data['email'],
                    "password": pending_data['password'],
                    "is_verified": True,
                    "check_account": False, # Chờ Super Admin duyệt
                    "role": "1",
                    "created_at": datetime.now()
                }
                db.admins.insert_one(new_admin)
                
                # XÓA DỮ LIỆU Ở BẢNG TẠM (Xài xong xóa luôn!)
                db.pending_admins.delete_one({"email": email})
                
                return {"status": "success", "message": "Xác thực thành công! Vui lòng chờ Admin duyệt."}
            else:
                db.pending_admins.delete_one({"email": email}) # Hết hạn cũng xóa cho sạch
                return {"status": "error", "message": "Mã OTP đã hết hạn!"}
        
        return {"status": "error", "message": "Mã OTP không chính xác!"}

    @staticmethod
    def select_by_auth(email, password):
        db = get_db()
        admin_data = db.admins.find_one({"email": email})
        
        if admin_data and check_password_hash(admin_data['password'], password):   
            # 1. PHẢI CHECK KHÓA TRƯỚC (Ưu tiên cao nhất)
            if admin_data.get("is_locked", False):
                return "LOCKED" 

            # 2. RỒI MỚI CHECK DUYỆT (Ưu tiên thấp hơn)
            if not admin_data.get("check_account", False):
                return "PENDING_APPROVAL"
            
            # 3. Nếu mọi thứ OK thì mới tạo Object Admin
            return Admin(**admin_data)
            
        return None

    @staticmethod
    def get_pending_admins():
        """Lấy danh sách Admin đã xong OTP nhưng chưa được duyệt"""
        db = get_db()
        cursor = db.admins.find({"check_account": False})
        return list(cursor)

    @staticmethod
    def approve_admin(admin_id):
        """Super Admin duyệt từ xa"""
        db = get_db()
        result = db.admins.update_one(
            {"_id": ObjectId(admin_id)}, 
            {"$set": {"check_account": True}}
        )
        return result.modified_count > 0

    @staticmethod
    def get_all_admins():
        db = get_db()
        # Lấy tất cả trừ mật khẩu để bảo mật
        cursor = db.admins.find({}, {"password": 0}) 
        return list(cursor)

    @staticmethod
    def update_admin_profile(admin_id, data):
        """Cập nhật thông tin họ tên và số điện thoại"""
        try:
            admin = Admin.objects(pk=admin_id).first()
            if admin:
                # Cập nhật các trường cho phép
                admin.username = data.get('fullName', admin.username)

                # Kiểm tra nếu model có trường phone thì mới cập nhật
                if hasattr(admin, 'phone'):
                    admin.phone = data.get('phone', admin.phone)
                    
                if 'avatar' in data:
                    admin.avatar = data.get('avatar')
                admin.save() # Lưu vào MongoDB
                return True
            return False
        except Exception as e:
            print(f" Lỗi DAO (update_admin_profile): {e}")
            return False
        
    @staticmethod
    def delete_admin_account(admin_id):
        """Chủ tài khoản tự xóa chính mình"""
        try:
            # Dùng MongoEngine để xóa cho đồng bộ với logic Profile
            admin = Admin.objects(pk=admin_id).first()
            if admin:
                admin.delete()
                return True
            return False
        except Exception as e:
            print(f" Lỗi xóa tài khoản: {e}")
            return False

    @staticmethod
    def delete_admin(admin_id):
        """Xóa vĩnh viễn Admin"""
        try:
            db = get_db()
            result = db.admins.delete_one({"_id": ObjectId(admin_id)})
            return result.deleted_count > 0, "Đã xóa tài khoản thành công"
        except Exception as e:
            return False, str(e)
    
    @staticmethod
    def change_password(admin_id, current_password, new_password):
        try:
            admin = Admin.objects(pk=admin_id).first()
            if admin and check_password_hash(admin.password, current_password):
                # Nếu mật khẩu cũ đúng, tiến hành hash và lưu mật khẩu mới
                admin.password = generate_password_hash(new_password)
                admin.save()
                return True, "Cập nhật mật khẩu thành công!"
            return False, "Mật khẩu hiện tại không chính xác!"
        except Exception as e:
            return False, f"Lỗi: {str(e)}"
        
    @staticmethod
    def toggle_lock_admin(admin_id):
        """Khóa hoặc mở khóa tài khoản Admin"""
        try:
            db = get_db()
            admin = db.admins.find_one({"_id": ObjectId(admin_id)})
            if not admin:
                return False, "Không tìm thấy Admin"
            
            # Đảo ngược trạng thái is_locked (nếu chưa có thì mặc định là False)
            new_lock_status = not admin.get("is_locked", False)
            
            db.admins.update_one(
                {"_id": ObjectId(admin_id)},
                {"$set": {"is_locked": new_lock_status}}
            )
            return True, ("Đã khóa tài khoản" if new_lock_status else "Đã mở khóa tài khoản")
        except Exception as e:
            return False, str(e)
    
