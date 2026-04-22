import React, { useState, useRef, useEffect } from 'react';
import { 
  Search, Plus, Edit, Trash2, Eye, EyeOff, ArrowLeft, Save, Image as ImageIcon,
  Bold, Italic, Underline, List, ListOrdered, AlignLeft, AlignCenter, AlignRight, Link, ChevronDown,
  Check
} from 'lucide-react';
import axios from 'axios';
import { motion, AnimatePresence } from "framer-motion";
import "../styles/DiseaseManagement.css";

const API_URL = "http://127.0.0.1:3000/api";

const DiseaseManagement = () => {
  // --- STATE QUẢN LÝ VIEW VÀ DỮ LIỆU ---
  const [currentView, setCurrentView] = useState('list'); // 'list' | 'editor'
  const [editingDisease, setEditingDisease] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [isPlantDropdownOpen, setIsPlantDropdownOpen] = useState(false);
  const [selectedPlant, setSelectedPlant] = useState("");
  const [thumbnailPreview, setThumbnailPreview] = useState("");
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [isOpenFilter, setIsOpenFilter] = useState(false);
  const [filterStatus, setFilterStatus] = useState("all");
  const [editorTab, setEditorTab] = useState('overview'); // Các tab giống App Mobile
  const [contentValues, setContentValues] = useState({
  overview: "", symptoms: "", causes: "", prevention: "", treatment: ""
});

  // --- STATE CHO TRÌNH SOẠN THẢO (RICH TEXT EDITOR) ---
  const editorRef = useRef(null);
  const [isFontFamilyOpen, setIsFontFamilyOpen] = useState(false);
  const [isFontSizeOpen, setIsFontSizeOpen] = useState(false);
  const [currentFont, setCurrentFont] = useState("Arial");
  const [currentSizeLabel, setCurrentSizeLabel] = useState("14pt");
  const fileInputRef = useRef(null); // Ref cho ô upload ảnh
  const [isDragging, setIsDragging] = useState(false);

  const [activeFormats, setActiveFormats] = useState({
    bold: false, italic: false, underline: false,
    justifyLeft: false, justifyCenter: false, justifyRight: false,
    insertUnorderedList: false, insertOrderedList: false
  });

  // Dữ liệu mẫu (CN.092)
  const [diseases, setDiseases] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const statusOptions = [
    { id: 'all', label: 'Tất cả loại cây', color: '#64748b' },
    { id: 'Lúa', label: 'Lúa', color: '#10b981' },
    { id: 'Cà Phê', label: 'Cà phê', color: '#ef4444' } // Sửa id lại cho chuẩn xác
  ];

  const suggestions = diseases
    .filter(d => 
      (d.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
       d.scientificName.toLowerCase().includes(searchTerm.toLowerCase())) && 
      searchTerm.length > 0
    )
    .slice(0, 5);
  

  const fetchDiseases = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/disease/list`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        setDiseases(res.data.data); // Đổ data thật vào bảng
      }
    } catch (error) {
      console.error("Lỗi tải danh sách bệnh:", error);
    } finally {
      setIsLoading(false);
    }
  };

// Tự động chạy khi vừa vào trang
  useEffect(() => {
    fetchDiseases();
  }, []);
  // --- CÁC HÀM XỬ LÝ (CN.089, CN.090, CN.091, CN.094) ---
  const handleAddNew = () => {
    setEditingDisease(null);
    setCurrentView('editor');
    setEditorTab('overview');
  };

  const handleEdit = (disease) => {
    setEditingDisease(disease);
    setCurrentView('editor');
    setEditorTab('overview');

    setThumbnailPreview(disease.image || "");
    setSelectedPlant(disease.affected_plant !== "Chưa cập nhật" ? disease.affected_plant : "");
    setContentValues(disease.content || {
      overview: "", symptoms: "", causes: "", prevention: "", treatment: ""
    });
  };

  const handleContentChange = (val) => {
  setContentValues(prev => ({ ...prev, [editorTab]: val }));
};

  useEffect(() => {
    if (editorRef.current) {
      editorRef.current.innerHTML = contentValues[editorTab] || "";
    }
  }, [editorTab]);

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

  const handleThumbnailClick = () => fileInputRef.current?.click();

  const convertToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);
  });
};

  const handleThumbnailChange = async (e) => {
  const file = e.target.files?.[0];
  if (file) {
    // Ép sang Base64 thay vì tạo link ảo blob
    const base64Str = await convertToBase64(file);
    setThumbnailPreview(base64Str); 
  }
};




  const handleFormat = (command, value = null) => {
      document.execCommand(command, false, value);
      if (editorRef.current) editorRef.current.focus();
      handleContentChange(editorRef.current.innerHTML);
      checkFormatState(); // Bắt nút sáng lên ngay lập tức
  };

  const handleEditorInput = () => {
    if (editorRef.current) {
      handleContentChange(editorRef.current.innerHTML);
    }
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

  // Xử lý chèn Link và Ảnh
  const handleAddLink = () => {
    const url = prompt("Nhập đường dẫn URL:");
    if (url) handleFormat('createLink', url);
  };
  const handleAddImage = () => {
    const url = prompt("Nhập đường dẫn ảnh (URL):");
    if (url) handleFormat('insertImage', url);
  };

  const handleSave = async () => {
    try {
      // 1. Lấy dữ liệu (Riêng affected_plant lấy trực tiếp từ STATE của ông)
      const nameInput = document.querySelector('input[placeholder="VD: Bệnh Bỏng Lá Lúa"]')?.value.trim();
      const sciNameInput = document.querySelector('.italic-input')?.value.trim();
      const stageInput = document.querySelector('input[placeholder="VD: Làm đòng - Trổ"]')?.value.trim();
      const partInput = document.querySelector('input[placeholder="VD: Chóp và mép lá"]')?.value.trim();

      // 2. VALIDATION: Bắt lỗi
      if (!nameInput) {
        alert(" Lỗi: Vui lòng nhập [Tên bệnh]!");
        return; 
      }
      //  Thay vì check plantSelect như cũ, giờ check thẳng biến selectedPlant
      if (!selectedPlant) { 
        alert(" Lỗi: Vui lòng chọn [Cây bị ảnh hưởng] từ danh sách!");
        return;
      }
      if (!stageInput) {
        alert(" Lỗi: Vui lòng nhập [Giai đoạn gây hại]!");
        return;
      }

      // 3. ĐÓNG GÓI DỮ LIỆU
      const token = localStorage.getItem("token");
      const payload = {
        id: editingDisease?.id,
        name: nameInput,
        scientificName: sciNameInput || "Chưa cập nhật",
        
        //  Lấy dữ liệu trực tiếp từ State cực kỳ an toàn
        affected_plant: selectedPlant, 
        
        stage: stageInput, 
        part: partInput || "Chưa cập nhật",
        image: thumbnailPreview, // Nhớ kèm cái state ảnh bìa ở bước trước
        content: contentValues, 
        status: "Visible"
      };

    // 4. GỌI API
    const res = await axios.post(`${API_URL}/disease/save`, payload, {
      headers: { Authorization: `Bearer ${token}` }
    });

    if(res.data.status === "success") {
      alert(" Đã lưu bài đăng thành công!");
      setCurrentView('list');
      fetchDiseases();
    }
    
    } catch (error) {
      console.error("Chi tiết lỗi:", error);
      const errorMsg = error.response?.data?.message || error.message || "Lỗi máy chủ không xác định";
      alert(` Lưu thất bại: ${errorMsg}`);
    }
  };

  const handleToggleVisibility = (id) => {
    setDiseases(diseases.map(d => {
      if (d.id === id) return { ...d, status: d.status === 'Visible' ? 'Hidden' : 'Visible' };
      return d;
    }));
  };

  // Lọc dữ liệu tìm kiếm (CN.093)
  const filteredDiseases = diseases.filter(d => {
    // 1. Lọc theo thanh tìm kiếm
    const matchSearch = d.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                        d.scientificName.toLowerCase().includes(searchTerm.toLowerCase());
    
    
    const matchFilter = filterStatus === "all" || d.affected_plant === filterStatus;
    
    return matchSearch && matchFilter;
  });

  // ==========================================
  // VIEW 1: MÀN HÌNH DANH SÁCH BỆNH
  // ==========================================
  if (currentView === 'list') {
    return (
      <div className="disease-mgmt-container">
        <div className="mgmt-header-container" style={{ display: 'flex', flexDirection: 'column', marginBottom: '24px' }}>
          
          {/* --- DÒNG 1: TIÊU ĐỀ & NÚT THÊM --- */}
          <div className="header-row-top" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px' }}>
            <div className="mgmt-title" style={{ margin: 0 }}>
              <h2 style={{ margin: 0, marginBottom: '4px' }}>Từ điển Bệnh cây trồng</h2>
              <span style={{ color: '#64748b', fontSize: '14px' }}>Quản lý {diseases.length} cơ sở dữ liệu bệnh</span>
            </div>
            
            <button className="btn-add-primary" onClick={handleAddNew} style={{ margin: 0 }}>
              <Plus size={18} /> Thêm bệnh mới
            </button>
          </div>

          {/* --- DÒNG 2: THANH TÌM KIẾM & BỘ LỌC TRẠNG THÁI --- */}
          <div className="mgmt-controls" style={{ display: 'flex', gap: '16px', alignItems: 'center', justifyContent: 'flex-end', marginBottom: '24px' }}>
          
            {/* KHUNG SEARCH MƯỢT MÀ */}
            <div className="search-wrapper" style={{ width: '100%', position: 'relative' }}>
              <div className="search-box-modern" style={{ width: '97%' }}>
                <Search size={18} style={{ flexShrink: 0 }} />
                <input 
                  type="text" 
                  placeholder="Tìm tên bệnh, tên khoa học..." 
                  value={searchTerm}
                  onChange={(e) => {setSearchTerm(e.target.value); setShowSuggestions(true);}}
                  onFocus={() => setShowSuggestions(true)}
                  onBlur={() => setTimeout(() => setShowSuggestions(false), 200)} 
                  style={{ width: '100%', flex: 1 }} 
                />
              </div>
              
              {/* Dropdown Gợi ý Bệnh */}
              <AnimatePresence>
                {showSuggestions && suggestions.length > 0 && (
                  <motion.ul 
                    className="search-suggestions"
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                  >
                    {suggestions.map(s => (
                      <li key={s.id} onClick={() => {setSearchTerm(s.name); setShowSuggestions(false);}}>
                        <ImageIcon size={14} color="#64748b" />
                        <div className="sugg-info">
                          <span className="sugg-name">{s.name}</span>
                          <span className="sugg-email"><i>{s.scientificName}</i></span> 
                        </div>
                      </li>
                    ))}
                  </motion.ul>
                )}
              </AnimatePresence>
            </div>

            {/* Dropdown Lọc Trạng thái (Visible/Hidden) */}
            <div className="custom-filter" style={{ position: 'relative', flexShrink: 0, minWidth: '180px' }}>
              <button className="filter-trigger" onClick={() => setIsOpenFilter(!isOpenFilter)} style={{ width: '100%' }}>
                <div className="filter-dot" style={{ 
                  background: statusOptions.find(o => o.id === filterStatus)?.color || '#64748b' 
                }}></div>
                <span style={{ flex: 1, textAlign: 'left' }}>
                  {statusOptions.find(o => o.id === filterStatus)?.label}
                </span>
                <ChevronDown size={16} className={isOpenFilter ? 'rotate' : ''} style={{ flexShrink: 0 }} />
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
                      <li key={opt.id} onClick={() => {
                          setFilterStatus(opt.id);
                          setIsOpenFilter(false);
                      }}>
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
                <th>Thông tin Bệnh</th>
                <th>Loại cây trồng</th>
                <th>Giai đoạn / Bộ phận</th>
                <th>Cập nhật lần cuối</th>
                <th>Trạng thái</th>
                <th style={{ textAlign: 'right' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredDiseases.map((disease) => (
                <tr key={disease.id} className={disease.status === 'Hidden' ? 'row-dimmed' : ''}>
                  <td>
                    <div className="disease-info-cell">
                      <img src={disease.image} alt="thumb" className="disease-thumb-sm" />
                      <div>
                        <div className="disease-name">{disease.name}</div>
                        <div className="disease-sci-name"><i>{disease.scientificName}</i></div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className="plant-badge">
                      {disease.affected_plant || "Chưa cập nhật"}
                    </span>
                  </td>
                  <td>
                    <div className="disease-meta-cell">
                      <span><strong>Giai đoạn:</strong> {disease.stage}</span>
                      <span><strong>Bộ phận:</strong> {disease.part}</span>
                    </div>
                  </td>
                  <td><span className="join-date">{disease.updatedAt}</span></td>
                  <td>
                    <span className={`status-badge ${disease.status.toLowerCase()}`}>
                      {disease.status === 'Visible' ? 'Đang Hiển Thị' : 'Đang Ẩn'}
                    </span>
                  </td>
                  <td>
                    <div className="action-buttons" style={{ justifyContent: 'flex-end' }}>
                      <button 
                        className="icon-btn toggle-eye" 
                        title={disease.status === 'Visible' ? "Ẩn bài viết" : "Hiện bài viết"}
                        onClick={() => handleToggleVisibility(disease.id)}
                      >
                        {disease.status === 'Visible' ? <Eye size={18} /> : <EyeOff size={18} />}
                      </button>
                      <button className="icon-btn edit" title="Chỉnh sửa" onClick={() => handleEdit(disease)}>
                        <Edit size={18} />
                      </button>
                      <button className="icon-btn delete" title="Xóa dữ liệu"><Trash2 size={18} /></button>
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
  // VIEW 2: MÀN HÌNH SOẠN THẢO (WORD-LIKE EDITOR)
  // ==========================================
  return (
    <div className="disease-editor-container">
      {/* Header Editor */}
      <div className="editor-header">
        <div className="editor-header-left">
          <button className="btn-back-editor" onClick={() => setCurrentView('list')}>
            <ArrowLeft size={20} />
          </button>
          <div>
            <h3>{editingDisease ? "Chỉnh sửa bài đăng" : "Thêm bệnh cây mới"}</h3>
            <span>{editingDisease ? editingDisease.name : "Đang tạo bản nháp..."}</span>
          </div>
        </div>
        <button className="btn-save-primary" onClick={handleSave}>
          <Save size={18} /> Lưu & Xuất bản
        </button>
      </div>

      <div className="editor-layout-grid">
        {/* Cột Trái: Thông tin cơ bản (Metadata) */}
        <div className="editor-sidebar">
          <div className="form-group">
            <label>Ảnh bìa (Thumbnail)</label>
            {/* Input ẩn */}
            <input type="file" ref={fileInputRef} style={{ display: 'none' }} accept="image/*" onChange={handleThumbnailChange} />
            
            {/* Khu vực bấm / Kéo thả */}
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
            <label>Tên bệnh (Tiếng Việt)</label>
            <input type="text" className="form-input" defaultValue={editingDisease?.name} placeholder="VD: Bệnh Bỏng Lá Lúa" />
          </div>
          <div className="form-group">
            <label>Tên Khoa học</label>
            <input type="text" className="form-input italic-input" defaultValue={editingDisease?.scientificName} placeholder="VD: Monographella albescens" />
          </div>
          <div className="form-group">
            <label>Giai đoạn gây hại</label>
            <input type="text" className="form-input" defaultValue={editingDisease?.stage} placeholder="VD: Làm đòng - Trổ" />
          </div>
          <div className="form-group">
            <label>Cây bị ảnh hưởng</label>
            <div className="custom-premium-select">
              <div 
                className={`select-trigger ${isPlantDropdownOpen ? 'open' : ''}`}
                onClick={() => setIsPlantDropdownOpen(!isPlantDropdownOpen)}
              >
                <span className={selectedPlant ? 'has-value' : 'placeholder'}>
                  {selectedPlant || "-- Chọn loại cây --"}
                </span>
                <ChevronDown size={16} className="chevron-icon" />
              </div>
              {isPlantDropdownOpen && (
                <div className="select-dropdown-menu">
                  {['Lúa', 'Cà Phê'].map((plant) => (
                    <div 
                      key={plant}
                      className={`select-option ${selectedPlant === plant ? 'selected' : ''}`}
                      onClick={() => {
                        setSelectedPlant(plant);
                        setIsPlantDropdownOpen(false);
                      }}
                    >
                      {plant}
                      {selectedPlant === plant && <span className="check-icon">✓</span>}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
          <div className="form-group">
            <label>Bộ phận gây hại</label>
            <input type="text" className="form-input" defaultValue={editingDisease?.part} placeholder="VD: Chóp và mép lá" />
          </div>
        </div>

        {/* Cột Phải: Word-like Rich Text Editor */}
        <div className="editor-main-workspace">
          {/* Tabs nội dung map với App Mobile */}
          <div className="editor-content-tabs">
            <button className={`content-tab ${editorTab === 'overview' ? 'active' : ''}`} onClick={() => setEditorTab('overview')}>Tổng quan</button>
            <button className={`content-tab ${editorTab === 'symptoms' ? 'active' : ''}`} onClick={() => setEditorTab('symptoms')}>Triệu chứng</button>
            <button className={`content-tab ${editorTab === 'causes' ? 'active' : ''}`} onClick={() => setEditorTab('causes')}>Nguyên nhân</button>
            <button className={`content-tab ${editorTab === 'prevention' ? 'active' : ''}`} onClick={() => setEditorTab('prevention')}>Phòng ngừa</button>
            <button className={`content-tab ${editorTab === 'treatment' ? 'active' : ''}`} onClick={() => setEditorTab('treatment')}>Điều trị</button>
          </div>

          <div className="word-editor-wrapper">
            {/* Thanh công cụ Word-like Premium */}
            <div className="word-toolbar">
              
              {/* Dropdown Chọn Font */}
              <div className="custom-toolbar-select">
                <div className="select-trigger-mini" onClick={() => setIsFontFamilyOpen(!isFontFamilyOpen)}>
                  <span>{currentFont}</span> <ChevronDown size={14} className={`chevron ${isFontFamilyOpen ? 'open' : ''}`}/>
                </div>
                {isFontFamilyOpen && (
                  <div className="select-dropdown-menu-mini">
                    {['Arial', 'Roboto', 'Times New Roman', 'Inter'].map(font => (
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

              {/* Dropdown Chọn Size */}
              <div className="custom-toolbar-select">
                <div className="select-trigger-mini" onClick={() => setIsFontSizeOpen(!isFontSizeOpen)}>
                  <span>{currentSizeLabel}</span> <ChevronDown size={14} className={`chevron ${isFontSizeOpen ? 'open' : ''}`}/>
                </div>
                {isFontSizeOpen && (
                  <div className="select-dropdown-menu-mini">
                    {/* HTML execCommand dùng size từ 1-7 */}
                    {[
                      { label: '10pt', value: '1' }, { label: '12pt', value: '2' }, 
                      { label: '14pt', value: '3' }, { label: '18pt', value: '4' }, 
                      { label: '24pt', value: '5' }
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

              {/* Các nút Format (Bấm là ăn ngay) */}
              <div className="toolbar-group">
                <button className={`toolbar-btn ${activeFormats.bold ? 'active' : ''}`} onClick={() => handleFormat('bold')} title="In đậm"><Bold size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.italic ? 'active' : ''}`} onClick={() => handleFormat('italic')} title="In nghiêng"><Italic size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.underline ? 'active' : ''}`} onClick={() => handleFormat('underline')} title="Gạch chân"><Underline size={16} /></button>
              </div>
              <div className="toolbar-divider"></div>
              <div className="toolbar-group">
                <button className={`toolbar-btn ${activeFormats.justifyLeft ? 'active' : ''}`} onClick={() => handleFormat('justifyLeft')}><AlignLeft size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.justifyCenter ? 'active' : ''}`} onClick={() => handleFormat('justifyCenter')}><AlignCenter size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.justifyRight ? 'active' : ''}`} onClick={() => handleFormat('justifyRight')}><AlignRight size={16} /></button>
              </div>
              <div className="toolbar-divider"></div>
              <div className="toolbar-group">
                <button className={`toolbar-btn ${activeFormats.insertUnorderedList ? 'active' : ''}`} onClick={() => handleFormat('insertUnorderedList')}><List size={16} /></button>
                <button className={`toolbar-btn ${activeFormats.insertOrderedList ? 'active' : ''}`} onClick={() => handleFormat('insertOrderedList')}><ListOrdered size={16} /></button>
                <button className="toolbar-btn" onClick={handleAddLink}><Link size={16} /></button>
                <button className="toolbar-btn" onClick={handleAddImage}><ImageIcon size={16} /></button>
              </div>
            </div>

            {/* Vùng soạn thảo văn bản ĐỘNG (Rich Text Canvas) */}
            <div className="word-canvas">
              <div 
                ref={editorRef}
                contentEditable="true"
                className="rich-text-area" 
                onInput={handleEditorInput}
                onKeyUp={checkFormatState}   
                onMouseUp={checkFormatState}  
                placeholder={`Nhập nội dung cho phần [${editorTab.toUpperCase()}]... (Bôi đen chữ để dùng công cụ định dạng)`}
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DiseaseManagement;