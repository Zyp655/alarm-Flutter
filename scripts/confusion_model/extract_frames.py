import os
import sys
import cv2
import pandas as pd
import numpy as np
from pathlib import Path
from face_crop_utils import detect_and_crop_face

DAISEE_ROOT = "D:/DAiSEE/DAiSEE"
DATASET_DIR = f"{DAISEE_ROOT}/DataSet"
LABELS_DIR = f"{DAISEE_ROOT}/Labels"
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frames")

FRAME_SIZE = (224, 224)
FRAMES_PER_CLIP = 15

def extract_frames_from_clip(video_path, output_path, n_frames=FRAMES_PER_CLIP):
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened():
        return []

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total_frames <= 0:
        cap.release()
        return []

    indices = np.linspace(0, total_frames - 1, n_frames, dtype=int)
    saved = []

    for i, idx in enumerate(indices):
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ret, frame = cap.read()
        if not ret:
            continue

        face = detect_and_crop_face(frame, FRAME_SIZE)
        fname = f"{Path(video_path).stem}_f{i}.jpg"
        fpath = os.path.join(output_path, fname)
        cv2.imwrite(fpath, face)
        saved.append(fpath)

    cap.release()
    return saved

def process_split(split_name):
    split_dir = os.path.join(DATASET_DIR, split_name)
    if not os.path.exists(split_dir):
        print(f"  {split_name} directory not found, skipping")
        return []

    labels_df = pd.read_csv(f"{LABELS_DIR}/{split_name}Labels.csv")
    labels_df.columns = labels_df.columns.str.strip()
    label_map = {}
    for _, row in labels_df.iterrows():
        clip_id = row['ClipID'].replace('.avi', '').replace('.mp4', '')
        label_map[clip_id] = {
            'confusion': int(row['Confusion']),
            'boredom': int(row['Boredom']),
            'engagement': int(row['Engagement']),
            'frustration': int(row['Frustration']),
        }

    out_dir = os.path.join(OUTPUT_DIR, split_name.lower())
    os.makedirs(os.path.join(out_dir, "confused"), exist_ok=True)
    os.makedirs(os.path.join(out_dir, "not_confused"), exist_ok=True)

    records = []
    processed = 0
    skipped = 0

    subjects = sorted(os.listdir(split_dir))
    subjects = [s for s in subjects if os.path.isdir(os.path.join(split_dir, s))]

    for si, subject in enumerate(subjects):
        subject_dir = os.path.join(split_dir, subject)
        clips = sorted(os.listdir(subject_dir))
        clips = [c for c in clips if os.path.isdir(os.path.join(subject_dir, c))]

        for clip_folder in clips:
            clip_dir = os.path.join(subject_dir, clip_folder)
            video_files = [f for f in os.listdir(clip_dir) if f.endswith(('.avi', '.mp4'))]

            if not video_files:
                skipped += 1
                continue

            clip_id = clip_folder
            if clip_id not in label_map:
                skipped += 1
                continue

            labels = label_map[clip_id]
            is_confused = 1 if labels['confusion'] >= 1 else 0
            class_dir = "confused" if is_confused else "not_confused"

            video_path = os.path.join(clip_dir, video_files[0])
            frame_out = os.path.join(out_dir, class_dir)
            frames = extract_frames_from_clip(video_path, frame_out)

            for fp in frames:
                records.append({
                    'frame_path': fp,
                    'clip_id': clip_id,
                    'subject': subject,
                    'is_confused': is_confused,
                    **labels,
                })
            processed += 1

        if (si + 1) % 5 == 0 or si == len(subjects) - 1:
            print(f"  [{split_name}] {si+1}/{len(subjects)} subjects | "
                  f"{processed} clips processed, {skipped} skipped")

    return records

def main():
    print("=" * 60)
    print("  DAiSEE Frame Extraction")
    print(f"  Frame size: {FRAME_SIZE}, Frames/clip: {FRAMES_PER_CLIP}")
    print("=" * 60)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    all_records = []

    for split in ['Train', 'Test', 'Validation']:
        print(f"\nProcessing {split}...")
        records = process_split(split)
        all_records.extend(records)
        print(f"  → {len(records)} frames extracted")

    if all_records:
        df = pd.DataFrame(all_records)
        csv_path = os.path.join(OUTPUT_DIR, "frame_labels.csv")
        df.to_csv(csv_path, index=False)
        print(f"\nTotal frames: {len(df)}")
        print(f"Confused: {df['is_confused'].sum()}")
        print(f"Not confused: {len(df) - df['is_confused'].sum()}")
        print(f"Labels saved: {csv_path}")
    else:
        print("\nNo frames extracted!")

    print("\nDONE!")

if __name__ == '__main__':
    main()
