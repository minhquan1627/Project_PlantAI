from mongoengine import (
    Document, EmbeddedDocument, StringField, IntField, FloatField, 
    EmbeddedDocumentField, ListField, EmailField, DateTimeField,
    ObjectIdField, ReferenceField, BooleanField, DictField
)

from datetime import datetime


# Database thiết kế của Admin
class Admin(Document):
    _id = ObjectIdField(primary_key=True, db_field='_id')
    email = StringField(required=True, unique=True)
    phone = StringField(default="Chưa cập nhật")
    username = StringField(required=True)
    password = StringField(required=True)
    token = StringField(required=False)

    avatar = StringField(default="")
    is_locked = BooleanField(default=False)
    role = StringField(default="1")
    is_verified = BooleanField(default=False)
    check_account = BooleanField(default=False)
    created_at = DateTimeField(default=datetime.now)

    meta = {'collection': 'admins', 'ordering': ['username'], 'strict': False}

# Database thiết kế của người dùng
class User(Document):
    name = StringField(required=True)
    email = EmailField(required=True, unique=True)
    password = StringField(required=True)
    # default giúp DB tự điền nếu ông không truyền vào lúc tạo user
    location = StringField(default="Chưa cập nhật") 
    avatar = StringField(default="")
    is_locked = BooleanField(default=False)
    createdAt = DateTimeField(default=datetime.now)

    meta = {'collection': 'users', 'strict': False}


# Database thiết kế của thông tin bệnh
class DiseaseContent(EmbeddedDocument):
    overview = StringField(default="")
    symptoms = StringField(default="")
    causes = StringField(default="")
    prevention = StringField(default="")
    treatment = StringField(default="")

class Disease(Document):
    # Dùng _id tự sinh của MongoDB hoặc tự định nghĩa như Admin
    name = StringField(required=True)
    scientificName = StringField(default="Chưa cập nhật")

    affected_plant = StringField(default="Chưa cập nhật")
    incubation_time = StringField(default="Chưa cập nhật") 
    outbreak_season = StringField(default="Chưa cập nhật") 
    danger_level = StringField(default="Chưa cập nhật")

    status = StringField(default="Visible") # "Visible" | "Hidden"
    image = StringField(default="")
    
    # Chứa 5 phần nội dung chi tiết
    content = EmbeddedDocumentField(DiseaseContent, default=DiseaseContent)
    
    updatedAt = DateTimeField(default=datetime.now)

    meta = {
        'collection': 'diseases',
        'ordering': ['-updatedAt'],
        'strict': False
    }

class Handbook(Document):
    title = StringField(required=True)
    category = StringField(required=True)
    summary = StringField(default="")
    content = StringField(default="") # Chứa HTML của khung soạn thảo
    image = StringField(default="")   # Chứa link Cloudinary
    status = StringField(default="Visible")
    isPinned = BooleanField(default=False)
    views = IntField(default=0)
    publishDate = DateTimeField(default=datetime.now)

    meta = {
        'collection': 'handbooks',
        'ordering': ['-isPinned', '-publishDate'], # Ưu tiên bài Ghim lên trước, sau đó là bài mới nhất
        'strict': False
    }

class Comment(Document):
    postId = ObjectIdField(required=True)  # DB là ObjectId
    text = StringField(required=True)      # DB là text
    authorData = DictField()               # DB lưu nguyên 1 object authorData
    likes = ListField(default=list) 
    createdAt = StringField()              # 👉 SỬA: DB đang lưu String, không phải DateTime
    replyToId = ObjectIdField(null=True)   # DB là ObjectId hoặc null

    meta = {
        'collection': 'comments', # Đã khớp ảnh 2
        'strict': False
    }

# Database thiết kế cho Bài đăng (Post)
class CommunityPost(Document):
    authorId = ObjectIdField(required=True) # DB là ObjectId
    content = StringField(required=True)
    imageUrl = StringField(default=None, null=True)
    
    likes = ListField(default=list) 
    commentsCount = IntField(default=0)
    sharesCount = IntField(default=0) 
    
    createdAt = StringField()               # 👉 SỬA: DB đang lưu String
    
    # Các trường phục vụ Admin Web (DB chưa có thì nó sẽ lấy default)
    status = StringField(default="Visible")
    isPinned = BooleanField(default=False)

    meta = {
        'collection': 'posts', # 👉 SỬA: Đã khớp với ảnh 1 của ông
        'ordering': ['-isPinned', '-createdAt'], 
        'strict': False
    }