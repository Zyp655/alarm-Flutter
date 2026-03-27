import os
import json
import shutil
import random
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import classification_report, confusion_matrix
import seaborn as sns

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FRAMES_DIR = os.path.join(SCRIPT_DIR, "frames")
MODEL_DIR = os.path.join(SCRIPT_DIR, "models")
os.makedirs(MODEL_DIR, exist_ok=True)

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS_PHASE1 = 30
EPOCHS_PHASE2 = 40
UNDERSAMPLE_RATIO = 1.3
LABEL_SMOOTHING = 0.1
MIXUP_ALPHA = 0.2


def undersample_directory(train_dir, ratio=UNDERSAMPLE_RATIO):
    confused_dir = os.path.join(train_dir, "confused")
    not_confused_dir = os.path.join(train_dir, "not_confused")

    confused_files = os.listdir(confused_dir)
    not_confused_files = os.listdir(not_confused_dir)

    minority_count = len(confused_files)
    target_majority = int(minority_count * ratio)

    if len(not_confused_files) <= target_majority:
        print(f"  No undersampling needed ({len(not_confused_files)} <= {target_majority})")
        return None

    balanced_dir = os.path.join(os.path.dirname(train_dir), "train_balanced")
    os.makedirs(os.path.join(balanced_dir, "confused"), exist_ok=True)
    os.makedirs(os.path.join(balanced_dir, "not_confused"), exist_ok=True)

    for f in confused_files:
        shutil.copy2(os.path.join(confused_dir, f), os.path.join(balanced_dir, "confused", f))

    random.seed(42)
    selected = random.sample(not_confused_files, target_majority)
    for f in selected:
        shutil.copy2(os.path.join(not_confused_dir, f), os.path.join(balanced_dir, "not_confused", f))

    print(f"  Undersampled: confused={minority_count}, not_confused={target_majority} (ratio={ratio})")
    return balanced_dir


def focal_loss(gamma=2.0, alpha=0.75):
    def loss_fn(y_true, y_pred):
        y_true = y_true * (1.0 - LABEL_SMOOTHING) + 0.5 * LABEL_SMOOTHING
        y_pred = tf.clip_by_value(y_pred, 1e-7, 1.0 - 1e-7)
        bce = -(y_true * tf.math.log(y_pred) + (1 - y_true) * tf.math.log(1 - y_pred))
        p_t = y_true * y_pred + (1 - y_true) * (1 - y_pred)
        alpha_t = y_true * alpha + (1 - y_true) * (1 - alpha)
        focal_weight = alpha_t * tf.pow(1.0 - p_t, gamma)
        return tf.reduce_mean(focal_weight * bce)
    return loss_fn


class MixupGenerator(keras.utils.Sequence):
    def __init__(self, generator, alpha=MIXUP_ALPHA):
        self.generator = generator
        self.alpha = alpha
        self.batch_size = generator.batch_size
        self.samples = generator.samples
        self.n = len(generator)

    def __len__(self):
        return self.n

    def __getitem__(self, index):
        x1, y1 = self.generator[index]
        idx2 = np.random.randint(0, self.n)
        x2, y2 = self.generator[idx2]

        min_len = min(len(x1), len(x2))
        x1, y1 = x1[:min_len], y1[:min_len]
        x2, y2 = x2[:min_len], y2[:min_len]

        lam = np.random.beta(self.alpha, self.alpha)
        x_mix = lam * x1 + (1 - lam) * x2
        y_mix = lam * y1 + (1 - lam) * y2
        return x_mix, y_mix

    def on_epoch_end(self):
        self.generator.on_epoch_end()


def create_data_generators(use_balanced=True):
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=20,
        width_shift_range=0.15,
        height_shift_range=0.15,
        horizontal_flip=True,
        brightness_range=[0.7, 1.3],
        zoom_range=0.15,
        shear_range=0.1,
        channel_shift_range=20,
        fill_mode='nearest',
    )

    val_datagen = ImageDataGenerator(rescale=1./255)

    train_dir = os.path.join(FRAMES_DIR, "train")
    val_dir = os.path.join(FRAMES_DIR, "validation")
    test_dir = os.path.join(FRAMES_DIR, "test")

    if not os.path.exists(train_dir):
        print(f"Train dir not found: {train_dir}")
        print("Run extract_frames.py first!")
        return None, None, None

    actual_train_dir = train_dir
    if use_balanced:
        print("\n--- Undersampling majority class ---")
        balanced = undersample_directory(train_dir)
        if balanced:
            actual_train_dir = balanced

    train_gen = train_datagen.flow_from_directory(
        actual_train_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=True,
    )

    val_gen_dir = val_dir if os.path.exists(val_dir) else test_dir
    val_gen = val_datagen.flow_from_directory(
        val_gen_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=False,
    )

    test_gen = None
    if os.path.exists(test_dir) and test_dir != val_gen_dir:
        test_gen = val_datagen.flow_from_directory(
            test_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
            class_mode='binary', shuffle=False,
        )

    return train_gen, val_gen, test_gen


