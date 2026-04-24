import os, json, shutil, random, time, copy
import numpy as np
from pathlib import Path
from collections import Counter

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset, WeightedRandomSampler
from torchvision import transforms, models
from PIL import Image

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

FRAMES_DIR = Path(__file__).parent / 'frames_v2'
OUTPUT_DIR = Path(__file__).parent / 'output_v3'
MODELS_DIR = OUTPUT_DIR / 'models'
MODELS_DIR.mkdir(parents=True, exist_ok=True)

IMG_SIZE = 224
BATCH_SIZE = 16
SEQ_LEN = 5
SEED = 42
PHASE1_EPOCHS = 15
PHASE2_EPOCHS = 30
PHASE3_EPOCHS = 20

torch.manual_seed(SEED)
np.random.seed(SEED)
random.seed(SEED)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'Device: {device}')
if torch.cuda.is_available():
    print(f'GPU: {torch.cuda.get_device_name(0)}')
    torch.backends.cudnn.benchmark = True


class ClipDataset(Dataset):
    def __init__(self, csv_path, split, transform=None, seq_len=SEQ_LEN):
        df = pd.read_csv(csv_path)
        df = df[df['frame_path'].str.contains(f'/{split}/' if '/' in df['frame_path'].iloc[0] else f'\\\\{split}\\\\', regex=True)]

        self.transform = transform
        self.seq_len = seq_len
        self.clips = []

        grouped = df.groupby('clip_id')
        for clip_id, group in grouped:
            group = group.sort_values('frame_path')
            frames = group['frame_path'].tolist()
            label = int(group['is_confused'].iloc[0])
            aux = [
                float(group['boredom'].iloc[0]) / 3.0,
                float(group['engagement'].iloc[0]) / 3.0,
                float(group['frustration'].iloc[0]) / 3.0,
            ]
            aux.append(aux[0] / (aux[1] + 0.01))
            aux.append(aux[0] + aux[2])
            self.clips.append({
                'frames': frames,
                'label': label,
                'aux': aux,
                'clip_id': clip_id,
            })

    def __len__(self):
        return len(self.clips)

    def __getitem__(self, idx):
        clip = self.clips[idx]
        frames = clip['frames']

        if len(frames) >= self.seq_len:
            indices = np.linspace(0, len(frames) - 1, self.seq_len, dtype=int)
            frames = [frames[i] for i in indices]
        else:
            while len(frames) < self.seq_len:
                frames.append(frames[-1])

        imgs = []
        for fp in frames:
            try:
                img = Image.open(fp).convert('RGB')
            except:
                img = Image.new('RGB', (IMG_SIZE, IMG_SIZE))
            if self.transform:
                img = self.transform(img)
            imgs.append(img)

        sequence = torch.stack(imgs)
        aux = torch.tensor(clip['aux'], dtype=torch.float32)
        label = torch.tensor(clip['label'], dtype=torch.float32)
        return sequence, aux, label


