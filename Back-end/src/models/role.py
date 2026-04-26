from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from src.core.database import Base


class Role(Base):
    __tablename__ = "roles"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(50), nullable=False, unique=True)

    # un rol tiene muchos usuarios
    usuarios = relationship("User", back_populates="rol")