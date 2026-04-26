from fastapi import APIRouter, Depends, status
from typing import List
from src.schemas.user_schema import UserCreate, UserResponse
from src.services.user_service import UserService
from src.dependencies.user_dependency import get_user_service
from src.dependencies.role_checker import RoleChecker
from src.dependencies.auth_dependency import get_current_user
from src.models.user import User

router = APIRouter(prefix="/users", tags=["Usuarios"])


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(
    user_in: UserCreate, 
    service: UserService = Depends(get_user_service)
):
    return service.create_user(user_in)


@router.get("/", response_model=List[UserResponse])
def get_users(
    service: UserService = Depends(get_user_service),
    current_user: User = Depends(RoleChecker(["ADMIN", "USER"]))
):
    return service.list_users()


@router.get("/me", response_model=UserResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    return current_user


@router.get("/admin-only", response_model=dict)
def admin_only_endpoint(
    current_user: User = Depends(RoleChecker(["ADMIN"]))
):
    return {
        "message": "Acceso exclusivo para administradores",
        "user": current_user.username,
        "rol": current_user.rol.nombre
    }