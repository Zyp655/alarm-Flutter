import os
import json
import numpy as np

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import classification_report

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FRAMES_DIR = os.path.join(SCRIPT_DIR, "frames")
MODEL_DIR = os.path.join(SCRIPT_DIR, "models")

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
TEMPERATURE = 4.0
ALPHA = 0.7
EPOCHS = 30


def distillation_loss(y_true, y_pred):
    y_pred = tf.clip_by_value(y_pred, 1e-7, 1.0 - 1e-7)
    return -(y_true * tf.math.log(y_pred) + (1 - y_true) * tf.math.log(1 - y_pred))


def build_student():
    base = keras.applications.MobileNetV2(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
    )
    base.trainable = False

    model = keras.Sequential([
        base,
        layers.GlobalAveragePooling2D(),
        layers.Dropout(0.3),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(1, activation='sigmoid'),
    ])
    return model, base


def generate_soft_labels(teacher, data_dir, temperature=TEMPERATURE):
    datagen = ImageDataGenerator(rescale=1./255)
    gen = datagen.flow_from_directory(
        data_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=False,
    )

    gen.reset()
    hard_labels = gen.classes
    teacher_preds = teacher.predict(gen).flatten()

    logits = np.log(teacher_preds / (1 - np.clip(teacher_preds, 1e-7, 1 - 1e-7)))
    soft_labels = 1.0 / (1.0 + np.exp(-logits / temperature))

    combined = ALPHA * soft_labels + (1 - ALPHA) * hard_labels
    return gen, combined


def main():
    teacher_path = os.path.join(MODEL_DIR, "confusion_cnn.keras")
    if not os.path.exists(teacher_path):
        print(f"Teacher model not found: {teacher_path}")
        print("Run train_cnn.py first!")
        return

    print("=" * 60)
    print("  Knowledge Distillation: EfficientNetV2-S → MobileNetV2")
    print(f"  Temperature={TEMPERATURE}, Alpha={ALPHA}")
    print("=" * 60)

    teacher = keras.models.load_model(teacher_path, compile=False)
    print(f"Teacher loaded: {teacher_path}")

    train_dir = os.path.join(FRAMES_DIR, "train_balanced")
    if not os.path.exists(train_dir):
        train_dir = os.path.join(FRAMES_DIR, "train")

    val_dir = os.path.join(FRAMES_DIR, "validation")
    test_dir = os.path.join(FRAMES_DIR, "test")
    val_dir = val_dir if os.path.exists(val_dir) else test_dir

    print("\nGenerating soft labels from teacher...")
    train_gen, train_soft = generate_soft_labels(teacher, train_dir)

    val_datagen = ImageDataGenerator(rescale=1./255)
    val_gen = val_datagen.flow_from_directory(
        val_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=False,
    )

    print("\nBuilding student model...")
    student, base = build_student()
    student.compile(
        optimizer=keras.optimizers.Adam(1e-3),
        loss='binary_crossentropy',
        metrics=['accuracy'],
    )

    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=15,
        width_shift_range=0.1,
        height_shift_range=0.1,
        horizontal_flip=True,
        brightness_range=[0.8, 1.2],
    )
    train_gen_aug = train_datagen.flow_from_directory(
        train_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=True,
    )

    print(f"\n--- Phase 1: Train with soft labels ({EPOCHS} epochs) ---")
    student.fit(
        train_gen_aug,
        validation_data=val_gen,
        epochs=EPOCHS,
        callbacks=[
            keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True),
            keras.callbacks.ReduceLROnPlateau(factor=0.5, patience=2),
        ],
    )

    print(f"\n--- Phase 2: Fine-tune student (20 epochs) ---")
    base.trainable = True
    for layer in base.layers[:-30]:
        layer.trainable = False

    student.compile(
        optimizer=keras.optimizers.Adam(1e-5),
        loss='binary_crossentropy',
        metrics=['accuracy'],
    )

    student.fit(
        train_gen_aug,
        validation_data=val_gen,
        epochs=20,
        callbacks=[
            keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True),
        ],
    )

    test_gen = val_datagen.flow_from_directory(
        test_dir if os.path.exists(test_dir) else val_dir,
        target_size=IMG_SIZE, batch_size=BATCH_SIZE,
        class_mode='binary', shuffle=False,
    )
    test_gen.reset()
    y_pred = (student.predict(test_gen) > 0.5).astype(int).flatten()
    y_true = test_gen.classes[:len(y_pred)]
    print("\n--- Student Classification Report ---")
    print(classification_report(y_true, y_pred, target_names=['Not Confused', 'Confused']))

    student_path = os.path.join(MODEL_DIR, "confusion_student.keras")
    student.save(student_path)

    converter = tf.lite.TFLiteConverter.from_keras_model(student)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    tflite_path = os.path.join(MODEL_DIR, "confusion_student.tflite")
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)

    print(f"\nStudent saved: {student_path}")
    print(f"Student TFLite: {tflite_path} ({len(tflite_model)/1024/1024:.1f} MB)")
    print("DONE!")


if __name__ == '__main__':
    main()
