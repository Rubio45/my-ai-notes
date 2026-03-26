from typing import Any

from tools.time_tools import TimeTools

from .data.users_datasource import UsersDataSource
from .models.user_model import CreateUser, UserInDb


class UsersRepository:
    def __init__(self, users_ds: UsersDataSource):
        self.users_ds = users_ds

    async def create_user(self, create_user: CreateUser, hashed_password: str) -> UserInDb:
        now = TimeTools.get_now_in_milliseconds()
        user_dict = {
            "username": create_user.username,
            "password_hash": hashed_password,
            "created_at": now,
        }
        result = await self.users_ds.create_user(user_dict)
        return UserInDb.model_validate(result)

    async def get_user_by_username(self, username: str) -> dict[str, Any] | None:
        return await self.users_ds.get_user_by_username(username)

    async def get_user_by_id(self, user_id: str) -> UserInDb | None:
        result = await self.users_ds.get_user_by_id(user_id)
        if result is None:
            return None
        return UserInDb.model_validate(result)
