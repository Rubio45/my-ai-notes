from .data.notes_datasource import NotesDataSource
from .models.note_model import CreateNote, UpdateNote, NoteInDb


class NotesRepository:
    def __init__(self, notes_ds: NotesDataSource):
        self.notes_ds = notes_ds

    async def create_note(self, create_note: CreateNote) -> NoteInDb:
        # TODO: implement create
        raise NotImplementedError()

    async def get_all_notes(self) -> list[NoteInDb]:
        results = await self.notes_ds.get_all_notes()
        models = [NoteInDb.model_validate(result) for result in results]
        return models

    async def get_note_by_id(self, note_id: str) -> NoteInDb | None :
        result = await self.notes_ds.get_note_by_id(note_id)
        
        if result is None:
            return None
        
        return NoteInDb.model_validate(result)

    async def update_note_by_id(self, note_id: str, note: UpdateNote) -> NoteInDb | None:
        # TODO: implement update
        raise NotImplementedError()

    async def delete_note_by_id(self, note_id: str) -> NoteInDb | None:
        result = await self.notes_ds.delete_note_by_id(note_id)
        
        if result is None:
            return None
        
        return NoteInDb.model_validate(result)
