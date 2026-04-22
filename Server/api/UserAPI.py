from flask import Blueprint, request, jsonify
from utils.auth_utils import gen_token, token_required # Nhớ import token_required nhé
from Models.AdminDAO import AdminDAO
from datetime import datetime
from Models.UserDAO import UserDAO
from Models.DiseaseDAO import DiseaseDAO
from Models.HandbookDAO import HandbookDAO
from bson import ObjectId
import traceback

user_bp = Blueprint('user_bp', __name__)

# --- Helper: Chuyển ObjectId sang String để JSON không lỗi ---
def convert_objectid_to_str(doc):
    if isinstance(doc, dict):
        for key, value in doc.items():
            if isinstance(value, ObjectId):
                doc[key] = str(value)
            elif isinstance(value, (dict, list)):
                convert_objectid_to_str(value)
    elif isinstance(doc, list):
        for i in range(len(doc)):
            convert_objectid_to_str(doc[i])
    return doc

def make_json_safe(data):
    # 1. Nếu là ObjectId -> Biến thành chuỗi ngay
    if isinstance(data, ObjectId):
        return str(data)
    
    # 2. Nếu là Datetime -> Biến thành chuỗi ISO (để React đọc được)
    if isinstance(data, datetime):
        return data.isoformat()
    
    # 3. Nếu là Dictionary -> Đệ quy quét từng cặp Key-Value
    if isinstance(data, dict):
        return {k: make_json_safe(v) for k, v in data.items()}
    
    # 4. Nếu là List -> Đệ quy quét từng phần tử và tạo List mới
    if isinstance(data, list):
        return [make_json_safe(v) for v in data]
    
    # 5. Còn lại (String, Int, Float, None) -> Giữ nguyên
    return data

# ================================================================
# CÁC ROUTE QUẢN LÝ ADMIN (Login, Register, Quản lý Admin)
# ================================================================
### 1. Đăng Nhập Admin (Đã thêm check Duyệt)
@user_bp.route('/admin/login', methods=['POST'])
def login():
    try:
        data = request.json
        email = data.get('username') # Hoặc email tùy code của ông
        password = data.get('password')

        admin = AdminDAO.select_by_auth(email, password)
        
        # Xử lý trường hợp bị KHÓA
        if admin == "LOCKED":
            return jsonify({
                "status": "error", 
                "message": "Tài khoản của bạn đã bị khóa!"
            }), 403
    
        # Xử lý trường hợp chờ DUYỆT
        if admin == "PENDING_APPROVAL":
            return jsonify({
                "status": "warning", 
                "message": "Tài khoản đang chờ phê duyệt, vui lòng quay lại sau!"
            }), 403

        # Đăng nhập thành công
        if admin:
            payload = {"uid": str(admin.id), "role": str(admin.role)}
            token = gen_token(payload)
            return jsonify({
                "status": "success",
                "token": token,
                "admin": {"username": admin.username, "role": admin.role}
            }), 200
        
        return jsonify({"status": "error", "message": "Sai tài khoản hoặc mật khẩu!"}), 401

    except Exception as e:
        print(traceback.format_exc())
        return jsonify({"status": "error", "message": "Lỗi hệ thống!"}), 500

### 2. API Đăng ký Admin (Lưu vào bảng tạm)
@user_bp.route('/admin/register', methods=['POST'])
def register():
    try:
        data = request.json
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')

        if not email or not password or not username:
            return jsonify({"status": "error", "message": "Vui lòng điền đầy đủ thông tin"}), 400

        # GỌI HÀM MỚI: register_admin_temp
        result = AdminDAO.register_admin_temp(email, username, password)

        return jsonify(result), (201 if result["status"] == "success" else 400)
        
    except Exception as e:
        print(traceback.format_exc())
        return jsonify({"status": "error", "message": "Lỗi hệ thống nội bộ!"}), 500
    

### 3. API Xác thực OTP (Chuyển từ tạm sang chính)
@user_bp.route('/admin/verify-otp', methods=['POST'])
def verify_otp():
    data = request.json
    email = data.get('email')
    otp = data.get('otp')
    
    if not email or not otp:
        return jsonify({"status": "error", "message": "Thiếu email hoặc mã OTP"}), 400
        
    # GỌI HÀM MỚI: verify_otp_and_promote
    result = AdminDAO.verify_otp_and_promote(email, otp)
    return jsonify(result), (200 if result["status"] == "success" else 400)