def build_model():
    base_model = keras.applications.EfficientNetV2S(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
    )
    base_model.trainable = False

    model = keras.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.BatchNormalization(),
        layers.Dropout(0.4),
        layers.Dense(256, activation='relu'),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(1, activation='sigmoid'),
    ])

    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=1e-3),
        loss=focal_loss(gamma=2.0, alpha=0.75),
        metrics=['accuracy', keras.metrics.Precision(name='prec'), keras.metrics.Recall(name='rec')],
    )

    return model, base_model


def cosine_warmup_schedule(epoch, lr, warmup_epochs=5, base_lr=1e-4, min_lr=1e-6, total_epochs=40):
    if epoch < warmup_epochs:
        return base_lr * (epoch + 1) / warmup_epochs
    progress = (epoch - warmup_epochs) / (total_epochs - warmup_epochs)
    return min_lr + 0.5 * (base_lr - min_lr) * (1 + np.cos(np.pi * progress))


def fine_tune(model, base_model, train_gen, val_gen):
    base_model.trainable = True
    for layer in base_model.layers[:-80]:
        layer.trainable = False

    trainable = sum(1 for l in model.layers for _ in [] if l.trainable) or sum(l.trainable for l in base_model.layers)
    print(f"  Trainable layers in base: {trainable}")

    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=1e-4),
        loss=focal_loss(gamma=2.0, alpha=0.75),
        metrics=['accuracy', keras.metrics.Precision(name='prec'), keras.metrics.Recall(name='rec')],
    )

    mixup_gen = MixupGenerator(train_gen, alpha=MIXUP_ALPHA)

    history_ft = model.fit(
        mixup_gen,
        validation_data=val_gen,
        epochs=EPOCHS_PHASE2,
        callbacks=[
            keras.callbacks.EarlyStopping(patience=8, restore_best_weights=True, monitor='val_loss'),
            keras.callbacks.LearningRateScheduler(
                lambda epoch, lr: cosine_warmup_schedule(epoch, lr, total_epochs=EPOCHS_PHASE2)
            ),
        ],
    )

    return history_ft


def tta_predict(model, test_gen, n_augments=5):
    test_datagen_tta = ImageDataGenerator(
        rescale=1./255,
        rotation_range=10,
        width_shift_range=0.05,
        height_shift_range=0.05,
        horizontal_flip=True,
        brightness_range=[0.9, 1.1],
    )

    test_dir = test_gen.directory
    predictions = []

    for i in range(n_augments):
        if i == 0:
            gen = test_gen
        else:
            gen = test_datagen_tta.flow_from_directory(
                test_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
                class_mode='binary', shuffle=False,
            )
        gen.reset()
        preds = model.predict(gen)
        predictions.append(preds)

    avg_preds = np.mean(predictions, axis=0)
    return avg_preds


