from flask import Flask, request, jsonify
from flask_cors import CORS
from api.UserAPI import user_bp
from flask_mail import Mail, Message
from utils.mailer import mail
import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv
from utils.db import connect_mongoengine
import os

load_dotenv()

app = Flask(__name__)

connect_mongoengine()

app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USE_SSL'] = False
app.config['MAIL_USERNAME'] = os.getenv("MAIL_USERNAME") # Email của ông
app.config['MAIL_PASSWORD'] = os.getenv("MAIL_PASSWORD") # Mật khẩu ứng dụng (App Password)
app.config['MAIL_DEFAULT_SENDER'] = os.getenv("MAIL_USERNAME")

mail = Mail()
mail.init_app(app)

# Cấu hình CORS
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

# Cấu hình payload tối đa
app.config['MAX_CONTENT_LENGTH'] = int(os.getenv("MAX_CONTENT_LENGTH", 10)) * 1024 * 1024  # default 10MB
cloudinary.config( 
  cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME"), 
  api_key = os.getenv("CLOUDINARY_API_KEY"), 
  api_secret = os.getenv("CLOUDINARY_API_SECRET"),
  secure = True
)
# Mount blueprint
app.register_blueprint(user_bp, url_prefix='/api')

@app.route('/', methods=['GET'])
def hello():
    return jsonify({'message': 'Hello from server!'})

def send_otp_email(receiver_email, otp):
    try:
        # Message bây giờ đã được định nghĩa trong file này nên sẽ KHÔNG lỗi nữa
        msg = Message(
            subject='Mã xác thực OTP - PlantAI',
            recipients=[receiver_email],
            body=f"Mã OTP của bạn là: {otp}. Mã này có hiệu lực trong 5 phút."
        )
        mail.send(msg)
        return True
    except Exception as e:
        print(f" Lỗi gửi mail thực tế: {e}")
        return False

app.send_otp_email = send_otp_email
# Khởi động server
if __name__ == '__main__':
    port = int(os.getenv("PORT", 3000))
    debug = os.getenv("DEBUG", "False").lower() == "true"
    app.run(host='0.0.0.0', port=port, debug=debug)