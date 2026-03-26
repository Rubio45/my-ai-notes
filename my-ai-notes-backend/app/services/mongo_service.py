import os
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase


class MongoService:
    client: AsyncIOMotorClient | None = None
    db: AsyncIOMotorDatabase | None = None

    async def connect(self) -> None:
        uri = os.getenv("MONGO_URI", "mongodb://localhost:27017")
        db_name = os.getenv("MONGO_DB", "my_notes_db")
        self.client = AsyncIOMotorClient(uri)
        self.db = self.client[db_name]
        print(f"[MongoDB] Conectado a '{db_name}'")

    async def disconnect(self) -> None:
        if self.client:
            self.client.close()
            print("[MongoDB] Conexión cerrada")

    def get_collection(self, name: str):
        if self.db is None:
            raise RuntimeError("MongoService no está conectado. Llama a connect() primero.")
        return self.db[name]


mongo_service = MongoService()