class SEBlock(nn.Module):
    def __init__(self, channels, reduction=16):
        super().__init__()
        self.pool = nn.AdaptiveAvgPool1d(1)
        self.fc = nn.Sequential(
            nn.Linear(channels, channels // reduction),
            nn.SiLU(),
            nn.Linear(channels // reduction, channels),
            nn.Sigmoid(),
        )

    def forward(self, x):
        b, c = x.shape
        w = self.fc(x)
        return x * w


class TemporalConfusionModel(nn.Module):
    def __init__(self, num_aux=5, hidden_size=256):
        super().__init__()
        base = models.efficientnet_v2_s(weights=models.EfficientNet_V2_S_Weights.IMAGENET1K_V1)
        self.backbone = nn.Sequential(*list(base.children())[:-1])
        self.feat_dim = 1280

        self.se = SEBlock(self.feat_dim)
        self.lstm = nn.LSTM(self.feat_dim, hidden_size, num_layers=2,
                            batch_first=True, bidirectional=True, dropout=0.3)

        self.attn = nn.Sequential(
            nn.Linear(hidden_size * 2, 1),
            nn.Softmax(dim=1),
        )

        fusion_dim = hidden_size * 2 + num_aux
        self.head = nn.Sequential(
            nn.LayerNorm(fusion_dim),
            nn.Dropout(0.4),
            nn.Linear(fusion_dim, 256),
            nn.SiLU(),
            nn.BatchNorm1d(256),
            nn.Dropout(0.3),
            nn.Linear(256, 128),
            nn.SiLU(),
            nn.Dropout(0.2),
            nn.Linear(128, 1),
        )

    def freeze_backbone(self):
        for p in self.backbone.parameters():
            p.requires_grad = False

    def unfreeze_backbone(self, last_n=150):
        params = list(self.backbone.parameters())
        for p in params:
            p.requires_grad = False
        for p in params[-last_n:]:
            p.requires_grad = True

    def unfreeze_all(self):
        for p in self.backbone.parameters():
            p.requires_grad = True

    def forward(self, seq, aux):
        B, T, C, H, W = seq.shape
        x = seq.view(B * T, C, H, W)
        x = self.backbone(x).flatten(1)
        x = self.se(x)
        x = x.view(B, T, self.feat_dim)

        lstm_out, _ = self.lstm(x)
        attn_w = self.attn(lstm_out)
        context = (attn_w * lstm_out).sum(dim=1)

        fused = torch.cat([context, aux], dim=1)
        return self.head(fused).squeeze(1)


class FocalLoss(nn.Module):
    def __init__(self, alpha=0.6, gamma=2.0, smoothing=0.05):
        super().__init__()
        self.alpha = alpha
        self.gamma = gamma
        self.smoothing = smoothing

    def forward(self, inputs, targets):
        targets = targets * (1 - self.smoothing) + 0.5 * self.smoothing
        bce = nn.functional.binary_cross_entropy_with_logits(inputs, targets, reduction='none')
        pt = torch.exp(-bce)
        alpha_t = self.alpha * targets + (1 - self.alpha) * (1 - targets)
        return (alpha_t * (1 - pt) ** self.gamma * bce).mean()


class EMA:
    def __init__(self, model, decay=0.999):
        self.decay = decay
        self.shadow = {k: v.clone().detach() for k, v in model.state_dict().items()}

    def update(self, model):
        for k, v in model.state_dict().items():
            self.shadow[k] = self.decay * self.shadow[k] + (1 - self.decay) * v

    def apply(self, model):
        model.load_state_dict(self.shadow)


def get_transforms():
    train_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE + 20, IMG_SIZE + 20)),
        transforms.RandomCrop(IMG_SIZE),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.2, hue=0.05),
        transforms.RandomPerspective(distortion_scale=0.2, p=0.3),
        transforms.RandomGrayscale(p=0.05),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        transforms.RandomErasing(p=0.2),
    ])
    val_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    return train_tf, val_tf


@torch.no_grad()
def evaluate(model, loader):
    model.eval()
    total_loss, correct, total = 0, 0, 0
    all_probs, all_labels = [], []
    criterion = nn.BCEWithLogitsLoss()

    for seq, aux, labels in loader:
        seq, aux, labels = seq.to(device), aux.to(device), labels.to(device)
        with torch.amp.autocast('cuda'):
            out = model(seq, aux)
        loss = criterion(out, labels)
        total_loss += loss.item() * seq.size(0)
        probs = torch.sigmoid(out)
        preds = (probs > 0.5).long()
        correct += (preds == labels.long()).sum().item()
        total += seq.size(0)
        all_probs.extend(probs.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())

    acc = correct / total
    try:
        auc = roc_auc_score(all_labels, all_probs)
    except:
        auc = 0
    return total_loss / total, acc, auc


def find_optimal_threshold(model, loader):
    model.eval()
    all_probs, all_labels = [], []
    with torch.no_grad():
        for seq, aux, labels in loader:
            seq, aux, labels = seq.to(device), aux.to(device), labels.to(device)
            with torch.amp.autocast('cuda'):
                out = model(seq, aux)
            all_probs.extend(torch.sigmoid(out).cpu().numpy())
            all_labels.extend(labels.cpu().numpy())

    best_t, best_f1 = 0.5, 0
    for t in np.arange(0.3, 0.7, 0.01):
        preds = (np.array(all_probs) > t).astype(int)
        tp = ((preds == 1) & (np.array(all_labels) == 1)).sum()
        fp = ((preds == 1) & (np.array(all_labels) == 0)).sum()
        fn = ((preds == 0) & (np.array(all_labels) == 1)).sum()
        prec = tp / (tp + fp + 1e-8)
        rec = tp / (tp + fn + 1e-8)
        f1 = 2 * prec * rec / (prec + rec + 1e-8)
        if f1 > best_f1:
            best_f1 = f1
            best_t = t
    return best_t


