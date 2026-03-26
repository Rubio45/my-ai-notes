from tools.time_tools import TimeTools

from .data.notes_datasource import NotesDataSource
from .models.note_model import CreateNote, UpdateNote, NoteInDb


class NotesRepository:
    def __init__(self, notes_ds: NotesDataSource):
        self.notes_ds = notes_ds

    async def create_note(self, create_note: CreateNote, user_id: str) -> NoteInDb:
        now = TimeTools.get_now_in_milliseconds()
        note_dict = {
            **create_note.model_dump(),
            "user_id": user_id,
            "created_at": now,
            "updated_at": now,
        }
        result = await self.notes_ds.create_note(note_dict)
        return NoteInDb.model_validate(result)

    async def get_all_notes(self, user_id: str) -> list[NoteInDb]:
        results = await self.notes_ds.get_all_notes(user_id)
        return [NoteInDb.model_validate(r) for r in results]

    async def get_note_by_id(self, note_id: str) -> NoteInDb | None:
        result = await self.notes_ds.get_note_by_id(note_id)
        if result is None:
            return None
        return NoteInDb.model_validate(result)

    async def update_note_by_id(self, note_id: str, note: UpdateNote) -> NoteInDb | None:
        now = TimeTools.get_now_in_milliseconds()
        update_dict = {k: v for k, v in note.model_dump().items() if v is not None}
        update_dict["updated_at"] = now
        result = await self.notes_ds.update_note_by_id(note_id, update_dict)
        if result is None:
            return None
        return NoteInDb.model_validate(result)

    async def delete_note_by_id(self, note_id: str) -> NoteInDb | None:
        result = await self.notes_ds.delete_note_by_id(note_id)
        if result is None:
            return None
        return NoteInDb.model_validate(result)
