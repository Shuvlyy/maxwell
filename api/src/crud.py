import uuid
import secrets
from datetime import datetime, timezone
from fastapi import HTTPException
from src.database import db_users, db_machines, db_bookings, SECRET_ACTIVATION_CODE, save_db
from src.models import RegisterRequest, BookingCreate, MachineStatusUpdate
from src.ws import manager
import re

def create_user(request: RegisterRequest):
    if request.activation_code != SECRET_ACTIVATION_CODE:
        raise HTTPException(status_code=403, detail="Wrong activation code.")

    user_id = f"usr_{uuid.uuid4().hex[:8]}"
    access_token = secrets.token_urlsafe(32)

    first_letter = request.first_name[0].lower() if request.first_name else ""
    last_name_clean = request.last_name.replace(" ", "").lower() if request.last_name else ""
    username = f"{first_letter}{last_name_clean}-{request.room_number}"

    if not re.match(r"^\d{4}$", request.room_number):
        raise HTTPException(status_code=400, detail="Room number must be exactly 4 digits.")

    if request.phone:
        phone_regex = r"^\+?[1-9]\d{1,14}(?:[\s.-]\d{1,13})*$"
        if not re.match(phone_regex, request.phone):
            raise HTTPException(status_code=400, detail="Invalid phone number format. Use international format (e.g., +33 7 67 30 51 05).")

    db_users[user_id] = {
        "id": user_id,
        "username": username,
        "first_name": request.first_name,
        "last_name": request.last_name,
        "room_number": request.room_number,
        "phone": request.phone,
        "access_token": access_token
    }

    save_db()

    return {"access_token": access_token, "token_type": "bearer", "user_id": user_id}

def login_user(request):
    user_id = None
    access_token = None

    for uid, user_data in db_users.items():
        if user_data.get("username") == request.username:
            user_id = uid
            access_token = user_data["access_token"]
            break

    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid password.")

    return {"access_token": access_token, "token_type": "bearer", "user_id": user_id}

def get_user_profile(user_id: str):
    user = db_users.get(user_id)
    if not user:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="User not found.")

    from datetime import timezone
    now = datetime.now(timezone.utc)

    upcoming = [
        b for b in db_bookings.values()
        if b["user_id"] == user_id and b["end_time"] > now
    ]

    return {
        "id": user["id"],
        "username": user["username"],
        "first_name": user["first_name"],
        "last_name": user["last_name"],
        "room_number": user["room_number"],
        "phone": user.get("phone"),
        "upcoming_bookings": upcoming
    }

def get_all_machines():
    return list(db_machines.values())

async def update_machine_status(machine_id: str, update_data: MachineStatusUpdate):
    if machine_id not in db_machines:
        raise HTTPException(status_code=404, detail="Unknown machine.")
    db_machines[machine_id]["status"] = update_data.status
    await manager.broadcast({"type": "machines_updated"})
    save_db()
    return db_machines[machine_id]

async def create_booking(user_id: str, booking: BookingCreate):
    if booking.machine_id not in db_machines:
        raise HTTPException(status_code=404, detail="Unknown machine.")

    if booking.start_time < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Bookings can't be in the past lol")

    for existing in db_bookings.values():
        if existing["machine_id"] == booking.machine_id:
            if max(booking.start_time, existing["start_time"]) < min(booking.end_time, existing["end_time"]):
                raise HTTPException(status_code=409, detail="This timeslot has already been taken.")

    booking_id = f"bk_{uuid.uuid4().hex[:8]}"
    db_bookings[booking_id] = {
        "id": booking_id,
        "user_id": user_id,
        "machine_id": booking.machine_id,
        "start_time": booking.start_time,
        "end_time": booking.end_time
    }
    await manager.broadcast({"type": "bookings_updated"})

    save_db()

    return {"id": booking_id, "status": "confirmed"}

def get_bookings(machine_id: str = None, date: str = None):
    results = []
    for b in db_bookings.values():
        if machine_id and b["machine_id"] != machine_id:
            continue

        # todo: don't include bookings that are older than timestamp(NOW)

        user = db_users.get(b["user_id"])

        results.append({
            "id": b["id"],
            "machine_id": b["machine_id"],
            "start_time": b["start_time"],
            "end_time": b["end_time"],
            "user": {
                "first_name": user["first_name"] if user else "Unknown",
                "last_name": user["last_name"] if user else "",
                "room_number": user["room_number"] if user else "?",
                "phone": user.get("phone")
            }
        })
    return results

async def delete_booking(user_id: str, booking_id: str):
    booking = db_bookings.get(booking_id)
    if not booking:
        raise HTTPException(status_code=404, detail="Unknown booking.")
    if booking["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="You can only cancel your own bookings.")

    del db_bookings[booking_id]
    await manager.broadcast({"type": "bookings_updated"})
    save_db()
    return True

async def update_booking(user_id: str, booking_id: str, booking: BookingCreate):
    if booking_id not in db_bookings:
        raise HTTPException(status_code=404, detail="Unknown booking.")

    existing = db_bookings[booking_id]
    if existing["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="You can only edit your own bookings.")

    if booking.start_time < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Bookings can't be in the past lol")

    for bid, b in db_bookings.items():
        if bid == booking_id: continue
        if b["machine_id"] == booking.machine_id:
            if max(booking.start_time, b["start_time"]) < min(booking.end_time, b["end_time"]):
                raise HTTPException(status_code=409, detail="This timeslot has already been taken.")

    db_bookings[booking_id].update({
        "start_time": booking.start_time,
        "end_time": booking.end_time
    })

    await manager.broadcast({"type": "bookings_updated"})
    save_db()
    return {"id": booking_id, "status": "updated"}
