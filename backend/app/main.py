import asyncio
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import settings
from app.database import Base, engine
from app.routers import auth_router, trucks_router, dashboard_router, stream_router, detections_router
from app.video_preprocess import generate_annotated_video
from app.event_scheduler import start_event_scheduler
from app.db_listener import start_listener

import os
os.makedirs(settings.OUTPUT_DIR, exist_ok=True)

app = FastAPI(title="Smart Dispatch Verification API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)
app.include_router(trucks_router.router)
app.include_router(dashboard_router.router)
app.include_router(stream_router.router)
app.include_router(detections_router.router)
app.mount("/media", StaticFiles(directory=settings.OUTPUT_DIR), name="media")


@app.on_event("startup")
async def on_startup():
    Base.metadata.create_all(bind=engine)

    asyncio.create_task(start_listener())

    if os.getenv("RUN_PREPROCESS", "false").lower() == "true":
        await asyncio.to_thread(generate_annotated_video)
        start_event_scheduler()


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/health/video")
def health_video():
    """Poll this from the frontend if you want to show a 'processing
    video, please wait' state — true once annotated.mp4 exists."""
    from app.video_preprocess import FINAL_OUTPUT
    return {"ready": os.path.exists(FINAL_OUTPUT)}
