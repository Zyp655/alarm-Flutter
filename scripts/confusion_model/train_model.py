import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.model_selection import cross_val_score, StratifiedKFold, train_test_split
from sklearn.metrics import classification_report, confusion_matrix, f1_score, accuracy_score
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
import joblib
import os
import json

DAISEE_LABELS = "D:/DAiSEE/DAiSEE/Labels"
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(OUTPUT_DIR, "models")
os.makedirs(MODEL_DIR, exist_ok=True)

def load_data():
    train_df = pd.read_csv(f"{DAISEE_LABELS}/TrainLabels.csv")
    test_df = pd.read_csv(f"{DAISEE_LABELS}/TestLabels.csv")
    val_df = pd.read_csv(f"{DAISEE_LABELS}/ValidationLabels.csv")
    all_df = pd.concat([train_df, test_df, val_df], ignore_index=True)

    all_df.columns = all_df.columns.str.strip()

    print(f"Total samples: {len(all_df)}")
    print(f"Train: {len(train_df)}, Test: {len(test_df)}, Validation: {len(val_df)}")
    return all_df, train_df, test_df, val_df

def analyze_distribution(df):
    print("\n=== Confusion Distribution ===")
    dist = df['Confusion'].value_counts().sort_index()
    for level, count in dist.items():
        pct = count / len(df) * 100
        bar = "█" * int(pct / 2)
        print(f"  Level {level}: {count:5d} ({pct:5.1f}%) {bar}")

    print("\n=== Correlation Matrix ===")
    corr = df[['Boredom', 'Engagement', 'Confusion', 'Frustration']].corr()
    print(corr.round(3))

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    for i, col in enumerate(['Boredom', 'Engagement', 'Confusion', 'Frustration']):
        ax = axes[i // 2][i % 2]
        df[col].value_counts().sort_index().plot(kind='bar', ax=ax, color=['#2ecc71', '#f1c40f', '#e67e22', '#e74c3c'])
        ax.set_title(f'{col} Distribution', fontsize=14, fontweight='bold')
        ax.set_xlabel('Level')
        ax.set_ylabel('Count')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "daisee_distribution.png"), dpi=150)
    print(f"\nSaved: daisee_distribution.png")

    fig2, ax2 = plt.subplots(figsize=(8, 6))
    sns.heatmap(corr, annot=True, cmap='RdBu_r', center=0, ax=ax2, fmt='.3f')
    ax2.set_title('Affective States Correlation', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "daisee_correlation.png"), dpi=150)
    print(f"Saved: daisee_correlation.png")

def prepare_features(df):
    df = df.copy()
    df['is_confused'] = (df['Confusion'] >= 2).astype(int)

    df['subject_id'] = df['ClipID'].str[:6]
    df['session_id'] = df['ClipID'].str[:10]

    df['bore_engage_ratio'] = df['Boredom'] / (df['Engagement'] + 1)
    df['negative_sum'] = df['Boredom'] + df['Frustration']
    df['frustration_x_boredom'] = df['Frustration'] * df['Boredom']
    df['low_engagement'] = (df['Engagement'] <= 1).astype(int)
    df['high_boredom'] = (df['Boredom'] >= 2).astype(int)
    df['high_frustration'] = (df['Frustration'] >= 2).astype(int)
    df['negative_state'] = ((df['Boredom'] >= 2) | (df['Frustration'] >= 2)).astype(int)

    feature_cols = [
        'Boredom', 'Engagement', 'Frustration',
        'bore_engage_ratio', 'negative_sum', 'frustration_x_boredom',
        'low_engagement', 'high_boredom', 'high_frustration', 'negative_state'
    ]

    X = df[feature_cols].values
    y = df['is_confused'].values

    print(f"\nFeatures shape: {X.shape}")
    print(f"Positive (confused): {y.sum()} ({y.sum()/len(y)*100:.1f}%)")
    print(f"Negative (not confused): {len(y)-y.sum()} ({(len(y)-y.sum())/len(y)*100:.1f}%)")

    return X, y, feature_cols, df

def train_and_compare(X, y, feature_cols):
    models = {
        'Random Forest': RandomForestClassifier(
            n_estimators=200, max_depth=10, min_samples_split=5,
            class_weight='balanced', random_state=42, n_jobs=-1
        ),
        'Gradient Boosting': GradientBoostingClassifier(
            n_estimators=200, max_depth=5, learning_rate=0.1,
            random_state=42
        ),
        'SVM': SVC(
            kernel='rbf', C=10, gamma='scale',
            class_weight='balanced', random_state=42
        ),
        'Logistic Regression': LogisticRegression(
            C=1.0, class_weight='balanced',
            max_iter=1000, random_state=42
        ),
    }

    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    results = {}

    print("\n=== Model Comparison (5-Fold Cross Validation) ===")
    print(f"{'Model':<25} {'Accuracy':>10} {'F1 Score':>10} {'Precision':>10} {'Recall':>10}")
    print("-" * 70)

    for name, model in models.items():
        acc_scores = cross_val_score(model, X, y, cv=cv, scoring='accuracy')
        f1_scores = cross_val_score(model, X, y, cv=cv, scoring='f1')
        prec_scores = cross_val_score(model, X, y, cv=cv, scoring='precision')
        rec_scores = cross_val_score(model, X, y, cv=cv, scoring='recall')

        results[name] = {
            'accuracy': acc_scores.mean(),
            'f1': f1_scores.mean(),
            'precision': prec_scores.mean(),
            'recall': rec_scores.mean(),
            'accuracy_std': acc_scores.std(),
            'f1_std': f1_scores.std(),
        }

        print(f"{name:<25} {acc_scores.mean():>9.4f} {f1_scores.mean():>9.4f} "
              f"{prec_scores.mean():>9.4f} {rec_scores.mean():>9.4f}")

    return results, models

