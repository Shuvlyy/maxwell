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

SECRET_ACTIVATION_CODE = "HILOL"
