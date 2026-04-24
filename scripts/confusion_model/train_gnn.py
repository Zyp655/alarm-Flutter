import os, json, random, time
import numpy as np
import pandas as pd
from pathlib import Path
from collections import Counter

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset, WeightedRandomSampler

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns

FRAMES_DIR = Path(__file__).parent / 'frames_v2'
OUTPUT_DIR = Path(__file__).parent / 'output_gnn'
MODELS_DIR = OUTPUT_DIR / 'models'
MODELS_DIR.mkdir(parents=True, exist_ok=True)

BATCH_SIZE = 64
SEQ_LEN = 5
SEED = 42
EPOCHS = 50

torch.manual_seed(SEED)
np.random.seed(SEED)
random.seed(SEED)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

class LandmarkDataset(Dataset):
    def __init__(self, csv_path, npz_path, split, seq_len=SEQ_LEN):
        df = pd.read_csv(csv_path)
        # Filter by split
        df = df[df['frame_path'].str.contains(f'/{split}/' if '/' in df['frame_path'].iloc[0] else f'\\\\{split}\\\\', regex=True)]
        
        self.seq_len = seq_len
        self.clips = []
        
        print(f"Loading {npz_path} into memory...")
        data = np.load(npz_path)
        
        grouped = df.groupby('clip_id')
        for clip_id, group in grouped:
            cid_str = str(clip_id)
            if cid_str not in data:
                continue
                
            lm_seq = data[cid_str] # shape: [num_frames, 478, 3]
            
            label = int(group['is_confused'].iloc[0])
            aux = [
                float(group['boredom'].iloc[0]) / 3.0,
                float(group['engagement'].iloc[0]) / 3.0,
                float(group['frustration'].iloc[0]) / 3.0,
            ]
            aux.append(aux[0] / (aux[1] + 0.01))
            aux.append(aux[0] + aux[2])
            
            self.clips.append({
                'landmarks': lm_seq,
                'label': label,
                'aux': aux,
                'clip_id': clip_id,
            })

    def __len__(self):
        return len(self.clips)

    def __getitem__(self, idx):
        clip = self.clips[idx]
        lm_seq = clip['landmarks']
        num_frames = len(lm_seq)
        
        # Temporal Sampling
        if num_frames >= self.seq_len:
            indices = np.linspace(0, num_frames - 1, self.seq_len, dtype=int)
            lm_seq = lm_seq[indices]
        else:
            # Pad by repeating the last frame
            pad_len = self.seq_len - num_frames
            padding = np.repeat(lm_seq[-1:], pad_len, axis=0)
            lm_seq = np.concatenate([lm_seq, padding], axis=0)
            
        # Add random noise to landmarks during training for data augmentation
        # We'll do this in the training loop or assume the dataset is small enough
        
        # Normalize landmarks relative to face center (nose is usually at index 1 or 4)
        # To make it scale and translation invariant
        seq_tensor = torch.tensor(lm_seq, dtype=torch.float32) # [5, 478, 3]
        
        # Center the face coordinates based on the nose (index 1)
        # We do this per frame
        nose_coords = seq_tensor[:, 1:2, :] # [5, 1, 3]
        seq_tensor = seq_tensor - nose_coords
        
        aux = torch.tensor(clip['aux'], dtype=torch.float32)
        label = torch.tensor(clip['label'], dtype=torch.float32)
        return seq_tensor, aux, label

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

