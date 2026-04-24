import os, json, shutil, random, time
import numpy as np
from pathlib import Path
from collections import Counter

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, WeightedRandomSampler
from torchvision import transforms, datasets, models

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns

FRAMES_DIR = Path(__file__).parent / 'confusion_model' / 'frames'
OUTPUT_DIR = Path(__file__).parent / 'confusion_model' / 'output'
MODELS_DIR = OUTPUT_DIR / 'models'
MODELS_DIR.mkdir(parents=True, exist_ok=True)

IMG_SIZE = 260
BATCH_SIZE = 32
SEED = 42
PHASE1_EPOCHS = 25
PHASE2_EPOCHS = 60
NUM_WORKERS = 0

torch.manual_seed(SEED)
np.random.seed(SEED)
random.seed(SEED)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'Device: {device}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB')
    torch.backends.cudnn.benchmark = True


def balance_dataset():
    balanced = FRAMES_DIR / 'train_balanced'
    if balanced.exists():
        shutil.rmtree(balanced)
    for c in ['confused', 'not_confused']:
        (balanced / c).mkdir(parents=True, exist_ok=True)

    cf = list((FRAMES_DIR / 'train' / 'confused').iterdir())
    nf = list((FRAMES_DIR / 'train' / 'not_confused').iterdir())

    if len(cf) <= len(nf):
        mc, Mc, mf, Mf = 'confused', 'not_confused', cf, nf
    else:
        mc, Mc, mf, Mf = 'not_confused', 'confused', nf, cf

    for f in mf:
        shutil.copy2(f, balanced / mc / f.name)
    random.shuffle(Mf)
    for f in Mf[:len(mf)]:
        shutil.copy2(f, balanced / Mc / f.name)

    for c in ['confused', 'not_confused']:
        print(f'  {c}: {len(list((balanced / c).iterdir()))}')
    return balanced


def get_transforms():
    train_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE + 20, IMG_SIZE + 20)),
        transforms.RandomCrop(IMG_SIZE),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.15, hue=0.03),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        transforms.RandomErasing(p=0.15),
    ])
    val_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    return train_tf, val_tf


class FocalLoss(nn.Module):
    def __init__(self, alpha=0.5, gamma=2.0, label_smoothing=0.05):
        super().__init__()
        self.alpha = alpha
        self.gamma = gamma
        self.ls = label_smoothing

    def forward(self, inputs, targets):
        targets = targets * (1 - self.ls) + 0.5 * self.ls
        bce = nn.functional.binary_cross_entropy_with_logits(inputs, targets, reduction='none')
        pt = torch.exp(-bce)
        alpha_t = self.alpha * targets + (1 - self.alpha) * (1 - targets)
        loss = alpha_t * (1 - pt) ** self.gamma * bce
        return loss.mean()


class MixupDataset(torch.utils.data.Dataset):
    def __init__(self, dataset, alpha=0.2, prob=0.3):
        self.dataset = dataset
        self.alpha = alpha
        self.prob = prob

    def __len__(self):
        return len(self.dataset)

    def __getitem__(self, idx):
        img, label = self.dataset[idx]
        if random.random() < self.prob:
            idx2 = random.randint(0, len(self.dataset) - 1)
            img2, label2 = self.dataset[idx2]
            lam = np.random.beta(self.alpha, self.alpha)
            img = lam * img + (1 - lam) * img2
            label = lam * label + (1 - lam) * label2
        return img, float(label)


def build_model():
    base = models.efficientnet_v2_s(weights=models.EfficientNet_V2_S_Weights.IMAGENET1K_V1)
    for param in base.parameters():
        param.requires_grad = False

    base.classifier = nn.Sequential(
        nn.Dropout(0.4),
        nn.Linear(1280, 512),
        nn.SiLU(),
        nn.BatchNorm1d(512),
        nn.Dropout(0.3),
        nn.Linear(512, 256),
        nn.SiLU(),
        nn.BatchNorm1d(256),
        nn.Dropout(0.2),
        nn.Linear(256, 1),
    )
    return base.to(device)


def train_one_epoch(model, loader, criterion, optimizer, scaler=None):
    model.train()
    total_loss, correct, total = 0, 0, 0
    for imgs, labels in loader:
        imgs, labels = imgs.to(device), labels.float().to(device)
        optimizer.zero_grad(set_to_none=True)

        if scaler:
            with torch.amp.autocast('cuda'):
                out = model(imgs).squeeze(1)
                loss = criterion(out, labels)
            scaler.scale(loss).backward()
            scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            scaler.step(optimizer)
            scaler.update()
        else:
            out = model(imgs).squeeze(1)
            loss = criterion(out, labels)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            optimizer.step()

        total_loss += loss.item() * imgs.size(0)
        preds = (torch.sigmoid(out) > 0.5).long()
        correct += (preds == labels.round().long()).sum().item()
        total += imgs.size(0)
    return total_loss / total, correct / total


