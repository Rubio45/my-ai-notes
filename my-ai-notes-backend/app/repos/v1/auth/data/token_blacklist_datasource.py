import hashlib
from datetime import datetime, timezone

from services.mongo_service import mongo_service


class TokenBlacklistDataSource:
    COLLECTION = "token_blacklist"

    def _col(self):
        return mongo_service.get_collection(self.COLLECTION)

    @staticmethod
    def _hash(token: str) -> str:
        return hashlib.sha256(token.encode("utf-8")).hexdigest()

    async def add(self, token: str, exp: int) -> None:
        expires_at = datetime.fromtimestamp(exp, tz=timezone.utc)
        await self._col().update_one(
            {"token_hash": self._hash(token)},
            {"$setOnInsert": {"token_hash": self._hash(token), "expires_at": expires_at}},
            upsert=True,
        )

    async def is_blacklisted(self, token: str) -> bool:
        doc = await self._col().find_one({"token_hash": self._hash(token)})
        return doc is not None
