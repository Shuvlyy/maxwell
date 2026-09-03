import secrets
import hashlib
import re
from datetime import datetime, timezone
from fastapi import HTTPException
from sqlalchemy.orm import Session
from src.database import SECRET_ACTIVATION_CODE
from src.db_models import User, Machine, Booking
from src.models import RegisterRequest, BookingCreate, MachineStatusUpdate
from src.ws import manager

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

def create_user(db: Session, request: RegisterRequest):
    if request.activation_code != SECRET_ACTIVATION_CODE:
        raise HTTPException(status_code=403, detail="Wrong activation code.")

    first_letter = request.first_name[0].lower() if request.first_name else ""
    last_name_clean = request.last_name.replace(" ", "").lower() if request.last_name else ""
    username = f"{first_letter}{last_name_clean}-{request.room_number}"

    if db.query(User).filter(User.username == username).first():
        raise HTTPException(status_code=400, detail="User already exists for this room.")

    if not re.match(r"^\d{4}$", request.room_number):
        raise HTTPException(status_code=400, detail="Room number must be exactly 4 digits.")

    if request.phone:
        phone_regex = r"^\+?[1-9]\d{1,14}(?:[\s.-]\d{1,13})*$"
        if not re.match(phone_regex, request.phone):
            raise HTTPException(status_code=400, detail="Invalid phone number format.")

    new_user = User(
        username=username,
        password_hash=hash_password(request.password),
        first_name=request.first_name,
        last_name=request.last_name,
        room_number=request.room_number,
        phone=request.phone,
        access_token=secrets.token_urlsafe(32)
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"access_token": new_user.access_token, "token_type": "bearer", "user_id": new_user.id}

def login_user(db: Session, request):
    user = db.query(User).filter(User.username == request.username).first()
    if not user or user.password_hash != hash_password(request.password):
        raise HTTPException(status_code=401, detail="Invalid username or password.")
    return {"access_token": user.access_token, "token_type": "bearer", "user_id": user.id}

def get_user_profile(db: Session, user: User):
    now = datetime.now(timezone.utc)
    upcoming = db.query(Booking).filter(
        Booking.user_id == user.id,
        Booking.end_time > now
    ).all()

    return {
        "id": user.id,
        "username": user.username,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "room_number": user.room_number,
        "phone": user.phone,
        "upcoming_bookings": upcoming
    }

def get_all_machines(db: Session):
    return db.query(Machine).all()

async def update_machine_status(db: Session, machine_id: str, update_data: MachineStatusUpdate):
    machine = db.query(Machine).filter(Machine.id == machine_id).first()
    if not machine:
        raise HTTPException(status_code=404, detail="Unknown machine.")

    machine.status = update_data.status
    machine.note = update_data.note
    db.commit()
    db.refresh(machine)

    await manager.broadcast({"type": "machines_updated"})
    return machine

async def create_booking(db: Session, user_id: str, booking: BookingCreate):
    machine = db.query(Machine).filter(Machine.id == booking.machine_id).first()
    if not machine:
        raise HTTPException(status_code=404, detail="Unknown machine.")

    if booking.start_time < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Bookings can't be in the past lol")

    overlap = db.query(Booking).filter(
        Booking.machine_id == booking.machine_id,
        Booking.start_time < booking.end_time,
        Booking.end_time > booking.start_time
    ).first()

    if overlap:
        raise HTTPException(status_code=409, detail="This timeslot has already been taken.")

    new_booking = Booking(
        user_id=user_id,
        machine_id=booking.machine_id,
        start_time=booking.start_time,
        end_time=booking.end_time
    )
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)

    await manager.broadcast({"type": "bookings_updated"})
    return {"id": new_booking.id, "status": "confirmed"}

def get_bookings(db: Session, machine_id: str = None):
    now = datetime.now(timezone.utc)
    query = db.query(Booking).filter(Booking.end_time >= now)

    if machine_id:
        query = query.filter(Booking.machine_id == machine_id)
    return query.all()

async def delete_booking(db: Session, user_id: str, booking_id: str):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Unknown booking.")
    if booking.user_id != user_id:
        raise HTTPException(status_code=403, detail="You can only cancel your own bookings.")

    db.delete(booking)
    db.commit()
    await manager.broadcast({"type": "bookings_updated"})
    return True

async def update_booking(db: Session, user_id: str, booking_id: str, new_booking: BookingCreate):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Unknown booking.")
    if booking.user_id != user_id:
        raise HTTPException(status_code=403, detail="You can only edit your own bookings.")
    if new_booking.start_time < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Bookings can't be in the past lol")

    overlap = db.query(Booking).filter(
        Booking.id != booking_id,
        Booking.machine_id == new_booking.machine_id,
        Booking.start_time < new_booking.end_time,
        Booking.end_time > new_booking.start_time
    ).first()

    if overlap:
        raise HTTPException(status_code=409, detail="This timeslot has already been taken.")

    booking.start_time = new_booking.start_time
    booking.end_time = new_booking.end_time
    db.commit()

    await manager.broadcast({"type": "bookings_updated"})
    return {"id": booking_id, "status": "updated"}
