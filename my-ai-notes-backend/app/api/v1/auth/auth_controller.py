from fastapi import HTTPException, status

from core.security import hash_password, verify_password, create_access_token
from repos.v1.users import (
    CreateUser,
    UserInDb,
    LoginRequest,
    TokenResponse,
    UsersRepository,
    UsersDataSource,
)


class AuthController:
    def __init__(self, users_repo: UsersRepository) -> None:
        self.users_repo = users_repo

    async def register(self, body: CreateUser) -> UserInDb:
        existing = await self.users_repo.get_user_by_username(body.username)
        if existing is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="El nombre de usuario ya está en uso",
            )
        hashed = hash_password(body.password)
        return await self.users_repo.create_user(body, hashed)

    async def login(self, body: LoginRequest) -> TokenResponse:
        user = await self.users_repo.get_user_by_username(body.username)
        if user is None or not verify_password(body.password, user["password_hash"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenciales incorrectas",
            )
        token = create_access_token({"sub": user["id"]})
        return TokenResponse(access_token=token)


auth_controller = AuthController(
    users_repo=UsersRepository(users_ds=UsersDataSource()),
)
