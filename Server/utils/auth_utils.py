import jwt
import datetime
from flask import request, jsonify
from functools import wraps
from .my_constants import MyConstants

# Tạo token
def gen_token(uid): 
    payload = {
        'uid': uid, 
        'exp': datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(seconds=int(MyConstants.JWT_EXPIRES) / 1000)
    }
    token = jwt.encode(payload, MyConstants.JWT_SECRET, algorithm='HS256')
    return token

# Kiểm tra token decorator
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        # 👉 CẢI TIẾN: Trả về 200 OK ngay lập tức cho request OPTIONS
        # Không được gọi f(*args, **kwargs) ở đây!
        if request.method == 'OPTIONS':
            return '', 200 

        token = request.headers.get('Authorization') or request.headers.get('x-access-token')   

        if not token:
            return jsonify({'success': False, 'message': 'No token provided'}), 403

        if token.startswith('Bearer '):
            token = token[7:]

        try:
            data = jwt.decode(token, MyConstants.JWT_SECRET, algorithms=['HS256'])
            request.user = data 
        except jwt.ExpiredSignatureError:
            return jsonify({'success': False, 'message': 'Token expired'}), 401
        except (jwt.InvalidTokenError, jwt.DecodeError):
            return jsonify({'success': False, 'message': 'Invalid token'}), 401

        return f(*args, **kwargs)

    return decorated

def check_token():
    # 👉 Cũng nên thêm ở đây nếu hàm này được gọi lẻ
    if request.method == 'OPTIONS':
        return {}, None, 200

    token = request.headers.get('Authorization') or request.headers.get('x-access-token')

    if not token:
        return None, {'success': False, 'message': 'No token provided'}, 403

    if token.startswith('Bearer '):
        token = token[7:]

    try:
        data = jwt.decode(token, MyConstants.JWT_SECRET, algorithms=['HS256'])
        return data, None, 200
    except jwt.ExpiredSignatureError:
        return None, {'success': False, 'message': 'Token expired'}, 401
    except jwt.InvalidTokenError:
        return None, {'success': False, 'message': 'Invalid token'}, 401