import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { User, Shield, Lock, Trash2, Camera, Check, X, Loader2 } from 'lucide-react';

const API_URL = "http://127.0.0.1:3000/api";

const ProfilePanel = ({ onLogout }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [showPasswordChange, setShowPasswordChange] = useState(false);
  const [avatarPreview, setAvatarPreview] = useState(null);
  const [userData, setUserData] = useState({
    fullName: "",
    email: "",
    role: "",
    phone: "",
    avatar: ""
  });

  const [passwords, setPasswords] = useState({
  current: "",
  new: "",
  confirm: ""
});

const convertToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);
  });
};
  // --- Logic: Lấy dữ liệu hồ sơ từ Backend ---
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get(`${API_URL}/admin/profile`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        setUserData(res.data);
      } catch (err) {
        console.error("Lỗi lấy hồ sơ:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, []);

  // --- Logic: Lưu thay đổi ---
  const handleSave = async () => {
    try {
      const token = localStorage.getItem("token");
      await axios.post(`${API_URL}/admin/update-profile`, userData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setIsEditing(false);
      alert("Đã cập nhật hồ sơ thành công!");
    } catch (err) {
      alert("Lỗi khi lưu thông tin!");
    }
  };

  if (loading) return <div className="loading-state"><Loader2 className="animate-spin" /> Đang tải...</div>;

  // Lấy 2 chữ cái đầu của tên để làm Avatar (Ví dụ: Minh Quân -> MQ)
  const getInitials = (name) => {
    if (!name) return "??";
    const parts = name.split(" ");
    return parts.length > 1 
      ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
      : name.slice(0, 2).toUpperCase();
  };

  const handleChangePassword = async () => {
  // Validation cơ bản tại Client
  if (passwords.new !== passwords.confirm) {
    alert("Mật khẩu mới và xác nhận không khớp!");
    return;
  }
  if (passwords.new.length < 6) {
    alert("Mật khẩu mới phải có ít nhất 6 ký tự!");
    return;
  }

  try {
    const token = localStorage.getItem("token");
    const res = await axios.post(`${API_URL}/admin/change-password`, {
      currentPassword: passwords.current,
      newPassword: passwords.new
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    alert(res.data.message);
    setShowPasswordChange(false); // Đóng form
    setPasswords({ current: "", new: "", confirm: "" }); // Reset form
  } catch (err) {
    alert(err.response?.data?.message || "Lỗi khi đổi mật khẩu");
  }
};

  const handleImageChange = async (e) => {
  const file = e.target.files[0];
  if (file) {
    if (file.size > 2 * 1024 * 1024) { // Giới hạn 2MB
      alert("Ảnh quá lớn, vui lòng chọn ảnh dưới 2MB");
      return;
    }
    const base64Str = await convertToBase64(file);
    setAvatarPreview(base64Str);
    
    // Cập nhật luôn vào userData để lúc bấm "Lưu Thay Đổi" nó đẩy lên Server
    setUserData(prev => ({ ...prev, avatar: base64Str })); 
  }
};

  const handleDeleteAccount = async () => {
  // BƯỚC 1: Xác nhận cực kỳ nghiêm túc
  const confirmFirst = window.confirm("CẢNH BÁO: Bạn có chắc chắn muốn XÓA VĨNH VIỄN tài khoản này không?");
  if (!confirmFirst) return;

  const confirmSecond = window.prompt("Hành động này không thể hoàn tác. Vui lòng nhập 'DELETE' để xác nhận:");
  if (confirmSecond !== "DELETE") {
    alert("Xác nhận không đúng, hủy lệnh xóa.");
    return;
  }

  // BƯỚC 2: Gọi API xóa
  try {
    const token = localStorage.getItem("token");
    const res = await axios.post(`${API_URL}/admin/delete-account`, {}, {
      headers: { Authorization: `Bearer ${token}` }
    });

    alert(res.data.message);
    
    // BƯỚC 3: Sau khi xóa xong thì đá người dùng ra trang Login
    onLogout(); 
    
  } catch (err) {
    alert("Có lỗi xảy ra khi xóa tài khoản. Vui lòng thử lại sau.");
  }
};

  return (
    <div className="profile-container">
      <div className="profile-header-card">
        <div className="avatar-section">
          <div className="large-avatar" style={{ overflow: 'hidden' }}>
            {avatarPreview || userData.avatar ? (
              <img 
                src={avatarPreview || userData.avatar} 
                alt="Avatar" 
                style={{ width: '100%', height: '100%', objectFit: 'cover' }} 
              />
            ) : (
              getInitials(userData.fullName)
            )}
          </div>
          
          {/* Thêm input file bị ẩn, và nút bấm kích hoạt nó */}
          <input 
            type="file" 
            id="avatar-upload" 
            accept="image/*" 
            style={{ display: 'none' }} 
            onChange={handleImageChange}
          />
          <label htmlFor="avatar-upload" className="btn-upload" style={{ cursor: 'pointer' }}>
            <Camera size={14} />
          </label>
        </div>
        <div className="user-basic-info">
          <h2>{userData.fullName}</h2>
          <span className="role-badge">{userData.role}</span>
        </div>
        <div className="header-actions">
          {!isEditing ? (
            <button className="btn-edit" onClick={() => setIsEditing(true)}>Chỉnh sửa hồ sơ</button>
          ) : (
            <div className="edit-group">
              <button className="btn-save" onClick={handleSave}><Check size={16} /> Lưu</button>
              <button className="btn-cancel" onClick={() => setIsEditing(false)}><X size={16} /></button>
            </div>
          )}
        </div>
      </div>

      <div className="profile-grid">
        <div className="info-card">
          <h3><User size={18} /> Thông tin cá nhân</h3>
          <div className="info-fields">
            <div className="field-group">
              <label>Họ và tên</label>
              <input 
                type="text" 
                value={userData.fullName} 
                disabled={!isEditing} 
                onChange={(e) => setUserData({...userData, fullName: e.target.value})}
              />
            </div>
            <div className="field-group">
              <label>Email</label>
              <input type="email" value={userData.email} disabled={true} />
              <small>Liên hệ quản trị hệ thống để đổi email</small>
            </div>
            <div className="field-group">
              <label>Số điện thoại</label>
              <input 
                type="text" 
                value={userData.phone} 
                disabled={!isEditing} 
                onChange={(e) => setUserData({...userData, phone: e.target.value})}
              />
            </div>
          </div>
        </div>

        
        <div className="info-card">
          <h3><Lock size={18} /> Bảo mật</h3>
          {!showPasswordChange ? (
            <button className="btn-secondary" onClick={() => setShowPasswordChange(true)}>
              Thay đổi mật khẩu
            </button>
          ) : (
            <div className="password-form">
                <div className="field-group">
                  <label>Mật khẩu hiện tại</label>
                  <input type="password" 
                    placeholder="••••••••" 
                    value={passwords.current}
                    onChange={(e) => setPasswords({...passwords, current: e.target.value})} />
                </div>
                
                <div className="field-group">
                  <label>Mật khẩu mới</label>
                  <input type="password" 
                    placeholder="Nhập mật khẩu mới" 
                    value={passwords.new}
                    onChange={(e) => setPasswords({...passwords, new: e.target.value})}/>
                </div>
                
                <div className="field-group">
                  <label>Xác nhận mật khẩu mới</label>
                  <input type="password" 
                    placeholder="Nhập lại mật khẩu mới" 
                    value={passwords.confirm}
                    onChange={(e) => setPasswords({...passwords, confirm: e.target.value})} />
                </div>

                <div className="edit-group">
                  <button className="btn-save-sm" onClick={handleChangePassword}>Cập nhật mật khẩu</button>
                  <button className="btn-cancel-sm" onClick={() => setShowPasswordChange(false)}>Hủy</button>
                </div>
            </div>
                  )}
          </div>

        
        <div className="info-card danger-zone">
          <h3><Shield size={18} /> Vùng nguy hiểm</h3>
          <p>Xóa tài khoản sẽ gỡ bỏ mọi quyền truy cập của bạn vào hệ thống PlantAI.</p>
          <button className="btn-danger" onClick={handleDeleteAccount}>
            <Trash2 size={16} /> Xóa tài khoản
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProfilePanel;