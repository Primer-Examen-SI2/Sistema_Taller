from pydantic import BaseModel, EmailStr
from typing import Optional


class UserCreate(BaseModel):
    username: str
    password: str
    correo: EmailStr
    telefono: Optional[str] = None
    rol_id: int


class UserResponse(BaseModel):
    id: int
    username: str
    correo: EmailStr
    telefono: Optional[str]
    rol_id: int

    class Config:
        from_attributes = True # Permite convertir modelos de SQLAlchemy a Pydantic