def train_phase(model, train_loader, val_loader, optimizer, scheduler, scaler,
                criterion, ema, epochs, phase_name, patience_limit=10):
    best_auc = 0
    patience = 0
    history = {'train_loss': [], 'train_acc': [], 'val_loss': [], 'val_acc': [], 'val_auc': []}

    for epoch in range(epochs):
        torch.cuda.empty_cache()
        t0 = time.time()
        model.train()
        total_loss, correct, total = 0, 0, 0

        for seq, aux, labels in train_loader:
            seq, aux, labels = seq.to(device), aux.to(device), labels.to(device)
            optimizer.zero_grad(set_to_none=True)

            with torch.amp.autocast('cuda'):
                out = model(seq, aux)
                loss = criterion(out, labels)

            scaler.scale(loss).backward()
            scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            scaler.step(optimizer)
            scaler.update()

            if scheduler and hasattr(scheduler, 'step') and isinstance(scheduler, optim.lr_scheduler.OneCycleLR):
                scheduler.step()

            ema.update(model)
            total_loss += loss.item() * seq.size(0)
            preds = (torch.sigmoid(out) > 0.5).long()
            correct += (preds == labels.round().long()).sum().item()
            total += seq.size(0)

        if scheduler and not isinstance(scheduler, optim.lr_scheduler.OneCycleLR):
            scheduler.step()

        train_loss = total_loss / total
        train_acc = correct / total

        ema_state = copy.deepcopy(model.state_dict())
        ema.apply(model)
        val_loss, val_acc, val_auc = evaluate(model, val_loader)
        model.load_state_dict(ema_state)

        history['train_loss'].append(train_loss)
        history['train_acc'].append(train_acc)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(val_acc)
        history['val_auc'].append(val_auc)

        elapsed = time.time() - t0
        lr = optimizer.param_groups[0]['lr']
        print(f'  [{phase_name}] Epoch {epoch+1:2d}/{epochs} | '
              f'Loss: {train_loss:.4f} Acc: {train_acc:.4f} | '
              f'Val Loss: {val_loss:.4f} Acc: {val_acc:.4f} AUC: {val_auc:.4f} | '
              f'LR: {lr:.2e} | {elapsed:.0f}s')

        if val_auc > best_auc:
            best_auc = val_auc
            ema.apply(model)
            torch.save(model.state_dict(), MODELS_DIR / f'best_{phase_name}.pth')
            ema_state_saved = copy.deepcopy(model.state_dict())
            model.load_state_dict(ema_state)
            patience = 0
        else:
            patience += 1
            if patience >= patience_limit:
                print(f'  Early stopping at epoch {epoch+1}')
                break

    model.load_state_dict(torch.load(MODELS_DIR / f'best_{phase_name}.pth', weights_only=True))
    print(f'  {phase_name} Best AUC: {best_auc:.4f}')
    return history, best_auc