class TemporalLandmarkModel(nn.Module):
    def __init__(self, num_nodes=478, node_dim=3, num_aux=5, hidden_size=256):
        super().__init__()
        input_dim = num_nodes * node_dim
        
        # Spatial Feature Extractor (MLP over flattened landmarks)
        self.spatial = nn.Sequential(
            nn.Linear(input_dim, 512),
            nn.LayerNorm(512),
            nn.GELU(),
            nn.Dropout(0.3),
            nn.Linear(512, 256),
            nn.LayerNorm(256),
            nn.GELU(),
            nn.Dropout(0.3)
        )
        
        # Temporal Modeling
        self.lstm = nn.LSTM(256, hidden_size//2, num_layers=2,
                            batch_first=True, bidirectional=True, dropout=0.3)
        
        # Temporal Attention
        self.attn = nn.Sequential(
            nn.Linear(hidden_size, 1),
            nn.Softmax(dim=1)
        )
        
        # Fusion and Classification
        fusion_dim = hidden_size + num_aux
        self.head = nn.Sequential(
            nn.LayerNorm(fusion_dim),
            nn.Dropout(0.4),
            nn.Linear(fusion_dim, 128),
            nn.GELU(),
            nn.BatchNorm1d(128),
            nn.Dropout(0.3),
            nn.Linear(128, 64),
            nn.GELU(),
            nn.Dropout(0.2),
            nn.Linear(64, 1)
        )

    def forward(self, seq, aux):
        B, T, N, D = seq.shape
        # Flatten landmarks: [B, T, 478*3]
        x = seq.view(B, T, N * D)
        
        # Apply spatial extractor to each frame
        x = x.view(B * T, N * D)
        x = self.spatial(x)
        x = x.view(B, T, 256)
        
        # Temporal sequence modeling
        lstm_out, _ = self.lstm(x) # [B, T, hidden_size]
        
        # Attention over frames
        attn_w = self.attn(lstm_out) # [B, T, 1]
        context = (attn_w * lstm_out).sum(dim=1) # [B, hidden_size]
        
        # Fusion
        fused = torch.cat([context, aux], dim=1)
        return self.head(fused).squeeze(1)

@torch.no_grad()
def evaluate(model, loader):
    model.eval()
    total_loss, correct, total = 0, 0, 0
    all_probs, all_labels = [], []
    criterion = nn.BCEWithLogitsLoss()

    for seq, aux, labels in loader:
        seq, aux, labels = seq.to(device), aux.to(device), labels.to(device)
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
            out = model(seq, aux)
            all_probs.extend(torch.sigmoid(out).cpu().numpy())
            all_labels.extend(labels.cpu().numpy())

    best_t, best_f1 = 0.5, 0
    for t in np.arange(0.1, 0.9, 0.01):
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

