import os
import cv2
import numpy as np
import pandas as pd
from pathlib import Path
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
from tqdm import tqdm
import urllib.request
import warnings
warnings.filterwarnings('ignore')

BASE_DIR = Path(__file__).parent
FRAMES_DIR = BASE_DIR / 'frames_v2'
CSV_PATH = FRAMES_DIR / 'frame_labels.csv'
OUTPUT_NPZ = FRAMES_DIR / 'landmarks.npz'
TASK_PATH = BASE_DIR / 'face_landmarker.task'

def extract_landmarks():
    if not CSV_PATH.exists():
        print(f"Error: {CSV_PATH} not found!")
        return

    if not TASK_PATH.exists():
        print("Downloading face_landmarker.task...")
        url = 'https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task'
        urllib.request.urlretrieve(url, str(TASK_PATH))

    print("Loading frame_labels.csv...")
    df = pd.read_csv(CSV_PATH)
    grouped = df.groupby('clip_id')
    
    landmarks_dict = {}
    
    base_options = python.BaseOptions(model_asset_path=str(TASK_PATH))
    options = vision.FaceLandmarkerOptions(
        base_options=base_options,
        output_face_blendshapes=False,
        output_facial_transformation_matrixes=False,
        num_faces=1)
        
    print("Initializing MediaPipe FaceLandmarker...")
    with vision.FaceLandmarker.create_from_options(options) as landmarker:
        for clip_id, group in tqdm(grouped, desc="Extracting Landmarks"):
            group = group.sort_values('frame_path')
            frames = group['frame_path'].tolist()
            
            clip_landmarks = []
            last_valid_lm = np.zeros((478, 3), dtype=np.float32)
            
            for fp in frames:
                if not os.path.exists(fp):
                    clip_landmarks.append(last_valid_lm)
                    continue
                    
                image = cv2.imread(fp)
                if image is None:
                    clip_landmarks.append(last_valid_lm)
                    continue
                
                rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_image)
                
                result = landmarker.detect(mp_image)
                
                if not result.face_landmarks:
                    clip_landmarks.append(last_valid_lm)
                else:
                    lm_list = []
                    # results.face_landmarks is a list of faces. We take the first one.
                    for lm in result.face_landmarks[0]:
                        lm_list.append([lm.x, lm.y, lm.z])
                    
                    lm_arr = np.array(lm_list, dtype=np.float32)
                    last_valid_lm = lm_arr
                    clip_landmarks.append(lm_arr)
            
            landmarks_dict[str(clip_id)] = np.array(clip_landmarks, dtype=np.float32)

    print(f"\nSaving to {OUTPUT_NPZ}...")
    np.savez_compressed(OUTPUT_NPZ, **landmarks_dict)
    print("Done! Total clips processed:", len(landmarks_dict))

if __name__ == '__main__':
    extract_landmarks()
