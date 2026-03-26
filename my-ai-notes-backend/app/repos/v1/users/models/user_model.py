from pydantic import BaseModel


class BaseUser(BaseModel):
    username: str


class CreateUser(BaseUser):
    password: str


class UserInDb(BaseUser):
    id: str
    created_at: int


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
