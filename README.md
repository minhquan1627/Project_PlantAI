#  Project_PlantAI: Hệ Sinh Thái AI Chẩn Đoán Bệnh Lý Cây Trồng

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Framework-Flask-red.svg)](https://flask.palletsprojects.com/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B.svg)](https://flutter.dev/)
[![Docker](https://img.shields.io/badge/DevOps-Docker-2496ED.svg)](https://www.docker.com/)
[![AI](https://img.shields.io/badge/Model-SAM2--L-orange.svg)](https://github.com/facebookresearch/segment-anything-2)
[![Geolocation](https://img.shields.io/badge/Feature-Geolocation-34A853.svg)](https://developers.google.com/maps/documentation/geolocation/overview)
[![Weather](https://img.shields.io/badge/Feature-WeatherData-FF9900.svg)](https://openweathermap.org/api)
[![Chatbot](https://img.shields.io/badge/Feature-ChatbotAI-4F46E5.svg)](https://huggingface.dev/docs/transformers/main_classes/tokenizer)

##  Tổng quan dự án

**Project_PlantAI** là một giải pháp công nghệ toàn diện hướng tới nông nghiệp thông minh. Dự án tập trung vào việc tự động hóa quá trình nhận diện và chẩn đoán bệnh lý trên cây trồng (trọng tâm là bệnh rỉ sắt trên lá cà phê) thông qua sức mạnh của **Deep Learning** và kiến trúc hệ thống hiện đại.

Dự án không chỉ dừng lại ở mức độ phần mềm mà còn là kết quả của quá trình **Nghiên cứu khoa học (NCKH)** thực địa, giúp chuyển hóa các thuật toán phức tạp thành công cụ thực tiễn cho người nông dân.

---

##  Tính năng nổi bật

* **Chẩn đoán bệnh lý bằng AI:** Tích hợp mô hình **SAM2-L (Segment Anything Model 2)** được tinh chỉnh (fine-tune) để phân đoạn và nhận diện vùng bệnh lý chính xác.
* **Hệ sinh thái đa nền tảng:** Ứng dụng di động được phát triển bằng **Flutter**, cho phép chẩn đoán trực tiếp tại vườn.
* **Tích hợp dữ liệu bối cảnh thực địa:** Mobile App tự động thu thập vị trí, dữ liệu thời tiết thực tế để hỗ trợ chẩn đoán chính xác hơn.
* **Kiến trúc Microservices:** Hệ thống Backend được thiết kế theo dạng các module độc lập, giúp tối ưu hóa hiệu suất và dễ dàng mở rộng.
* **Xác thực bảo mật:** Tích hợp hệ thống Email OTP để quản lý tài khoản người dùng an toàn.
* **Quản lý dữ liệu tập trung:** Kết nối MongoDB và Cloudinary để lưu trữ thông tin và hình ảnh chẩn đoán một cách khoa học.

---

##  Giao diện & Tính năng Ứng dụng Di động (Mobile App)

Phần này giới thiệu chi tiết về ứng dụng Flutter, "cánh tay nối dài" của hệ thống AI ra thực địa đồng ruộng.

Dưới đây là một số hình ảnh thực tế của ứng dụng di động:

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Đăng nhập / OTP</b></td>
      <td align="center"><b>Màn hình chính</b></td>
      <td align="center"><b>Chẩn đoán</b></td>
    </tr>
    <tr>
      <td>
        <img src="https://res.cloudinary.com/dmxpgpq01/image/upload/v1776937957/Screenshot_2026-04-23_165219_zfkkfy.png" width="200" alt="Login & OTP Screen">
        </td>
      <td>
        <img src="https://res.cloudinary.com/dmxpgpq01/image/upload/v1776938066/Screenshot_2026-04-23_165342_xzetca.png" width="200" alt="Main App Screen">
        </td>
      <td>
        <img src="https://res.cloudinary.com/dmxpgpq01/image/upload/v1776938167/Screenshot_2026-04-23_165535_ctwbua.png" width="200" alt="Diagnostic Result Screen">
        </td>
    </tr>
    <tr>
      <td align="center"><b>Vị trí & Thời tiết</b></td>
      <td align="center"><b>Chatbot AI</b></td>
    </tr>
    <tr>
      <td>
        <img src="https://res.cloudinary.com/dmxpgpq01/image/upload/v1776938387/Screenshot_2026-04-23_165811_ar8lk6.png" width="200" alt="Location & Weather Screen">
        </td>
      <td>
        <img src="https://res.cloudinary.com/dmxpgpq01/image/upload/v1776938474/Screenshot_2026-04-23_170101_srhxkf.png" width="200" alt="AI Chatbot Screen">
        </td>
    </tr>
  </table>
</div>

### 🎯 Các Tính năng Độc đáo khác trên Mobile App

* **Định vị & Quản lý Vị trí:** Sử dụng GPS để lấy chính xác tọa độ vị trí chẩn đoán, hỗ trợ lập bản đồ dịch bệnh.
* **Tích hợp Dữ liệu Thời tiết (Weather Data):** Lấy dữ liệu thực tế về nhiệt độ và độ ẩm từ các nguồn API thời tiết tại vị trí của người dùng, giúp phân tích nguy cơ bùng phát bệnh.
* **Trợ lý Chatbot AI (ChatbotAI):** Tích hợp chatbot AI hội thoại để giải đáp các thắc mắc về bệnh lý, cung cấp thông tin hướng dẫn và hỗ trợ người nông dân.

---

## 🛠 Stack Công nghệ

### AI & Deep Learning
* **Mô hình cốt lõi:** SAM2-L.
* **Thư viện:** PyTorch, OpenCV, NumPy, Hugging Face, Transformers.
* **Môi trường huấn luyện:** Google Colab.

### Backend (Hệ thống máy chủ)
* **Framework:** Python Flask (Blueprint Architecture).
* **Cơ sở dữ liệu:** MongoDB (MongoEngine), MySQL.
* **Xử lý bất đồng bộ:** AsyncIO.
* **Dịch vụ ngoài:** Cloudinary (Hosting hình ảnh), Flask-Mail (SMTP Service), [OpenWeatherMap API](https://openweathermap.org/api) (dữ liệu thời tiết).

### Frontend (Giao diện người dùng)
* **Ứng dụng di động:** Flutter (Dart).
* **Kiến trúc:** BLoC / Provider.
* **Gói Mobile độc đáo:** Geolocation / `geolocator`, Weather / `weather`, Chatbot / `dialogflow_flutter` (hoặc GPT/LLM integration package).

### DevOps & Vận hành
* **Containerization:** Docker & Docker Compose.
* **Hệ điều hành:** Linux Ubuntu Server.

---

## 🏗 Kiến trúc hệ thống sơ bộ

```text
[ Mobile App (Flutter) ] <------> [ API Gateway / Backend ]
        |                                     |
        --------------------------    ------------------------------------
        |                        |  |                         |          |
[ Geolocation Service ]  [ Weather API ]  [ User Service ] [ AI Inference Service ]
(GPS, Maps)              (OpenWeather)    (Flask + MongoDB)   (PyTorch + SAM2)
