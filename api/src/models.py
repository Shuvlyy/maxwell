from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from datetime import datetime

class RegisterRequest(BaseModel):
    activation_code: str
    first_name: str
    last_name: str
    room_number: str
    password: str
    phone: Optional[str] = None

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str

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
    model_config = ConfigDict(from_attributes=True)

class BookingResponse(BaseModel):
    id: str
    machine_id: str
    user: BookingUser
    start_time: datetime
    end_time: datetime
    model_config = ConfigDict(from_attributes=True)

class BookingShort(BaseModel):
    id: str
    machine_id: str
    start_time: datetime
    end_time: datetime
    model_config = ConfigDict(from_attributes=True)

class BookingConfirmed(BaseModel):
    id: str
    status: str = "confirmed"

class UserMeResponse(BaseModel):
    id: str
    username: str
    first_name: str
    last_name: str
    room_number: str
    phone: Optional[str] = None
    upcoming_bookings: List[BookingShort] = []
    model_config = ConfigDict(from_attributes=True)

class MachineResponse(BaseModel):
    id: str
    type: str
    status: str
    note: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class MachineStatusUpdate(BaseModel):
    status: str
    note: Optional[str] = None
