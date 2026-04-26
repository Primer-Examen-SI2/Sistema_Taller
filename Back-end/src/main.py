from fastapi import FastAPI
from src.models.role import Role
from src.models.user import User
from src.core.database import Base, engine
from src.controllers import user_controller, auth_controller

from fastapi.middleware.cors import CORSMiddleware

Base.metadata.create_all(bind=engine)

app = FastAPI(title="FastAPI OAuth2 + RBAC")

app.include_router(auth_controller.router)
app.include_router(user_controller.router)

# En desarrollo puedes usar ["*"], pero en producción sé específico.
origins = [
    "http://localhost:4200",      # Angular default
    "http://localhost:8080",      # Flutter Web default
    "http://127.0.0.1:4200",
    # "https://tu-app-angular.com", # Producción
]

# 2. Agrega el middleware a la aplicación
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,            # Permite estos dominios
    allow_credentials=True,           # Permite cookies/auth headers
    allow_methods=["*"],              # Permite todos los métodos (GET, POST, etc.)
    allow_headers=["*"],              # Permite todos los headers (Content-Type, Authorization)
)


@app.get("/")
def read_root():
    return {"message": "FastAPI con OAuth2 y Control de Roles"}