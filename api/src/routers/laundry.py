from typing import List, Optional
from fastapi import APIRouter, Depends, status
from src import crud
from src.models import MachineResponse, MachineStatusUpdate, BookingCreate, BookingConfirmed, BookingResponse
from src.dependencies import get_current_user

router = APIRouter(prefix="/api", tags=["Laundry"])

@router.get("/machines", response_model=List[MachineResponse])
def read_machines(current_user: dict = Depends(get_current_user)):
    return crud.get_all_machines()

@router.patch("/machines/{machine_id}/status", response_model=MachineResponse)
async def update_machine(machine_id: str, status_data: MachineStatusUpdate, current_user: dict = Depends(get_current_user)):
    return await crud.update_machine_status(machine_id, status_data)

@router.get("/bookings", response_model=List[BookingResponse])
def read_bookings(machine_id: Optional[str] = None, date: Optional[str] = None, current_user: dict = Depends(get_current_user)):
    return crud.get_bookings(machine_id, date)

@router.post("/bookings", response_model=BookingConfirmed, status_code=status.HTTP_201_CREATED)
async def create_new_booking(booking: BookingCreate, current_user: dict = Depends(get_current_user)):
    return await crud.create_booking(current_user["id"], booking)

@router.delete("/bookings/{booking_id}", status_code=status.HTTP_204_NO_CONTENT)
async def cancel_booking(booking_id: str, current_user: dict = Depends(get_current_user)):
    await crud.delete_booking(current_user["id"], booking_id)

@router.patch("/bookings/{booking_id}", response_model=BookingConfirmed)
async def edit_booking(booking_id: str, booking: BookingCreate, current_user: dict = Depends(get_current_user)):
    return await crud.update_booking(current_user["id"], booking_id, booking)
