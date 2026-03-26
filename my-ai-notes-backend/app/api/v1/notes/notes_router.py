from fastapi import APIRouter

from repos.v1.notes import CreateNote, UpdateNote, NoteInDb

from .notes_controller import notes_controller


notes_router = APIRouter(tags=["notesV1"])


@notes_router.post("")
async def create_note(body: CreateNote) -> NoteInDb:
    return await notes_controller.create_note(body)


@notes_router.get("")
async def get_all_notes() -> list[NoteInDb]:
    return await notes_controller.get_all_notes()


@notes_router.get("/{note_id}")
async def get_note_by_id(note_id: str) -> NoteInDb:
    return await notes_controller.get_note_by_id(note_id)


@notes_router.patch("/{note_id}")
async def update_note_by_id(note_id: str, body: UpdateNote) -> NoteInDb: 
    return await notes_controller.update_note_by_id(note_id, body)


@notes_router.delete("/{note_id}")
async def delete_note_by_id(note_id: str) -> NoteInDb:
    return await notes_controller.delete_note_by_id(note_id)
