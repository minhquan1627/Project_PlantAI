import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Search, UserPlus, ShieldCheck, ShieldAlert, Trash2, 
  History, Lock, Unlock, CheckCircle, X, Clock, Eye,
  ChevronDown, Check, User
} from 'lucide-react';
import { motion, AnimatePresence } from "framer-motion";
import "../styles/AdminManagement.css";

const API_URL = "http://127.0.0.1:3000/api";


const AdminManagement = () => {
  const [admins, setAdmins] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [filterStatus, setFilterStatus] = useState("all");
  const [showSuggestions, setShowSuggestions] = useState(false); 
  const [isOpenFilter, setIsOpenFilter] = useState(false);

  // --- Logic: Lấy danh sách từ Backend ---
  const suggestions = admins
    .filter(a => a.username.toLowerCase().includes(searchTerm.toLowerCase()) && searchTerm.length > 0)
    .slice(0, 5);
  
  const statusOptions = [
    { id: 'all', label: 'Tất cả trạng thái', color: '#64748b' },
    { id: 'active', label: 'Đang hoạt động', color: '#10b981' },
    { id: 'pending', label: 'Chờ phê duyệt', color: '#f59e0b' },
    { id: 'locked', label: 'Đang bị khóa', color: '#ef4444' }
  ];
  const fetchAdmins = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/admin/list`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setAdmins(res.data);
    } catch (err) {
      console.error("Lỗi lấy danh sách:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchAdmins(); }, []);

  // --- Logic: Duyệt hồ sơ (Tích xanh) ---
  const handleApprove = async (adminId) => {
    if (!window.confirm("Bạn có chắc chắn muốn duyệt quản trị viên này?")) return;
    try {
      const token = localStorage.getItem("token");
      await axios.post(`${API_URL}/admin/approve`, { admin_id: adminId }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert("Đã phê duyệt thành công!");
      fetchAdmins(); // Load lại danh sách
    } catch (err) {
      alert("Lỗi khi duyệt!");
    }
  };

  const handleToggleLock = async (adminId) => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.post(`${API_URL}/admin/toggle-lock`, { admin_id: adminId }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert(res.data.message);
      fetchAdmins(); // Load lại danh sách để cập nhật icon
    } catch (err) {
      alert(err.response?.data?.message || "Lỗi khi thực hiện thao tác");
    }
  };

  const handleDelete = async (adminId) => {
    if (!window.confirm("CẢNH BÁO: Bạn có chắc chắn muốn XÓA VĨNH VIỄN quản trị viên này?")) return;
    
    try {
      const token = localStorage.getItem("token");
      const res = await axios.post(`${API_URL}/admin/delete`, { admin_id: adminId }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      alert(res.data.message);
      fetchAdmins();
    } catch (err) {
      alert(err.response?.data?.message || "Lỗi khi xóa");
    }
  };

  const filteredAdmins = admins.filter(admin => {
    // 1. Lọc theo tên hoặc email
    const matchesSearch = 
        admin.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
        admin.email.toLowerCase().includes(searchTerm.toLowerCase());

    // 2. Xác định trạng thái thực tế để lọc
    const isPending = !admin.check_account;
    const isLocked = admin.is_locked;
    let currentStatus = "active";
    if (isPending) currentStatus = "pending";
    else if (isLocked) currentStatus = "locked";

    // 3. Lọc theo trạng thái đã chọn
    const matchesFilter = filterStatus === "all" || currentStatus === filterStatus;

    return matchesSearch && matchesFilter;
});

  // Các hàm khác (Delete, Lock...) Quân viết tương tự nhé
  const [activityLogs, setActivityLogs] = useState([]);
  const [selectedAdmin, setSelectedAdmin] = useState(null);
  const [showHistory, setShowHistory] = useState(false);


  return (
    <div className="admin-mgmt-container">
      <div className="mgmt-header">
        <div className="mgmt-title">
          <h2>Danh sách Quản trị viên</h2>
          <span>Tổng cộng {admins.length} nhân sự</span>
        </div>
        <div className="mgmt-controls">
          {/* THANH TÌM KIẾM CÓ GỢI Ý */}
          <div className="search-wrapper">
            <div className="search-box-modern">
              <Search size={18} />
              <input 
                type="text" 
                placeholder="Tìm tên hoặc email..." 
                value={searchTerm}
                onChange={(e) => {setSearchTerm(e.target.value); setShowSuggestions(true);}}
                onFocus={() => setShowSuggestions(true)}
                onBlur={() => setTimeout(() => setShowSuggestions(false), 200)} 
              />
            </div>
            
            <AnimatePresence>
              {showSuggestions && suggestions.length > 0 && (
                <motion.ul 
                  className="search-suggestions"
                  initial={{ opacity: 0, y: -10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                >
                  {suggestions.map(s => (
                    <li key={s._id} onClick={() => {setSearchTerm(s.username); setShowSuggestions(false);}}>
                      <User size={14} />
                      <div className="sugg-info">
                        <span className="sugg-name">{s.username}</span>
                        <span className="sugg-email">{s.email}</span>
                      </div>
                    </li>
                  ))}
                </motion.ul>
              )}
            </AnimatePresence>
          </div>

          {/* BỘ LỌC CUSTOM THAY THẾ CHO SELECT CŨ */}
          <div className="custom-filter">
            <button className="filter-trigger" onClick={() => setIsOpenFilter(!isOpenFilter)}>
              <div className="filter-dot" style={{ 
                background: statusOptions.find(o => o.id === filterStatus)?.color || '#64748b' 
              }}></div>
              <span>{statusOptions.find(o => o.id === filterStatus)?.label}</span>
              <ChevronDown size={16} className={isOpenFilter ? 'rotate' : ''} />
            </button>

            <AnimatePresence>
              {isOpenFilter && (
                <motion.ul 
                  className="filter-dropdown"
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                >
                  {statusOptions.map(opt => (
                    <li key={opt.id} onClick={() => {setFilterStatus(opt.id); setIsOpenFilter(false);}}>
                      <div className="dot" style={{ background: opt.color }}></div>
                      {opt.label}
                      {filterStatus === opt.id && <Check size={14} className="check-icon" />}
                    </li>
                  ))}
                </motion.ul>
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>

      <div className="admin-table-wrapper">
        <table className="admin-table">
          <thead>
            <tr>
              <th>Quản trị viên</th>
              <th>Trạng thái</th>
              <th>Vai trò</th>
              <th style={{ textAlign: 'right' }}>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {filteredAdmins.map((admin) => {
              // Xác định trạng thái dựa trên dữ liệu DB
              const isPending = !admin.check_account;
              const isLocked = admin.is_locked; // Đảm bảo dòng này nằm TRÊN cùng

              // BƯỚC 2: Sau đó mới dùng các biến đó để tính toán logic
              let status = "Active";
              if (isPending) {
                status = "Pending";
              } else if (isLocked) {
                status = "Locked";
              }

              

              return (
                <tr key={admin._id} className={isLocked ? 'row-locked' : ''}>
                  <td>
                    <div className="admin-info-cell">
                      {admin.avatar ? (
                        <img 
                          src={admin.avatar} 
                          alt="Avatar" 
                          className="admin-avatar-sm" 
                          style={{ objectFit: 'cover' }} // Giúp ảnh không bị méo
                        />
                      ) : (
                        <div className="admin-avatar-sm">
                          {admin.username ? admin.username.charAt(0).toUpperCase() : "?"}
                        </div>
                      )}
                      <div>
                        <div className="admin-name">{admin.username}</div>
                        <div className="admin-email">{admin.email}</div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className={`status-badge ${status.toLowerCase()}`}>
                      {status}
                    </span>
                  </td>
                  <td>{admin.role === "0" ? "Super Admin" : "Admin"}</td>
                  <td>
                    <div className="action-buttons" style={{ justifyContent: 'flex-end' }}>
                      
                      {/* NÚT TÍCH XANH: Chỉ hiện khi là Pending */}
                      {isPending && (
                        <button 
                          className="icon-btn approve" 
                          title="Duyệt hồ sơ"
                          onClick={() => handleApprove(admin._id)}
                          style={{ color: '#10b981' }}
                        >
                          <ShieldCheck size={18} />
                        </button>
                      )}

                      <button className="icon-btn history" onClick={() => {setSelectedAdmin(admin); setShowHistory(true);}}>
                        <History size={18} />
                      </button>
                      <button 
                          className={`icon-btn toggle-lock ${admin.is_locked ? 'active-locked' : ''}`}
                          onClick={() => handleToggleLock(admin._id)}
                          title={admin.is_locked ? "Mở khóa" : "Khóa tài khoản"}
                        >
                          {admin.is_locked ? <Unlock size={18} color="#f59e0b" /> : <Lock size={18} />}
                      </button>
                      <button 
                          className="icon-btn delete" 
                          onClick={() => handleDelete(admin._id)} 
                          style={{ color: '#ef4444' }}
                        >
                          <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* MODAL LỊCH SỬ HOẠT ĐỘNG (CN.081) */}
      {showHistory && (
        <div className="modal-overlay" onClick={() => setShowHistory(false)}>
          <div className="history-modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <div className="header-text">
                <h3>Lịch sử hoạt động</h3>
                <p>Quản trị viên: <strong>{selectedAdmin?.name}</strong></p>
              </div>
              <button className="close-btn" onClick={() => setShowHistory(false)}>
                <X size={20} />
              </button>
            </div>

            <div className="modal-body">
              <div className="timeline-container">
                {/* Kiểm tra nếu có dữ liệu thì map, không thì hiện trống */}
                {activityLogs && activityLogs.length > 0 ? (
                  activityLogs.map((log, index) => (
                    <div key={log.id} className="timeline-item">
                      <div className="timeline-dot"></div>
                      <div className="timeline-content">
                        <div className="log-main">
                          <span className={`log-type ${log.type}`}>{log.action}</span>
                          <span className="log-target">{log.target}</span>
                        </div>
                        <div className="log-time">
                          <Clock size={12} /> {log.time}
                        </div>
                      </div>
                    </div>
                  ))
                ) : (
                  /* HIỂN THỊ KHI TRỐNG */
                  <div className="empty-history" style={{ textAlign: 'center', padding: '40px 20px', color: '#94a3b8' }}>
                    <Clock size={40} style={{ opacity: 0.2, marginBottom: '15px' }} />
                    <p>Chưa có lịch sử hoạt động nào cho quản trị viên này.</p>
                  </div>
                )}
              </div>
            </div>
            
            <div className="modal-footer">
              <button className="btn-secondary-full" onClick={() => setShowHistory(false)}>Đóng</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminManagement;