"""
CONFUSION DETECTION — Google Colab Training Script
===================================================
Binary: confused vs not_confused on DAiSEE dataset
Target: >90% accuracy via EfficientNetV2-S + advanced techniques

HOW TO RUN ON GOOGLE COLAB:
1. Upload this file to Colab
2. Upload DAiSEE dataset to Google Drive
3. Mount Drive and run cells below

SETUP CELL (run first in Colab):
!pip install -q tensorflow opencv-python-headless scikit-learn seaborn matplotlib

import google.colab
from google.colab import drive
drive.mount('/content/drive')
"""

import os
import json
import shutil
import random
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, callbacks
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
from sklearn.utils.class_weight import compute_class_weight

# ============================================================
# CONFIG
# ============================================================
DAISEE_ROOT = "/content/drive/MyDrive/DAiSEE/DAiSEE"
OUTPUT_DIR = "/content/confusion_output"
MODEL_DIR = os.path.join(OUTPUT_DIR, "models")
FRAMES_DIR = os.path.join(OUTPUT_DIR, "frames")

IMG_SIZE = (260, 260)
BATCH_SIZE = 32
EPOCHS_P1 = 20
EPOCHS_P2 = 50
CONFUSION_THRESHOLD = 1
FRAMES_PER_CLIP = 10
SEED = 42

os.makedirs(MODEL_DIR, exist_ok=True)
os.makedirs(FRAMES_DIR, exist_ok=True)

tf.random.set_seed(SEED)
np.random.seed(SEED)
random.seed(SEED)

print(f"TF version: {tf.__version__}")
print(f"GPU: {tf.config.list_physical_devices('GPU')}")

# ============================================================
# STEP 1: EXTRACT FRAMES FROM DAISEE VIDEOS
# ============================================================
def extract_frames():
    import cv2

    labels_dir = os.path.join(DAISEE_ROOT, "Labels")
    dataset_dir = os.path.join(DAISEE_ROOT, "DataSet")

    for split in ['Train', 'Test', 'Validation']:
        split_lower = split.lower()
        for cls in ['confused', 'not_confused']:
            os.makedirs(os.path.join(FRAMES_DIR, split_lower, cls), exist_ok=True)

        csv_path = os.path.join(labels_dir, f"{split}Labels.csv")
        if not os.path.exists(csv_path):
            print(f"  {csv_path} not found, skip")
            continue

        df = pd.read_csv(csv_path)
        df.columns = df.columns.str.strip()

        label_map = {}
        for _, row in df.iterrows():
            clip_id = row['ClipID'].replace('.avi', '').replace('.mp4', '')
            label_map[clip_id] = int(row['Confusion'])

        split_dir = os.path.join(dataset_dir, split)
        if not os.path.exists(split_dir):
            print(f"  {split_dir} not found, skip")
            continue

        count = 0
        subjects = sorted([s for s in os.listdir(split_dir) if os.path.isdir(os.path.join(split_dir, s))])

        for subject in subjects:
            subj_dir = os.path.join(split_dir, subject)
            clips = sorted([c for c in os.listdir(subj_dir) if os.path.isdir(os.path.join(subj_dir, c))])

            for clip_folder in clips:
                clip_dir = os.path.join(subj_dir, clip_folder)
                videos = [f for f in os.listdir(clip_dir) if f.endswith(('.avi', '.mp4'))]
                if not videos or clip_folder not in label_map:
                    continue

                confusion_level = label_map[clip_folder]
                is_confused = 1 if confusion_level >= CONFUSION_THRESHOLD else 0
                cls = "confused" if is_confused else "not_confused"

                video_path = os.path.join(clip_dir, videos[0])
                cap = cv2.VideoCapture(video_path)
                if not cap.isOpened():
                    continue

                total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
                if total <= 0:
                    cap.release()
                    continue

                indices = np.linspace(0, total - 1, FRAMES_PER_CLIP, dtype=int)
                for i, idx in enumerate(indices):
                    cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
                    ret, frame = cap.read()
                    if not ret:
                        continue

                    h, w = frame.shape[:2]
                    cx, cy = w // 2, h // 2
                    crop_size = min(h, w) * 3 // 4
                    x1 = max(0, cx - crop_size // 2)
                    y1 = max(0, cy - crop_size // 2)
                    face = frame[y1:y1+crop_size, x1:x1+crop_size]
                    face = cv2.resize(face, IMG_SIZE)

                    fname = f"{clip_folder}_f{i}.jpg"
                    cv2.imwrite(os.path.join(FRAMES_DIR, split_lower, cls, fname), face)

                cap.release()
                count += 1

        print(f"  {split}: {count} clips processed")

    for split in ['train', 'test', 'validation']:
        for cls in ['confused', 'not_confused']:
            d = os.path.join(FRAMES_DIR, split, cls)
            if os.path.exists(d):
                print(f"  {split}/{cls}: {len(os.listdir(d))} frames")


# ============================================================
# STEP 2: BALANCE DATASET
# ============================================================
def balance_dataset():
    train_dir = os.path.join(FRAMES_DIR, "train")
    balanced_dir = os.path.join(FRAMES_DIR, "train_balanced")

    if os.path.exists(balanced_dir):
        shutil.rmtree(balanced_dir)

    for cls in ['confused', 'not_confused']:
        os.makedirs(os.path.join(balanced_dir, cls), exist_ok=True)

    confused = os.listdir(os.path.join(train_dir, "confused"))
    not_confused = os.listdir(os.path.join(train_dir, "not_confused"))

    minority = min(len(confused), len(not_confused))
    majority_cls = "not_confused" if len(not_confused) > len(confused) else "confused"
    minority_cls = "confused" if majority_cls == "not_confused" else "not_confused"

    minority_files = confused if minority_cls == "confused" else not_confused
    majority_files = not_confused if majority_cls == "not_confused" else confused

    for f in minority_files:
        shutil.copy2(
            os.path.join(train_dir, minority_cls, f),
            os.path.join(balanced_dir, minority_cls, f)
        )

    target = int(minority * 1.2)
    random.shuffle(majority_files)
    for f in majority_files[:target]:
        shutil.copy2(
            os.path.join(train_dir, majority_cls, f),
            os.path.join(balanced_dir, majority_cls, f)
        )

    for cls in ['confused', 'not_confused']:
        print(f"  Balanced {cls}: {len(os.listdir(os.path.join(balanced_dir, cls)))}")

    return balanced_dir


# ============================================================
# STEP 3: DATA GENERATORS
# ============================================================
def create_generators(train_dir):
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=25,
        width_shift_range=0.15,
        height_shift_range=0.15,
        horizontal_flip=True,
        brightness_range=[0.7, 1.3],
        zoom_range=0.2,
        shear_range=0.1,
        channel_shift_range=25,
        fill_mode='nearest',
    )

    val_datagen = ImageDataGenerator(rescale=1./255)

    train_gen = train_datagen.flow_from_directory(
        train_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=True, seed=SEED,
    )

    val_dir = os.path.join(FRAMES_DIR, "validation")
    if not os.path.exists(val_dir):
        val_dir = os.path.join(FRAMES_DIR, "test")

    val_gen = val_datagen.flow_from_directory(
        val_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=False,
    )

    test_dir = os.path.join(FRAMES_DIR, "test")
    test_gen = val_datagen.flow_from_directory(
        test_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=False,
    )

    return train_gen, val_gen, test_gen


# ============================================================
# STEP 4: BUILD MODEL — EfficientNetV2S Pre-trained
# ============================================================
def build_model():
    base = keras.applications.EfficientNetV2S(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
    )
    base.trainable = False

    inputs = keras.Input(shape=(*IMG_SIZE, 3))
    x = base(inputs, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.5)(x)
    x = layers.Dense(512, activation='swish', kernel_regularizer=keras.regularizers.l2(1e-4))(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.4)(x)
    x = layers.Dense(256, activation='swish', kernel_regularizer=keras.regularizers.l2(1e-4))(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.3)(x)
    x = layers.Dense(128, activation='swish')(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(1, activation='sigmoid')(x)

    model = keras.Model(inputs, outputs)
    return model, base


def focal_loss(gamma=2.0, alpha=0.75):
    def loss_fn(y_true, y_pred):
        y_pred = tf.clip_by_value(y_pred, 1e-7, 1.0 - 1e-7)
        bce = -(y_true * tf.math.log(y_pred) + (1 - y_true) * tf.math.log(1 - y_pred))
        p_t = y_true * y_pred + (1 - y_true) * (1 - y_pred)
        alpha_t = y_true * alpha + (1 - y_true) * (1 - alpha)
        return tf.reduce_mean(alpha_t * tf.pow(1.0 - p_t, gamma) * bce)
    return loss_fn


# ============================================================
# STEP 5: TRAINING
# ============================================================
def train_model(model, base, train_gen, val_gen):
    class_w = compute_class_weight(
        'balanced', classes=np.array([0, 1]), y=train_gen.classes
    )
    class_weight = {0: class_w[0], 1: class_w[1]}
    print(f"Class weights: {class_weight}")

    model.compile(
        optimizer=keras.optimizers.Adam(1e-3),
        loss=focal_loss(gamma=2.0, alpha=0.75),
        metrics=['accuracy',
                 keras.metrics.Precision(name='precision'),
                 keras.metrics.Recall(name='recall'),
                 keras.metrics.AUC(name='auc')],
    )

    print(f"\n{'='*50}")
    print(f"Phase 1: Feature extraction ({EPOCHS_P1} epochs)")
    print(f"{'='*50}")

    h1 = model.fit(
        train_gen, validation_data=val_gen,
        epochs=EPOCHS_P1, class_weight=class_weight,
        callbacks=[
            callbacks.EarlyStopping(patience=5, restore_best_weights=True, monitor='val_auc', mode='max'),
            callbacks.ReduceLROnPlateau(factor=0.5, patience=2, min_lr=1e-6),
        ],
    )

    print(f"\n{'='*50}")
    print(f"Phase 2: Fine-tuning ({EPOCHS_P2} epochs)")
    print(f"{'='*50}")

    base.trainable = True
    for layer in base.layers[:-100]:
        layer.trainable = False

    model.compile(
        optimizer=keras.optimizers.Adam(1e-5),
        loss=focal_loss(gamma=2.0, alpha=0.75),
        metrics=['accuracy',
                 keras.metrics.Precision(name='precision'),
                 keras.metrics.Recall(name='recall'),
                 keras.metrics.AUC(name='auc')],
    )

    h2 = model.fit(
        train_gen, validation_data=val_gen,
        epochs=EPOCHS_P2, class_weight=class_weight,
        callbacks=[
            callbacks.EarlyStopping(patience=10, restore_best_weights=True, monitor='val_auc', mode='max'),
            callbacks.ReduceLROnPlateau(factor=0.3, patience=3, min_lr=1e-7),
            callbacks.LearningRateScheduler(
                lambda ep, lr: 1e-7 + 0.5 * (1e-5 - 1e-7) * (1 + np.cos(np.pi * ep / EPOCHS_P2))
            ),
        ],
    )

    return h1, h2


# ============================================================
# STEP 6: TTA PREDICTION
# ============================================================
def tta_predict(model, test_dir, n_aug=7):
    base_gen = ImageDataGenerator(rescale=1./255)
    aug_gen = ImageDataGenerator(
        rescale=1./255, rotation_range=10,
        width_shift_range=0.05, height_shift_range=0.05,
        horizontal_flip=True, brightness_range=[0.9, 1.1],
    )

    preds_list = []
    for i in range(n_aug):
        gen_cls = base_gen if i == 0 else aug_gen
        gen = gen_cls.flow_from_directory(
            test_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
            class_mode='binary', shuffle=False,
        )
        gen.reset()
        preds_list.append(model.predict(gen).flatten())

    return np.mean(preds_list, axis=0)


# ============================================================
# STEP 7: CLIP-LEVEL VOTING
# ============================================================
def clip_level_accuracy(y_true_frames, y_pred_frames, filenames):
    clip_preds = {}
    clip_trues = {}

    for fname, yt, yp in zip(filenames, y_true_frames, y_pred_frames):
        clip_id = '_'.join(Path(fname).stem.split('_')[:-1])
        if clip_id not in clip_preds:
            clip_preds[clip_id] = []
            clip_trues[clip_id] = yt
        clip_preds[clip_id].append(yp)

    clip_y_true = []
    clip_y_pred = []
    for clip_id in clip_preds:
        clip_y_true.append(clip_trues[clip_id])
        avg_pred = np.mean(clip_preds[clip_id])
        clip_y_pred.append(1 if avg_pred > 0.5 else 0)

    return np.array(clip_y_true), np.array(clip_y_pred)


# ============================================================
# STEP 8: EVALUATION + PLOTS
# ============================================================
def evaluate(model, test_gen, test_dir):
    print("\n--- TTA Prediction (7 augments) ---")
    y_pred_prob = tta_predict(model, test_dir)
    y_pred = (y_pred_prob > 0.5).astype(int)
    y_true = test_gen.classes[:len(y_pred)]

    print("\n=== FRAME-LEVEL Results ===")
    print(classification_report(y_true, y_pred, target_names=['Not Confused', 'Confused'], digits=4))

    try:
        auc = roc_auc_score(y_true, y_pred_prob[:len(y_true)])
        print(f"AUC-ROC: {auc:.4f}")
    except:
        auc = 0

    filenames = test_gen.filenames[:len(y_pred)]
    clip_true, clip_pred = clip_level_accuracy(y_true, y_pred, filenames)

    print("\n=== CLIP-LEVEL Results (majority voting) ===")
    clip_acc = np.mean(clip_true == clip_pred)
    print(f"Clip-level Accuracy: {clip_acc*100:.2f}%")
    print(classification_report(clip_true, clip_pred, target_names=['Not Confused', 'Confused'], digits=4))

    cm = confusion_matrix(y_true, y_pred)
    fig, axes = plt.subplots(1, 3, figsize=(20, 5))

    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[0],
                xticklabels=['Not Confused', 'Confused'],
                yticklabels=['Not Confused', 'Confused'])
    axes[0].set_title('Frame-level Confusion Matrix', fontweight='bold')
    axes[0].set_xlabel('Predicted')
    axes[0].set_ylabel('Actual')

    cm2 = confusion_matrix(clip_true, clip_pred)
    sns.heatmap(cm2, annot=True, fmt='d', cmap='Greens', ax=axes[1],
                xticklabels=['Not Confused', 'Confused'],
                yticklabels=['Not Confused', 'Confused'])
    axes[1].set_title('Clip-level Confusion Matrix', fontweight='bold')
    axes[1].set_xlabel('Predicted')
    axes[1].set_ylabel('Actual')

    if auc > 0:
        fpr, tpr, _ = roc_curve(y_true, y_pred_prob[:len(y_true)])
        axes[2].plot(fpr, tpr, 'b-', lw=2, label=f'AUC={auc:.4f}')
        axes[2].plot([0, 1], [0, 1], 'r--')
        axes[2].set_title('ROC Curve', fontweight='bold')
        axes[2].set_xlabel('FPR')
        axes[2].set_ylabel('TPR')
        axes[2].legend()

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "evaluation_results.png"), dpi=150)
    plt.show()
    print(f"Saved: evaluation_results.png")

    return {
        'frame_accuracy': float(np.mean(y_true == y_pred)),
        'clip_accuracy': float(clip_acc),
        'auc_roc': float(auc),
    }


