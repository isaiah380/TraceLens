"""
URL Classifier Training Pipeline (Level 3)
Trains a Random Forest classifier on structural URL features.
Usage:
    python train_url_model.py --dataset path/to/dataset.csv
"""
import os
import sys
import argparse
import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

# Ensure ml directory can import features
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from ml.url_features import extract_features_vector, URL_FEATURE_NAMES

def train(dataset_csv: str, output_model: str):
    print(f"[*] Reading dataset from: {dataset_csv}")
    df = pd.read_csv(dataset_csv)
    
    # Expected schema: 'url', 'label' (where label is 0 for benign, 1 for phishing)
    if 'url' not in df.columns or 'label' not in df.columns:
        raise ValueError("Dataset CSV must contain 'url' and 'label' columns.")

    print(f"[*] Extracting structural features for {len(df)} URLs...")
    features_list = []
    labels = []
    
    for _, row in df.iterrows():
        try:
            vec = extract_features_vector(str(row['url']))
            features_list.append(vec)
            labels.append(int(row['label']))
        except Exception:
            continue

    X = np.array(features_list)
    y = np.array(labels)

    print(f"[*] Extracted shape: X={X.shape}, y={y.shape}")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    print("[*] Training RandomForestClassifier...")
    clf = RandomForestClassifier(n_estimators=100, max_depth=12, random_state=42, n_jobs=-1)
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"[+] Evaluation Test Accuracy: {acc * 100:.2f}%")
    print("\nClassification Report:\n", classification_report(y_test, y_pred))

    joblib.dump(clf, output_model)
    print(f"[+] Model saved successfully to: {output_model}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train TraceLens URL Machine Learning Classifier")
    parser.add_argument("--dataset", required=True, help="Path to CSV dataset containing 'url' and 'label'")
    parser.add_argument("--output", default=os.path.join(os.path.dirname(__file__), "url_random_forest.joblib"), help="Path to save joblib model")
    args = parser.parse_args()
    train(args.dataset, args.output)
