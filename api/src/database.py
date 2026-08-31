import json
import os
from datetime import datetime
from dotenv import load_dotenv
import sys

load_dotenv()

DB_FILE = "database.json"

db_users = {}
db_bookings = {}
db_machines = {
    "machine_dryer_1": {
        "id": "machine_dryer_1",
        "type": "dryer",
        "status": "available",
        "current_user_id": None,
        "next_booking": None
    },
    "machine_washer_1": {
        "id": "machine_washer_1",
        "type": "washer",
        "status": "available",
        "current_user_id": None,
        "next_booking": None
    }
}

SECRET_ACTIVATION_CODE = os.getenv("SECRET_ACTIVATION_CODE")

if SECRET_ACTIVATION_CODE is None or len(SECRET_ACTIVATION_CODE) == 0:
    print("Secret activation code (SECRET_CODE) has not been found in the .env file. Please provide it.")
    sys.exit(1)

def custom_serializer(obj):
    if isinstance(obj, datetime):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} non sérialisable")

def load_db():
    global db_users, db_bookings, db_machines
    if os.path.exists(DB_FILE):
        with open(DB_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            db_users.update(data.get("users", {}))

            loaded_bookings = data.get("bookings", {})
            for b_id, b in loaded_bookings.items():
                b["start_time"] = datetime.fromisoformat(b["start_time"])
                b["end_time"] = datetime.fromisoformat(b["end_time"])
            db_bookings.update(loaded_bookings)

            if "machines" in data:
                db_machines.update(data["machines"])

def save_db():
    with open(DB_FILE, "w", encoding="utf-8") as f:
        json.dump({
            "users": db_users,
            "bookings": db_bookings,
            "machines": db_machines
        }, f, default=custom_serializer, indent=4)

load_db()
