"""
URL Classifier Evaluation Script (Level 3)
Evaluates a trained Joblib model on a labelled test dataset.
"""
import os
import sys
import argparse
import pandas as pd
import numpy as np
import joblib
from sklearn.metrics import classification_report, confusion_matrix, precision_recall_fscore_support

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from ml.url_features import extract_features_vector

def evaluate(model_path: str, test_csv: str):
    if not os.path.exists(model_path):
        print(f"[ERROR] Model file not found at {model_path}")
        return

    print(f"[*] Loading model from {model_path}...")
    model = joblib.load(model_path)

    print(f"[*] Loading test data from {test_csv}...")
    df = pd.read_csv(test_csv)
    
    features = []
    labels = []
    for _, row in df.iterrows():
        try:
            vec = extract_features_vector(str(row['url']))
            features.append(vec)
            labels.append(int(row['label']))
        except Exception:
            continue

    X = np.array(features)
    y = np.array(labels)

    preds = model.predict(X)
    probs = model.predict_proba(X)[:, 1] if hasattr(model, "predict_proba") else None

    print("\n" + "="*50)
    print("TRACELENS URL ML MODEL EVALUATION RESULTS")
    print("="*50)
    print("\nConfusion Matrix:")
    cm = confusion_matrix(y, preds)
    print(cm)
    tn, fp, fn, tp = cm.ravel()
    fpr = fp / (fp + tn) if (fp + tn) > 0 else 0
    print(f"\nFalse Positive Rate (FPR): {fpr * 100:.2f}%")

    print("\nClassification Report:")
    print(classification_report(y, preds, target_names=["Benign (0)", "Phishing (1)"]))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Evaluate TraceLens URL Model")
    parser.add_argument("--model", default=os.path.join(os.path.dirname(__file__), "url_random_forest.joblib"))
    parser.add_argument("--test-data", required=True)
    args = parser.parse_args()
    evaluate(args.model, args.test_data)
