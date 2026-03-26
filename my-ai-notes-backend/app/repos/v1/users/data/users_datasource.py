from typing import Any

from bson import ObjectId

from services.mongo_service import mongo_service


class UsersDataSource:
    COLLECTION = "users"

    def _col(self):
        return mongo_service.get_collection(self.COLLECTION)

    def _to_dict(self, doc: dict) -> dict:
        doc["id"] = str(doc.pop("_id"))
        return doc

    async def create_user(self, user: dict[str, Any]) -> dict[str, Any]:
        result = await self._col().insert_one(user)
        created = await self._col().find_one({"_id": result.inserted_id})
        return self._to_dict(created)

    async def get_user_by_username(self, username: str) -> dict[str, Any] | None:
        doc = await self._col().find_one({"username": username})
        if doc is None:
            return None
        return self._to_dict(doc)

    async def get_user_by_id(self, user_id: str) -> dict[str, Any] | None:
        if not ObjectId.is_valid(user_id):
            return None
        doc = await self._col().find_one({"_id": ObjectId(user_id)})
        if doc is None:
            return None
        return self._to_dict(doc)
