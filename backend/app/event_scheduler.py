"""
Replays the pre-computed carton door-crossing events (from
video_preprocess.py) in sync with the looping <video> element on the
frontend, so loaded_count in Postgres — and therefore the dashboard —
updates at the same moment a carton visually crosses the door line.
Also answers "what's detected right now" from the real recorded
per-frame confidences, keyed off the same elapsed-time clock, instead
of any fixed/dummy number.
"""
import json
import time
import threading
from datetime import datetime, timezone

from app.database import SessionLocal
from app.models import Truck, CountEvent
from app.video_preprocess import EVENTS_FILE

_lock = threading.Lock()
_state = {"loop_start": time.time(), "duration": 1.0, "detections": []}

DETECTION_WINDOW_SEC = 1.0


def _get_active_truck(db):
    truck = (
        db.query(Truck)
        .filter(Truck.status == "loading")
        .order_by(Truck.created_at.desc())
        .first()
    )
    if truck is None:
        truck = db.query(Truck).order_by(Truck.created_at.desc()).first()
    return truck


def _fire_carton_event(track_id):
    db = SessionLocal()
    try:
        truck = _get_active_truck(db)
        if truck is None:
            return
        truck.loaded_count = (truck.loaded_count or 0) + 1
        if truck.expected_count and truck.loaded_count >= truck.expected_count:
            truck.status = "completed"
        elif truck.status == "waiting":
            truck.status = "loading"
            truck.loading_started_at = datetime.now(timezone.utc)
        db.add(truck)
        db.add(CountEvent(
            truck_id=truck.id,
            event_type="carton_added",
            track_id=track_id,
            note="carton centroid entered the open_door box (synced with annotated video playback)",
        ))
        db.commit()
    finally:
        db.close()


def _set_plate_once(plate_number, already_set_flag):
    if not plate_number or already_set_flag[0]:
        return
    db = SessionLocal()
    try:
        truck = _get_active_truck(db)
        if truck and truck.plate_number != plate_number:
            truck.plate_number = plate_number
            db.add(truck)
            db.commit()
        already_set_flag[0] = True
    finally:
        db.close()


def get_current_elapsed() -> float:
    with _lock:
        return (time.time() - _state["loop_start"]) % max(_state["duration"], 0.01)


def get_detection_status() -> dict:
    """Real status derived from the actual detections recorded during
    preprocessing, looked up at the current point in the playback loop —
    not a fixed number."""
    elapsed = get_current_elapsed()
    with _lock:
        detections = _state["detections"]

    result = {}
    active_confidences = []
    for d in detections:
        if abs(d["time_sec"] - elapsed) <= DETECTION_WINDOW_SEC:
            existing = result.get(d["label"])
            if existing is None or d["confidence"] > existing["confidence"]:
                result[d["label"]] = {"detected": True, "confidence": d["confidence"]}

    for label, info in result.items():
        active_confidences.append(info["confidence"])

    overall_accuracy = (
        round(sum(active_confidences) / len(active_confidences), 1)
        if active_confidences else None
    )
    return {"classes": result, "overall_accuracy": overall_accuracy}


def _scheduler_loop():
    with open(EVENTS_FILE) as f:
        data = json.load(f)

    duration = max(data["duration_sec"], 0.5)
    carton_events = sorted(data["carton_events"], key=lambda e: e["time_sec"])
    plate_number = data.get("plate_number")

    with _lock:
        _state["duration"] = duration
        _state["detections"] = data.get("detections", [])
        _state["loop_start"] = time.time()

    next_idx = 0
    plate_set = [False]
    last_elapsed = -1.0

    while True:
        elapsed = get_current_elapsed()

        if elapsed < last_elapsed:
            next_idx = 0  # elapsed decreased -> we just wrapped to a new loop
            plate_set[0] = False
        last_elapsed = elapsed

        while next_idx < len(carton_events) and carton_events[next_idx]["time_sec"] <= elapsed:
            _fire_carton_event(carton_events[next_idx]["track_id"])
            next_idx += 1

        if elapsed > 0.5:
            _set_plate_once(plate_number, plate_set)

        time.sleep(0.15)


def start_event_scheduler():
    t = threading.Thread(target=_scheduler_loop, daemon=True)
    t.start()
