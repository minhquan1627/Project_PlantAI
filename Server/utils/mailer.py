# utils/mailer.py
from flask_mail import Mail, Message # Phải có cả 2 thằng này
import os

mail = Mail()

def send_otp_email(receiver_email, otp):
    try:
        # Bây giờ Message đã được định nghĩa, nó sẽ không báo lỗi nữa
        msg = Message('Mã xác thực OTP - PlantAI',
                      recipients=[receiver_email])
        msg.body = f"Mã OTP của bạn là: {otp}. Mã này có hiệu lực trong 5 phút. Vui lòng không chia sẻ cho bất kỳ ai."
        
        mail.send(msg)
        return True
    except Exception as e:
        print(f" Lỗi gửi mail: {e}")
        return False