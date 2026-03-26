from fastapi import HTTPException, status

from core.security import hash_password, verify_password, create_access_token, decode_access_token
from repos.v1.auth import TokenBlacklistDataSource
from repos.v1.users import (
    CreateUser,
    UserInDb,
    LoginRequest,
    TokenResponse,
    UsersRepository,
    UsersDataSource,
)


class AuthController:
    def __init__(self, users_repo: UsersRepository, blacklist_ds: TokenBlacklistDataSource) -> None:
        self.users_repo = users_repo
        self.blacklist_ds = blacklist_ds

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

    async def logout(self, token: str) -> None:
        payload = decode_access_token(token)
        if payload is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido o expirado",
            )
        exp: int = payload["exp"]
        await self.blacklist_ds.add(token, exp)


auth_controller = AuthController(
    users_repo=UsersRepository(users_ds=UsersDataSource()),
    blacklist_ds=TokenBlacklistDataSource(),
)
