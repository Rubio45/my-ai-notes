from pydantic import BaseModel


class BaseNote(BaseModel):
    pass


class CreateNote(BaseNote):
    pass


class UpdateNote(BaseModel):
    pass


class NoteInDb(BaseNote):
    id: str
    created_at: str
    updated_at: str
