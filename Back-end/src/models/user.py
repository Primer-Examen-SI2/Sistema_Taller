from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from src.core.database import Base


class User(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), nullable=False, unique=True)
    password = Column(String(255), nullable=False)
    correo = Column(String(150), nullable=False, unique=True)
    telefono = Column(String(20), nullable=True)

    # llave foránea
    rol_id = Column(Integer, ForeignKey("roles.id"), nullable=False)

    # muchos usuarios pertenecen a un rol
    rol = relationship("Role", back_populates="usuarios")