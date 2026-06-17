import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { 
  Search, Plus, Trash2, ArrowLeft, MessageCircle, 
  User, Image as ImageIcon, CornerDownRight, MessageSquare, Heart, Maximize2, X
} from 'lucide-react';
import { motion, AnimatePresence } from "framer-motion";
import "../styles/CommunityManagement.css";

const API_URL = "http://127.0.0.1:3000/api";

const CommunityManagementComponent = () => {
  const [currentView, setCurrentView] = useState('list'); 
  const [posts, setPosts] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  
  const [selectedPost, setSelectedPost] = useState(null);
  const [comments, setComments] = useState([]);

  // 👉 THÊM STATE ĐỂ LƯU BÀI VIẾT ĐANG XEM CHI TIẾT
  const [viewingPost, setViewingPost] = useState(null);

  const [adminContent, setAdminContent] = useState("");
  const [thumbnailPreview, setThumbnailPreview] = useState("");
  const fileInputRef = useRef(null);

  // --- API CALLS ---
  const fetchPosts = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/community/list`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        setPosts(res.data.data);
      }
    } catch (error) {
      console.error("Lỗi tải bài viết cộng đồng:", error);
    }
  };

  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchCommentsForPost = async (postId) => {
    try {
      const token = localStorage.getItem("token");
      const res = await axios.get(`${API_URL}/community/post/${postId}/comments`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        setComments(res.data.data); 
      }
    } catch (error) {
      console.error("Lỗi tải bình luận:", error);
    }
  };

  const handleDeletePost = async (postId) => {
    if (!window.confirm("Bạn có chắc chắn muốn xóa bài viết này cùng toàn bộ bình luận liên quan?")) return;
    try {
      const token = localStorage.getItem("token");
      const res = await axios.delete(`${API_URL}/community/post/delete/${postId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        alert("Đã xóa bài viết khỏi hệ thống!");
        fetchPosts();
        if(viewingPost && viewingPost._id === postId) setViewingPost(null); // Đóng popup nếu đang mở
      }
    } catch (error) {
      alert("Xóa bài viết thất bại!");
    }
  };

  const handleDeleteComment = async (commentId) => {
    if (!window.confirm("Xóa bình luận này?")) return;
    try {
      const token = localStorage.getItem("token");
      const res = await axios.delete(`${API_URL}/community/comment/delete/${commentId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        fetchCommentsForPost(selectedPost._id); 
        fetchPosts(); 
      }
    } catch (error) {
      alert("Không thể xóa bình luận này!");
    }
  };

  const handleAdminPublish = async () => {
    if (!adminContent.trim() && !thumbnailPreview) {
      alert("Vui lòng nhập nội dung hoặc thêm hình ảnh!");
      return;
    }
    try {
      const token = localStorage.getItem("token");
      const payload = {
        content: adminContent,
        imageUrl: thumbnailPreview || null
      };
      const res = await axios.post(`${API_URL}/community/save`, payload, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.data.status === "success") {
        alert("Đăng bài viết của Ban Quản Trị thành công!");
        setAdminContent("");
        setThumbnailPreview("");
        setCurrentView('list');
        fetchPosts();
      }
    } catch (error) {
      alert("Đăng bài thất bại!");
    }
  };

  const handleThumbnailChange = async (e) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => setThumbnailPreview(reader.result);
    }
  };

  const filteredPosts = posts.filter(p => 
    p.content?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.authorName?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // ==========================================
  // VIEW 1: DANH SÁCH BÀI ĐĂNG CỦA APP
  // ==========================================
  if (currentView === 'list') {
    return (
      <div className="community-mgmt-container">
        <div className="mgmt-header">
          <div className="mgmt-title">
            <h2>Quản lý Diễn đàn & Cộng đồng</h2>
            <span>Hệ thống có {posts.length} bài đăng từ người dùng</span>
          </div>
          <button className="btn-add-primary" onClick={() => setCurrentView('create')}>
            <Plus size={18} /> Đăng bài BQT
          </button>
        </div>

        <div className="mgmt-controls" style={{ marginBottom: '24px' }}>
          <div className="search-wrapper" style={{ width: '100%' }}>
            <div className="search-box-modern" style={{ width: '100%' }}>
              <Search size={18} />
              <input 
                type="text" 
                placeholder="Tìm nội dung bài đăng hoặc tên tài khoản người dùng..." 
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
        </div>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Người đăng</th>
                <th>Nội dung bài viết</th>
                <th style={{ textAlign: 'center' }}>Tương tác</th>
                <th>Ngày đăng</th>
                <th style={{ textAlign: 'right' }}>Thao tác kiểm duyệt</th>
              </tr>
            </thead>
            <tbody>
              {filteredPosts.map((post) => (
                <tr key={post._id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontWeight: '500' }}>
                      <User size={16} color="#64748b" />
                      <span>{post.authorName || `User_${post.authorId?.slice(-5)}`}</span>
                    </div>
                  </td>
                  <td>
                    <div className="post-info-cell">
                      {post.imageUrl && (
                        <img src={post.imageUrl} alt="post-attached" className="post-thumb-sm" />
                      )}
                      <div style={{ maxWidth: '400px' }}>
                        <div className="post-content-preview">
                          {post.content}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td style={{ textAlign: 'center' }}>
                    <div className="post-stats-group">
                      <span className="post-stats-item"><Heart size={14} color="#ef4444" fill="#ef4444" /> {post.likes?.length || 0}</span>
                      <span className="post-stats-item"><MessageSquare size={14} color="#3b82f6" /> {post.commentsCount || 0}</span>
                    </div>
                  </td>
                  <td>
                    <span className="publish-date">
                      {post.createdAt ? new Date(post.createdAt).toLocaleDateString('vi-VN') : "Vừa xong"}
                    </span>
                  </td>
                  <td>
                    <div className="action-buttons" style={{ justifyContent: 'flex-end' }}>
                      {/* NÚT XEM CHI TIẾT BÀI ĐĂNG */}
                      <button 
                        className="icon-btn edit" 
                        title="Xem chi tiết nội dung"
                        onClick={() => setViewingPost(post)}
                      >
                        <Maximize2 size={18} color="#10b981" />
                      </button>

                      <button 
                        className="icon-btn edit" 
                        title="Quản lý chi tiết bình luận"
                        onClick={() => {
                          setSelectedPost(post);
                          fetchCommentsForPost(post._id);
                          setCurrentView('comments');
                        }}
                      >
                        <MessageCircle size={18} color="#3b82f6" />
                      </button>
                      <button className="icon-btn delete" onClick={() => handleDeletePost(post._id)}>
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* ====================================================
            MODAL XEM CHI TIẾT BÀI ĐĂNG (POPUP)
            ==================================================== */}
        <AnimatePresence>
          {viewingPost && (
            <div className="modal-overlay" onClick={() => setViewingPost(null)}>
              <motion.div 
                className="post-detail-modal"
                onClick={(e) => e.stopPropagation()} /* Chống click xuyên thấu */
                initial={{ opacity: 0, scale: 0.95, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: 20 }}
                transition={{ duration: 0.2 }}
              >
                <div className="modal-header">
                  <h3>Nội dung bài đăng</h3>
                  <button className="btn-close-modal" onClick={() => setViewingPost(null)}>
                    <X size={20} />
                  </button>
                </div>
                
                <div className="modal-body">
                  <div className="detail-author-row">
                    <div className="comment-avatar">
                      {viewingPost.authorName ? viewingPost.authorName.charAt(0).toUpperCase() : 'U'}
                    </div>
                    <div>
                      <div className="detail-author-name">{viewingPost.authorName}</div>
                      <div className="detail-time">
                        {new Date(viewingPost.createdAt).toLocaleString('vi-VN', {
                          hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit', year: 'numeric'
                        })}
                      </div>
                    </div>
                  </div>
                  
                  <div className="detail-text">{viewingPost.content}</div>
                  
                  {viewingPost.imageUrl && (
                    <img src={viewingPost.imageUrl} alt="post-img" className="detail-image" />
                  )}
                  
                  <div className="detail-stats">
                    <span><Heart size={18} color="#ef4444" fill="#ef4444" /> {viewingPost.likes?.length || 0} lượt thích</span>
                    <span><MessageSquare size={18} color="#3b82f6" fill="#bfdbfe" /> {viewingPost.commentsCount || 0} bình luận</span>
                  </div>
                </div>
              </motion.div>
            </div>
          )}
        </AnimatePresence>
      </div>
    );
  }

  // ==========================================
  // VIEW 2: QUẢN LÝ LUỒNG BÌNH LUẬN & PHẢN HỒI 
  // ==========================================
  if (currentView === 'comments') {
    return (
      <div className="community-mgmt-container">
        <div className="editor-header" style={{ marginBottom: '20px', borderRadius: '16px' }}>
          <div className="editor-header-left">
            <button className="btn-back-editor" onClick={() => { setCurrentView('list'); setSelectedPost(null); }}><ArrowLeft size={20} /></button>
            <div>
              <h3>Quản lý bình luận của bài viết</h3>
              <p style={{ color: '#64748b', fontSize: '13px' }}>Bài đăng bởi: <strong>{selectedPost?.authorName}</strong> - "{selectedPost?.content?.substring(0, 50)}..."</p>
            </div>
          </div>
        </div>

        <div className="comments-moderation-wrapper">
          <h4 style={{ marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '16px' }}>
            <MessageSquare size={20} color="#64748b" /> Danh sách phản hồi dữ liệu thực tế ({comments.length} đầu mục):
          </h4>
          
          {comments.length === 0 ? (
            <p style={{ textAlign: 'center', color: '#94a3b8', padding: '40px 0' }}>Bài viết này hiện chưa có bình luận nào.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              {comments.map((comment) => (
                <div key={comment._id} className="comment-group-box">
                  
                  <div className="comment-main-item">
                    <div style={{ display: 'flex', flex: 1, gap: '16px' }}>
                      <div className="comment-avatar">
                        {comment.authorName ? comment.authorName.charAt(0).toUpperCase() : 'U'}
                      </div>
                      
                      <div className="comment-content-wrapper" style={{ flex: 1 }}>
                        <div className="comment-meta">
                          <span className="comment-author">{comment.authorName}</span>
                          <span className="comment-time">
                            {new Date(comment.createdAt).toLocaleString('vi-VN', { 
                              hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit', year: 'numeric' 
                            })}
                          </span>
                        </div>
                        <div className="comment-text">{comment.content}</div>
                      </div>
                    </div>
                    
                    <button className="icon-btn delete-comment" title="Xóa bình luận" onClick={() => handleDeleteComment(comment._id)}>
                      <Trash2 size={16} strokeWidth={2.5} />
                    </button>
                  </div>

                  {comment.replies && comment.replies.map((reply) => (
                    <div key={reply._id} className="comment-reply-item">
                      <div style={{ display: 'flex', flex: 1, gap: '12px' }}>
                        <div className="reply-avatar">
                          {reply.authorName ? reply.authorName.charAt(0).toUpperCase() : 'R'}
                        </div>
                        <div className="comment-content-wrapper" style={{ flex: 1 }}>
                          <div className="comment-meta">
                            <span className="comment-author">{reply.authorName}</span>
                            <span className="comment-time">
                              {new Date(reply.createdAt).toLocaleString('vi-VN', { 
                                hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit' 
                              })}
                            </span>
                          </div>
                          <div className="comment-text reply-text">{reply.content}</div>
                        </div>
                      </div>
                      <button className="icon-btn delete-comment" title="Xóa phản hồi" onClick={() => handleDeleteComment(reply._id)}>
                        <Trash2 size={14} strokeWidth={2.5} />
                      </button>
                    </div>
                  ))}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    );
  }

  // ==========================================
  // VIEW 3: MÀN HÌNH ĐĂNG BÀI VIẾT MỚI TỪ BQT 
  // ==========================================
  return (
    <div className="community-editor-container">
      <div className="editor-header">
        <div className="editor-header-left">
          <button className="btn-back-editor" onClick={() => setCurrentView('list')}><ArrowLeft size={20} /></button>
          <div>
            <h3>Đăng bài viết mới từ Ban Quản Trị</h3>
            <span>Bài viết sẽ xuất hiện trực tiếp trên bảng tin Cộng đồng của tất cả các máy App</span>
          </div>
        </div>
        <button className="btn-save-primary" onClick={handleAdminPublish}><Plus size={18} /> Đăng lên App</button>
      </div>

      <div className="editor-layout-grid" style={{ gridTemplateColumns: '1fr' }}>
        <div className="editor-sidebar" style={{ width: '100%' }}>
          <div className="form-group">
            <label>Hình ảnh đính kèm bài đăng</label>
            <input type="file" ref={fileInputRef} style={{ display: 'none' }} accept="image/*" onChange={handleThumbnailChange} />
            <div className="image-upload-box" onClick={() => fileInputRef.current?.click()} style={{ height: '200px' }}>
              {thumbnailPreview ? (
                <img src={thumbnailPreview} alt="Preview" className="thumbnail-preview-img" style={{ objectFit: 'contain' }} />
              ) : (
                <>
                  <ImageIcon size={32} color="#cbd5e1" />
                  <p>Bấm vào đây để tải hình ảnh đính kèm (Lá bệnh, sâu bọ, thông báo...)</p>
                </>
              )}
            </div>
          </div>
          <div className="form-group">
            <label>Nội dung bài đăng thảo luận</label>
            <textarea 
              className="admin-post-textarea" 
              rows="6" 
              value={adminContent}
              onChange={(e) => setAdminContent(e.target.value)}
              placeholder="Nhập nội dung chia sẻ kỹ thuật, thông báo mùa vụ hoặc cảnh báo sâu bệnh đến mọi thành viên..."
            ></textarea>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CommunityManagementComponent;