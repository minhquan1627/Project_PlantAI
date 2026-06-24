import React, { useState, useRef, useEffect } from 'react';
import axios from 'axios';
import { 
  Search, Plus, Edit, Trash2, Eye, EyeOff, ArrowLeft, Save, 
  Image as ImageIcon, ChevronDown, Check, FileText, LayoutList, Pin 
} from 'lucide-react';
import { motion, AnimatePresence } from "framer-motion";
import "../styles/HandbookManagement.css";

const API_URL = "https://project-plantai.onrender.com/api";

const HandbookManagement = () => {
  const [currentView, setCurrentView] = useState('list'); 
  const [editingPost, setEditingPost] = useState(null);

  const [handbooks, setHandbooks] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("");
  const [isOpenFilter, setIsOpenFilter] = useState(false);
  const [showSuggestions, setShowSuggestions] = useState(false);
  
  // Biến thông tin cơ bản
  const [title, setTitle] = useState("");
  const [category, setCategory] = useState("");
  const [summary, setSummary] = useState("");
  const [thumbnailPreview, setThumbnailPreview] = useState("");
  const [isDragging, setIsDragging] = useState(false);

  // ========================================================
  // STATE CHO CẤU TRÚC JSON CỦA FLUTTER (THAY THẾ HTML EDITOR)
  // ========================================================
  const [introData, setIntroData] = useState("");
  const [sectionsData, setSectionsData] = useState([]);
  const [tipsData, setTipsData] = useState(""); // Chứa text thô, mỗi dòng là 1 mẹo

  const fileInputRef = useRef(null);
  const suggestions = handbooks
    .filter(h => h.title.toLowerCase().includes(searchTerm.toLowerCase()) && searchTerm.length > 0)
    .slice(0, 5);

  const categoryOptions = [
    { id: 'Tất cả', label: 'Tất cả danh mục', color: '#64748b' },
    { id: 'Phòng trừ bệnh', label: 'Phòng trừ bệnh', color: '#ef4444' },
    { id: 'Kỹ thuật canh tác', label: 'Kỹ thuật canh tác', color: '#10b981' },
    { id: 'Nhận diện sâu bệnh', label: 'Nhận diện sâu bệnh', color: '#f59e0b' },
    { id: 'Mẹo nhà nông', label: 'Mẹo nhà nông', color: '#3b82f6' }
  ];

  const fetchHandbooks = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/handbook/list`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        setHandbooks(res.data.data); 
      }
    } catch (error) {
      console.error("Lỗi tải danh sách cẩm nang:", error);
    }
  };

  useEffect(() => { fetchHandbooks(); }, []);

  const categories = ["Tất cả", "Phòng trừ bệnh", "Kỹ thuật canh tác", "Nhận diện sâu bệnh", "Mẹo nhà nông"];

  const convertToBase64 = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result);
      reader.onerror = (error) => reject(error);
    });
  };

  const handleThumbnailClick = () => fileInputRef.current?.click();
  const handleThumbnailChange = async (e) => {
    const file = e.target.files?.[0];
    if (file) {
      const base64Str = await convertToBase64(file);
      setThumbnailPreview(base64Str);
    }
    e.target.value = "";
  };
  const handleDragOver = (e) => { e.preventDefault(); setIsDragging(true); };
  const handleDragLeave = (e) => { e.preventDefault(); setIsDragging(false); };
  const handleDrop = async (e) => {
    e.preventDefault();
    setIsDragging(false);
    const file = e.dataTransfer.files?.[0];
    if (file && file.type.startsWith('image/')) {
      const base64Str = await convertToBase64(file);
      setThumbnailPreview(base64Str);
    }
  };

  // ==========================================
  // LOGIC XỬ LÝ CÁC KHỐI NHẬP LIỆU
  // ==========================================
  const addSection = () => {
    setSectionsData([...sectionsData, { sectionTitle: "", diseases: [] }]);
  };

  const removeSection = (sIdx) => {
    const newSecs = [...sectionsData];
    newSecs.splice(sIdx, 1);
    setSectionsData(newSecs);
  };

  const updateSectionTitle = (sIdx, value) => {
    const newSecs = [...sectionsData];
    newSecs[sIdx].sectionTitle = value;
    setSectionsData(newSecs);
  };

  const addDisease = (sIdx) => {
    const newSecs = [...sectionsData];
    newSecs[sIdx].diseases.push({ diseaseName: "", lines: "" });
    setSectionsData(newSecs);
  };

  const removeDisease = (sIdx, dIdx) => {
    const newSecs = [...sectionsData];
    newSecs[sIdx].diseases.splice(dIdx, 1);
    setSectionsData(newSecs);
  };

  const updateDisease = (sIdx, dIdx, field, value) => {
    const newSecs = [...sectionsData];
    newSecs[sIdx].diseases[dIdx][field] = value;
    setSectionsData(newSecs);
  };

  // ==========================================
  // LƯU DỮ LIỆU & ĐÓNG GÓI THÀNH JSON
  // ==========================================
  const handleSave = async () => {
    try {
      if (!title.trim()) { alert("❗ LỖI: Vui lòng nhập tiêu đề bài viết!"); return; }
      if (!category) { alert("❗ LỖI: Vui lòng chọn chủ đề!"); return; }

      // Chuyển đổi text thô thành array dựa trên dấu xuống hàng (enter)
      const formattedSections = sectionsData.map(sec => ({
          sectionTitle: sec.sectionTitle,
          diseases: sec.diseases.map(dis => ({
              diseaseName: dis.diseaseName,
              lines: dis.lines.split('\n').filter(l => l.trim() !== '') // Tách mỗi dòng thành 1 ý
          }))
      }));

      const tipsArray = tipsData.split('\n').filter(t => t.trim() !== '');

      // Đóng gói cấu trúc chuẩn JSON
      const flutterContentData = {
          intro: introData,
          sections: formattedSections,
          tips: tipsArray
      };

      const payload = {
        id: editingPost?._id || editingPost?.id, 
        title: title,
        category: category,
        summary: summary,
        content: JSON.stringify(flutterContentData), // Stringify để lưu vào DB
        image: thumbnailPreview,
        status: editingPost?.status || "Visible",
        isPinned: editingPost?.isPinned || false
      };

      const token = localStorage.getItem("token");
      const res = await axios.post(`${API_URL}/handbook/save`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if(res.data.status === "success") {
        alert("Xuất bản Cẩm nang thành công!");
        setCurrentView('list');
        fetchHandbooks();
      }
    } catch (error) {
      console.error("Lỗi:", error);
      alert("Lưu thất bại: Lỗi máy chủ");
    }
  };

  const handleEdit = (post) => {
    setEditingPost(post);
    setTitle(post.title);
    setCategory(post.category);
    setSummary(post.summary || "");
    setThumbnailPreview(post.image || "");

    // Cố gắng Parse JSON từ Database để đổ ngược vào Form
    try {
        const parsed = JSON.parse(post.content);
        setIntroData(parsed.intro || "");
        setTipsData(parsed.tips ? parsed.tips.join('\n') : "");
        
        // Chuyển mảng lines về lại chuỗi thô để dễ đưa vào Textarea
        const secData = (parsed.sections || []).map(s => ({
            sectionTitle: s.sectionTitle,
            diseases: (s.diseases || []).map(d => ({
                diseaseName: d.diseaseName,
                lines: (d.lines || []).join('\n')
            }))
        }));
        setSectionsData(secData);
    } catch (e) {
        // Nếu bài cũ bị lỗi cấu trúc, xóa trắng form
        setIntroData("");
        setTipsData("");
        setSectionsData([]);
    }

    setCurrentView('editor');
  };
  
  const handleAddNew = () => {
    setEditingPost(null);
    setTitle("");
    setCategory("");
    setSummary("");
    setThumbnailPreview("");
    setIntroData("");
    setSectionsData([]);
    setTipsData("");
    setCurrentView('editor');
  };

  const handleDelete = async (postId) => {
    if (!window.confirm("Bạn có chắc chắn muốn xóa bài cẩm nang này vĩnh viễn không?")) return;
    try {
      const token = localStorage.getItem("token");
      const res = await axios.delete(`${API_URL}/handbook/delete/${postId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        fetchHandbooks();
      }
    } catch (error) { alert("Lỗi khi xóa!"); }
  };

  const handleToggleVisibility = async (post) => {
    const nextStatus = post.status === 'Visible' ? 'Hidden' : 'Visible';
    setHandbooks(handbooks.map(h => (h._id || h.id) === (post._id || post.id) ? { ...h, status: nextStatus } : h));
    try {
      const token = localStorage.getItem("token");
      await axios.post(`${API_URL}/handbook/save`, { ...post, id: post._id || post.id, status: nextStatus }, {
        headers: { Authorization: `Bearer ${token}` }
      });
    } catch (error) { console.error("Lỗi"); }
  };

  const handleTogglePin = async (post) => {
    const nextPin = !post.isPinned;
    setHandbooks(handbooks.map(h => (h._id || h.id) === (post._id || post.id) ? { ...h, isPinned: nextPin } : h));
    try {
      const token = localStorage.getItem("token");
      await axios.post(`${API_URL}/handbook/save`, { ...post, id: post._id || post.id, isPinned: nextPin }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      fetchHandbooks(); 
    } catch (error) { console.error("Lỗi"); }
  };

  const filteredHandbooks = handbooks.filter(h => {
    const matchSearch = h.title.toLowerCase().includes(searchTerm.toLowerCase());
    const matchCategory = selectedCategory === "" || selectedCategory === "Tất cả" || h.category === selectedCategory;
    return matchSearch && matchCategory;
  });

  // ==========================================
  // VIEW 1: MÀN HÌNH DANH SÁCH 
  // ==========================================
  if (currentView === 'list') {
    return (
      <div className="handbook-mgmt-container">
        <div className="mgmt-header">
          <div className="mgmt-title">
            <h2>Quản lý Cẩm nang</h2>
            <span>Hệ thống có {handbooks.length} bài viết hướng dẫn</span>
          </div>
          <button className="btn-add-primary" onClick={handleAddNew}>
            <Plus size={18} /> Viết bài mới
          </button>
        </div>

        <div className="mgmt-controls" style={{ display: 'flex', gap: '16px', alignItems: 'center', justifyContent: 'flex-end', marginBottom: '24px' }}>
          <div className="search-wrapper" style={{ width: '100%', position: 'relative' }}>
            <div className="search-box-modern" style={{ width: '97%', }}>
              <Search size={18} />
              <input 
                type="text" 
                placeholder="Tìm theo tiêu đề bài viết..." 
                value={searchTerm}
                onChange={(e) => {setSearchTerm(e.target.value); setShowSuggestions(true);}}
                onFocus={() => setShowSuggestions(true)}
                onBlur={() => setTimeout(() => setShowSuggestions(false), 200)} 
              />
            </div>
            <AnimatePresence>
              {showSuggestions && suggestions.length > 0 && (
                <motion.ul className="search-suggestions" initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
                  {suggestions.map(s => (
                    <li key={s._id || s.id} onClick={() => {setSearchTerm(s.title); setShowSuggestions(false);}}>
                      <FileText size={14} color="#64748b" /> 
                      <div className="sugg-info">
                        <span className="sugg-name">{s.title}</span>
                        <span className="sugg-email">{s.category}</span> 
                      </div>
                    </li>
                  ))}
                </motion.ul>
              )}
            </AnimatePresence>
          </div>

          <div className="custom-filter" style={{ position: 'relative', minWidth: '200px' }}>
            <button className="filter-trigger" onClick={() => setIsOpenFilter(!isOpenFilter)}>
              <div className="filter-dot" style={{ background: categoryOptions.find(o => o.id === (selectedCategory || 'Tất cả'))?.color || '#64748b' }}></div>
              <span>{selectedCategory === "" || selectedCategory === "Tất cả" ? "Tất cả danh mục" : selectedCategory}</span>
              <ChevronDown size={16} className={isOpenFilter ? 'rotate' : ''} />
            </button>
            <AnimatePresence>
              {isOpenFilter && (
                <motion.ul className="filter-dropdown" initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.95 }}>
                  {categoryOptions.map(opt => (
                    <li key={opt.id} onClick={() => { setSelectedCategory(opt.id); setIsOpenFilter(false); }}>
                      <div className="dot" style={{ background: opt.color }}></div>
                      {opt.label}
                      {(selectedCategory === opt.id || (selectedCategory === "" && opt.id === "Tất cả")) && <Check size={14} className="check-icon" />}
                    </li>
                  ))}
                </motion.ul>
              )}
            </AnimatePresence>
          </div>
        </div>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th style={{ width: '40px' }}></th> 
                <th>Bài viết cẩm nang</th>
                <th>Chủ đề</th>
                <th>Ngày đăng</th>
                <th>Trạng thái</th>
                <th style={{ textAlign: 'right' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredHandbooks.map((post) => (
                <tr key={post._id || post.id} className={post.status === 'Hidden' ? 'row-dimmed' : ''}>
                  <td>
                    <button className={`icon-btn pin-btn ${post.isPinned ? 'pinned' : ''}`} onClick={() => handleTogglePin(post)} title={post.isPinned ? "Bỏ ghim" : "Ghim lên đầu"}>
                      <Pin size={18} fill={post.isPinned ? "#f59e0b" : "none"} color={post.isPinned ? "#f59e0b" : "#94a3b8"} />
                    </button>
                  </td>
                  <td>
                    <div className="handbook-info-cell">
                      <img src={post.image} alt="thumb" className="handbook-thumb-sm" />
                      <div>
                        <div className="handbook-title">{post.title}</div>
                        <div className="handbook-stats">{post.views || 0} lượt xem</div>
                      </div>
                    </div>
                  </td>
                  <td><span className="category-tag">{post.category}</span></td>
                  <td><span className="publish-date">{post.publishDate}</span></td>
                  <td>
                    <span className={`status-badge ${(post.status || 'Visible').toLowerCase()}`}>
                      {post.status === 'Visible' ? 'Đang Hiển Thị' : 'Đang Ẩn'}
                    </span>
                  </td>
                  <td>
                    <div className="action-buttons" style={{ justifyContent: 'flex-end' }}>
                      <button className="icon-btn toggle-eye" onClick={() => handleToggleVisibility(post)}>
                        {post.status === 'Visible' ? <Eye size={18} /> : <EyeOff size={18} />}
                      </button>
                      <button className="icon-btn edit" onClick={() => handleEdit(post)}><Edit size={18} /></button>
                      <button className="icon-btn delete" onClick={() => handleDelete(post._id || post.id)}><Trash2 size={18} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    );
  }

  // ==========================================
  // VIEW 2: FORM XÂY DỰNG NỘI DUNG (APP BUILDER)
  // ==========================================
  return (
    <div className="handbook-editor-container">
      <div className="editor-header">
        <div className="editor-header-left">
          <button className="btn-back-editor" onClick={() => setCurrentView('list')}><ArrowLeft size={20} /></button>
          <div>
            <h3>{editingPost ? "Chỉnh sửa Cẩm nang" : "Viết Cẩm nang mới"}</h3>
            <span>{editingPost ? "Chỉnh sửa nội dung" : "Đang tạo bản nháp..."}</span>
          </div>
        </div>
        <button className="btn-save-primary" onClick={handleSave}><Save size={18} /> Lưu & Xuất bản</button>
      </div>

      <div className="editor-layout-grid">
        {/* CỘT TRÁI: CẤU HÌNH CƠ BẢN */}
        <div className="editor-sidebar" style={{ width: '380px' }}>
          <div className="form-group">
            <label>Ảnh đại diện bài viết</label>
            <input type="file" ref={fileInputRef} style={{ display: 'none' }} accept="image/*" onChange={handleThumbnailChange} />
            <div className={`image-upload-box ${isDragging ? 'dragging' : ''}`} onClick={handleThumbnailClick} onDragOver={handleDragOver} onDragLeave={handleDragLeave} onDrop={handleDrop}>
                  {thumbnailPreview ? <img src={thumbnailPreview} alt="Preview" className="thumbnail-preview-img" /> : (
                    <>
                      <ImageIcon size={32} color={isDragging ? "#90A955" : "#cbd5e1"} />
                      <p>Click hoặc kéo thả để tải ảnh lên</p>
                    </>
                  )}
              </div>
          </div>
          <div className="form-group">
            <label>Tiêu đề bài viết</label>
            <textarea className="form-input title-input" rows="3" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="VD: Bí quyết phòng bệnh mùa mưa..." />
          </div>
          <div className="form-group">
            <label>Chủ đề (Danh mục)</label>
            <select className="form-input" value={category} onChange={(e) => setCategory(e.target.value)}>
              <option value="" disabled>Chọn chủ đề...</option>
              {categories.slice(1).map((cat, i) => <option key={i} value={cat}>{cat}</option>)}
            </select>
          </div>
          <div className="form-group">
            <label>Tóm tắt ngắn (Mô tả)</label>
            <textarea className="form-input" rows="4" value={summary} onChange={(e) => setSummary(e.target.value)} placeholder="Nhập đoạn mô tả ngắn hiển thị dưới tiêu đề..."></textarea>
          </div>
        </div>

        {/* CỘT PHẢI: FORM DỰNG CẤU TRÚC (APP BUILDER) */}
        <div className="editor-main-workspace" style={{ background: '#f8fafc', padding: '30px' }}>
          <div style={{ background: 'white', padding: '24px', borderRadius: '16px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px rgba(0,0,0,0.02)' }}>
             <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px', color: '#1e293b' }}>
                 <LayoutList size={20} color="#90A955" /> Cấu trúc nội dung hiển thị trên App
             </h4>

             {/* INTRO */}
             <div className="form-group">
                <label>1. Đoạn giới thiệu chung</label>
                <textarea className="form-input" rows="3" value={introData} onChange={(e) => setIntroData(e.target.value)} placeholder="Mùa mưa là thời điểm các loại nấm phát triển..." />
             </div>

             <hr style={{ border: 'none', borderTop: '1px solid #e2e8f0', margin: '24px 0' }}/>

             {/* SECTIONS */}
             <div className="form-group">
                <label>2. Các phần nội dung (VD: 1. Phòng bệnh cho cây lúa)</label>
                {sectionsData.map((sec, sIdx) => (
                    <div key={sIdx} style={{ background: '#f1f5f9', padding: '16px', borderRadius: '12px', marginBottom: '16px', border: '1px solid #cbd5e1' }}>
                        <div style={{ display: 'flex', gap: '10px', marginBottom: '16px' }}>
                            <input className="form-input" value={sec.sectionTitle} onChange={(e) => updateSectionTitle(sIdx, e.target.value)} placeholder="Nhập Tiêu đề Phần (VD: 1. Phòng bệnh cho lúa)" style={{ fontWeight: 'bold' }} />
                            <button className="icon-btn delete" onClick={() => removeSection(sIdx)} style={{ background: '#fee2e2' }}><Trash2 size={18} color="#ef4444"/></button>
                        </div>

                        {sec.diseases.map((dis, dIdx) => (
                            <div key={dIdx} style={{ background: '#ffffff', padding: '16px', borderRadius: '8px', marginLeft: '20px', marginBottom: '12px', border: '1px solid #e2e8f0' }}>
                                <div style={{ display: 'flex', gap: '10px', marginBottom: '12px' }}>
                                    <input className="form-input" value={dis.diseaseName} onChange={(e) => updateDisease(sIdx, dIdx, 'diseaseName', e.target.value)} placeholder="Tên bệnh/Sâu hại (VD: Bệnh đạo ôn)" style={{ color: '#8DAA5B', fontWeight: 'bold' }} />
                                    <button className="icon-btn delete" onClick={() => removeDisease(sIdx, dIdx)}><Trash2 size={16}/></button>
                                </div>
                                <textarea className="form-input" rows="3" value={dis.lines} onChange={(e) => updateDisease(sIdx, dIdx, 'lines', e.target.value)} placeholder="Nhập các biện pháp (Mỗi biện pháp nhấn Enter xuống 1 dòng)" />
                            </div>
                        ))}

                        <button onClick={() => addDisease(sIdx)} className="btn-add-primary" style={{ marginLeft: '20px', background: '#ffffff', color: '#475569', border: '1px dashed #cbd5e1' }}>
                            + Thêm Mối đe dọa (Sâu/Bệnh)
                        </button>
                    </div>
                ))}
                
                <button onClick={addSection} className="btn-save-primary" style={{ width: '100%', justifyContent: 'center', background: '#94a3b8' }}>
                    + Thêm Phần Nội Dung Mới
                </button>
             </div>

             <hr style={{ border: 'none', borderTop: '1px solid #e2e8f0', margin: '24px 0' }}/>

             {/* TIPS */}
             <div className="form-group" style={{ marginBottom: 0 }}>
                <label style={{ color: '#f59e0b' }}>3. Khung Mẹo từ PlantAI</label>
                <textarea className="form-input" rows="4" value={tipsData} onChange={(e) => setTipsData(e.target.value)} placeholder="Nhập các mẹo (Mỗi mẹo nhấn Enter xuống 1 dòng)" />
             </div>

          </div>
        </div>
      </div>
    </div>
  );
};

export default HandbookManagement;
