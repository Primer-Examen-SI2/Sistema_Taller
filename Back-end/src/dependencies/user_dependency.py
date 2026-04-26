from fastapi import Depends
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.repositories.user_repository import UserRepository
from src.services.user_service import UserService


def get_user_repository(db: Session = Depends(get_db)):
    return UserRepository(db)

def get_user_service(repo: UserRepository = Depends(get_user_repository)):
    return UserService(repo)