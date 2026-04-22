import React, { useState, useRef } from "react";
import axios from "axios";
import { motion, AnimatePresence } from "framer-motion";
import { Mail, Lock, User, ShieldCheck, ArrowRight, AlertCircle, CheckCircle2, Key, UserKey, Eye, EyeOff } from "lucide-react";
import '../styles/LoginandRegisterComponent.css'; 
import logoImg from '../assets/Logo.png';

const API_URL = "http://127.0.0.1:3000/api";

const LoginAndRegister = ({ onLoginSuccess }) => {
  const [view, setView] = useState('login'); 
  const [loading, setLoading] = useState(false);
  const [loginError, setLoginError] = useState(null);
  const [registerSuccess, setRegisterSuccess] = useState(false);

  // State hiển thị password
  const [showRegPass, setShowRegPass] = useState(false);
  const [showRegConfirmPass, setShowRegConfirmPass] = useState(false);

  // State lưu dữ liệu Form
  const [loginData, setLoginData] = useState({ email: '', password: '' });
  const [regData, setRegData] = useState({ fullName: '', email: '', password: '', confirmPassword: '' });
  const [otp, setOtp] = useState(new Array(6).fill(""));

  const [serverMessage, setServerMessage] = useState("");

  // --- Logic 1: Đăng nhập (Chỉ dùng Email) ---
  const handleLogin = async (e) => {
    e.preventDefault();
    setLoginError(null);
    setServerMessage("");
    setLoading(true);

    try {
      const res = await axios.post(`${API_URL}/admin/login`, {
        username: loginData.email, 
        password: loginData.password
      });

      if (res.data.status === "success") {
        const { token, admin } = res.data;
        const userRole = admin.role;

        localStorage.setItem("token", token);
        localStorage.setItem("role", userRole);
        localStorage.setItem("username", admin.username);

        console.log(`Đăng nhập thành công với quyền: ${userRole === "0" ? "Super Admin" : "Admin"}`);
        onLoginSuccess(userRole); 
      }
    } catch (err) {
      // ✅ KHAI BÁO BIẾN ĐỂ LẤY DỮ LIỆU TỪ SERVER
      const responseData = err.response?.data; 

      if (responseData && responseData.message) {
        // Nếu Server có trả về message cụ thể (Khóa, Chờ duyệt...)
        setLoginError(responseData.status); // Lấy "error" hoặc "warning"
        setServerMessage(responseData.message); // Lấy nội dung câu thông báo
      } else {
        // Nếu lỗi mạng hoặc lỗi không xác định
        setLoginError('wrong'); 
        setServerMessage("Sai tài khoản hoặc mật khẩu hoặc lỗi kết nối!");
      }
      
      console.error("Lỗi đăng nhập:", err.response);
    } finally {
      setLoading(false);
    }
  };

  // --- Logic 2: Đăng ký (Họ tên -> Username) ---
  const handleRegisterSubmit = async (e) => {
    e.preventDefault();
    if (regData.password !== regData.confirmPassword) {
      alert("Mật khẩu nhập lại không khớp!");
      return;
    }

    setLoading(true);
    try {
      const res = await axios.post(`${API_URL}/admin/register`, {
        username: regData.fullName, // "Họ và tên" chính là Username
        email: regData.email,
        password: regData.password
      });
      if (res.data.status === "success") {
        setView('otp');
      }
    } catch (err) {
      alert(err.response?.data?.message || "Lỗi đăng ký!");
    } finally { setLoading(false); }
  };

  // --- Logic 3: Xác nhận OTP ---
  const handleVerifyOTP = async () => {
    setLoading(true);
    try {
      const otpCode = otp.join("");
      const res = await axios.post(`${API_URL}/admin/verify-otp`, {
        email: regData.email,
        otp: otpCode
      });
      if (res.data.status === "success") {
        setRegisterSuccess(true);
        setView('login');
      }
    } catch (err) {
      alert(err.response?.data?.message || "Mã OTP không chính xác!");
    } finally { setLoading(false); }
  };

  // --- Logic 4: Xử lý ô OTP (Tự nhảy ô) ---
  const handleOtpChange = (element, index) => {
    if (isNaN(element.value)) return;
    let newOtp = [...otp];
    newOtp[index] = element.value;
    setOtp(newOtp);
    if (element.nextSibling && element.value !== "") {
      element.nextSibling.focus();
    }
  };

  const eyeButtonStyle = { position: 'absolute', right: '15px', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: '#94a3b8', display: 'flex', alignItems: 'center', padding: 0 };

  return (
    <div className="mac-container">
      <div className="mac-window">
        {/* Cột trái - GIỮ NGUYÊN */}
        <div className="side-brand">
          <img src={logoImg} alt="PlantAI Logo" style={{ width: '200px', height: 'auto', marginBottom: '20px', display: 'block' }} />
          <h1>PlantAI</h1>
          <p>Hệ thống quản trị thông minh<br/>cho tương lai xanh.</p>
        </div>

        {/* Cột phải - GIỮ NGUYÊN CẤU TRÚC THẺ */}
        <div className="side-form">
          <AnimatePresence mode="wait">
            
            {/* VIEW LOGIN */}
            {view === 'login' && (  
              <motion.div key="login" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }}>
                <div className="form-header">
                  <h2>Đăng nhập</h2>
                  <p>Chào mừng Admin quay trở lại.</p>
                </div>

                {loginError && serverMessage && (
                  <div className={`alert ${loginError === 'error' ? 'alert-danger' : 'alert-warning'}`}
                      style={loginError === 'error' ? { background: '#fee2e2', color: '#dc2626', border: '1px solid #fecaca' } : {}}>
                    <AlertCircle size={18} /> {serverMessage}
                  </div>
                )}

                {registerSuccess && (
                  <div className="alert alert-success">
                    <CheckCircle2 size={18} /> Đăng ký thành công! Hãy đợi duyệt.
                  </div>
                )}

                <form onSubmit={handleLogin}>
                  <div className="input-group">
                    <Mail className="input-icon" size={18} />
                    <input type="email" placeholder="Email" required 
                      value={loginData.email} onChange={(e) => setLoginData({...loginData, email: e.target.value})} />
                  </div>
                  <div className="input-group">
                    <Lock className="input-icon" size={18} />
                    <input type="password" placeholder="Mật khẩu" required 
                      value={loginData.password} onChange={(e) => setLoginData({...loginData, password: e.target.value})} />
                  </div>
                  <button type="submit" className="btn-primary" disabled={loading}>
                    {loading ? "ĐANG XỬ LÝ..." : "ĐANG NHẬP"} <ArrowRight size={18} style={{float: 'right'}}/>
                  </button>
                </form>
                <p style={{textAlign: 'center', marginTop: '25px', fontSize: '0.9rem', color: '#888'}}>
                  Chưa có tài khoản? <button onClick={() => {setView('register'); setLoginError(null)}} style={{color: '#90A955', fontWeight: 'bold', border: 'none', background: 'none', cursor: 'pointer'}}>Đăng ký</button>
                </p>
              </motion.div>
            )}

            {/* VIEW OTP */}
            {view === 'otp' && (
              <motion.div key="otp" initial={{ opacity: 0 }} animate={{ opacity: 1 }} style={{textAlign: 'center'}}>
                <ShieldCheck size={50} color="#90A955" style={{margin: '0 auto 20px'}} />
                <h2>Xác nhận OTP</h2>
                <p style={{marginBottom: '30px', color: '#888'}}>Mã đã gửi vào {regData.email}</p>
                <div className="otp-container">
                  {otp.map((data, index) => (
                    <input key={index} className="otp-input" maxLength="1" 
                      value={data} onChange={e => handleOtpChange(e.target, index)} />
                  ))}
                </div>
                <button className="btn-primary" onClick={handleVerifyOTP} disabled={loading}>
                  {loading ? "ĐANG XÁC THỰC..." : "XÁC NHẬN"}
                </button>
              </motion.div>
            )}

            {/* VIEW REGISTER */}
            {view === 'register' && (
              <motion.div key="register" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }}>
                <div className="form-header">
                  <h2>Đăng ký Admin</h2>
                  <p>Yêu cầu quyền quản trị hệ thống.</p>
                </div>
                <form onSubmit={handleRegisterSubmit}>
                  <div className="input-group">
                    <User className="input-icon" size={18} />
                    <input type="text" placeholder="Họ và tên" required
                      value={regData.fullName} onChange={(e) => setRegData({...regData, fullName: e.target.value})} />
                  </div>
                  <div className="input-group">
                    <Mail className="input-icon" size={18} />
                    <input type="email" placeholder="Email" required
                      value={regData.email} onChange={(e) => setRegData({...regData, email: e.target.value})} />
                  </div>
                  <div className="input-group" style={{ position: 'relative' }}>
                    <Key className="input-icon" size={18} />
                    <input type={showRegPass ? "text" : "password"} placeholder="Nhập mật khẩu" required
                      value={regData.password} onChange={(e) => setRegData({...regData, password: e.target.value})} style={{ paddingRight: '40px' }} />
                    <button type="button" onClick={() => setShowRegPass(!showRegPass)} style={eyeButtonStyle}>
                      {showRegPass ? <EyeOff size={18} /> : <Eye size={18} />}
                    </button>
                  </div>
                  <div className="input-group" style={{ position: 'relative' }}>
                    <UserKey className="input-icon" size={18} />
                    <input type={showRegConfirmPass ? "text" : "password"} placeholder="Nhập lại mật khẩu" required
                      value={regData.confirmPassword} onChange={(e) => setRegData({...regData, confirmPassword: e.target.value})} style={{ paddingRight: '40px' }} />
                    <button type="button" onClick={() => setShowRegConfirmPass(!showRegConfirmPass)} style={eyeButtonStyle}>
                      {showRegConfirmPass ? <EyeOff size={18} /> : <Eye size={18} />}
                    </button>
                  </div>
                  <button type="submit" className="btn-primary" disabled={loading}>GỬI MÃ OTP</button>
                </form>
                <button onClick={() => setView('login')} style={{display: 'block', width: '100%', marginTop: '15px', color: '#aaa', border: 'none', background: 'none', cursor: 'pointer'}}>Quay lại</button>
              </motion.div>
            )}

          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};

export default LoginAndRegister;