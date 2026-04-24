import os, shutil
import pandas as pd
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
FRAMES_DIR = SCRIPT_DIR / 'frames'
OUTPUT_DIR = SCRIPT_DIR / 'frames_v2'
CSV_PATH = FRAMES_DIR / 'frame_labels.csv'

CONFUSION_THRESHOLD = 2

def main():
    print("Re-labeling frames with confusion >= 2...")
    df = pd.read_csv(CSV_PATH)
    print(f"Total frames: {len(df)}")

    confusion_dist = df['confusion'].value_counts().sort_index()
    print(f"Confusion distribution:\n{confusion_dist}")

    df['is_confused_v2'] = (df['confusion'] >= CONFUSION_THRESHOLD).astype(int)
    print(f"\nNew labels (confusion>={CONFUSION_THRESHOLD}):")
    print(f"  Confused: {df['is_confused_v2'].sum()}")
    print(f"  Not confused: {len(df) - df['is_confused_v2'].sum()}")

    for split in ['train', 'test', 'validation']:
        for cls in ['confused', 'not_confused']:
            (OUTPUT_DIR / split / cls).mkdir(parents=True, exist_ok=True)

    copied = 0
    for _, row in df.iterrows():
        src = Path(row['frame_path'])
        if not src.exists():
            continue

        if '/train/' in str(src) or '\\train\\' in str(src):
            split = 'train'
        elif '/test/' in str(src) or '\\test\\' in str(src):
            split = 'test'
        elif '/validation/' in str(src) or '\\validation\\' in str(src):
            split = 'validation'
        else:
            continue

        cls = 'confused' if row['is_confused_v2'] == 1 else 'not_confused'
        dst = OUTPUT_DIR / split / cls / src.name
        shutil.copy2(str(src), str(dst))
        copied += 1

        if copied % 5000 == 0:
            print(f"  Copied {copied} frames...")

    new_csv = OUTPUT_DIR / 'frame_labels.csv'
    df['is_confused'] = df['is_confused_v2']
    df['frame_path'] = df.apply(
        lambda r: str(OUTPUT_DIR / ('train' if '\\train\\' in r['frame_path'] or '/train/' in r['frame_path']
                       else 'test' if '\\test\\' in r['frame_path'] or '/test/' in r['frame_path']
                       else 'validation') / ('confused' if r['is_confused'] == 1 else 'not_confused') / Path(r['frame_path']).name),
        axis=1
    )
    df.drop(columns=['is_confused_v2'], inplace=True)
    df.to_csv(new_csv, index=False)

    print(f"\nCopied {copied} frames total")
    for split in ['train', 'test', 'validation']:
        for cls in ['confused', 'not_confused']:
            count = len(list((OUTPUT_DIR / split / cls).iterdir()))
            print(f"  {split}/{cls}: {count}")

    print(f"CSV saved: {new_csv}")
    print("DONE!")


if __name__ == '__main__':
    main()