@torch.no_grad()
def evaluate(model, loader):
    model.eval()
    total_loss, correct, total = 0, 0, 0
    all_probs, all_labels = [], []
    criterion = nn.BCEWithLogitsLoss()
    for imgs, labels in loader:
        imgs, labels = imgs.to(device), labels.float().to(device)
        with torch.amp.autocast('cuda'):
            out = model(imgs).squeeze(1)
        loss = criterion(out, labels)
        total_loss += loss.item() * imgs.size(0)
        probs = torch.sigmoid(out)
        preds = (probs > 0.5).long()
        correct += (preds == labels.long()).sum().item()
        total += imgs.size(0)
        all_probs.extend(probs.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())
    acc = correct / total
    try:
        auc = roc_auc_score(all_labels, all_probs)
    except:
        auc = 0
    return total_loss / total, acc, auc


def tta_predict(model, test_dir, n=7):
    base_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    aug_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ColorJitter(brightness=0.1),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    all_preds = []
    filenames = None
    labels = None

    for i in range(n):
        tf = base_tf if i == 0 else aug_tf
        ds = datasets.ImageFolder(str(test_dir), transform=tf)
        loader = DataLoader(ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=NUM_WORKERS, pin_memory=True)
        if filenames is None:
            filenames = [Path(p).stem for p, _ in ds.samples]
            labels = np.array([l for _, l in ds.samples])

        model.eval()
        probs = []
        with torch.no_grad():
            for imgs, _ in loader:
                with torch.amp.autocast('cuda'):
                    out = model(imgs.to(device)).squeeze(1)
                probs.extend(torch.sigmoid(out).cpu().numpy())
        all_preds.append(np.array(probs))

    avg_probs = np.mean(all_preds, axis=0)
    return avg_probs, labels, filenames


def clip_voting(probs, labels, filenames):
    clips = {}
    clip_labels = {}
    for fn, label, prob in zip(filenames, labels, probs):
        parts = fn.rsplit('_f', 1)
        clip_name = parts[0] if len(parts) > 1 else fn
        if clip_name not in clips:
            clips[clip_name] = []
            clip_labels[clip_name] = label
        clips[clip_name].append(prob)

    ct = np.array([clip_labels[c] for c in clips])
    cp = np.array([1 if np.mean(clips[c]) > 0.5 else 0 for c in clips])
    return ct, cp


