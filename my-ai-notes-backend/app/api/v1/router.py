from fastapi import APIRouter

from .auth.auth_router import auth_router
from .notes.notes_router import notes_router

router_v1 = APIRouter(tags=["apiV1"])

router_v1.include_router(auth_router, prefix="/auth")
router_v1.include_router(notes_router, prefix="/notes")

