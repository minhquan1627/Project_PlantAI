import React, { useState, useRef, useEffect } from 'react';
import axios from 'axios';
import { 
  Search, Plus, Edit, Trash2, Eye, EyeOff, ArrowLeft, Save, Image as ImageIcon,
  Bold, Italic, Underline, List, ListOrdered, AlignLeft, AlignCenter, AlignRight, Link,
  Pin, MessageSquareWarning, ChevronDown, Check, FileText
} from 'lucide-react';
import { motion, AnimatePresence } from "framer-motion";
import "../styles/HandbookManagement.css";


const API_URL = "http://127.0.0.1:3000/api";

const HandbookManagement = () => {
  const [currentView, setCurrentView] = useState('list'); 
  const [editingPost, setEditingPost] = useState(null);

  const [handbooks, setHandbooks] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("");
  const [isOpenFilter, setIsOpenFilter] = useState(false);
  const [showSuggestions, setShowSuggestions] = useState(false);
  // Biến dành cho việc viết bài
  const [title, setTitle] = useState("");
  const [isFontFamilyOpen, setIsFontFamilyOpen] = useState(false);
  const [isFontSizeOpen, setIsFontSizeOpen] = useState(false);
  const [currentFont, setCurrentFont] = useState("Roboto");
  const [currentSizeLabel, setCurrentSizeLabel] = useState("16pt (Bình thường)");

  // Biến phân loại và xử lý ảnh
  const [category, setCategory] = useState("");
  const [summary, setSummary] = useState("");
  const [thumbnailPreview, setThumbnailPreview] = useState("");
  const [isDragging, setIsDragging] = useState(false);

  // Biến xử lý đầu vào va chỉnh sửa bài
  const fileInputRef = useRef(null);
  const editorRef = useRef(null);
  const suggestions = handbooks
    .filter(h => h.title.toLowerCase().includes(searchTerm.toLowerCase()) && searchTerm.length > 0)
    .slice(0, 5);

  // BIẾN KIỂU DỮ LIỆU ĐẦU VÀO CỦA BÀI VIẾT
  // State theo dõi nút nào đang sáng (Active)
  const [activeFormats, setActiveFormats] = useState({
    bold: false, italic: false, underline: false,
    justifyLeft: false, justifyCenter: false, justifyRight: false,
    insertUnorderedList: false, insertOrderedList: false
  });

  const categoryOptions = [
    { id: 'Tất cả', label: 'Tất cả danh mục', color: '#64748b' },
    { id: 'Phòng trừ bệnh', label: 'Phòng trừ bệnh', color: '#ef4444' },
    { id: 'Kỹ thuật canh tác', label: 'Kỹ thuật canh tác', color: '#10b981' },
    { id: 'Nhận diện sâu bệnh', label: 'Nhận diện sâu bệnh', color: '#f59e0b' },
    { id: 'Mẹo nhà nông', label: 'Mẹo nhà nông', color: '#3b82f6' }
  ];

  const checkFormatState = () => {
    setActiveFormats({
      bold: document.queryCommandState('bold'),
      italic: document.queryCommandState('italic'),
      underline: document.queryCommandState('underline'),
      justifyLeft: document.queryCommandState('justifyLeft'),
      justifyCenter: document.queryCommandState('justifyCenter'),
      justifyRight: document.queryCommandState('justifyRight'),
      insertUnorderedList: document.queryCommandState('insertUnorderedList'),
      insertOrderedList: document.queryCommandState('insertOrderedList'),
    });
  };

  const fetchHandbooks = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/handbook/list`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        setHandbooks(res.data.data); // Đổ data thật vào bảng
      }
    } catch (error) {
      console.error("Lỗi tải danh sách cẩm nang:", error);
    }
  };

  // Tự động chạy ngay khi vừa mở trang Cẩm nang
  useEffect(() => {
    fetchHandbooks();
  }, []);

  const categories = ["Tất cả", "Phòng trừ bệnh", "Kỹ thuật canh tác", "Nhận diện sâu bệnh", "Mẹo nhà nông"];

  // --- CÁC HÀM XỬ LÝ ---
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

  const handleFormat = (command, value = null) => {
    document.execCommand(command, false, value);
    if (editorRef.current) editorRef.current.focus(); // Giữ focus lại vào ô soạn thảo
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
  // HÀM LƯU BÀI VIẾT VÀO DATABASE BẰNG API
  // ==========================================

  const handleSave = async () => {
    try {
      // 1. Kiểm tra dữ liệu (Validation)
      if (!title.trim()) { alert(" !LỖI: Vui lòng nhập tiêu đề bài viết!"); return; }
      if (!category) { alert(" !LỖI: Vui lòng chọn chủ đề!"); return; }

      // 2. Lấy HTML từ ô soạn thảo Rich Text
      const editorContent = editorRef.current?.innerHTML || "";

      // 3. Đóng gói dữ liệu để gửi đi
      const payload = {
        id: editingPost?.id, 
        title: title,
        category: category,
        summary: summary,
        content: editorContent,
        image: thumbnailPreview,
        status: "Visible",
        isPinned: editingPost?.isPinned || false
      };

      const token = localStorage.getItem("token");
      
      // 4. Bắn API lưu dữ liệu
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
      const errorMsg = error.response?.data?.message || "Lỗi máy chủ";
      alert(` Lưu thất bại: ${errorMsg}`);
    }
  };

  const handleEdit = (post) => {
    setEditingPost(post);
    setTitle(post.title);
    setCategory(post.category);
    setSummary(post.summary || "");
    setThumbnailPreview(post.image || "");
    setCurrentView('editor');
  };

  // 👉 THÊM CÁI NÀY VÀO DƯỚI HÀM handleEdit:
  // Vì cái thẻ div soạn thảo nó render chậm hơn state, 
  // nên phải dùng useEffect để đút nội dung HTML vào sau khi nó đã hiện ra
  useEffect(() => {
    if (currentView === 'editor' && editorRef.current) {
      editorRef.current.innerHTML = editingPost ? editingPost.content : "";
    }
  }, [currentView, editingPost]);
  
  const handleAddNew = () => {
    // Xóa sạch form cũ khi tạo bài mới
    setEditingPost(null);
    setTitle("");
    setCategory("");
    setSummary("");
    setThumbnailPreview("");
    if(editorRef.current) editorRef.current.innerHTML = "";
    setCurrentView('editor');
  };

  const handleToggleVisibility = (id) => {
    setHandbooks(handbooks.map(h => h.id === id ? { ...h, status: h.status === 'Visible' ? 'Hidden' : 'Visible' } : h));
  };

  const handleTogglePin = (id) => {
    setHandbooks(handbooks.map(h => h.id === id ? { ...h, isPinned: !h.isPinned } : h));
  };

  // Lọc dữ liệu kết hợp Tìm kiếm & Danh mục
  const filteredHandbooks = handbooks.filter(h => {
    const matchSearch = h.title.toLowerCase().includes(searchTerm.toLowerCase());
    const matchCategory = selectedCategory === "" || selectedCategory === "Tất cả" || h.category === selectedCategory;
    return matchSearch && matchCategory;
  });

  // ==========================================
  // VIEW 1: MÀN HÌNH DANH SÁCH (LIST VIEW)
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


        {/* THANH TÌM KIẾM & BỘ LỌC ĐỒNG BỘ UI */}
        <div className="mgmt-controls" style={{ display: 'flex', gap: '16px', alignItems: 'center', justifyContent: 'flex-end', marginBottom: '24px' }}>
          
          {/* KHUNG SEARCH MƯỢT MÀ */}
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
                <motion.ul 
                  className="search-suggestions"
                  initial={{ opacity: 0, y: -10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                >
                  {suggestions.map(s => (
                    <li key={s.id} onClick={() => {setSearchTerm(s.title); setShowSuggestions(false);}}>
                      <FileText size={14} color="#64748b" /> {/* Đổi icon User thành icon Bài viết */}
                      <div className="sugg-info">
                        <span className="sugg-name">{s.title}</span>
                        {/* Dùng luôn class sugg-email để hiện tên Danh mục cho lẹ, css giống nhau */}
                        <span className="sugg-email">{s.category}</span> 
                      </div>
                    </li>
                  ))}
                </motion.ul>
              )}
            </AnimatePresence>
          </div>

          {/* CUSTOM CATEGORY DROPDOWN */}
          <div className="custom-filter" style={{ position: 'relative', minWidth: '200px' }}>
            <button className="filter-trigger" onClick={() => setIsOpenFilter(!isOpenFilter)}>
              <div className="filter-dot" style={{ 
                background: categoryOptions.find(o => o.id === (selectedCategory || 'Tất cả'))?.color || '#64748b' 
              }}></div>
              <span>{selectedCategory === "" || selectedCategory === "Tất cả" ? "Tất cả danh mục" : selectedCategory}</span>
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
                  {categoryOptions.map(opt => (
                    <li key={opt.id} onClick={() => {
                        setSelectedCategory(opt.id);
                        setIsOpenFilter(false);
                    }}>
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
                <th style={{ width: '40px' }}></th> {/* Cột ghim */}
                <th>Bài viết cẩm nang</th>
                <th>Chủ đề</th>
                <th>Ngày đăng</th>
                <th>Trạng thái</th>
                <th style={{ textAlign: 'right' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredHandbooks.map((post) => (
                <tr key={post.id} className={post.status === 'Hidden' ? 'row-dimmed' : ''}>
                  <td>
                    <button 
                      className={`icon-btn pin-btn ${post.isPinned ? 'pinned' : ''}`}
                      onClick={() => handleTogglePin(post.id)}
                      title={post.isPinned ? "Bỏ ghim" : "Ghim lên đầu"}
                    >
                      <Pin size={18} fill={post.isPinned ? "#f59e0b" : "none"} color={post.isPinned ? "#f59e0b" : "#94a3b8"} />
                    </button>
                  </td>
                  <td>
                    <div className="handbook-info-cell">
                      <img src={post.image} alt="thumb" className="handbook-thumb-sm" />
                      <div>
                        <div className="handbook-title">{post.title}</div>
                        <div className="handbook-stats">{post.views} lượt xem</div>
                      </div>
                    </div>
                  </td>
                  <td><span className="category-tag">{post.category}</span></td>
                  <td><span className="publish-date">{post.publishDate}</span></td>
                  <td>
                    <span className={`status-badge ${post.status.toLowerCase()}`}>
                      {post.status === 'Visible' ? 'Đang Hiển Thị' : 'Đang Ẩn'}
                    </span>
                  </td>
                  <td>
                    <div className="action-buttons" style={{ justifyContent: 'flex-end' }}>
                      <button className="icon-btn toggle-eye" onClick={() => handleToggleVisibility(post.id)}>
                        {post.status === 'Visible' ? <Eye size={18} /> : <EyeOff size={18} />}
                      </button>
                      <button className="icon-btn edit" onClick={() => handleEdit(post)}><Edit size={18} /></button>
                      <button className="icon-btn delete"><Trash2 size={18} /></button> {/* CN.097 */}
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
  // VIEW 2: MÀN HÌNH SOẠN THẢO (EDITOR VIEW)
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
        {/* Cột Trái: Cấu hình bài viết */}
        <div className="editor-sidebar">
          <div className="form-group">
            <label>Ảnh đại diện bài viết</label>
            <input type="file" ref={fileInputRef} style={{ display: 'none' }} accept="image/*" onChange={handleThumbnailChange} />
            <div 
                className={`image-upload-box ${isDragging ? 'dragging' : ''}`} 
                onClick={handleThumbnailClick}
                onDragOver={handleDragOver}
                onDragLeave={handleDragLeave}
                onDrop={handleDrop}
                >
                  {thumbnailPreview ? (
                  <img src={thumbnailPreview} alt="Thumbnail preview" className="thumbnail-preview-img" />
                  ) : (
                    <>
                      <ImageIcon size={32} color={isDragging ? "#90A955" : "#cbd5e1"} />
                      <p>{isDragging ? "Thả ảnh vào đây..." : "Kéo thả hoặc click để tải ảnh lên"}</p>
                      </>
                  )}
              </div>
          </div>
          <div className="form-group">
            <label>Tiêu đề bài viết</label>
            <textarea 
              className="form-input title-input" 
              rows="3" 
              value={title} 
              onChange={(e) => setTitle(e.target.value)} 
              placeholder="VD: Bí quyết phòng bệnh mùa mưa..." 
            />
          </div>
          <div className="form-group">
            <label>Chủ đề (Danh mục)</label>
            <select 
              className="form-input" 
              value={category} 
              onChange={(e) => setCategory(e.target.value)}
            >
              <option value="" disabled>Chọn chủ đề...</option>
              {categories.slice(1).map((cat, i) => <option key={i} value={cat}>{cat}</option>)}
            </select>
          </div>
          <div className="form-group">
            <label>Tóm tắt ngắn (Mô tả)</label>
            <textarea 
              className="form-input" 
              rows="4" 
              value={summary}
              onChange={(e) => setSummary(e.target.value)}
              placeholder="Nhập đoạn mô tả ngắn hiển thị dưới tiêu đề..."
            ></textarea>
          </div>
        </div>

        {/* Cột Phải: Word-like Editor */}
        <div className="editor-main-workspace">
          <div className="word-editor-wrapper">
            <div className="word-toolbar">
              {/* DROPDOWN FONT XỊN XÒ */}
              <div className="custom-toolbar-select">
                <div className="select-trigger-mini" onClick={() => setIsFontFamilyOpen(!isFontFamilyOpen)}>
                  <span>{currentFont}</span> <ChevronDown size={14} className={`chevron ${isFontFamilyOpen ? 'open' : ''}`}/>
                </div>
                {isFontFamilyOpen && (
                  <div className="select-dropdown-menu-mini">
                    {['Roboto', 'Arial', 'Times New Roman'].map(font => (
                      <div key={font} className="select-option-mini" onClick={() => {
                        setCurrentFont(font);
                        handleFormat('fontName', font);
                        setIsFontFamilyOpen(false);
                      }}>
                        <span style={{ fontFamily: font }}>{font}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* DROPDOWN SIZE XỊN XÒ */}
              <div className="custom-toolbar-select">
                <div className="select-trigger-mini" onClick={() => setIsFontSizeOpen(!isFontSizeOpen)}>
                  <span>{currentSizeLabel}</span> <ChevronDown size={14} className={`chevron ${isFontSizeOpen ? 'open' : ''}`}/>
                </div>
                {isFontSizeOpen && (
                  <div className="select-dropdown-menu-mini">
                    {[
                      { label: '14pt (Nhỏ)', value: '2' }, 
                      { label: '16pt (Bình thường)', value: '3' }, 
                      { label: '18pt (Tiêu đề 2)', value: '4' }, 
                      { label: '24pt (Tiêu đề 1)', value: '5' }
                    ].map(size => (
                      <div key={size.label} className="select-option-mini" onClick={() => {
                        setCurrentSizeLabel(size.label);
                        handleFormat('fontSize', size.value);
                        setIsFontSizeOpen(false);
                      }}>{size.label}</div>
                    ))}
                  </div>
                )}
              </div>

              <div className="toolbar-divider"></div>

              {/* NÚT ĐỊNH DẠNG CHỮ */}
              <div className="toolbar-group">
                <button 
                  className={`toolbar-btn ${activeFormats.bold ? 'active' : ''}`} 
                  onMouseDown={(e) => e.preventDefault()} // 👉 THÊM DÒNG NÀY CHỐNG MẤT FOCUS
                  onClick={() => handleFormat('bold')} 
                  title="In đậm"
                ><Bold size={16} /></button>
                
                <button 
                  className={`toolbar-btn ${activeFormats.italic ? 'active' : ''}`} 
                  onMouseDown={(e) => e.preventDefault()} // 👉 THÊM VÀO ĐÂY NỮA
                  onClick={() => handleFormat('italic')} 
                  title="In nghiêng"
                ><Italic size={16} /></button>
                
                <button 
                  className={`toolbar-btn ${activeFormats.underline ? 'active' : ''}`} 
                  onMouseDown={(e) => e.preventDefault()} // 👉 VÀ ĐÂY NỮA
                  onClick={() => handleFormat('underline')} 
                  title="Gạch chân"
                ><Underline size={16} /></button>
              </div>

              <div className="toolbar-divider"></div>

              {/* NÚT CĂN LỀ */}
              <div className="toolbar-group">
                <button className={`toolbar-btn ${activeFormats.justifyLeft ? 'active' : ''}`} onClick={() => handleFormat('justifyLeft')} title="Căn trái"><AlignLeft size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.justifyCenter ? 'active' : ''}`} onClick={() => handleFormat('justifyCenter')} title="Căn giữa"><AlignCenter size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.justifyRight ? 'active' : ''}`} onClick={() => handleFormat('justifyRight')} title="Căn phải"><AlignRight size={16} /></button>
              </div>

              <div className="toolbar-divider"></div>

              {/* DANH SÁCH & TIỆN ÍCH */}
              <div className="toolbar-group">
                <button className={`toolbar-btn ${activeFormats.insertUnorderedList ? 'active' : ''}`} onClick={() => handleFormat('insertUnorderedList')}><List size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.insertOrderedList ? 'active' : ''}`} onClick={() => handleFormat('insertOrderedList')}><ListOrdered size={16} /></button>
                <button className="toolbar-btn" title="Chèn Link"><Link size={16} /></button>
                <button className="toolbar-btn" title="Chèn Ảnh"><ImageIcon size={16} /></button>
                <button className="toolbar-btn tip-btn" title="Chèn Box Mẹo PlantAI">
                  <MessageSquareWarning size={16} color="#90A955" />
                </button>
              </div>
            </div>

            <div className="word-canvas">
              <div 
                ref={editorRef}
                contentEditable="true"
                className="rich-text-area" 
                onKeyUp={checkFormatState}   
                onMouseUp={checkFormatState} 
                placeholder="Bắt đầu viết nội dung cẩm nang của bạn tại đây... (Bôi đen chữ để dùng định dạng)"
                style={{ outline: 'none', minHeight: '400px' }}
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HandbookManagement;