from Models import Disease, DiseaseContent
from datetime import datetime
from bson import ObjectId

class DiseaseDAO:
    @staticmethod
    def save_disease(data):
        try:
            disease_id = data.get('id')
            
            # Chuẩn bị nội dung 5 tab từ frontend gửi lên
            content_data = data.get('content', {})
            content_obj = DiseaseContent(
                overview=content_data.get('overview', ""),
                symptoms=content_data.get('symptoms', ""),
                causes=content_data.get('causes', ""),
                prevention=content_data.get('prevention', ""),
                treatment=content_data.get('treatment', "")
            )

            if disease_id:
                # Logic CẬP NHẬT (Sửa bài)
                disease = Disease.objects(id=ObjectId(disease_id)).first()
                if disease:
                    disease.update(
                        name=data.get('name'),
                        scientificName=data.get('scientificName'),
                        affected_plant=data.get('affected_plant', "Chưa cập nhật"),
                        stage=data.get('stage'),
                        part=data.get('part'),
                        status=data.get('status', 'Visible'),
                        image=data.get('image', ""),
                        content=content_obj,
                        updatedAt=datetime.now()
                    )
                    return True, "Cập nhật thành công!"
            else:
                # Logic THÊM MỚI
                new_disease = Disease(
                    name=data.get('name'),
                    scientificName=data.get('scientificName'),
                    affected_plant=data.get('affected_plant', "Chưa cập nhật"),
                    stage=data.get('stage'),
                    part=data.get('part'),
                    status=data.get('status', 'Visible'),
                    image=data.get('image', ""),
                    content=content_obj
                )
                new_disease.save()
                return True, "Thêm bệnh mới thành công!"
                
            return False, "Không tìm thấy dữ liệu"
        except Exception as e:
            return False, str(e)
        
    @staticmethod
    def get_all_diseases():
        try:
            diseases = Disease.objects().order_by('-updatedAt')
            result = []
            
            for d in diseases:
                # Trích xuất content an toàn (Nếu không có thì mặc định là None)
                content_obj = getattr(d, 'content', None)
                
                result.append({
                    "id": str(d.id),
                    "name": getattr(d, 'name', "Chưa có tên"),
                    "scientificName": getattr(d, 'scientificName', "Chưa cập nhật"),
                    "affected_plant": getattr(d, 'affected_plant', "Chưa cập nhật"),
                    "stage": getattr(d, 'stage', "Chưa cập nhật"),
                    "part": getattr(d, 'part', "Chưa cập nhật"),
                    "status": getattr(d, 'status', "Visible"),
                    "image": getattr(d, 'image', ""),
                    "updatedAt": d.updatedAt.strftime("%d/%m/%Y") if getattr(d, 'updatedAt', None) else "",
                    
                    # 👉 Lấy 5 tab an toàn: Có content thì lấy, không thì để chuỗi rỗng ""
                    "content": {
                        "overview": getattr(content_obj, 'overview', "") if content_obj else "",
                        "symptoms": getattr(content_obj, 'symptoms', "") if content_obj else "",
                        "causes": getattr(content_obj, 'causes', "") if content_obj else "",
                        "prevention": getattr(content_obj, 'prevention', "") if content_obj else "",
                        "treatment": getattr(content_obj, 'treatment', "") if content_obj else ""
                    }
                })
            return result
        except Exception as e:
            import traceback
            print(f"❌ Lỗi DAO (get_all_diseases): {traceback.format_exc()}")
            raise e # Ném lỗi ra ngoài để API UserAPI hứng và báo 500
        
    @staticmethod
    def get_total_diseases():
        try:
            # Chỉ làm đúng 1 việc: Đếm tổng số bệnh có trong Database
            return Disease.objects.count()
        except Exception as e:
            print(f"❌ Lỗi đếm số lượng bệnh: {e}")
            return 0 # Nếu lỗi thì trả về 0 cho an toàn