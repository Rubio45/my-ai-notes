from fastapi import APIRouter, Depends

from repos.v1.notes import CreateNote, UpdateNote, NoteInDb
from dependencies.auth_dependency import get_current_user_id

from .notes_controller import notes_controller

notes_router = APIRouter(tags=["notesV1"], dependencies=[Depends(get_current_user_id)])


@notes_router.post("")
async def create_note(
    body: CreateNote, user_id: str = Depends(get_current_user_id)
) -> NoteInDb:
    return await notes_controller.create_note(body, user_id)


@notes_router.get("")
async def get_all_notes(user_id: str = Depends(get_current_user_id)) -> list[NoteInDb]:
    return await notes_controller.get_all_notes(user_id)


@notes_router.get("/{note_id}")
async def get_note_by_id(
    note_id: str, user_id: str = Depends(get_current_user_id)
) -> NoteInDb:
    return await notes_controller.get_note_by_id(note_id, user_id)


@notes_router.patch("/{note_id}")
async def update_note_by_id(
    note_id: str, body: UpdateNote, user_id: str = Depends(get_current_user_id)
) -> NoteInDb:
    return await notes_controller.update_note_by_id(note_id, body, user_id)


@notes_router.delete("/{note_id}")
async def delete_note_by_id(
    note_id: str, user_id: str = Depends(get_current_user_id)
) -> NoteInDb:
    return await notes_controller.delete_note_by_id(note_id, user_id)
