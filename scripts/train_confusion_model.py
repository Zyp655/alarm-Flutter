"""
Confusion Detection Model Training Script
==========================================
Train a custom MobileNetV3-Small model to detect:
  - confused, focused, frustrated, bored, neutral
  
Uses FER2013 dataset from HuggingFace, re-mapped to confusion-relevant classes.
Exports to TensorFlow.js for browser deployment.
"""

# ============================================================
# CELL 1: Install dependencies
# ============================================================
# !pip install -q torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
# !pip install -q datasets pillow scikit-learn tensorflowjs tensorflow onnx onnx-tf

# ============================================================
# CELL 2: Imports
# ============================================================
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, models
from datasets import load_dataset
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np
from PIL import Image
import os
import json
import time

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {DEVICE}")

# ============================================================
# CELL 3: Load and re-map FER2013
# ============================================================
"""
FER2013 original labels:
  0=angry, 1=disgust, 2=fear, 3=happy, 4=sad, 5=surprise, 6=neutral

Re-mapping for confusion detection:
  confused  = fear + surprise + sad (uncertainty signals)
  frustrated = angry + disgust (negative arousal)
  focused   = happy (positive engagement proxy)
  bored     = subset of neutral (low arousal)
  neutral   = neutral
"""

FER_TO_CONFUSION = {
    0: 'frustrated',   # angry -> frustrated
    1: 'frustrated',   # disgust -> frustrated
    2: 'confused',     # fear -> confused
    3: 'focused',      # happy -> focused/engaged
    4: 'confused',     # sad -> confused
    5: 'confused',     # surprise -> confused
    6: 'neutral',      # neutral -> neutral
}

CLASS_NAMES = ['confused', 'focused', 'frustrated', 'neutral', 'bored']
CLASS_TO_IDX = {name: idx for idx, name in enumerate(CLASS_NAMES)}
NUM_CLASSES = len(CLASS_NAMES)

print("Loading FER2013 dataset from HuggingFace...")
ds = load_dataset("uoft-cs/fer2013", trust_remote_code=True)
print(f"Train size: {len(ds['train'])}, Test size: {len(ds['test'])}")

# ============================================================
# CELL 4: Create balanced dataset with bored class
# ============================================================
class ConfusionDataset(Dataset):
    def __init__(self, hf_dataset, transform=None):
        self.transform = transform
        self.images = []
        self.labels = []

        class_counts = {name: 0 for name in CLASS_NAMES}

        for item in hf_dataset:
            fer_label = item['label']
            confusion_label = FER_TO_CONFUSION[fer_label]

            img = item['image']
            if img.mode != 'RGB':
                img = img.convert('RGB')

            self.images.append(img)
            self.labels.append(CLASS_TO_IDX[confusion_label])
            class_counts[confusion_label] += 1

        neutral_indices = [i for i, l in enumerate(self.labels) if l == CLASS_TO_IDX['neutral']]
        np.random.seed(42)
        bored_count = min(len(neutral_indices) // 3, 2000)
        bored_indices = np.random.choice(neutral_indices, bored_count, replace=False)

        for idx in bored_indices:
            self.labels[idx] = CLASS_TO_IDX['bored']
            class_counts['bored'] += 1
            class_counts['neutral'] -= 1

        print(f"Class distribution: {class_counts}")

    def __len__(self):
        return len(self.images)

    def __getitem__(self, idx):
        img = self.images[idx]
        label = self.labels[idx]
        if self.transform:
            img = self.transform(img)
        return img, label


train_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.RandomHorizontalFlip(p=0.5),
    transforms.RandomRotation(15),
    transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.2),
    transforms.RandomAffine(degrees=0, translate=(0.1, 0.1)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

val_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

print("Creating training dataset...")
train_dataset = ConfusionDataset(ds['train'], transform=train_transform)
val_dataset = ConfusionDataset(ds['test'], transform=val_transform)

train_labels = train_dataset.labels
class_counts_tensor = torch.zeros(NUM_CLASSES)
for l in train_labels:
    class_counts_tensor[l] += 1
class_weights = 1.0 / class_counts_tensor
class_weights = class_weights / class_weights.sum() * NUM_CLASSES
print(f"Class weights: {class_weights}")

train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True, num_workers=2, pin_memory=True)
val_loader = DataLoader(val_dataset, batch_size=64, shuffle=False, num_workers=2, pin_memory=True)

# ============================================================
# CELL 5: Build Model
# ============================================================
class ConfusionNet(nn.Module):
    def __init__(self, num_classes=5):
        super().__init__()
        self.backbone = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.IMAGENET1K_V1)
        in_features = self.backbone.classifier[0].in_features
        self.backbone.classifier = nn.Sequential(
            nn.Linear(in_features, 256),
            nn.Hardswish(),
            nn.Dropout(p=0.3),
            nn.Linear(256, 128),
            nn.Hardswish(),
            nn.Dropout(p=0.2),
            nn.Linear(128, num_classes),
        )

    def forward(self, x):
        return self.backbone(x)

model = ConfusionNet(NUM_CLASSES).to(DEVICE)
criterion = nn.CrossEntropyLoss(weight=class_weights.to(DEVICE))
optimizer = optim.AdamW(model.parameters(), lr=1e-4, weight_decay=1e-4)
scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=40, eta_min=1e-6)

