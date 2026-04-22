from Models.Models import Handbook
import cloudinary.uploader

class HandbookDAO:
    @staticmethod
    def save_handbook(data):
        try:
            image_url = data.get('image', "")
            
            # 👉 XỬ LÝ ẢNH CLOUDINARY (Y hệt phần Disease)
            if image_url.startswith("data:image"):
                upload_result = cloudinary.uploader.upload(
                    image_url,
                    folder="plantai/handbooks" 
                )
                image_url = upload_result.get("secure_url")

            # 👉 THÊM MỚI BÀI VIẾT (Tạm thời làm Insert trước)
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
            print(f"❌ Lỗi lưu Cẩm nang: {traceback.format_exc()}")
            return False, str(e)
        
    @staticmethod
    def get_all_handbooks():
        try:
            # Lấy toàn bộ, sắp xếp Ghim lên trước, bài mới lên trước
            handbooks = Handbook.objects().order_by('-isPinned', '-publishDate')
            result = []
            
            for h in handbooks:
                result.append({
                    "id": str(h.id),
                    "title": getattr(h, 'title', "Chưa có tiêu đề"),
                    "category": getattr(h, 'category', "Chưa cập nhật"),
                    "summary": getattr(h, 'summary', ""),
                    "content": getattr(h, 'content', ""), # Lấy cả nội dung HTML để lát nữa bấm Sửa bài
                    "image": getattr(h, 'image', ""),
                    "status": getattr(h, 'status', "Visible"),
                    "isPinned": getattr(h, 'isPinned', False),
                    "views": getattr(h, 'views', 0),
                    # Đổi ngày giờ thành format dd/mm/yyyy
                    "publishDate": h.publishDate.strftime("%d/%m/%Y") if getattr(h, 'publishDate', None) else ""
                })
            return result
        except Exception as e:
            import traceback
            print(f"❌ Lỗi lấy danh sách cẩm nang: {traceback.format_exc()}")
            return []
        
    @staticmethod
    def get_total_handbook():
        try:
            # Chỉ làm đúng 1 việc: Đếm tổng số bệnh có trong Database
            return Handbook.objects.count()
        except Exception as e:
            print(f"LỖI đếm số lượng handbook: {e}")
            return 0 # Nếu lỗi thì trả về 0 cho an toàn