### 4. API Check Trạng Thái Duyệt (Dành cho React polling)
@user_bp.route('/admin/check-status', methods=['GET'])
def check_status():
    email = request.args.get('email')
    if not email:
        return jsonify({"status": "error", "message": "Thiếu email"}), 400
        
    from utils.db import get_db
    db = get_db()
    admin = db.admins.find_one({"email": email})
    
    if admin:
        return jsonify({
            "status": "success",
            "check_account": admin.get("check_account", False)
        }), 200
    return jsonify({"status": "error", "message": "Tài khoản chưa hoàn tất đăng ký"}), 404



### 5. API Duyệt tài khoản (Chỉ Super Admin)
@user_bp.route('/admin/list', methods=['GET'])
@token_required # Chỉ ai có token mới được xem
def get_admins():
    admins = AdminDAO.get_all_admins()
    return jsonify(convert_objectid_to_str(admins)), 200

@user_bp.route('/admin/approve', methods=['POST'])
@token_required
def approve_admin():
    # 1. Debug để ông tự tin nhìn thấy dữ liệu
    print(f"DEBUG - Full User data: {request.user}")
    
    # 2. Lấy cái 'túi' uid ra trước (Vì dữ liệu của ông đang bị lồng)
    user_payload = request.user.get('uid', {})
    
    # 3. Lấy role từ trong cái túi đó và ép kiểu về string cho chắc
    user_role = str(user_payload.get('role')) 
    
    print(f"DEBUG - Role thực tế lấy được: {user_role}")

    # 4. So sánh: Nếu không phải "0" thì chặn luôn
    if user_role != "0": 
        return jsonify({"status": "error", "message": "Bạn không có quyền duyệt hồ sơ!"}), 403
        
    # --- PHẦN LOGIC DUYỆT GIỮ NGUYÊN ---
    admin_id = request.json.get('admin_id')
    
    if not admin_id:
        return jsonify({"status": "error", "message": "Thiếu ID quản trị viên!"}), 400

    if AdminDAO.approve_admin(admin_id):
        return jsonify({"status": "success", "message": "Đã duyệt thành công!"}), 200
    
    return jsonify({"status": "error", "message": "Duyệt thất bại!"}), 400

@user_bp.route('/admin/toggle-lock', methods=['POST'])
@token_required
def lock_admin():
    # Chỉ Super Admin mới được khóa người khác
    if str(request.user.get('uid', {}).get('role')) != "0":
        return jsonify({"status": "error", "message": "Bạn không có quyền!"}), 403
        
    admin_id = request.json.get('admin_id')
    success, msg = AdminDAO.toggle_lock_admin(admin_id)
    
    if success:
        return jsonify({"status": "success", "message": msg}), 200
    return jsonify({"status": "error", "message": msg}), 400

@user_bp.route('/admin/delete', methods=['POST'])
@token_required
def delete_admin_by_id():
    if str(request.user.get('uid', {}).get('role')) != "0":
        return jsonify({"status": "error", "message": "Bạn không có quyền!"}), 403
        
    admin_id = request.json.get('admin_id')
    
    # Không cho phép tự xóa chính mình ở đây (nên xóa ở Profile Panel)
    if admin_id == request.user.get('uid', {}).get('uid'):
        return jsonify({"status": "error", "message": "Không thể tự xóa chính mình tại đây!"}), 400

    success, msg = AdminDAO.delete_admin(admin_id)
    if success:
        return jsonify({"status": "success", "message": msg}), 200
    return jsonify({"status": "error", "message": msg}), 400


# ----- Tài khoảng cá nhân ----- #


# Tài khoản sau khi đăng nhập
@user_bp.route('/admin/profile', methods=['GET'])
@token_required
def get_profile():
    # Lấy ID từ Vali (Token)
    user_payload = request.user.get('uid', {})
    admin_id = user_payload.get('uid')
    
    # Ra lệnh cho DAO bốc dữ liệu lên
    admin = AdminDAO.get_admin_by_id(admin_id)
    
    if not admin:
        return jsonify({"message": "Không tìm thấy hồ sơ"}), 404
        
    return jsonify({
        "fullName": admin.username,
        "email": admin.email,
        "role": "Super Admin" if admin.role == "0" else "Admin",
        "phone": getattr(admin, 'phone', "Chưa cập nhật"),
        "avatar": getattr(admin, 'avatar', "")
    }), 200

@user_bp.route('/admin/update-profile', methods=['POST'])
@token_required
def update_profile():
    user_payload = request.user.get('uid', {})
    admin_id = user_payload.get('uid')
    data = request.json

    # Ra lệnh cho DAO đi sửa dữ liệu
    if AdminDAO.update_admin_profile(admin_id, data):
        return jsonify({"status": "success", "message": "Cập nhật thành công!"}), 200
    
    return jsonify({"status": "error", "message": "Cập nhật thất bại!"}), 400

