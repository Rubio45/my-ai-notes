from services.mongo_service import mongo_service


async def init_services() -> None:
    await mongo_service.connect()
