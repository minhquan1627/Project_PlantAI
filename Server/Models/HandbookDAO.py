from Models.Models import Handbook
import cloudinary.uploader
from bson import ObjectId # Bắt buộc phải có cái này để truy vấn ID

class HandbookDAO:
    @staticmethod
    def save_handbook(data):
        try:
            handbook_id = data.get('id') or data.get('_id')
            image_url = data.get('image', "")
            
            # XỬ LÝ ẢNH CLOUDINARY
            if image_url.startswith("data:image"):
                upload_result = cloudinary.uploader.upload(
                    image_url,
                    folder="plantai/handbooks" 
                )
                image_url = upload_result.get("secure_url")

            if handbook_id:
                # 1. LOGIC CẬP NHẬT BÀI VIẾT CŨ
                handbook = Handbook.objects(id=ObjectId(handbook_id)).first()
                if handbook:
                    handbook.update(
                        title=data.get('title', handbook.title),
                        category=data.get('category', handbook.category),
                        summary=data.get('summary', handbook.summary),
                        content=data.get('content', handbook.content),
                        # Nếu không có ảnh mới (image_url rỗng) thì giữ nguyên ảnh cũ
                        image=image_url if image_url else handbook.image,
                        status=data.get('status', handbook.status),
                        isPinned=data.get('isPinned', handbook.isPinned)
                    )
                    return True, "Cập nhật cẩm nang thành công!"
                return False, "Không tìm thấy bài viết để cập nhật"
            
            else:
                # 2. LOGIC THÊM MỚI BÀI VIẾT
                new_handbook = Handbook(
                    title=data.get('title'),
                    category=data.get('category'),
                    summary=data.get('summary'),
                    content=data.get('content'),
                    image=image_url,
                    status=data.get('status', 'Visible'),
                    isPinned=data.get('isPinned', False)
                )
                new_handbook.save()
                return True, "Xuất bản cẩm nang thành công!"

        except Exception as e:
            import traceback
            print(f" Lỗi lưu Cẩm nang: {traceback.format_exc()}")
            return False, str(e)
        
    @staticmethod
    def get_all_handbooks():
        try:
            # Lấy toàn bộ, sắp xếp Ghim lên trước, bài mới lên trước
            handbooks = Handbook.objects().order_by('-isPinned', '-publishDate')
            result = []
            
            for h in handbooks:
                result.append({
                    "_id": str(h.id), # Thêm _id để React dễ bắt
                    "id": str(h.id),
                    "title": getattr(h, 'title', "Chưa có tiêu đề"),
                    "category": getattr(h, 'category', "Chưa cập nhật"),
                    "summary": getattr(h, 'summary', ""),
                    "content": getattr(h, 'content', ""), 
                    "image": getattr(h, 'image', ""),
                    "status": getattr(h, 'status', "Visible"),
                    "isPinned": getattr(h, 'isPinned', False),
                    "views": getattr(h, 'views', 0),
                    "publishDate": h.publishDate.strftime("%d/%m/%Y") if getattr(h, 'publishDate', None) else ""
                })
            return result
        except Exception as e:
            import traceback
            print(f" Lỗi lấy danh sách cẩm nang: {traceback.format_exc()}")
            return []
        
    @staticmethod
    def get_total_handbook():
        try:
            return Handbook.objects.count()
        except Exception as e:
            print(f" LỖI đếm số lượng handbook: {e}")
            return 0 

    # 👉 THÊM HÀM XÓA BÀI VIẾT
    @staticmethod
    def delete_handbook(handbook_id):
        try:
            handbook = Handbook.objects(id=ObjectId(handbook_id)).first()
            if handbook:
                handbook.delete()
                return True, "Đã xóa bài viết cẩm nang!"
            return False, "Không tìm thấy bài viết để xóa!"
        except Exception as e:
            return False, str(e)
        
    @staticmethod
    def get_handbook_by_id(handbook_id):
        try:
            h = Handbook.objects(id=ObjectId(handbook_id)).first()
            if h:
                return {
                    "id": str(h.id),
                    "title": getattr(h, 'title', ""),
                    "category": getattr(h, 'category', ""),
                    "summary": getattr(h, 'summary', ""),
                    "content": getattr(h, 'content', ""), 
                    "image": getattr(h, 'image', ""),
                    "publishDate": h.publishDate.strftime("%d/%m/%Y") if getattr(h, 'publishDate', None) else ""
                }
            return None
        except Exception as e:
            print(f"Lỗi lấy chi tiết cẩm nang: {e}")
            return None