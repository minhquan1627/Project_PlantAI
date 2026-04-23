
# 🌿 Project_PlantAI: Hệ Sinh Thái AI Chẩn Đoán Bệnh Lý Cây Trồng

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Framework-Flask-red.svg)](https://flask.palletsprojects.com/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B.svg)](https://flutter.dev/)
[![Docker](https://img.shields.io/badge/DevOps-Docker-2496ED.svg)](https://www.docker.com/)
[![AI](https://img.shields.io/badge/Model-SAM2--L-orange.svg)](https://github.com/facebookresearch/segment-anything-2)

## 🎯 Tổng quan dự án

**Project_PlantAI** là một giải pháp công nghệ toàn diện hướng tới nông nghiệp thông minh. Dự án tập trung vào việc tự động hóa quá trình nhận diện và chẩn đoán bệnh lý trên cây trồng (trọng tâm là bệnh rỉ sắt trên lá cà phê) thông qua sức mạnh của **Deep Learning** và kiến trúc hệ thống hiện đại.

Dự án không chỉ dừng lại ở mức độ phần mềm mà còn là kết quả của quá trình **Nghiên cứu khoa học (NCKH)** thực địa, giúp chuyển hóa các thuật toán phức tạp thành công cụ thực tiễn cho người nông dân.

---

## ✨ Tính năng nổi bật

* **Chẩn đoán bệnh lý bằng AI:** Tích hợp mô hình **SAM2-L (Segment Anything Model 2)** được tinh chỉnh (fine-tune) để phân đoạn và nhận diện vùng bệnh lý chính xác.
* **Hệ sinh thái đa nền tảng:** Ứng dụng di động được phát triển bằng **Flutter**, cho phép chẩn đoán trực tiếp tại vườn.
* **Kiến trúc Microservices:** Hệ thống Backend được thiết kế theo dạng các module độc lập, giúp tối ưu hóa hiệu suất và dễ dàng mở rộng.
* **Xác thực bảo mật:** Tích hợp hệ thống Email OTP để quản lý tài khoản người dùng an toàn.
* **Quản lý dữ liệu tập trung:** Kết nối MongoDB và Cloudinary để lưu trữ thông tin và hình ảnh chẩn đoán một cách khoa học.

---

## 🛠 Stack Công nghệ

### AI & Deep Learning
* **Mô hình cốt lõi:** SAM2-L.
* **Thư viện:** PyTorch, OpenCV, NumPy, Hugging Face.
* **Môi trường huấn luyện:** Google Colab.

### Backend (Hệ thống máy chủ)
* **Framework:** Python Flask (Blueprint Architecture).
* **Cơ sở dữ liệu:** MongoDB (MongoEngine), MySQL.
* **Xử lý bất đồng bộ:** AsyncIO.
* **Dịch vụ ngoài:** Cloudinary (Hosting hình ảnh), Flask-Mail (SMTP Service).

### Frontend (Giao diện người dùng)
* **Ứng dụng di động:** Flutter (Dart).
* **Kiến trúc:** BLoC / Provider.

### DevOps & Vận hành
* **Containerization:** Docker & Docker Compose.
* **Hệ điều hành:** Linux Ubuntu Server.

---

## 🏗 Kiến trúc hệ thống sơ bộ

```text
[ Mobile App (Flutter) ] <------> [ API Gateway / Backend ]
                                          |
        ------------------------------------------------------------------
        |                         |                              |
[ User Service ]          [ AI Inference Service ]        [ Media Service ]
(Flask + MongoDB)         (PyTorch + SAM2)                (Cloudinary API)