# ============================================================
# STEP 9: EXPORT
# ============================================================
def export_model(model, metrics):
    model_path = os.path.join(MODEL_DIR, "confusion_detector.keras")
    model.save(model_path)
    print(f"Keras model: {model_path}")

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite = converter.convert()
    tflite_path = os.path.join(MODEL_DIR, "confusion_detector.tflite")
    with open(tflite_path, 'wb') as f:
        f.write(tflite)
    print(f"TFLite: {tflite_path} ({len(tflite)/1024/1024:.1f} MB)")

    meta = {
        'model': 'EfficientNetV2-S (pretrained ImageNet)',
        'task': 'Binary confusion detection',
        'input_size': list(IMG_SIZE) + [3],
        'output': 'sigmoid (0=not_confused, 1=confused)',
        'confusion_threshold': CONFUSION_THRESHOLD,
        'techniques': [
            'Focal Loss (gamma=2, alpha=0.75)',
            'Two-phase training (frozen + fine-tune)',
            'Cosine annealing LR',
            'Heavy augmentation',
            'Test-Time Augmentation (7x)',
            'Clip-level majority voting',
            'Class balancing',
        ],
        'metrics': metrics,
        'dataset': 'DAiSEE',
    }
    with open(os.path.join(MODEL_DIR, "model_meta.json"), 'w') as f:
        json.dump(meta, f, indent=2)
    print("Metadata saved")


