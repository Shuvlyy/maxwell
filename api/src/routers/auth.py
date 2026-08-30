from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from src import crud
from src.models import RegisterRequest, TokenResponse, UserMeResponse
from src.dependencies import get_current_user

router = APIRouter(prefix="/api/auth", tags=["Authentication"])

class LoginRequest(BaseModel):
    username: str
    password: str

@router.post("/register", response_model=TokenResponse, status_code=201)
def register(request: RegisterRequest):
    return crud.create_user(request)

@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest):
    return crud.login_user(request)

@router.get("/me", response_model=UserMeResponse)
def get_me(current_user: dict = Depends(get_current_user)):
    return crud.get_user_profile(current_user["id"])
