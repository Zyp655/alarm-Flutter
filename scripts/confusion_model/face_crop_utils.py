import cv2
import numpy as np

try:
    import mediapipe as mp
    _mp_face_detection = mp.solutions.face_detection
    _HAS_MEDIAPIPE = True
except (ImportError, AttributeError):
    _HAS_MEDIAPIPE = False

try:
    _face_cascade = cv2.CascadeClassifier(
        cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
    )
    _HAS_HAAR = True
except Exception:
    _HAS_HAAR = False


def detect_and_crop_face(frame, target_size=(224, 224), padding=0.3):
    if _HAS_MEDIAPIPE:
        return _crop_mediapipe(frame, target_size, padding)
    if _HAS_HAAR:
        return _crop_haar(frame, target_size, padding)
    return _center_crop(frame, target_size)


def _crop_mediapipe(frame, target_size, padding):
    with _mp_face_detection.FaceDetection(
        model_selection=1, min_detection_confidence=0.5
    ) as face_det:
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = face_det.process(rgb)

        if not results.detections:
            return _center_crop(frame, target_size)

        detection = results.detections[0]
        bbox = detection.location_data.relative_bounding_box
        h, w = frame.shape[:2]

        x = int(bbox.xmin * w)
        y = int(bbox.ymin * h)
        bw = int(bbox.width * w)
        bh = int(bbox.height * h)

        return _extract_padded_face(frame, x, y, bw, bh, padding, target_size)


def _crop_haar(frame, target_size, padding):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = _face_cascade.detectMultiScale(gray, 1.1, 4, minSize=(30, 30))

    if len(faces) == 0:
        return _center_crop(frame, target_size)

    x, y, bw, bh = max(faces, key=lambda f: f[2] * f[3])
    return _extract_padded_face(frame, x, y, bw, bh, padding, target_size)


def _extract_padded_face(frame, x, y, bw, bh, padding, target_size):
    h, w = frame.shape[:2]
    pad_w = int(bw * padding)
    pad_h = int(bh * padding)

    x1 = max(0, x - pad_w)
    y1 = max(0, y - pad_h)
    x2 = min(w, x + bw + pad_w)
    y2 = min(h, y + bh + pad_h)

    face = frame[y1:y2, x1:x2]
    if face.size == 0:
        return _center_crop(frame, target_size)

    return cv2.resize(face, target_size)


def _center_crop(frame, target_size):
    h, w = frame.shape[:2]
    size = min(h, w)
    y1 = (h - size) // 2
    x1 = (w - size) // 2
    cropped = frame[y1:y1+size, x1:x1+size]
    return cv2.resize(cropped, target_size)
