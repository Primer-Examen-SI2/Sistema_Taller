from fastapi import HTTPException, status
from src.models.user import User
from src.repositories.user_repository import UserRepository
from src.schemas.user_schema import UserCreate
from src.core.security import verify_password, get_password_hash


class UserService:
    def __init__(self, repo: UserRepository):
        self.repo = repo

    def authenticate_user(self, username: str, password: str):
        user = self.repo.get_by_username(username)
        if not user:
            return None
        if not verify_password(password, user.password):
            return None
        return user

    def create_user(self, user_data: UserCreate):
        if self.repo.get_by_correo(user_data.correo):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El correo ya está registrado"
            )
        
        if self.repo.get_by_username(user_data.username):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El nombre de usuario ya está en uso"
            )

        new_user = User(
            username=user_data.username,
            password=get_password_hash(user_data.password),
            correo=user_data.correo,
            telefono=user_data.telefono,
            rol_id=user_data.rol_id
        )

        try:
            created_user = self.repo.create(new_user)
            self.repo.db.commit()
            self.repo.db.refresh(created_user)
            return created_user
        except Exception as e:
            self.repo.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error interno al crear el usuario"
            )
    
    def list_users(self):
        return self.repo.list()