def main():
    print('=' * 60)
    print('CONFUSION DETECTION v3 — TEMPORAL LSTM + MULTI-MODAL')
    print('EfficientNetV2-S + BiLSTM + Attention + SAM concepts')
    print('=' * 60)

    csv_path = FRAMES_DIR / 'frame_labels.csv'
    if not csv_path.exists():
        print(f'ERROR: {csv_path} not found. Run extract_frames_v2.py first!')
        return

    print('\n[1/7] Loading datasets...')
    train_tf, val_tf = get_transforms()
    train_ds = ClipDataset(csv_path, 'train', train_tf)
    val_ds = ClipDataset(csv_path, 'validation', val_tf)
    test_ds = ClipDataset(csv_path, 'test', val_tf)

    labels = [c['label'] for c in train_ds.clips]
    class_counts = Counter(labels)
    weights = [1.0 / class_counts[l] for l in labels]
    sampler = WeightedRandomSampler(weights, len(weights))

    train_loader = DataLoader(train_ds, batch_size=BATCH_SIZE, sampler=sampler,
                              num_workers=0, pin_memory=True)
    val_loader = DataLoader(val_ds, batch_size=BATCH_SIZE, shuffle=False,
                            num_workers=0, pin_memory=True)
    test_loader = DataLoader(test_ds, batch_size=BATCH_SIZE, shuffle=False,
                             num_workers=0, pin_memory=True)

    print(f'  Train clips: {len(train_ds)} | Val clips: {len(val_ds)} | Test clips: {len(test_ds)}')
    print(f'  Class dist (train): {dict(class_counts)}')

    print('\n[2/7] Building model...')
    model = TemporalConfusionModel().to(device)
    model.freeze_backbone()
    criterion = FocalLoss(alpha=0.6, gamma=2.0, smoothing=0.05)
    scaler = torch.amp.GradScaler('cuda')
    ema = EMA(model, decay=0.999)

    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total_params = sum(p.numel() for p in model.parameters())
    print(f'  Total: {total_params:,} | Trainable: {trainable:,}')

    print(f'\n[3/7] Phase 1: Head + LSTM only ({PHASE1_EPOCHS} epochs)...')
    if (MODELS_DIR / 'best_phase1.pth').exists():
        print("  Found best_phase1.pth, skipping Phase 1 training...")
        model.load_state_dict(torch.load(MODELS_DIR / 'best_phase1.pth', weights_only=True))
        ema.update(model)
        h1, auc1 = {'val_auc': []}, 0
    else:
        opt1 = optim.AdamW(filter(lambda p: p.requires_grad, model.parameters()), lr=1e-3, weight_decay=1e-3)
        sched1 = optim.lr_scheduler.OneCycleLR(opt1, max_lr=1e-3, epochs=PHASE1_EPOCHS,
                                                steps_per_epoch=len(train_loader))
        h1, auc1 = train_phase(model, train_loader, val_loader, opt1, sched1, scaler,
                               criterion, ema, PHASE1_EPOCHS, 'phase1', patience_limit=8)

    print(f'\n[4/7] Phase 2: Unfreeze last 150 backbone params ({PHASE2_EPOCHS} epochs)...')
    model.unfreeze_backbone(last_n=150)
    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f'  Trainable: {trainable:,}')
    opt2 = optim.AdamW(filter(lambda p: p.requires_grad, model.parameters()), lr=2e-5, weight_decay=1e-3)
    sched2 = optim.lr_scheduler.CosineAnnealingWarmRestarts(opt2, T_0=10, T_mult=2, eta_min=1e-7)
    ema = EMA(model, decay=0.9995)
    h2, auc2 = train_phase(model, train_loader, val_loader, opt2, sched2, scaler,
                           criterion, ema, PHASE2_EPOCHS, 'phase2', patience_limit=12)

    print(f'\n[5/7] Phase 3: Full unfreeze ({PHASE3_EPOCHS} epochs)...')
    model.unfreeze_all()
    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f'  Trainable: {trainable:,}')
    opt3 = optim.AdamW(model.parameters(), lr=5e-6, weight_decay=1e-3)
    sched3 = optim.lr_scheduler.CosineAnnealingLR(opt3, T_max=PHASE3_EPOCHS, eta_min=1e-8)
    ema = EMA(model, decay=0.9998)
    h3, auc3 = train_phase(model, train_loader, val_loader, opt3, sched3, scaler,
                           criterion, ema, PHASE3_EPOCHS, 'phase3', patience_limit=10)

    print('\n[6/7] Evaluating on test set...')
    opt_threshold = find_optimal_threshold(model, val_loader)
    print(f'  Optimal threshold: {opt_threshold:.2f}')

    model.eval()
    all_probs, all_labels, all_clips = [], [], []
    with torch.no_grad():
        for seq, aux, labels in test_loader:
            seq, aux = seq.to(device), aux.to(device)
            with torch.amp.autocast('cuda'):
                out = model(seq, aux)
            all_probs.extend(torch.sigmoid(out).cpu().numpy())
            all_labels.extend(labels.numpy())

    probs = np.array(all_probs)
    yt = np.array(all_labels)
    yp_default = (probs > 0.5).astype(int)
    yp_optimal = (probs > opt_threshold).astype(int)

    print('\n=== CLIP-LEVEL (threshold=0.5) ===')
    print(classification_report(yt, yp_default, target_names=['Not Confused', 'Confused'], digits=4))
    try:
        auc = roc_auc_score(yt, probs)
        print(f'AUC: {auc:.4f}')
    except:
        auc = 0

    print(f'\n=== CLIP-LEVEL (threshold={opt_threshold:.2f}) ===')
    print(classification_report(yt, yp_optimal, target_names=['Not Confused', 'Confused'], digits=4))

    acc_default = float(np.mean(yt == yp_default))
    acc_optimal = float(np.mean(yt == yp_optimal))

    print('\n[7/7] Saving model + plots...')
    torch.save(model.state_dict(), MODELS_DIR / 'confusion_v3.pth')

    model.eval()
    dummy_seq = torch.randn(1, SEQ_LEN, 3, IMG_SIZE, IMG_SIZE).to(device)
    dummy_aux = torch.randn(1, 5).to(device)
    try:
        traced = torch.jit.trace(model, (dummy_seq, dummy_aux))
        traced.save(str(MODELS_DIR / 'confusion_v3.pt'))
        pt_size = (MODELS_DIR / 'confusion_v3.pt').stat().st_size / 1024 / 1024
        print(f'  TorchScript: {pt_size:.1f} MB')
    except Exception as e:
        print(f'  TorchScript export failed: {e}')

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    cm = confusion_matrix(yt, yp_optimal)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[0],
                xticklabels=['Not Confused', 'Confused'], yticklabels=['Not Confused', 'Confused'])
    axes[0].set_title(f'Confusion Matrix (t={opt_threshold:.2f})', fontweight='bold')

    if auc > 0:
        fpr, tpr, _ = roc_curve(yt, probs)
        axes[1].plot(fpr, tpr, 'b-', lw=2, label=f'AUC={auc:.4f}')
        axes[1].plot([0, 1], [0, 1], 'r--')
        axes[1].legend()
        axes[1].set_title('ROC Curve', fontweight='bold')

    all_val_auc = h1['val_auc'] + h2['val_auc'] + h3['val_auc']
    axes[2].plot(all_val_auc, 'g-', lw=2)
    axes[2].set_title('Val AUC across phases', fontweight='bold')
    axes[2].set_xlabel('Epoch')
    axes[2].axvline(len(h1['val_auc']), color='r', linestyle='--', alpha=0.5, label='Phase 2')
    axes[2].axvline(len(h1['val_auc']) + len(h2['val_auc']), color='orange', linestyle='--', alpha=0.5, label='Phase 3')
    axes[2].legend()

    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'results_v3.png', dpi=150)

    meta = {
        'model': 'EfficientNetV2-S + BiLSTM + Attention + Multi-modal',
        'input_image': [SEQ_LEN, 260, 260, 3],
        'input_aux': 5,
        'confusion_threshold': '>=2',
        'techniques': ['Focal Loss', 'Three-phase progressive unfreeze', 'EMA',
                        'BiLSTM temporal', 'SE attention', 'Multi-modal fusion',
                        'Optimal threshold tuning', 'WeightedRandomSampler',
                        'Label Smoothing', 'Mixed Precision', 'Gradient Clipping',
                        'CosineAnnealing', 'AdamW'],
        'clip_acc_default': acc_default,
        'clip_acc_optimal': acc_optimal,
        'auc': float(auc),
        'optimal_threshold': float(opt_threshold),
        'dataset': 'DAiSEE (confusion>=2)',
        'device': str(device),
    }
    with open(MODELS_DIR / 'meta_v3.json', 'w') as f:
        json.dump(meta, f, indent=2)

    print('\n' + '=' * 60)
    print('TRAINING COMPLETE!')
    print(f'  Clip Acc (t=0.5):  {acc_default*100:.2f}%')
    print(f'  Clip Acc (t={opt_threshold:.2f}): {acc_optimal*100:.2f}%')
    print(f'  AUC:               {auc:.4f}')
    print(f'  Models:            {MODELS_DIR}')
    print('=' * 60)


if __name__ == '__main__':
    main()