@user_bp.route('/admin/change-password', methods=['POST'])
@token_required
def change_password():
    user_payload = request.user.get('uid', {})
    admin_id = user_payload.get('uid')
    data = request.json
    
    current_pass = data.get('currentPassword')
    new_pass = data.get('newPassword')
    
    if not current_pass or not new_pass:
        return jsonify({"status": "error", "message": "Vui lòng nhập đầy đủ thông tin!"}), 400

    success, message = AdminDAO.change_password(admin_id, current_pass, new_pass)
    
    if success:
        return jsonify({"status": "success", "message": message}), 200
    return jsonify({"status": "error", "message": message}), 400

@user_bp.route('/admin/delete-account', methods=['POST'])
@token_required
def delete_my_account():
    # Lấy ID từ Token của người đang đăng nhập
    user_payload = request.user.get('uid', {})
    admin_id = user_payload.get('uid')

    if AdminDAO.delete_admin_account(admin_id):
        return jsonify({
            "status": "success", 
            "message": "Tài khoản của bạn đã được xóa vĩnh viễn khỏi hệ thống."
        }), 200
    
    return jsonify({"status": "error", "message": "Không thể thực hiện yêu cầu lúc này!"}), 400


# ================================================================
# SECTION: QUẢN LÝ KHÁCH HÀNG (USERS) - DÀNH CHO ADMIN
# ================================================================

### 1. Lấy danh sách toàn bộ khách hàng (CN.083)
@user_bp.route('/user/list', methods=['GET'])
@token_required
def get_all_customers():
    try:
        # Gọi DAO lấy danh sách đã xử lý fallback (location, avatar)
        users = UserDAO.get_all_users()
        return jsonify(convert_objectid_to_str(users)), 200
    except Exception as e:
        print(traceback.format_exc())
        return jsonify({"status": "error", "message": "Không thể lấy danh sách người dùng"}), 500

