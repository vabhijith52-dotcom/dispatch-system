"""
Number plate text extraction using PaddleOCR. Called on cropped
"Number plate" detections coming from the YOLO model.
"""
import re
import cv2
import numpy as np
from paddleocr import PaddleOCR

_ocr = None


def get_ocr():
    global _ocr
    if _ocr is None:
        _ocr = PaddleOCR(
            use_angle_cls=True,
            lang="en",
            show_log=False
        )
    return _ocr


# Indian vehicle number plate format
PLATE_REGEX = re.compile(
    r"^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$"
)


def clean_plate_text(text: str) -> str:
    if not text:
        return ""

    text = re.sub(r"[^A-Za-z0-9]", "", text)
    return text.upper()


def correct_plate(text: str) -> str:
    """
    Correct common OCR mistakes based on expected
    Indian registration format.

    Format:
    AA00AA0000
    """

    text = clean_plate_text(text)

    if len(text) < 8:
        return text

    chars = list(text)

    # ---- State code (letters) ----
    for i in range(min(2, len(chars))):
        chars[i] = (
            chars[i]
            .replace("0", "O")
            .replace("1", "I")
            .replace("5", "S")
            .replace("8", "B")
            .replace("2", "Z")
        )

    # ---- District code (digits) ----
    for i in range(2, min(4, len(chars))):
        chars[i] = (
            chars[i]
            .replace("O", "0")
            .replace("Q", "0")
            .replace("I", "1")
            .replace("L", "1")
            .replace("Z", "2")
            .replace("S", "5")
            .replace("B", "8")
        )

    # ---- Series letters ----
    for i in range(4, min(len(chars) - 4, len(chars))):
        chars[i] = (
            chars[i]
            .replace("0", "O")
            .replace("1", "I")
            .replace("5", "S")
            .replace("8", "B")
            .replace("2", "Z")
        )

    # ---- Last four digits ----
    start = max(len(chars) - 4, 0)

    for i in range(start, len(chars)):
        chars[i] = (
            chars[i]
            .replace("O", "0")
            .replace("Q", "0")
            .replace("I", "1")
            .replace("L", "1")
            .replace("Z", "2")
            .replace("S", "5")
            .replace("B", "8")
        )

    return "".join(chars)


def preprocess_image(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    gray = cv2.bilateralFilter(gray, 9, 75, 75)

    clahe = cv2.createCLAHE(
        clipLimit=2.0,
        tileGridSize=(8, 8)
    )

    gray = clahe.apply(gray)

    gray = cv2.resize(
        gray,
        None,
        fx=2,
        fy=2,
        interpolation=cv2.INTER_CUBIC
    )

    _, thresh = cv2.threshold(
        gray,
        0,
        255,
        cv2.THRESH_BINARY + cv2.THRESH_OTSU
    )

    adaptive = cv2.adaptiveThreshold(
        gray,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        31,
        11
    )

    return [
        img,
        gray,
        thresh,
        adaptive
    ]


def run_ocr(image):
    try:
        result = get_ocr().ocr(image, cls=True)
    except Exception:
        return []

    outputs = []

    if not result or not result[0]:
        return outputs

    for line in result[0]:
        raw = line[1][0]
        score = float(line[1][1])

        cleaned = clean_plate_text(raw)
        corrected = correct_plate(cleaned)

        outputs.append({
            "raw": raw,
            "cleaned": corrected,
            "confidence": score
        })

    return outputs


def extract_plate_text(cropped_bgr_image):
    if (
        cropped_bgr_image is None
        or cropped_bgr_image.size == 0
    ):
        return None

    candidates = []

    variants = preprocess_image(cropped_bgr_image)

    for img in variants:
        candidates.extend(run_ocr(img))

    if not candidates:
        return None

    # Prefer valid Indian plates
    valid = [
        c
        for c in candidates
        if PLATE_REGEX.match(c["cleaned"])
    ]

    if valid:
        best = max(valid, key=lambda x: x["confidence"])

        if best["confidence"] >= 0.55:
            return best["cleaned"]

    # Otherwise return best confidence
    best = max(candidates, key=lambda x: x["confidence"])

    if best["confidence"] >= 0.60:
        return best["cleaned"]

    return None