from fastapi import Depends, HTTPException, status
from typing import List
from src.models.user import User
from src.dependencies.auth_dependency import get_current_user


class RoleChecker:
    def __init__(self, allowed_roles: List[str]):
        self.allowed_roles = allowed_roles

    def __call__(self, current_user: User = Depends(get_current_user)):
        if current_user.rol.nombre not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Rol no autorizado. Se requiere uno de: {', '.join(self.allowed_roles)}"
            )
        return current_user