from typing import Optional, List
from pydantic import BaseModel
from datetime import datetime

class RegisterRequest(BaseModel):
    activation_code: str
    first_name: str
    last_name: str
    room_number: str
    phone: Optional[str] = None

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str

# bookings
class BookingBase(BaseModel):
    machine_id: str
    start_time: datetime
    end_time: datetime

class BookingCreate(BookingBase):
    pass

class BookingUser(BaseModel):
    first_name: str
    last_name: str
    room_number: str
    phone: Optional[str] = None

class BookingResponse(BaseModel):
    id: str
    machine_id: str
    user: BookingUser
    start_time: datetime
    end_time: datetime

class BookingShort(BaseModel):
    id: str
    machine_id: str
    start_time: datetime
    end_time: datetime

class BookingConfirmed(BaseModel):
    id: str
    status: str = "confirmed"

# user
class UserMeResponse(BaseModel):
    id: str
    username: str
    first_name: str
    last_name: str
    room_number: str
    phone: Optional[str] = None
    upcoming_bookings: List[BookingShort] = []

# machines

# todo: enums for type & status?
class MachineResponse(BaseModel):
    id: str
    type: str # "washer" or "dryer"
    status: str # "available", "running", "out_of_order"
    current_user_id: Optional[str] = None
    next_booking: Optional[datetime] = None

class MachineStatusUpdate(BaseModel):
    status: str
    note: Optional[str] = None