def main():
    print('=' * 60)
    print('CONFUSION DETECTION - LOCAL TRAINING v2')
    print('PyTorch + RTX 3060 | Mixed Precision | Mixup | Gradient Clipping')
    print('=' * 60)

    print('\n[1/8] Balancing dataset...')
    balanced_dir = balance_dataset()

    print('\n[2/8] Creating data loaders...')
    train_tf, val_tf = get_transforms()
    raw_train_ds = datasets.ImageFolder(str(balanced_dir), transform=train_tf)
    train_ds = MixupDataset(raw_train_ds, alpha=0.2, prob=0.3)

    val_dir = FRAMES_DIR / 'validation'
    if not (val_dir / 'confused').exists() or len(list((val_dir / 'confused').iterdir())) == 0:
        val_dir = FRAMES_DIR / 'test'
    val_ds = datasets.ImageFolder(str(val_dir), transform=val_tf)
    test_ds = datasets.ImageFolder(str(FRAMES_DIR / 'test'), transform=val_tf)

    class_counts = Counter(raw_train_ds.targets)
    weights = [1.0 / class_counts[t] for t in raw_train_ds.targets]
    sampler = WeightedRandomSampler(weights, len(weights))

    train_loader = DataLoader(train_ds, batch_size=BATCH_SIZE, sampler=sampler,
                              num_workers=NUM_WORKERS, pin_memory=True)
    val_loader = DataLoader(val_ds, batch_size=BATCH_SIZE, shuffle=False,
                            num_workers=NUM_WORKERS, pin_memory=True)
    test_loader = DataLoader(test_ds, batch_size=BATCH_SIZE, shuffle=False,
                             num_workers=NUM_WORKERS, pin_memory=True)

    print(f'  Train: {len(raw_train_ds)} | Val: {len(val_ds)} | Test: {len(test_ds)}')
    print(f'  Classes: {raw_train_ds.class_to_idx}')

    print('\n[3/8] Building EfficientNetV2-S model...')
    model = build_model()
    criterion = FocalLoss(alpha=0.5, gamma=2.0, label_smoothing=0.05)
    scaler = torch.amp.GradScaler('cuda')
    total_params = sum(p.numel() for p in model.parameters())
    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f'  Total params: {total_params:,} | Trainable: {trainable:,}')

    print(f'\n[4/8] Phase 1: Training classifier head ({PHASE1_EPOCHS} epochs)...')
    optimizer = optim.AdamW(filter(lambda p: p.requires_grad, model.parameters()), lr=5e-4, weight_decay=1e-3)
    scheduler = optim.lr_scheduler.OneCycleLR(optimizer, max_lr=5e-4, epochs=PHASE1_EPOCHS,
                                               steps_per_epoch=len(train_loader))
    best_auc, patience_counter = 0, 0

    for epoch in range(PHASE1_EPOCHS):
        t0 = time.time()
        model.train()
        total_loss, correct, total = 0, 0, 0
        for imgs, labels in train_loader:
            imgs, labels = imgs.to(device), labels.float().to(device)
            optimizer.zero_grad(set_to_none=True)
            with torch.amp.autocast('cuda'):
                out = model(imgs).squeeze(1)
                loss = criterion(out, labels)
            scaler.scale(loss).backward()
            scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            scaler.step(optimizer)
            scaler.update()
            scheduler.step()
            total_loss += loss.item() * imgs.size(0)
            preds = (torch.sigmoid(out) > 0.5).long()
            correct += (preds == labels.round().long()).sum().item()
            total += imgs.size(0)
        train_loss = total_loss / total
        train_acc = correct / total

        val_loss, val_acc, val_auc = evaluate(model, val_loader)
        elapsed = time.time() - t0

        print(f'  Epoch {epoch+1:2d}/{PHASE1_EPOCHS} | '
              f'Train Loss: {train_loss:.4f} Acc: {train_acc:.4f} | '
              f'Val Loss: {val_loss:.4f} Acc: {val_acc:.4f} AUC: {val_auc:.4f} | '
              f'{elapsed:.0f}s')

        if val_auc > best_auc:
            best_auc = val_auc
            torch.save(model.state_dict(), MODELS_DIR / 'best_phase1.pth')
            patience_counter = 0
        else:
            patience_counter += 1
            if patience_counter >= 7:
                print(f'  Early stopping at epoch {epoch+1}')
                break

    model.load_state_dict(torch.load(MODELS_DIR / 'best_phase1.pth', weights_only=True))
    print(f'  Phase 1 Best AUC: {best_auc:.4f}')

    print(f'\n[5/8] Phase 2: Fine-tuning backbone ({PHASE2_EPOCHS} epochs)...')
    for param in model.parameters():
        param.requires_grad = True
    frozen_layers = list(model.features.parameters())
    for param in frozen_layers[:-150]:
        param.requires_grad = False

    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f'  Trainable params: {trainable:,}')

    optimizer = optim.AdamW(filter(lambda p: p.requires_grad, model.parameters()), lr=2e-5, weight_decay=1e-3)
    scheduler = optim.lr_scheduler.CosineAnnealingWarmRestarts(optimizer, T_0=10, T_mult=2, eta_min=1e-7)
    best_auc_p2, patience_counter = best_auc, 0

    for epoch in range(PHASE2_EPOCHS):
        t0 = time.time()
        train_loss, train_acc = train_one_epoch(model, train_loader, criterion, optimizer, scaler)
        scheduler.step(epoch)
        val_loss, val_acc, val_auc = evaluate(model, val_loader)
        elapsed = time.time() - t0

        print(f'  Epoch {epoch+1:2d}/{PHASE2_EPOCHS} | '
              f'Train Loss: {train_loss:.4f} Acc: {train_acc:.4f} | '
              f'Val Loss: {val_loss:.4f} Acc: {val_acc:.4f} AUC: {val_auc:.4f} | '
              f'{elapsed:.0f}s')

        if val_auc > best_auc_p2:
            best_auc_p2 = val_auc
            torch.save(model.state_dict(), MODELS_DIR / 'best_model.pth')
            patience_counter = 0
        else:
            patience_counter += 1
            if patience_counter >= 12:
                print(f'  Early stopping at epoch {epoch+1}')
                break

    model.load_state_dict(torch.load(MODELS_DIR / 'best_model.pth', weights_only=True))
    print(f'  Phase 2 Best AUC: {best_auc_p2:.4f}')

    print('\n[6/8] Evaluating with TTA (7x) + Clip Voting...')
    probs, yt, filenames = tta_predict(model, FRAMES_DIR / 'test', n=7)
    ypb = (probs > 0.5).astype(int)

    print('\n=== FRAME-LEVEL ===')
    print(classification_report(yt, ypb, target_names=['Not Confused', 'Confused'], digits=4))
    try:
        auc = roc_auc_score(yt, probs)
        print(f'AUC: {auc:.4f}')
    except:
        auc = 0

    ct_a, cp_a = clip_voting(probs, yt, filenames)
    clip_acc = np.mean(ct_a == cp_a)
    print(f'\n=== CLIP-LEVEL === Accuracy: {clip_acc*100:.2f}%')
    print(classification_report(ct_a, cp_a, target_names=['Not Confused', 'Confused'], digits=4))

    print('\n[7/8] Generating plots...')
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    cm = confusion_matrix(yt, ypb)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[0],
                xticklabels=['Not Confused', 'Confused'], yticklabels=['Not Confused', 'Confused'])
    axes[0].set_title('Frame-level Confusion Matrix', fontweight='bold')

    cm2 = confusion_matrix(ct_a, cp_a)
    sns.heatmap(cm2, annot=True, fmt='d', cmap='Greens', ax=axes[1],
                xticklabels=['Not Confused', 'Confused'], yticklabels=['Not Confused', 'Confused'])
    axes[1].set_title('Clip-level Confusion Matrix', fontweight='bold')

    if auc > 0:
        fpr, tpr, _ = roc_curve(yt, probs)
        axes[2].plot(fpr, tpr, 'b-', lw=2, label=f'AUC={auc:.4f}')
        axes[2].plot([0, 1], [0, 1], 'r--')
        axes[2].legend()
        axes[2].set_title('ROC Curve', fontweight='bold')
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'results.png', dpi=150)
    print(f'  Saved: {OUTPUT_DIR}/results.png')

    print('\n[8/8] Exporting models...')
    torch.save(model.state_dict(), MODELS_DIR / 'confusion_detector.pth')

    model.eval()
    dummy = torch.randn(1, 3, IMG_SIZE, IMG_SIZE).to(device)
    traced = torch.jit.trace(model, dummy)
    traced.save(str(MODELS_DIR / 'confusion_detector.pt'))
    print(f'  TorchScript: {(MODELS_DIR / "confusion_detector.pt").stat().st_size / 1024 / 1024:.1f} MB')

    try:
        onnx_path = MODELS_DIR / 'confusion_detector.onnx'
        torch.onnx.export(model, dummy, str(onnx_path),
                          input_names=['input'], output_names=['output'],
                          dynamic_axes={'input': {0: 'batch'}, 'output': {0: 'batch'}},
                          opset_version=13)
        print(f'  ONNX: {onnx_path.stat().st_size / 1024 / 1024:.1f} MB')
    except Exception as e:
        print(f'  ONNX export skipped: {e}')

    frame_acc = float(np.mean(yt == ypb))
    meta = {
        'model': 'EfficientNetV2-S (PyTorch)',
        'input': [260, 260, 3],
        'techniques': ['Focal Loss', 'Two-phase', 'TTA 7x', 'Clip voting', 'Balanced 1:1',
                        'Mixup', 'Label Smoothing', 'Mixed Precision', 'Gradient Clipping',
                        'OneCycleLR', 'CosineAnnealingWarmRestarts', 'AdamW'],
        'frame_acc': frame_acc,
        'clip_acc': float(clip_acc),
        'auc': float(auc),
        'dataset': 'DAiSEE',
        'device': str(device),
        'class_mapping': {'0': 'confused', '1': 'not_confused'},
    }
    with open(MODELS_DIR / 'meta.json', 'w') as f:
        json.dump(meta, f, indent=2)

    print('\n' + '=' * 60)
    print('TRAINING COMPLETE!')
    print(f'  Frame Accuracy: {frame_acc*100:.2f}%')
    print(f'  Clip  Accuracy: {clip_acc*100:.2f}%')
    print(f'  AUC:            {auc:.4f}')
    print(f'  Models saved:   {MODELS_DIR}')
    print('=' * 60)


if __name__ == '__main__':
    main()
