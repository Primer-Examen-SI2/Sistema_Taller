from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from src.core.database import get_db
from src.core.security import decode_access_token
from src.repositories.user_repository import UserRepository
from src.schemas.auth_schema import TokenData

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
    
    username: str = payload.get("sub")
    if username is None:
        raise credentials_exception
    
    token_data = TokenData(username=username)
    
    repo = UserRepository(db)
    user = repo.get_by_username(username=token_data.username)
    if user is None:
        raise credentials_exception
    
    return user