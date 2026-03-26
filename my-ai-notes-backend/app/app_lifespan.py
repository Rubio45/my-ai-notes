from contextlib import asynccontextmanager

from fastapi import FastAPI

from core.services_initializer import init_services
from services.mongo_service import mongo_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_services()
    yield
    await mongo_service.disconnect()
