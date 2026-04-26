from sqlalchemy.orm import Session
from src.models.user import User


class UserRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_by_correo(self, correo: str):
        return (
            self.db.query(User)
            .filter(User.correo == correo)
            .first()
        )

    def get_by_username(self, username: str):
        return (
            self.db.query(User)
            .filter(User.username == username)
            .first()
        )

    def create(self, user: User):
        self.db.add(user)
        return user
    
    def list(self):
        return self.db.query(User).all()
