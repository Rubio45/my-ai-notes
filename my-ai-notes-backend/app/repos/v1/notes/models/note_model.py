from pydantic import BaseModel


class BaseNote(BaseModel):
    title: str
    content: str


class CreateNote(BaseNote):
    pass


class UpdateNote(BaseModel):
    title: str | None = None
    content: str | None = None


class NoteInDb(BaseNote):
    id: str
    user_id: str
    created_at: int
    updated_at: int
