"""
Listens to Postgres NOTIFY events fired by triggers (see sql/schema.sql).
This is what lets a MANUAL edit in the database (pgAdmin, psql, DBeaver, etc.)
show up live in the UI, exactly the same way a detection-driven update does.
"""
import asyncio
import json
import asyncpg

from app.config import settings
from app.websocket_manager import manager

CHANNEL = "dispatch_changes"


async def start_listener():
    conn = await asyncpg.connect(dsn=settings.ASYNC_DATABASE_URL)

    async def on_notify(connection, pid, channel, payload):
        try:
            data = json.loads(payload)
        except json.JSONDecodeError:
            data = {"raw": payload}
        await manager.broadcast({"source": "db_change", "data": data})

    await conn.add_listener(CHANNEL, on_notify)

    # keep the connection alive forever
    while True:
        await asyncio.sleep(3600)
