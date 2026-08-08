"""
One-time preprocessing: runs your trained YOLO model + ByteTrack over
test.mp4, bakes in thin bounding boxes + a per-carton track ID, and
re-encodes to a browser-safe H.264 MP4 (OpenCV's own mp4v output is not
reliably playable in-browser — this fixes that with an ffmpeg pass).

Counting rule (debounced centroid crossing): for each carton track, we
watch whether its centroid is inside the model's own open_door box.
A crossing only counts once a track has been confirmed OUTSIDE the door
box for at least 3 consecutive frames, immediately followed by 1 frame
INSIDE it. That "3 outside -> 1 inside" requirement is what makes it
robust — a single flickery/noisy detection can't fire a false count, it
has to see a real sustained approach-then-entry. Each track (unique
carton box ID) can only fire once.

Also records every detection's class + confidence (for the live status
cards) and the first plate number read via PaddleOCR (padded + upscaled
crop, for better OCR accuracy).

Runs once at backend startup and is cached — safe to restart the server
without waiting again, unless the source video changes or
FORCE_REPROCESS=1 is set. Delete backend/output/ or set FORCE_REPROCESS=1
any time you change this file's logic — the cache only checks the source
video's mtime, not this script's.
"""
import os
import json
import subprocess
import cv2
from ultralytics import YOLO

from app.config import settings
from app.ocr_service import extract_plate_text

RAW_OUTPUT = os.path.join(settings.OUTPUT_DIR, "_annotated_raw.mp4")
FINAL_OUTPUT = os.path.join(settings.OUTPUT_DIR, "annotated.mp4")
EVENTS_FILE = os.path.join(settings.OUTPUT_DIR, "annotated_events.json")

REQUIRED_OUTSIDE_STREAK = 3   # confirmed outside frames required before an entry counts
BOX_THICKNESS = 1
PLATE_CROP_PAD = 6


def _needs_processing() -> bool:
    if settings.FORCE_REPROCESS:
        return True
    if not os.path.exists(FINAL_OUTPUT) or not os.path.exists(EVENTS_FILE):
        return True
    return os.path.getmtime(settings.VIDEO_SOURCE_PATH) > os.path.getmtime(FINAL_OUTPUT)


def _class_name(model, cls_id):
    return model.names.get(int(cls_id), str(cls_id))


def _extract_plate_padded(frame, x1, y1, x2, y2, h, w):
    x1p = max(x1 - PLATE_CROP_PAD, 0)
    y1p = max(y1 - PLATE_CROP_PAD, 0)
    x2p = min(x2 + PLATE_CROP_PAD, w)
    y2p = min(y2 + PLATE_CROP_PAD, h)
    crop = frame[y1p:y2p, x1p:x2p]
    if crop.size == 0:
        return None
    ch = crop.shape[0]
    if 0 < ch < 64:
        scale = 64 / ch
        crop = cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
    return extract_plate_text(crop)


def _point_in_box(px, py, box):
    return box["x1"] <= px <= box["x2"] and box["y1"] <= py <= box["y2"]


def generate_annotated_video():
    os.makedirs(settings.OUTPUT_DIR, exist_ok=True)

    if not _needs_processing():
        return FINAL_OUTPUT, EVENTS_FILE

    model = YOLO(settings.YOLO_MODEL_PATH)
    cap = cv2.VideoCapture(settings.VIDEO_SOURCE_PATH)
    if not cap.isOpened():
        raise RuntimeError(f"Could not open video: {settings.VIDEO_SOURCE_PATH}")

    fps = cap.get(cv2.CAP_PROP_FPS) or 25
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    writer = cv2.VideoWriter(RAW_OUTPUT, fourcc, fps, (w, h))

    outside_streak = {}   # track_id -> consecutive confirmed-outside frame count
    already_counted = {}  # track_id -> True once it has fired a crossing event
    carton_events = []
    detections_log = []
    plate_number = None
    frame_idx = 0

    while True:
        ok, frame = cap.read()
        if not ok:
            break

        results = model.track(frame, persist=True, conf=settings.CONF_THRESHOLD, verbose=False, device="cpu")
        annotated = frame.copy()
        t_sec = round(frame_idx / fps, 3)

        boxes_this_frame = []
        if results and results[0].boxes is not None:
            for box in results[0].boxes:
                cls_id = int(box.cls[0])
                label = _class_name(model, cls_id)
                track_id = int(box.id[0]) if box.id is not None else None
                conf = float(box.conf[0]) if box.conf is not None else 0.0
                x1, y1, x2, y2 = [int(v) for v in box.xyxy[0].tolist()]
                boxes_this_frame.append({
                    "label": label, "track_id": track_id, "conf": conf,
                    "x1": x1, "y1": y1, "x2": x2, "y2": y2,
                })

        # The model's own detected open-door box for this frame (highest
        # confidence one if it sees more than one). No fixed line.
        door_box = max(
            (b for b in boxes_this_frame if b["label"] == settings.OPEN_DOOR_CLASS_NAME),
            key=lambda b: b["conf"],
            default=None,
        )

        for b in boxes_this_frame:
            is_door = b["label"] == settings.OPEN_DOOR_CLASS_NAME
            is_carton = b["label"] == settings.CARTON_CLASS_NAME
            color = (255, 180, 0) if is_door else (0, 255, 0)
            cv2.rectangle(annotated, (b["x1"], b["y1"]), (b["x2"], b["y2"]), color, BOX_THICKNESS)

            tag = f'{b["label"]} {round(b["conf"] * 100)}%'
            if is_carton and b["track_id"] is not None:
                tag = f'#{b["track_id"]} {tag}'  # unique box ID shown in the video
            cv2.putText(annotated, tag, (b["x1"], max(14, b["y1"] - 5)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.45, color, 1)

            detections_log.append({
                "time_sec": t_sec, "label": b["label"], "confidence": round(b["conf"] * 100, 1),
            })

            if is_carton and b["track_id"] is not None and door_box is not None:
                tid = b["track_id"]
                if not already_counted.get(tid, False):
                    cx = (b["x1"] + b["x2"]) / 2
                    cy = (b["y1"] + b["y2"]) / 2
                    inside = _point_in_box(cx, cy, door_box)

                    if inside:
                        if outside_streak.get(tid, 0) >= REQUIRED_OUTSIDE_STREAK:
                            carton_events.append({"time_sec": t_sec, "track_id": tid})
                            already_counted[tid] = True
                        outside_streak[tid] = 0
                    else:
                        outside_streak[tid] = outside_streak.get(tid, 0) + 1

            elif b["label"] == settings.PLATE_CLASS_NAME and plate_number is None:
                text = _extract_plate_padded(frame, b["x1"], b["y1"], b["x2"], b["y2"], h, w)
                if text:
                    plate_number = text

        writer.write(annotated)
        frame_idx += 1

    cap.release()
    writer.release()

    subprocess.run(
        [
            "ffmpeg", "-y", "-i", RAW_OUTPUT,
            "-vcodec", "libx264", "-pix_fmt", "yuv420p",
            "-movflags", "+faststart",
            FINAL_OUTPUT,
        ],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    os.remove(RAW_OUTPUT)

    with open(EVENTS_FILE, "w") as f:
        json.dump({
            "duration_sec": frame_idx / fps,
            "plate_number": plate_number,
            "carton_events": carton_events,
            "detections": detections_log,
        }, f)

    return FINAL_OUTPUT, EVENTS_FILE
