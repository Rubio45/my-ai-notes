from typing import Any

from bson import ObjectId
from pymongo import ReturnDocument

from services.mongo_service import mongo_service


class NotesDataSource:
    COLLECTION = "notes"

    def _col(self):
        return mongo_service.get_collection(self.COLLECTION)

    def _to_dict(self, doc: dict) -> dict:
        doc["id"] = str(doc.pop("_id"))
        return doc

    async def create_note(self, note: dict[str, Any]) -> dict[str, Any]:
        result = await self._col().insert_one(note)
        created = await self._col().find_one({"_id": result.inserted_id})
        return self._to_dict(created)

    async def get_all_notes(self, user_id: str) -> list[dict[str, Any]]:
        cursor = self._col().find({"user_id": user_id})
        docs = await cursor.to_list(length=None)
        return [self._to_dict(doc) for doc in docs]

    async def get_note_by_id(self, note_id: str) -> dict[str, Any] | None:
        if not ObjectId.is_valid(note_id):
            return None
        doc = await self._col().find_one({"_id": ObjectId(note_id)})
        if doc is None:
            return None
        return self._to_dict(doc)

    async def update_note_by_id(self, note_id: str, note: dict[str, Any]) -> dict[str, Any] | None:
        if not ObjectId.is_valid(note_id):
            return None
        doc = await self._col().find_one_and_update(
            {"_id": ObjectId(note_id)},
            {"$set": note},
            return_document=ReturnDocument.AFTER,
        )
        if doc is None:
            return None
        return self._to_dict(doc)

    async def delete_note_by_id(self, note_id: str) -> dict[str, Any] | None:
        if not ObjectId.is_valid(note_id):
            return None
        doc = await self._col().find_one_and_delete({"_id": ObjectId(note_id)})
        if doc is None:
            return None
        return self._to_dict(doc)
