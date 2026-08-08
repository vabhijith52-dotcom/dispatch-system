from fastapi import APIRouter, Depends
from app.auth import get_current_user
from app.event_scheduler import get_detection_status

router = APIRouter(prefix="/api/detections", tags=["detections"])


@router.get("/status")
def detection_status(user=Depends(get_current_user)):
    """
    Live per-class detection confidence (Truck / Number plate / Carton_box),
    looked up from the real detections recorded during video preprocessing
    at the current point in the playback loop — not a fixed number.
    """
    return get_detection_status()