def train_best_model(X, y, feature_cols, models, results):
    best_name = max(results, key=lambda k: results[k]['f1'])
    print(f"\n=== Best Model: {best_name} (F1={results[best_name]['f1']:.4f}) ===")

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, stratify=y, random_state=42
    )

    best_model = models[best_name]
    best_model.fit(X_train, y_train)
    y_pred = best_model.predict(X_test)

    print("\n--- Classification Report ---")
    print(classification_report(y_test, y_pred, target_names=['Not Confused', 'Confused']))

    cm = confusion_matrix(y_test, y_pred)
    fig, ax = plt.subplots(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax,
                xticklabels=['Not Confused', 'Confused'],
                yticklabels=['Not Confused', 'Confused'])
    ax.set_title(f'{best_name} — Confusion Matrix', fontsize=14, fontweight='bold')
    ax.set_xlabel('Predicted')
    ax.set_ylabel('Actual')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "confusion_matrix.png"), dpi=150)
    print("Saved: confusion_matrix.png")

    if hasattr(best_model, 'feature_importances_'):
        importances = best_model.feature_importances_
        indices = np.argsort(importances)[::-1]

        fig2, ax2 = plt.subplots(figsize=(10, 6))
        colors = plt.cm.viridis(np.linspace(0.3, 0.9, len(feature_cols)))
        ax2.barh(range(len(feature_cols)),
                 importances[indices],
                 color=colors)
        ax2.set_yticks(range(len(feature_cols)))
        ax2.set_yticklabels([feature_cols[i] for i in indices])
        ax2.set_title('Feature Importance', fontsize=14, fontweight='bold')
        ax2.set_xlabel('Importance')
        plt.tight_layout()
        plt.savefig(os.path.join(OUTPUT_DIR, "feature_importance.png"), dpi=150)
        print("Saved: feature_importance.png")

        print("\n--- Feature Importance ---")
        for i in indices:
            print(f"  {feature_cols[i]:<25} {importances[i]:.4f}")

    best_model.fit(X, y)

    model_path = os.path.join(MODEL_DIR, "confusion_model.joblib")
    joblib.dump(best_model, model_path)
    print(f"\nModel saved: {model_path}")

    meta = {
        'model_name': best_name,
        'features': feature_cols,
        'metrics': {k: float(v) for k, v in results[best_name].items()},
        'total_samples': len(y),
        'confused_samples': int(y.sum()),
        'threshold': 'Confusion >= 2 → is_confused=1',
        'dataset': 'DAiSEE (9,068 clips, 112 subjects)',
    }
    meta_path = os.path.join(MODEL_DIR, "model_meta.json")
    with open(meta_path, 'w') as f:
        json.dump(meta, f, indent=2)
    print(f"Metadata saved: {meta_path}")

    return best_model, best_name

def plot_comparison(results):
    fig, ax = plt.subplots(figsize=(10, 6))
    model_names = list(results.keys())
    metrics = ['accuracy', 'f1', 'precision', 'recall']
    x = np.arange(len(model_names))
    width = 0.2

    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    for i, metric in enumerate(metrics):
        values = [results[m][metric] for m in model_names]
        ax.bar(x + i * width, values, width, label=metric.capitalize(), color=colors[i])

    ax.set_xlabel('Model')
    ax.set_ylabel('Score')
    ax.set_title('Model Comparison', fontsize=14, fontweight='bold')
    ax.set_xticks(x + width * 1.5)
    ax.set_xticklabels(model_names, rotation=15)
    ax.legend()
    ax.set_ylim(0, 1.0)
    ax.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "model_comparison.png"), dpi=150)
    print("Saved: model_comparison.png")

if __name__ == '__main__':
    print("=" * 60)
    print("  DAiSEE Confusion Detection — Model Training")
    print("=" * 60)

    df, train_df, test_df, val_df = load_data()
    analyze_distribution(df)
    X, y, feature_cols, df_prepared = prepare_features(df)
    results, models = train_and_compare(X, y, feature_cols)
    plot_comparison(results)
    best_model, best_name = train_best_model(X, y, feature_cols, models, results)

    print("\n" + "=" * 60)
    print("  DONE!")
    print(f"  Best model: {best_name}")
    print(f"  Saved to: {MODEL_DIR}/confusion_model.joblib")
    print("=" * 60)
