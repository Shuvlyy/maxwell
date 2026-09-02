import uuid
import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, TypeDecorator
from sqlalchemy.orm import relationship
from src.database import Base

def generate_id(prefix: str):
    return f"{prefix}_{uuid.uuid4().hex[:8]}"

class UTCDateTime(TypeDecorator):
    impl = DateTime
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is not None:
            if value.tzinfo is None:
                value = value.replace(tzinfo=datetime.timezone.utc)
            return value.astimezone(datetime.timezone.utc).replace(tzinfo=None)
        return value

    def process_result_value(self, value, dialect):
        if value is not None:
            return value.replace(tzinfo=datetime.timezone.utc)
        return value

class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True, default=lambda: generate_id("usr"))
    username = Column(String, unique=True, index=True)
    password_hash = Column(String)
    first_name = Column(String)
    last_name = Column(String)
    room_number = Column(String)
    phone = Column(String, nullable=True)
    access_token = Column(String, unique=True, index=True)

    bookings = relationship("Booking", back_populates="user", cascade="all, delete-orphan")

class Machine(Base):
    __tablename__ = "machines"
    id = Column(String, primary_key=True)
    type = Column(String)
    status = Column(String)
    note = Column(String, nullable=True)

    bookings = relationship("Booking", back_populates="machine", cascade="all, delete-orphan")

class Booking(Base):
    __tablename__ = "bookings"
    id = Column(String, primary_key=True, default=lambda: generate_id("bk"))
    user_id = Column(String, ForeignKey("users.id"))
    machine_id = Column(String, ForeignKey("machines.id"))

    start_time = Column(UTCDateTime)
    end_time = Column(UTCDateTime)

    user = relationship("User", back_populates="bookings")
    machine = relationship("Machine", back_populates="bookings")
