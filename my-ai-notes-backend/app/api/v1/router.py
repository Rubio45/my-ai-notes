from fastapi import APIRouter

from .examples.examples_router import examples_router
from .notes.notes_router import notes_router

router_v1 = APIRouter(tags=["apiV1"])

router_v1.include_router(examples_router, prefix="/examples")
router_v1.include_router(notes_router, prefix='/notes')

