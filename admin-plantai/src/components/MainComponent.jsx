import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { 
  User, Shield, Users, Leaf, Book, MessageCircle, 
  LogOut, Search, Bell, ChevronRight, LayoutGrid, Activity,
  TrendingUp, Scan, AlertTriangle, Download, ChevronDown
} from 'lucide-react';
// Biểu đồ
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend, BarChart, Bar
} from 'recharts';
import html2canvas from 'html2canvas'; 
import { jsPDF } from 'jspdf';

import "../styles/MainComponent.css";
import "../styles/ProfilePanel.css";
import AdminManagement from './AdminManagementComponent.jsx';
import ProfilePanel from './ProfilePanelComponent.jsx';
import UserManagement from './UserManagementComponent.jsx';
import DiseaseManagement from './DiseaseManagementComponent.jsx';
import HandbookManagement from './HandbookManagementComponent.jsx';
import logoImg from '../assets/image.png';

const API_URL = "http://127.0.0.1:3000/api";

const MainComponent = ({ onLogout }) => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [adminInfo, setAdminInfo] = useState({ fullName: "Loading...", role: "..." });
  const primaryColor = "#90A955";
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [stats, setStats] = useState({ totalUsers: 0, totalhandbook: 0, totalDiseases: 0 });
  const [analyticsData, setAnalyticsData] = useState([]);
  const printRef = useRef();
  const [isExporting, setIsExporting] = useState(false);
  const [timeFilter, setTimeFilter] = useState('month');

  const filterOptions = [
    { value: 'month', label: 'Theo Tháng này' },
    { value: 'quarter', label: 'Theo Quý này' },
    { value: 'year', label: 'Theo Năm nay' }
  ];

  const fetchAnalytics = async () => {
  try {
    const token = localStorage.getItem("token");
    const res = await axios.get(`${API_URL}/dashboard/analytics?filter=${timeFilter}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    setAnalyticsData(res.data.data);
  } catch (err) {
    console.error("Lỗi biểu đồ:", err);
  }
};

// Gọi lại mỗi khi đổi Filter thời gian
useEffect(() => {
  fetchAnalytics();
}, [timeFilter]);


  const fetchSummary = async () => {
  try {
    const token = localStorage.getItem("token");
    const res = await axios.get(`${API_URL}/dashboard/summary`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    if (res.data.status === "success") {
      setStats(res.data.data);
    }
  } catch (err) {
    console.error("Lỗi lấy số liệu thống kê:", err);
  }
};

  useEffect(() => {
    fetchSummary();;
  }, []);

  const fetchAdminProfile = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/admin/profile`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setAdminInfo(res.data);
    } catch (err) {
      console.error("Không thể lấy thông tin header:", err);
    }
  };

  

  useEffect(() => {
    fetchAdminProfile();
  }, []);

  const getInitials = (name) => {
    if (!name || name === "Loading...") return "??";
    const parts = name.split(" ");
    return parts.length > 1 
      ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
      : name.slice(0, 2).toUpperCase();
  };

  // Phân loại 38 tính năng vào 6 nhóm tối giản
  const menuGroups = [
    {
      title: "Hệ thống",
      items: [
        { id: 'dashboard', label: 'Tổng quan', icon: <LayoutGrid size={18} /> },
        { id: 'profile', label: 'Hồ sơ của tôi', icon: <User size={18} />},
        { id: 'admins', label: 'Quản trị viên', icon: <Shield size={18} />},
      ]
    },
    {
      title: "Quản lý",
      items: [
        { id: 'users', label: 'Khách hàng', icon: <Users size={18} /> },
        { id: 'diseases', label: 'Dữ liệu bệnh', icon: <Leaf size={18} />},
        { id: 'handbook', label: 'Cẩm nang xanh', icon: <Book size={18} />},
      ]
    }
  ];

  const handleExportPDF = () => {
    const element = printRef.current;
    if (!element) return;
    
    setIsExporting(true); // Bật trạng thái đang tải (để làm cờ báo tắt animation)
    
    // TUYỆT CHIÊU: Đợi 0.5 giây (500ms) để biểu đồ đứng im hoàn toàn rồi mới chụp
    setTimeout(async () => {
      const originalStyle = element.getAttribute('style');
      element.style.width = '1200px'; 
      element.style.padding = '30px'; 
      element.style.backgroundColor = '#f8fafc';
      
      try {
        const canvas = await html2canvas(element, {
          scale: 2, 
          useCORS: true,
          backgroundColor: '#f8fafc',
          windowWidth: 1200, 
        });
        
        element.setAttribute('style', originalStyle || '');
        
        const imgData = canvas.toDataURL('image/png');
        const pdf = new jsPDF('l', 'mm', 'a4'); 
        
        const pdfWidth = pdf.internal.pageSize.getWidth();
        const margin = 15;
        const printWidth = pdfWidth - (margin * 2);
        const printHeight = (canvas.height * printWidth) / canvas.width; 
        
        pdf.addImage(imgData, 'PNG', margin, margin, printWidth, printHeight);
        pdf.save(`PlantAI_BaoCao_${timeFilter}.pdf`); 
        
      } catch (error) {
        console.error("Lỗi xuất PDF:", error);
        alert("Có lỗi xảy ra khi xuất báo cáo!");
        element.setAttribute('style', originalStyle || '');
      } finally {
        setIsExporting(false); // Chụp xong thì bật animation lại bình thường
      }
    }, 500); 
  };

  return (
    <div className="admin-layout">
      {/* SIDEBAR SIÊU GỌN */}
      <aside className="sidebar-minimal">
        <div className="sidebar-brand">
          <img 
                src={logoImg} 
                alt="PlantAI Logo" 
                style={{ 
                    width: '50px',      // Chỉnh lại kích thước cho vừa mắt
                    height: 'auto', 
                    marginBottom: '20px',
                    display: 'block'     // Đảm bảo nó không bị lệch
                }} 
            />
          <span>PlantAI</span>
        </div>

        <nav className="nav-container">
          {menuGroups.map((group, idx) => (
            <div key={idx} className="nav-group">
              <span className="nav-group-title">{group.title}</span>
              {group.items.map(item => {
                
                // --- LOGIC PHÂN QUYỀN: Ẩn mục Quản trị viên nếu không phải Super Admin ---
                if (item.id === 'admins' && adminInfo.role !== 'Super Admin') {
                  return null; // Trả về null nghĩa là React sẽ không vẽ cái nút này ra
                }

                return (
                  <div 
                    key={item.id}
                    className={`nav-link ${activeTab === item.id ? 'active' : ''}`}
                    onClick={() => setActiveTab(item.id)}
                  >
                    <span className="nav-icon">{item.icon}</span>
                    <div className="nav-text">
                      <span className="nav-label">{item.label}</span>
                    </div>
                  </div>
                );
              })}
            </div>
          ))}
        </nav>

        <button className="nav-logout" onClick={onLogout}>
          <LogOut size={18} /> <span>Rời hệ thống</span>
        </button>
      </aside>

      {/* VÙNG NỘI DUNG CHÍNH */}
      <main className="main-viewport">
        <header className="main-header">
          <div className="header-user">
            <div className="user-avatar">
              <div className="avatar-info">
                <strong>{adminInfo.fullName}</strong>
                <small>{adminInfo.role}</small>
              </div>
              {adminInfo.avatar ? (
                <img 
                  src={adminInfo.avatar} 
                  alt="Avatar" 
                  className="avatar-img" 
                  style={{ objectFit: 'cover', padding: 0 }} 
                />
              ) : (
                <div className="avatar-img">{getInitials(adminInfo.fullName)}</div>
              )}
            </div>
          </div>
        </header>

        <div className="scroll-content"ref={printRef} style={{ backgroundColor: '#f8fafc' }}>
          {/* STATS DẠNG MINIMAL CARDS */}
          <div className="grid-stats">
            {/* Card 1: Người dùng */}
            <div className="stat-card">
              <div className="stat-icon-wrapper">
                <Users size={24} strokeWidth={2.5} />
              </div>
              <div className="stat-info">
                <small>Người dùng</small>
                <h2>{stats.totalUsers.toLocaleString()}</h2>
              </div>
            </div>

            {/* Card 2: Yêu cầu hỗ trợ */}
            <div className="stat-card">
              <div className="stat-icon-wrapper">
                <Book size={24} strokeWidth={2.5} />
              </div>
              <div className="stat-info">
                <small>Cẩm nang</small>
                <h2>{stats.totalhandbook}</h2>
              </div>
            </div>

            {/* Card 3: Bệnh cây mới */}
            <div className="stat-card">
              <div className="stat-icon-wrapper">
                <Leaf size={24} strokeWidth={2.5} />
              </div>
              <div className="stat-info">
                <small>Bệnh cây mới</small>
                <h2>{stats.totalDiseases}</h2>
              </div>
            </div>
          </div>

          {/* KHU VỰC CHI TIẾT TÍNH NĂNG */}
          <div className="feature-showcase">

            {activeTab === 'dashboard' && (
              <div className={`dashboard-view ${isExporting ? 'freeze-opacity' : ''}`}>
                
                {/* --- THANH CÔNG CỤ CỦA BIỂU ĐỒ --- */}
                <div className="dashboard-toolbar" data-html2canvas-ignore="true">
                  <div className="toolbar-right">
                    {/* CUSTOM DROPDOWN */}
                    <div className="custom-dropdown-container">
                      <button 
                        className="custom-dropdown-trigger"
                        onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                        onBlur={() => setTimeout(() => setIsDropdownOpen(false), 200)} // Mẹo nhỏ: Đợi 200ms để kịp ghi nhận cú click chọn item trước khi menu đóng lại
                      >
                        <span>{filterOptions.find(opt => opt.value === timeFilter)?.label}</span>
                        <ChevronDown size={16} className={`dropdown-icon ${isDropdownOpen ? 'open' : ''}`} />
                      </button>

                      {isDropdownOpen && (
                        <div className="custom-dropdown-menu">
                          {filterOptions.map((option) => (
                            <div
                              key={option.value}
                              className={`custom-dropdown-item ${timeFilter === option.value ? 'active' : ''}`}
                              onClick={() => {
                                setTimeFilter(option.value);
                                setIsDropdownOpen(false); // Đóng menu sau khi chọn
                              }}
                            >
                              {option.label}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>

                    <button className="btn-export-pdf" onClick={handleExportPDF} disabled={isExporting}>
                      {isExporting ? (
                        <>Đang tạo PDF...</>
                      ) : (
                        <><Download size={16} /> Xuất PDF</>
                      )}
                    </button>
                  </div>
                </div>

                <div className="dashboard-charts-grid">
                  
                  {/* BIỂU ĐỒ 1: TƯƠNG TÁC ĐỘNG VỚI STATE */}
                  <div className="chart-box">
                    <div className="chart-header">
                      <h3>Khách hàng & Lượt quét AI</h3>
                      <p>Hiển thị theo: <strong>{timeFilter === 'month' ? 'Tháng' : timeFilter === 'quarter' ? 'Quý' : 'Năm'}</strong></p>
                    </div>
                    <div className="chart-container-inner" style={{ height: 300 }}>
                      <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={analyticsData} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                          <defs>
                            <linearGradient id="colorScans" x1="0" y1="0" x2="0" y2="1">
                              <stop offset="5%" stopColor="#90A955" stopOpacity={0.8}/>
                              <stop offset="95%" stopColor="#90A955" stopOpacity={0}/>
                            </linearGradient>
                            <linearGradient id="colorCustomers" x1="0" y1="0" x2="0" y2="1">
                              <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.8}/>
                              <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                            </linearGradient>
                          </defs>
                          <XAxis dataKey="name" tick={{fontSize: 12, fill: '#64748b'}} axisLine={false} tickLine={false} />
                          <YAxis tick={{fontSize: 12, fill: '#64748b'}} axisLine={false} tickLine={false} />
                          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                          <RechartsTooltip contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' }} />
                          <Area type="monotone" dataKey="scans" stroke="#90A955" fillOpacity={1} fill="url(#colorScans)" name="Lượt quét AI" />
                          <Area type="monotone" dataKey="customers" stroke="#3b82f6" fillOpacity={1} fill="url(#colorCustomers)" name="Khách đăng ký mới" />
                        </AreaChart>
                      </ResponsiveContainer>
                    </div>
                  </div>

                  {/* BIỂU ĐỒ 2: GIỮ NGUYÊN */}
                  <div className="chart-box">
                    <div className="chart-header">
                      <h3>Hoạt động cộng đồng</h3>
                      {/* Tiêu đề phụ tự động đổi chữ theo Filter */}
                      <p>Hiển thị theo: <strong>{timeFilter === 'month' ? 'Tháng' : timeFilter === 'quarter' ? 'Quý' : 'Năm'}</strong></p>
                    </div>
                    <div className="chart-container-inner" style={{ height: 300, width: '100%', minWidth: 0, minHeight: 0 }}>
                      <ResponsiveContainer width="100%" height="100%">
                        {/* NỐI DATA VÀO STATE TIMEFILTER */}
                        <BarChart data={analyticsData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                          
                          {/* Sửa dataKey thành "name" để khớp với bộ data mới */}
                          <XAxis 
                            dataKey="name" 
                            tick={{fontSize: 12, fill: '#64748b', fontWeight: 500}} 
                            axisLine={false} 
                            tickLine={false} 
                            dy={10} 
                          />
                          <YAxis 
                            tick={{fontSize: 12, fill: '#64748b'}} 
                            axisLine={false} 
                            tickLine={false} 
                          />
                          <RechartsTooltip 
                            cursor={{fill: 'rgba(144, 169, 85, 0.05)'}} 
                            contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.1)' }} 
                            itemStyle={{ color: '#0f172a', fontWeight: 600 }}
                          />
                          
                          <Legend 
                            verticalAlign="bottom" 
                            height={36} 
                            iconType="circle" 
                            wrapperStyle={{ fontSize: '13px', color: '#475569', paddingTop: '15px' }} 
                          />
                          
                          <Bar dataKey="posts" name="Bài viết mới" fill="#90A955" radius={[4, 4, 0, 0]} barSize={timeFilter === 'year' ? 10 : 15} />
                          <Bar dataKey="comments" name="Lượt bình luận" fill="#3b82f6" radius={[4, 4, 0, 0]} barSize={timeFilter === 'year' ? 10 : 15} />
                          
                        </BarChart>
                      </ResponsiveContainer>
                    </div>
                  </div>

                </div>
              </div>
            )}
            
            {/* Chỉnh sửa logic Render ở đây */}
            {activeTab === 'profile' && <ProfilePanel onLogout={onLogout} />}
            
            {activeTab === 'admins' && <AdminManagement />}

            {activeTab === 'users' && <UserManagement />}

            {activeTab === 'diseases' && <DiseaseManagement />}

            {activeTab === 'handbook' && <HandbookManagement />}
          </div>
        </div>
      </main>
    </div>
  );
};

export default MainComponent;