### 2. Khóa hoặc Mở khóa tài khoản khách hàng (CN.087)
@user_bp.route('/user/toggle-lock', methods=['POST'])
@token_required
def toggle_lock_customer():
    try:
        data = request.json
        user_id = data.get('user_id')
        
        if not user_id:
            return jsonify({"status": "error", "message": "Thiếu ID người dùng"}), 400

        success, msg = UserDAO.toggle_lock_user(user_id)
        if success:
            return jsonify({"status": "success", "message": msg}), 200
        return jsonify({"status": "error", "message": msg}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": "Lỗi thao tác khóa/mở khóa"}), 500

### 3. Xóa vĩnh viễn khách hàng (CN.088)
@user_bp.route('/user/delete', methods=['POST'])
@token_required
def delete_customer():
    try:
        # Admin và Super Admin đều có quyền xóa user (theo yêu cầu của ông)
        data = request.json
        user_id = data.get('user_id')
        
        if not user_id:
            return jsonify({"status": "error", "message": "Thiếu ID người dùng"}), 400

        success, msg = UserDAO.delete_user(user_id)
        if success:
            return jsonify({"status": "success", "message": msg}), 200
        return jsonify({"status": "error", "message": msg}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": "Lỗi khi xóa người dùng"}), 500

### 4. Lấy lịch sử chi tiết của 1 khách hàng (CN.085 & CN.086)
# 1. Tab Quét bệnh
@user_bp.route('/user/history/scans', methods=['GET', 'OPTIONS'])
@token_required
def get_history_scans():
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({"status": "error", "message": "Thiếu ID"}), 400
            
        scans = UserDAO.get_user_scans(user_id)
        return jsonify(convert_objectid_to_str(scans)), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# 2. Tab Bài đăng
@user_bp.route('/user/history/posts', methods=['GET', 'OPTIONS'])
@token_required
def get_history_posts():
    try:
        user_id = request.args.get('user_id')
        posts = UserDAO.get_user_posts(user_id)
        
        # Dùng hàm safe mới này, đảm bảo jsonify không bao giờ nghẹn
        return jsonify(make_json_safe(posts)), 200
    except Exception as e:
        import traceback
        print(traceback.format_exc()) # In lỗi chi tiết ra Terminal
        return jsonify({"status": "error", "message": str(e)}), 500

# 3. Tab Chat AI
@user_bp.route('/user/history/ai', methods=['GET', 'OPTIONS'])
@token_required
def get_history_ai():
    try:
        user_id = request.args.get('user_id')
        ai_chats = UserDAO.get_user_ai_chats(user_id)
        return jsonify(convert_objectid_to_str(ai_chats)), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

### Lấy bình luận của một bài đăng cụ thể (Dành cho nút "Xem bình luận")
@user_bp.route('/post/comments', methods=['GET', 'OPTIONS'])
@token_required
def get_post_comments():
    try:
        post_id = request.args.get('post_id')
        comments = UserDAO.get_comments_by_post(post_id)
        # Sử dụng hàm safe để xử lý đệ quy authorData và createdAt
        return jsonify(make_json_safe(comments)), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@user_bp.route('/post/comment/delete', methods=['POST', 'OPTIONS']) # 👉 Thêm OPTIONS
@token_required
def delete_comment():
    try:
        data = request.json
        comment_id = data.get('comment_id')
        success, msg = UserDAO.delete_comment(comment_id)
        return jsonify({"status": "success" if success else "error", "message": msg}), 200 if success else 400
    except Exception as e:
        return jsonify({"status": "error", "message": "Lỗi xóa bình luận"}), 500


@user_bp.route('/dashboard/analytics', methods=['GET', 'OPTIONS'])
@token_required
def get_dashboard_analytics():
    # 1. Xử lý pre-flight request cho CORS
    if request.method == 'OPTIONS': 
        return '', 200
        
    try:
        # 2. Lấy tham số filter từ URL (mặc định là month nếu React không gửi)
        # Ví dụ: /api/dashboard/analytics?filter=quarter
        t_filter = request.args.get('filter', 'month')
        
        # 3. Gọi DAO để thực hiện Aggregation đếm dữ liệu
        data = UserDAO.get_analytics(t_filter)
        
        # 4. Kiểm tra nếu data bị None hoặc rỗng (đề phòng lỗi logic)
        if not data:
            data = [] 

        # 5. Dùng hàm make_json_safe ông đã viết ở trên để xử lý Date/ObjectId
        # Việc này cực kỳ quan trọng để Recharts ở Frontend không bị "nghẹn"
        return jsonify({
            "status": "success", 
            "data": make_json_safe(data),
            "applied_filter": t_filter
        }), 200

    except Exception as e:
        # 6. In lỗi chi tiết ra Terminal để ông dễ fix (đừng giấu lỗi)
        import traceback
        print("❌ LỖI BIỂU ĐỒ DASHBOARD:")
        print(traceback.format_exc())
        
        return jsonify({
            "status": "error", 
            "message": "Không thể tải dữ liệu thống kê!",
            "detail": str(e)
        }), 500
    
@user_bp.route('/dashboard/summary', methods=['GET', 'OPTIONS'])
@token_required
def get_dashboard_summary():
    if request.method == 'OPTIONS': return '', 200
    try:
        # 1. Gọi UserDAO lấy số liệu Khách hàng & Hỗ trợ
        user_stats = UserDAO.get_dashboard_summary()
        
        # 2. Gọi DiseaseDAO lấy số liệu Bệnh
        total_diseases = DiseaseDAO.get_total_diseases()

        # 3. Gọi HandbookDAO lấy số liệu cẩm nang
        total_handbook = HandbookDAO.get_total_handbook()
        # 3. Gom chung vào 1 cục (Merge Dictionary) để React dễ đọc
        stats = {
            "totalUsers": user_stats.get("totalUsers", 0),
            "totalhandbook": total_handbook,
            "totalDiseases": total_diseases 
        }
        
        return jsonify({
            "status": "success",
            "data": stats
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
# ================================================================
# SECTION: QUẢN LÝ DỮ LIỆU BỆNH - DÀNH CHO ADMIN
# ================================================================

@user_bp.route('/disease/save', methods=['POST', 'OPTIONS'])
@token_required
def save_disease_api():
    if request.method == 'OPTIONS': return '', 200
    try:
        data = request.json
        success, message = DiseaseDAO.save_disease(data)
        
        if success:
            return jsonify({"status": "success", "message": message}), 200
        return jsonify({"status": "error", "message": message}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@user_bp.route('/disease/list', methods=['GET', 'OPTIONS'])
@token_required
def get_disease_list():
    if request.method == 'OPTIONS': return '', 200
    try:
        data = DiseaseDAO.get_all_diseases()
        return jsonify({"status": "success", "data": data}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    

# ================================================================
# SECTION: QUẢN LÝ DỮ LIỆU CẨM NANG - DÀNH CHO ADMIN
# ================================================================

@user_bp.route('/handbook/save', methods=['POST', 'OPTIONS'])
@token_required
def save_handbook():
    if request.method == 'OPTIONS': return '', 200
    try:
        data = request.json
        success, message = HandbookDAO.save_handbook(data)
        
        if success:
            return jsonify({"status": "success", "message": message}), 200
        else:
            return jsonify({"status": "error", "message": message}), 500
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
@user_bp.route('/handbook/list', methods=['GET', 'OPTIONS'])
@token_required
def get_handbook_list():
    if request.method == 'OPTIONS': return '', 200
    try:
        data = HandbookDAO.get_all_handbooks()
        return jsonify({"status": "success", "data": data}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500