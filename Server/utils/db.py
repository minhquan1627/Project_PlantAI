from pymongo import MongoClient, errors
from mongoengine import connect
from motor.motor_asyncio import AsyncIOMotorClient
from .my_constants import MyConstants
from urllib.parse import quote_plus
from dotenv import load_dotenv
load_dotenv()


# --------------------------
# Global URI (từ MyConstants)
# --------------------------
MONGO_URI = f"mongodb+srv://{MyConstants.DB_USER}:{MyConstants.DB_PASS}@{MyConstants.DB_SERVER}/{MyConstants.DB_DATABASE}?retryWrites=true&w=majority"

# --------------------------
# PYMONGO - Sync
# --------------------------
def get_db():
    try:
        client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
        client.server_info()
        print(" Kết nối MongoDB (pymongo) thành công!")
        return client[MyConstants.DB_DATABASE]
    except errors.ServerSelectionTimeoutError as err:
        print(" Lỗi pymongo:", err)
        return None
    except Exception as e:
        print(" Lỗi pymongo không xác định:", e)
        return None

# --------------------------
# MONGOENGINE - ODM
# --------------------------
def connect_mongoengine():
    try:
        connect(
            db=MyConstants.DB_DATABASE,
            host=MONGO_URI,
            alias='default'
        )
        print(" Kết nối MongoEngine thành công!")
    except Exception as e:
        print(" Kết nối MongoEngine thất bại:", e)
        return None

# --------------------------
# MOTOR - Async client
# --------------------------
_motor_client = None

async def get_async_db():
    global _motor_client

    if _motor_client is None:
        try:
            _motor_client = AsyncIOMotorClient(MONGO_URI, serverSelectionTimeoutMS=5000)
            await _motor_client.server_info()
            print(" Kết nối MongoDB (motor async) thành công!")
        except errors.ServerSelectionTimeoutError as err:
            print(" Kết nối MongoDB (motor async) thất bại:", err)
            return None
        except Exception as e:
            print(" Lỗi motor async:", e)
            return None

    return _motor_client[MyConstants.DB_DATABASE]