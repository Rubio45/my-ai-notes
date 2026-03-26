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

    async def create_note(self, body: CreateNote, user_id: str) -> NoteInDb:
        return await self.notes_repo.create_note(body, user_id)

    async def get_all_notes(self, user_id: str) -> list[NoteInDb]:
        return await self.notes_repo.get_all_notes(user_id)

    async def get_note_by_id(self, note_id: str, user_id: str) -> NoteInDb:
        note = await self.notes_repo.get_note_by_id(note_id)
        if note is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Nota no encontrada")
        if note.user_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tienes acceso a esta nota")
        return note

    async def update_note_by_id(self, note_id: str, body: UpdateNote, user_id: str) -> NoteInDb:
        note = await self.notes_repo.get_note_by_id(note_id)
        if note is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Nota no encontrada")
        if note.user_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tienes acceso a esta nota")
        updated = await self.notes_repo.update_note_by_id(note_id, body)
        if updated is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Nota no encontrada")
        return updated

    async def delete_note_by_id(self, note_id: str, user_id: str) -> NoteInDb:
        note = await self.notes_repo.get_note_by_id(note_id)
        if note is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Nota no encontrada")
        if note.user_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tienes acceso a esta nota")
        deleted = await self.notes_repo.delete_note_by_id(note_id)
        if deleted is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Nota no encontrada")
        return deleted


notes_controller = NotesController(
    notes_repo=NotesRepository(
        notes_ds=NotesDataSource(),
    ),
)
