import os
from dotenv import load_dotenv

# Load .env ngay khi file được import
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../.env'))

class MyConstants:
    DB_USER = os.getenv("DB_USER")
    DB_PASS = os.getenv("DB_PASS")
    DB_SERVER = os.getenv("DB_SERVER")
    DB_DATABASE = os.getenv("DB_NAME")

    JWT_SECRET = os.getenv("JWT_SECRET")
    JWT_EXPIRES = int(os.getenv("JWT_EXPIRES", "86400000"))