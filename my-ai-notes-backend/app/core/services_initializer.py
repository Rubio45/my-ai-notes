from pymongo import ASCENDING

from services.mongo_service import mongo_service


async def init_services() -> None:
    await mongo_service.connect()
    await mongo_service.get_collection("token_blacklist").create_index(
        [("expires_at", ASCENDING)],
        expireAfterSeconds=0,
        name="ttl_expires_at",
    )