def main():
    print('=' * 60)
    print('LANDMARK GNN CONFUSION DETECTION')
    print('MediaPipe FaceMesh + Spatial MLP + BiLSTM + Attention')
    print('=' * 60)

    csv_path = FRAMES_DIR / 'frame_labels.csv'
    npz_path = FRAMES_DIR / 'landmarks.npz'
    
    if not npz_path.exists():
        print(f"ERROR: {npz_path} not found. Run extract_landmarks.py first!")
        return

    print('\n[1/5] Loading datasets...')
    train_ds = LandmarkDataset(csv_path, npz_path, 'train')
    val_ds = LandmarkDataset(csv_path, npz_path, 'validation')
    test_ds = LandmarkDataset(csv_path, npz_path, 'test')

    labels = [c['label'] for c in train_ds.clips]
    class_counts = Counter(labels)
    weights = [1.0 / class_counts[l] for l in labels]
    sampler = WeightedRandomSampler(weights, len(weights))

    train_loader = DataLoader(train_ds, batch_size=BATCH_SIZE, sampler=sampler, num_workers=0)
    val_loader = DataLoader(val_ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=0)
    test_loader = DataLoader(test_ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=0)

    print(f'  Train clips: {len(train_ds)} | Val clips: {len(val_ds)} | Test clips: {len(test_ds)}')
    print(f'  Class dist (train): {dict(class_counts)}')

    print('\n[2/5] Building model...')
    model = TemporalLandmarkModel().to(device)
    criterion = FocalLoss(alpha=0.6, gamma=2.0, smoothing=0.05)
    optimizer = optim.AdamW(model.parameters(), lr=1e-3, weight_decay=1e-3)
    scheduler = optim.lr_scheduler.CosineAnnealingWarmRestarts(optimizer, T_0=10, T_mult=2, eta_min=1e-6)
    ema = EMA(model, decay=0.995)

    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f'  Trainable params: {trainable:,}')

    print(f'\n[3/5] Training ({EPOCHS} epochs)...')
    best_auc = 0
    patience = 0
    patience_limit = 15
    history = {'train_loss': [], 'train_acc': [], 'val_loss': [], 'val_acc': [], 'val_auc': []}

    for epoch in range(EPOCHS):
        t0 = time.time()
        model.train()
        total_loss, correct, total = 0, 0, 0

        for seq, aux, labels in train_loader:
            seq, aux, labels = seq.to(device), aux.to(device), labels.to(device)
            
            # Simple Data Augmentation: Add small random noise to landmarks
            if model.training:
                noise = torch.randn_like(seq) * 0.005
                seq = seq + noise

            optimizer.zero_grad()
            out = model(seq, aux)
            loss = criterion(out, labels)

            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            optimizer.step()
            
            ema.update(model)
            total_loss += loss.item() * seq.size(0)
            preds = (torch.sigmoid(out) > 0.5).long()
            correct += (preds == labels.long()).sum().item()
            total += seq.size(0)

        scheduler.step()
        
        train_loss = total_loss / total
        train_acc = correct / total

        # Eval with EMA
        ema_state = {k: v.clone() for k, v in model.state_dict().items()}
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
        print(f'  Epoch {epoch+1:2d}/{EPOCHS} | '
              f'Loss: {train_loss:.4f} Acc: {train_acc:.4f} | '
              f'Val Loss: {val_loss:.4f} Acc: {val_acc:.4f} AUC: {val_auc:.4f} | '
              f'LR: {lr:.2e} | {elapsed:.1f}s')

        if val_auc > best_auc:
            best_auc = val_auc
            ema.apply(model)
            torch.save(model.state_dict(), MODELS_DIR / 'best_gnn.pth')
            model.load_state_dict(ema_state)
            patience = 0
        else:
            patience += 1
            if patience >= patience_limit:
                print(f'  Early stopping at epoch {epoch+1}')
                break

    print(f'\n[4/5] Evaluating on test set...')
    model.load_state_dict(torch.load(MODELS_DIR / 'best_gnn.pth', weights_only=True))
    
    opt_threshold = find_optimal_threshold(model, val_loader)
    print(f'  Optimal threshold: {opt_threshold:.2f}')

    all_probs, all_labels = [], []
    model.eval()
    with torch.no_grad():
        for seq, aux, labels in test_loader:
            seq, aux = seq.to(device), aux.to(device)
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

    print('\n[5/5] Saving model + plots...')
    
    # Save TorchScript
    dummy_seq = torch.randn(1, SEQ_LEN, 478, 3).to(device)
    dummy_aux = torch.randn(1, 5).to(device)
    try:
        traced = torch.jit.trace(model, (dummy_seq, dummy_aux))
        traced.save(str(MODELS_DIR / 'confusion_gnn.pt'))
        print(f'  Saved TorchScript: confusion_gnn.pt')
    except Exception as e:
        print(f'  TorchScript export failed: {e}')

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    cm = confusion_matrix(yt, yp_optimal)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[0],
                xticklabels=['Not Confused', 'Confused'], yticklabels=['Not Confused', 'Confused'])
    axes[0].set_title(f'Confusion Matrix (t={opt_threshold:.2f})', fontweight='bold')

    axes[1].plot(history['val_auc'], 'g-', lw=2)
    axes[1].set_title('Validation AUC', fontweight='bold')
    axes[1].set_xlabel('Epoch')

    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'results_gnn.png', dpi=150)

    meta = {
        'model': 'Landmark MLP + BiLSTM + Attention',
        'input_shape': [SEQ_LEN, 478, 3],
        'input_aux': 5,
        'clip_acc_default': float(np.mean(yt == yp_default)),
        'clip_acc_optimal': float(np.mean(yt == yp_optimal)),
        'auc': float(auc),
        'optimal_threshold': float(opt_threshold),
    }
    with open(MODELS_DIR / 'meta_gnn.json', 'w') as f:
        json.dump(meta, f, indent=2)

    print('\n' + '=' * 60)
    print('TRAINING COMPLETE!')
    print(f'  AUC: {auc:.4f}')
    print('=' * 60)

if __name__ == '__main__':
    main()
