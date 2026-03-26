from fastapi import APIRouter

from repos.v1.users import CreateUser, UserInDb, LoginRequest, TokenResponse

from .auth_controller import auth_controller

auth_router = APIRouter(tags=["authV1"])


@auth_router.post("/register", status_code=201)
async def register(body: CreateUser) -> UserInDb:
    return await auth_controller.register(body)


@auth_router.post("/login")
async def login(body: LoginRequest) -> TokenResponse:
    return await auth_controller.login(body)