# ============================================================
# MAIN
# ============================================================
def main():
    print("=" * 60)
    print("  Confusion Detection — Pre-trained Model Training")
    print("  EfficientNetV2-S | Focal Loss | TTA | Clip Voting")
    print("=" * 60)

    if not os.path.exists(os.path.join(FRAMES_DIR, "train", "confused")):
        print("\n[1/7] Extracting frames from DAiSEE videos...")
        extract_frames()
    else:
        print("\n[1/7] Frames already extracted, skipping")

    print("\n[2/7] Balancing dataset...")
    balanced_dir = balance_dataset()

    print("\n[3/7] Creating data generators...")
    train_gen, val_gen, test_gen = create_generators(balanced_dir)
    print(f"  Train: {train_gen.samples}, Val: {val_gen.samples}, Test: {test_gen.samples}")

    print("\n[4/7] Building EfficientNetV2-S model...")
    model, base = build_model()
    model.summary()

    print("\n[5/7] Training...")
    h1, h2 = train_model(model, base, train_gen, val_gen)

    test_dir = os.path.join(FRAMES_DIR, "test")
    print("\n[6/7] Evaluating...")
    metrics = evaluate(model, test_gen, test_dir)

    print("\n[7/7] Exporting...")
    export_model(model, metrics)

    print("\n" + "=" * 60)
    print(f"  FRAME Accuracy: {metrics['frame_accuracy']*100:.2f}%")
    print(f"  CLIP  Accuracy: {metrics['clip_accuracy']*100:.2f}%")
    print(f"  AUC-ROC:        {metrics['auc_roc']:.4f}")
    print("=" * 60)
    print("DONE!")


if __name__ == '__main__':
    main()