total_params = sum(p.numel() for p in model.parameters())
trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
print(f"Total params: {total_params:,} | Trainable: {trainable_params:,}")

# ============================================================
# CELL 6: Training Loop
# ============================================================
NUM_EPOCHS = 40
best_val_acc = 0
best_model_state = None
history = {'train_loss': [], 'train_acc': [], 'val_loss': [], 'val_acc': []}

print(f"\n{'='*60}")
print(f"Starting training for {NUM_EPOCHS} epochs...")
print(f"{'='*60}\n")

for epoch in range(NUM_EPOCHS):
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    start_time = time.time()

    for images, labels in train_loader:
        images, labels = images.to(DEVICE), labels.to(DEVICE)
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        running_loss += loss.item() * images.size(0)
        _, predicted = outputs.max(1)
        total += labels.size(0)
        correct += predicted.eq(labels).sum().item()

    train_loss = running_loss / total
    train_acc = 100.0 * correct / total

    model.eval()
    val_loss = 0.0
    val_correct = 0
    val_total = 0

    with torch.no_grad():
        for images, labels in val_loader:
            images, labels = images.to(DEVICE), labels.to(DEVICE)
            outputs = model(images)
            loss = criterion(outputs, labels)
            val_loss += loss.item() * images.size(0)
            _, predicted = outputs.max(1)
            val_total += labels.size(0)
            val_correct += predicted.eq(labels).sum().item()

    val_loss = val_loss / val_total
    val_acc = 100.0 * val_correct / val_total
    elapsed = time.time() - start_time

    history['train_loss'].append(train_loss)
    history['train_acc'].append(train_acc)
    history['val_loss'].append(val_loss)
    history['val_acc'].append(val_acc)

    scheduler.step()

    if val_acc > best_val_acc:
        best_val_acc = val_acc
        best_model_state = model.state_dict().copy()
        marker = ' ★ BEST'
    else:
        marker = ''

    print(f"Epoch [{epoch+1:2d}/{NUM_EPOCHS}] "
          f"Train Loss: {train_loss:.4f} Acc: {train_acc:.2f}% | "
          f"Val Loss: {val_loss:.4f} Acc: {val_acc:.2f}% | "
          f"LR: {scheduler.get_last_lr()[0]:.6f} | "
          f"Time: {elapsed:.1f}s{marker}")

print(f"\n{'='*60}")
print(f"Best Validation Accuracy: {best_val_acc:.2f}%")
print(f"{'='*60}")

# ============================================================
# CELL 7: Evaluate best model
# ============================================================
model.load_state_dict(best_model_state)
model.eval()

all_preds = []
all_labels = []

with torch.no_grad():
    for images, labels in val_loader:
        images = images.to(DEVICE)
        outputs = model(images)
        _, predicted = outputs.max(1)
        all_preds.extend(predicted.cpu().numpy())
        all_labels.extend(labels.numpy())

print("\nClassification Report:")
print(classification_report(all_labels, all_preds, target_names=CLASS_NAMES, digits=3))

cm = confusion_matrix(all_labels, all_preds)
print("Confusion Matrix:")
print(cm)

# ============================================================
# CELL 8: Export to ONNX then TensorFlow.js
# ============================================================
EXPORT_DIR = '/content/confusion_model_export'
os.makedirs(EXPORT_DIR, exist_ok=True)

model.eval()
model.cpu()
dummy_input = torch.randn(1, 3, 224, 224)
onnx_path = os.path.join(EXPORT_DIR, 'confusion_model.onnx')

torch.onnx.export(
    model,
    dummy_input,
    onnx_path,
    export_params=True,
    opset_version=13,
    do_constant_folding=True,
    input_names=['input'],
    output_names=['output'],
    dynamic_axes={'input': {0: 'batch_size'}, 'output': {0: 'batch_size'}},
)
print(f"\nONNX model saved to: {onnx_path}")
print(f"ONNX file size: {os.path.getsize(onnx_path) / 1024 / 1024:.2f} MB")

import subprocess
tfjs_dir = os.path.join(EXPORT_DIR, 'tfjs_model')
os.makedirs(tfjs_dir, exist_ok=True)

subprocess.run([
    'python', '-m', 'tensorflowjs_converter',
    '--input_format=tf_saved_model',
    '--output_format=tfjs_graph_model',
    '--signature_name=serving_default',
    '--saved_model_tags=serve',
    onnx_path.replace('.onnx', '_saved_model'),
    tfjs_dir,
], check=False)

torch.save(best_model_state, os.path.join(EXPORT_DIR, 'confusion_model.pth'))
print(f"PyTorch weights saved to: {EXPORT_DIR}/confusion_model.pth")

meta = {
    'class_names': CLASS_NAMES,
    'class_to_idx': CLASS_TO_IDX,
    'input_size': 224,
    'num_classes': NUM_CLASSES,
    'best_val_accuracy': best_val_acc,
    'normalization': {
        'mean': [0.485, 0.456, 0.406],
        'std': [0.229, 0.224, 0.225],
    },
}
with open(os.path.join(EXPORT_DIR, 'model_meta.json'), 'w') as f:
    json.dump(meta, f, indent=2)

print(f"\nModel metadata saved.")
print(f"Classes: {CLASS_NAMES}")
print(f"Best accuracy: {best_val_acc:.2f}%")
print(f"\nAll exports in: {EXPORT_DIR}")
print("Done!")
