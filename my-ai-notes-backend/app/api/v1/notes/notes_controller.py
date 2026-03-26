from fastapi import HTTPException, status

from repos.v1.notes import (
    CreateNote, 
    UpdateNote, 
    NoteInDb, 
    NotesRepository,
    NotesDataSource,
)


class NotesController:
    def __init__(self, notes_repo: NotesRepository) -> None:
        self.notes_repo = notes_repo

    async def create_note(self, body: CreateNote) -> NoteInDb:
        return await self.notes_repo.create_note(body)

    async def get_all_notes(self) -> list[NoteInDb]:
        notes = await self.notes_repo.get_all_notes()
        return notes

    async def get_note_by_id(self, note_id: str) -> NoteInDb:
        note = await self.notes_repo.get_note_by_id(note_id)
        if note is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Note not found",
            )
        return note

    async def update_note_by_id(self, note_id: str, body: UpdateNote) -> NoteInDb:
        updated_note = await self.notes_repo.update_note_by_id(note_id, body)
        if updated_note is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Note not found",
            )
        return updated_note

    async def delete_note_by_id(self, note_id: str) -> NoteInDb:
        deleted_note = await self.notes_repo.delete_note_by_id(note_id)
        if deleted_note is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Note not found",
            )
        return deleted_note

notes_controller = NotesController(
    notes_repo=NotesRepository(
        notes_ds=NotesDataSource(),
    ),
)
