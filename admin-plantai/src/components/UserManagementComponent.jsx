import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Search, Trash2, History, Lock, Unlock, X, 
  User, Mail, Phone, Calendar, Activity, Scan, 
  MessageSquare, FileText, ArrowLeft, Locate,
  ChevronDown, Check
} from 'lucide-react';
import { motion, AnimatePresence } from "framer-motion";
import "../styles/UserManagement.css";

const API_URL = "http://127.0.0.1:3000/api";

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState(null);
  const [showDetail, setShowDetail] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [activeHistoryTab, setActiveHistoryTab] = useState('scans');
  const [scansData, setScansData] = useState([]);
  const [postsData, setPostsData] = useState([]);
  const [aiData, setAiData] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(false);
  const [viewingPostComments, setViewingPostComments] = useState(null);
  const [commentsData, setCommentsData] = useState([]);
  const [filterStatus, setFilterStatus] = useState("all");
  const [showSuggestions, setShowSuggestions] = useState(false); 
  const [isOpenFilter, setIsOpenFilter] = useState(false);
  
  const fetchUsers = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/user/list`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsers(res.data);
    } catch (err) { console.error("Lỗi:", err); }
    finally { setLoading(false); }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const statusOptions = [
    { id: 'all', label: 'Tất cả trạng thái', color: '#64748b' },
    { id: 'Active', label: 'Đang hoạt động', color: '#10b981' },
    { id: 'Locked', label: 'Đang bị khóa', color: '#ef4444' }
  ];

  const suggestions = users
    .filter(u => 
      (u.name?.toLowerCase().includes(searchTerm.toLowerCase()) || 
       u.email?.toLowerCase().includes(searchTerm.toLowerCase())) && 
      searchTerm.length > 0
    )
    .slice(0, 5);

  // 2. Logic Lọc dữ liệu hiển thị ra bảng (Kết hợp cả ô Search và Dropdown)
  const filteredUsers = users.filter(user => {
    const matchesSearch = 
      (user.name?.toLowerCase() || "").includes(searchTerm.toLowerCase()) ||
      (user.email?.toLowerCase() || "").includes(searchTerm.toLowerCase());

    const matchesFilter = filterStatus === "all" || user.status === filterStatus;

    return matchesSearch && matchesFilter;
  });

  useEffect(() => {
    const fetchTabData = async () => {
      if (!selectedUser) return;
      
      setLoadingHistory(true);
      const token = localStorage.getItem("token");
      const userId = selectedUser._id;

        try {
        // 👉 Chơi lớn: Gọi cả 3 API cùng lúc để lấy số lượng cho các ô thống kê
        const [scansRes, postsRes, aiRes] = await Promise.all([
          axios.get(`${API_URL}/user/history/scans?user_id=${userId}`, { headers: { Authorization: `Bearer ${token}` }}),
          axios.get(`${API_URL}/user/history/posts?user_id=${userId}`, { headers: { Authorization: `Bearer ${token}` }}),
          axios.get(`${API_URL}/user/history/ai?user_id=${userId}`, { headers: { Authorization: `Bearer ${token}` }})
        ]);

        setScansData(scansRes.data);
        setPostsData(postsRes.data);
        setAiData(aiRes.data);
      } catch (error) {
        console.error("Lỗi tải tổng hợp dữ liệu:", error);
      } finally {
        setLoadingHistory(false);
      }
    };

    fetchTabData();
  }, [ selectedUser]);


  useEffect(() => {
    const loadComments = async () => {
      // Nếu chưa bấm xem bài viết nào thì thôi, không gọi làm gì cho tốn tài nguyên
      if (!viewingPostComments) return;

      try {
        const token = localStorage.getItem("token");
        const postId = viewingPostComments._id;

        // Gọi đúng địa chỉ API mà anh em mình vừa thống nhất ở Backend
        const res = await axios.get(`${API_URL}/post/comments?post_id=${postId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });

        // Đổ dữ liệu vào state để React vẽ ra màn hình
        setCommentsData(res.data);
      } catch (err) {
        console.error("Lỗi lấy bình luận:", err);
        setCommentsData([]); // Lỗi thì cho trắng luôn để không bị crash giao diện
      }
    };

    loadComments();
  }, [viewingPostComments]);

  const handleToggleLock = async (userId) => {
    try {
      const token = localStorage.getItem("token");
      await axios.post(`${API_URL}/user/toggle-lock`, { user_id: userId }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      fetchUsers();
    } catch (err) { alert("Lỗi khóa/mở khóa"); }
  };

  const handleDelete = async (userId) => {
    if(!window.confirm("Xóa vĩnh viễn người dùng này?")) return;
    try {
      const token = localStorage.getItem("token");
      await axios.post(`${API_URL}/user/delete`, { user_id: userId }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      fetchUsers();
    } catch (err) { alert("Lỗi khi xóa"); }
  };

  const fetchUserHistory = async (userId) => {
    try {
      setLoadingHistory(true);
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/user/history?user_id=${userId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setHistoryData(res.data);
    } catch (err) {
      console.error("Lỗi lấy lịch sử:", err);
    } finally {
      setLoadingHistory(false);
    }
};
  
  const handleOpenDetail = (user) => {
    setSelectedUser(user);
    setShowDetail(true);
    setActiveHistoryTab('scans');
  
};
  return (
    <div className="user-mgmt-container">

      {/* THANH TÌM KIẾM (CN.084) */}
      {/* THANH TÌM KIẾM & BỘ LỌC MỚI (ĐỒNG BỘ VỚI TRANG ADMIN) */}
      <div className="mgmt-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px' }}>
        
        {/* BÊN TRÁI: TIÊU ĐỀ */}
        <div className="mgmt-title">
          <h2>Quản lý Khách hàng</h2>
          <span>Hệ thống có {users.length} người dùng đăng ký</span>
        </div>

        {/* BÊN PHẢI: THANH TÌM KIẾM & BỘ LỌC */}
        <div className="mgmt-controls" style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
          
          {/* KHUNG SEARCH CÓ GỢI Ý */}
          <div className="search-wrapper" style={{ position: 'relative' }}>
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
                    <li key={s._id} onClick={() => {setSearchTerm(s.name); setShowSuggestions(false);}}>
                      <User size={14} />
                      <div className="sugg-info">
                        <span className="sugg-name">{s.name || "Người dùng ẩn"}</span>
                        <span className="sugg-email">{s.email || "Không có email"}</span>
                      </div>
                    </li>
                  ))}
                </motion.ul>
              )}
            </AnimatePresence>
          </div>

          {/* CUSTOM DROPDOWN LỌC TRẠNG THÁI */}
          <div className="custom-filter" style={{ position: 'relative' }}>
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

      {/* DANH SÁCH NGƯỜI DÙNG (CN.083) */}
      <div className="admin-table-wrapper">
        <table className="admin-table">
          <thead>
            <tr>
              <th>Người dùng</th>
              <th>Vị trí</th>
              <th>Ngày tham gia</th>
              <th>Trạng thái</th>
              <th style={{ textAlign: 'right' }}>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.map((user) => (
              <tr key={user._id} className={user.is_locked ? 'row-locked' : ''}>
                <td>
                  <div className="admin-info-cell">
                    {user.avatar ? <img src={user.avatar} className="user-avatar-circle" /> : 
                    <div className="user-avatar-circle">{user.name?.charAt(0) || "U"}</div>}
                    <div>
                      <div className="admin-name">{user.name || "Người dùng ẩn"}</div>
                      <div className="admin-email">{user.email || "Không có email"}</div>
                    </div>
                  </div>
                </td>
                <td><span className="user-location">{user.location}</span></td> 
                <td><span className="join-date">{user.joinDate}</span></td>
                <td>
                  <span className={`status-badge ${user.status.toLowerCase()}`}>
                    {user.status}
                  </span>
                </td>
                <td>
                  <div className="action-buttons" style={{ justifyContent: 'flex-end' }}>
                    {/* Xem chi tiết & Lịch sử - CN.085, CN.086 */}
                    <button className="icon-btn info" onClick={() => {setSelectedUser(user); handleOpenDetail(user);}}>
                      <History size={18} />
                    </button>
                    {/* Khóa/Mở khóa - CN.087 */}
                    <button className="icon-btn toggle-lock" onClick={() => handleToggleLock(user._id)}>
                      {user.is_locked ? <Unlock size={18} color="#f59e0b" /> : <Lock size={18} />}
                    </button>
                    {/* Xóa - CN.088 */}
                    <button className="icon-btn delete" onClick={() => handleDelete(user._id)}><Trash2 size={18} /></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* MODAL CHI TIẾT HỒ SƠ & LỊCH SỬ (CN.085 & CN.086) */}
      {showDetail && (
        <div className="modal-overlay" onClick={() => setShowDetail(false)}>
          <div className="user-detail-modal" onClick={e => e.stopPropagation()}>
            <div className="user-modal-grid">
              
              <div className="user-info-section">
                <div className="profile-main">
                  <div className="large-avatar-user">{selectedUser?.avatar ? (
                    <img src={selectedUser.avatar} alt="avatar" className="user-avatar-large-img" />
                  ) : (
                    selectedUser?.name?.charAt(0) || "U"
                  )}
                  </div>
                  <h4>{selectedUser?.name}</h4>
                  <span className={`status-tag ${selectedUser?.status.toLowerCase()}`}>{selectedUser?.status}</span>
                </div>
                <div className="info-list">
                  <div className="info-item"><Mail size={14}/> {selectedUser?.email}</div>
                  <div className="info-item"><Locate size={14}/> {selectedUser?.location}</div>
                </div>
                <div className="user-stats-grid">
                  <div className="stat-box">
                    <Scan size={18} color="#90A955"/>
                    <strong>{scansData.length}</strong>
                    <small>Quét</small>
                  </div>
                  <div className="stat-box">
                    <FileText size={18} color="#90A955"/>
                    <strong>{postsData.length}</strong>
                    <small>Bài đăng</small>
                  </div>
                </div>
              </div>

              <div className="user-history-section">
                <div className="tabs-header-row">
                  <div className="history-tabs">
                    <button className={`tab-btn ${activeHistoryTab === 'scans' ? 'active' : ''}`} onClick={() => setActiveHistoryTab('scans')}><Scan size={16} /> Quét bệnh</button>
                    <button className={`tab-btn ${activeHistoryTab === 'posts' ? 'active' : ''}`} onClick={() => setActiveHistoryTab('posts')}><FileText size={16} /> Bài đăng</button>
                    <button className={`tab-btn ${activeHistoryTab === 'ai' ? 'active' : ''}`} onClick={() => setActiveHistoryTab('ai')}><MessageSquare size={16} /> Chat AI</button>
                  </div>
                  <button className="close-btn-inline" onClick={() => setShowDetail(false)}><X size={20} /></button>
                </div>
        
                <div className="tab-content">
                  {activeHistoryTab === 'scans' && (
                    <div className="history-list-scroll">
                      {scansData.length > 0 ? scansData.map(item => (
                        <div key={item._id} className="history-item-row post-item-horizontal"> 
                          <img src={item.image_path || "https://ui-avatars.com/api/?name=Plant&background=random"} className="scan-thumb" alt="crop" />
                          
                          {/* Khối chữ 2 dòng: Áp dụng class mới để căn lề trái */}
                          <div className="post-text-container">
                            <p className="post-preview-text">{item.disease_vi || "Cây trồng"}</p>
                            <span className="post-stats-sub">Độ chính xác: {(item.confidence * 100).toFixed(1)}%</span>
                          </div>

                          {/* Thời gian ép sang góc phải */}
                          <div className="item-meta-inline">{item.created_at?.split('.')[0]}</div>
                          
                        </div>
                      )) : <div className="empty-msg">Chưa có lịch sử quét bệnh.</div>}
                    </div>
                  )}

                  
                  {activeHistoryTab === 'posts' && (
                    <div className="posts-tab-wrapper">
                      {!viewingPostComments ? (
                        /* HIỂN THỊ DANH SÁCH BÀI VIẾT */
                        <div className="history-list">
                            {postsData.map(item => (
                            <div key={item._id} className="history-item-row post-item-horizontal">
                                
                                {/* 1. KHỐI BÊN TRÁI: Nội dung và Thống kê xếp HÀNG DỌC */}
                                <div className="post-text-container">
                                    <p className="post-preview-text">{item.content}</p> 
                                    <span className="post-stats-sub">
                                      {item.likes?.length || 0} thích • {item.commentsCount || 0} bình luận
                                    </span>
                                </div>
                                
                                {/* 2. NÚT Ở GIỮA */}
                                <div className="item-actions">
                                    <button 
                                    className="btn-view-comment" 
                                    onClick={() => setViewingPostComments(item)}
                                    >
                                    <MessageSquare size={14} /> Xem bình luận
                                    </button>
                                </div>

                                {/* 3. THỜI GIAN Ở GÓC PHẢI */}
                                <div className="item-meta-inline">{item.createdAt?.split(' ')[0]}</div>
                                
                            </div>
                            ))}
                        </div>
                      ) : (
                        /* HIỂN THỊ DANH SÁCH BÌNH LUẬN */
                        <div className="comments-drilldown">
                            <div className="drilldown-header">
                            <button className="btn-back" onClick={() => setViewingPostComments(null)}>
                                <ArrowLeft size={16} /> Quay lại
                            </button>
                            </div>

                            {/* Bổ sung phần nội dung bài viết ĐẦY ĐỦ */}
                            <div className="original-post-content">
                            <div className="post-author-info">
                                <div className="author-avatar-tiny">{selectedUser?.name.charAt(0)}</div>
                                <div className="author-details">
                                <strong>{selectedUser?.name}</strong>
                                <span>{viewingPostComments.time}</span>
                                </div>
                            </div>
                            <div className="full-post-body">
                                {viewingPostComments.content || viewingPostComments.title}
                            </div>
                            <div className="full-post-stats">
                                <span>{viewingPostComments.views} lượt xem</span>
                                <span>{viewingPostComments.comments} bình luận</span>
                            </div>
                            </div>

                            <div className="comments-list-scroll">
                            {commentsData.length > 0 ? commentsData.map(cmt => (
                                <div key={cmt._id} className="comment-bubble">
                                <div className="cmt-header">
                                    <strong>{cmt.authorData?.name || "Người dùng ẩn"}</strong>
                                    <small>{cmt.createdAt?.split('T')[0]}</small>
                                </div>
                                <p>{cmt.text}</p>
                                <button className="btn-delete-cmt"><Trash2 size={14} /> Xóa</button>
                                </div>
                            )) : <div className="empty-msg">Bài viết này chưa có bình luận nào.</div>}
                            </div>
                        </div>
                      )}
                    </div>
                  )}

                  {activeHistoryTab === 'ai' && (
                    <div className="history-list">
                      {aiData.map(item => (
                        <div key={item._id} className="history-item-row post-item-horizontal">
        
                          {/* Khối chữ 2 dòng: Áp dụng class mới để căn lề trái */}
                          <div className="post-text-container">
                            <p className="post-preview-text">{item.title || "Cuộc trò chuyện mới"}</p>
                            <span className="post-stats-sub">{item.messages?.length || 0} tin nhắn</span>
                          </div>

                          {/* Thời gian ép sang góc phải */}
                          <div className="item-meta-inline">{item.updatedAt?.split(' ')[0]}</div>
                          
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default UserManagement;