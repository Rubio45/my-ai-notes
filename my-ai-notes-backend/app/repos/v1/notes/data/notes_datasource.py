from typing import Any


class NotesDataSource:
    async def create_note(self, note: dict[str, Any]) -> dict[str, Any]:
        # TODO: implement create
        raise NotImplementedError()

    async def get_all_notes(self) -> list[dict[str, Any]]:
        # TODO: implement get all
        raise NotImplementedError()

    async def get_note_by_id(self, note_id: str) -> dict[str, Any] | None :
        # TODO: implement get by id
        raise NotImplementedError()

    async def update_note_by_id(self, note_id:str, note:dict[str, Any]) -> dict[str, Any] | None:
        # TODO: implement update
        raise NotImplementedError()

    async def delete_note_by_id(self, note_id:str) -> dict[str, Any] | None:
        # TODO: implement delete
        raise NotImplementedError()
