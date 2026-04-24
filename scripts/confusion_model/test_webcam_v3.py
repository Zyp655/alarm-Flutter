import cv2
import torch
import numpy as np
from torchvision import transforms
from PIL import Image
from pathlib import Path
import json

# Setup paths
BASE_DIR = Path(__file__).parent
MODEL_PATH = BASE_DIR / 'output_v3' / 'models' / 'confusion_v3.pt'
META_PATH = BASE_DIR / 'output_v3' / 'models' / 'meta_v3.json'

print("Loading metadata...")
try:
    with open(META_PATH, 'r') as f:
        meta = json.load(f)
    THRESHOLD = meta.get('optimal_threshold', 0.85)
except Exception as e:
    print(f"Could not load metadata, defaulting to 0.85: {e}")
    THRESHOLD = 0.85

print(f"Using CONFUSION_THRESHOLD = {THRESHOLD} (Strict Mode)")

# Initialize device and load TorchScript model
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Loading model on {device}...")
model = torch.jit.load(str(MODEL_PATH)).to(device)
model.eval()

# Transform expected by the model
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
])

SEQ_LEN = 5
frame_buffer = []

# For Sliding Window (Temporal smoothing)
# To trigger an intervention, the model must output CONFUSED for N consecutive checks
CONSECUTIVE_REQUIRED = 3
confusion_streak = 0

cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("Cannot open webcam!")
    exit()

print("\nWebcam started! Press 'q' to quit.")
print("Waiting for frames to fill buffer...")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Prepare frame
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    pil_img = Image.fromarray(rgb_frame)
    tensor_img = transform(pil_img)
    
    frame_buffer.append(tensor_img)
    if len(frame_buffer) > SEQ_LEN:
        frame_buffer.pop(0)

    display_frame = frame.copy()

    # Once we have enough frames, run inference
    if len(frame_buffer) == SEQ_LEN:
        # Create sequence batch: [1, 5, 3, 224, 224]
        seq = torch.stack(frame_buffer).unsqueeze(0).to(device)
        
        # Dummy auxiliary data (Boredom, Engagement, Frustration) 
        # In the real app, this would come from other sensors/logs
        # Here we simulate a "neutral" baseline for aux data [0, 0, 0, 0, 0]
        aux = torch.zeros((1, 5), dtype=torch.float32).to(device)

        with torch.no_grad():
            with torch.amp.autocast('cuda'):
                out = model(seq, aux)
                prob = torch.sigmoid(out).item()

        # Logic for strict intervention (Sliding Window)
        is_confused = prob >= THRESHOLD
        
        if is_confused:
            confusion_streak += 1
        else:
            confusion_streak = 0

        # Draw UI
        color = (0, 0, 255) if is_confused else (0, 255, 0)
        status_text = "CONFUSED" if is_confused else "FOCUSED"
        
        cv2.putText(display_frame, f"Conf Score: {prob:.2f} (Thresh: {THRESHOLD})", 
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display_frame, f"Status: {status_text}", 
                    (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.9, color, 2)
        cv2.putText(display_frame, f"Streak: {confusion_streak}/{CONSECUTIVE_REQUIRED}", 
                    (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 0), 2)

        # Trigger Event (Simulated Intervention)
        if confusion_streak >= CONSECUTIVE_REQUIRED:
            cv2.putText(display_frame, "TRIGGER INTERVENTION: ARE YOU OKAY?", 
                        (10, 150), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 165, 255), 3)
            # Reset streak after triggering to avoid spamming
            # confusion_streak = 0 

    cv2.imshow("V3 Confusion Detection", display_frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