def plot_history(history, filename):
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(history.history['accuracy'], label='Train')
    axes[0].plot(history.history['val_accuracy'], label='Validation')
    axes[0].set_title('Accuracy', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Epoch')
    axes[0].legend()
    axes[0].grid(alpha=0.3)

    axes[1].plot(history.history['loss'], label='Train')
    axes[1].plot(history.history['val_loss'], label='Validation')
    axes[1].set_title('Loss', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Epoch')
    axes[1].legend()
    axes[1].grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(SCRIPT_DIR, filename), dpi=150)
    print(f"Saved: {filename}")


def evaluate(model, test_gen, use_tta=True):
    if test_gen is None:
        return {}

    if use_tta:
        print("\n--- Test Time Augmentation (5 passes) ---")
        y_pred_prob = tta_predict(model, test_gen)
    else:
        test_gen.reset()
        y_pred_prob = model.predict(test_gen)

    y_pred = (y_pred_prob > 0.5).astype(int).flatten()
    y_true = test_gen.classes

    min_len = min(len(y_true), len(y_pred))
    y_true = y_true[:min_len]
    y_pred = y_pred[:min_len]

    print("\n--- Classification Report ---")
    report = classification_report(y_true, y_pred,
                                   target_names=['Not Confused', 'Confused'],
                                   output_dict=True)
    print(classification_report(y_true, y_pred,
                                target_names=['Not Confused', 'Confused']))

    cm = confusion_matrix(y_true, y_pred)
    fig, ax = plt.subplots(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax,
                xticklabels=['Not Confused', 'Confused'],
                yticklabels=['Not Confused', 'Confused'])
    ax.set_title('EfficientNetV2-S Confusion Matrix', fontsize=14, fontweight='bold')
    ax.set_xlabel('Predicted')
    ax.set_ylabel('Actual')
    plt.tight_layout()
    plt.savefig(os.path.join(SCRIPT_DIR, "cnn_confusion_matrix.png"), dpi=150)
    print("Saved: cnn_confusion_matrix.png")

    return report


def main():
    print("=" * 60)
    print("  DAiSEE Confusion Detection — Upgraded CNN Training")
    print(f"  EfficientNetV2-S | {IMG_SIZE} | Focal Loss + Mixup + TTA")
    print("=" * 60)

    gpus = tf.config.list_physical_devices('GPU')
    print(f"GPUs available: {len(gpus)}")
    if gpus:
        for gpu in gpus:
            print(f"  {gpu}")

    train_gen, val_gen, test_gen = create_data_generators()
    if train_gen is None:
        return

    print(f"\nTrain samples: {train_gen.samples}")
    print(f"Validation samples: {val_gen.samples}")
    if test_gen:
        print(f"Test samples: {test_gen.samples}")

    confused_count = train_gen.classes.sum()
    not_confused_count = len(train_gen.classes) - confused_count
    if confused_count > 0:
        class_weight = {
            0: len(train_gen.classes) / (2 * not_confused_count),
            1: len(train_gen.classes) / (2 * confused_count),
        }
    else:
        class_weight = {0: 1.0, 1: 1.0}
    print(f"Class distribution: confused={int(confused_count)}, not_confused={int(not_confused_count)}")
    print(f"Class weights: {class_weight}")

    print(f"\n--- Phase 1: Feature Extraction ({EPOCHS_PHASE1} epochs, frozen base) ---")
    model, base_model = build_model()
    model.summary()

    history = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=EPOCHS_PHASE1,
        class_weight=class_weight,
        callbacks=[
            keras.callbacks.EarlyStopping(patience=7, restore_best_weights=True),
            keras.callbacks.ReduceLROnPlateau(factor=0.5, patience=3, min_lr=1e-6),
        ],
    )
    plot_history(history, "cnn_training_phase1.png")

    print(f"\n--- Phase 2: Fine-tuning ({EPOCHS_PHASE2} epochs, last 80 layers, Mixup + Cosine LR) ---")
    history_ft = fine_tune(model, base_model, train_gen, val_gen)
    plot_history(history_ft, "cnn_training_phase2.png")

    eval_gen = test_gen if test_gen else val_gen
    report = evaluate(model, eval_gen, use_tta=True)

    model_path = os.path.join(MODEL_DIR, "confusion_cnn.keras")
    model.save(model_path)
    print(f"\nModel saved: {model_path}")

    tflite_path = os.path.join(MODEL_DIR, "confusion_cnn.tflite")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    print(f"TFLite model saved: {tflite_path} ({len(tflite_model)/1024/1024:.1f} MB)")

    meta = {
        'model_name': 'EfficientNetV2-S (Transfer Learning + Focal Loss + Mixup + TTA)',
        'input_size': list(IMG_SIZE) + [3],
        'output': 'sigmoid (0=not_confused, 1=confused)',
        'train_samples': train_gen.samples,
        'val_samples': val_gen.samples,
        'epochs_phase1': EPOCHS_PHASE1,
        'epochs_phase2': EPOCHS_PHASE2,
        'loss': 'focal_loss (gamma=2.0, alpha=0.75)',
        'label_smoothing': LABEL_SMOOTHING,
        'mixup_alpha': MIXUP_ALPHA,
        'tta_augments': 5,
        'fine_tune_layers': 80,
        'undersampling_ratio': UNDERSAMPLE_RATIO,
        'class_weight': {str(k): v for k, v in class_weight.items()},
        'dataset': 'DAiSEE (video frames, face-cropped)',
        'report': {k: v for k, v in report.items() if isinstance(v, dict)} if report else {},
    }
    meta_path = os.path.join(MODEL_DIR, "cnn_model_meta.json")
    with open(meta_path, 'w') as f:
        json.dump(meta, f, indent=2)
    print(f"Metadata saved: {meta_path}")

    print("\n" + "=" * 60)
    print("  DONE! Upgraded CNN model trained and exported.")
    print(f"  Keras: {model_path}")
    print(f"  TFLite: {tflite_path}")
    print("=" * 60)

if __name__ == '__main__':
    main()
