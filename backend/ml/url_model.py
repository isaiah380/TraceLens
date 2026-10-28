import os
import joblib
from typing import Optional, Dict, Any
from ml.url_features import extract_features_vector

MODEL_PATH = os.path.join(os.path.dirname(__file__), "url_random_forest.joblib")

_model = None
_model_loaded = False

def get_url_ml_status() -> str:
    if os.path.exists(MODEL_PATH):
        return "Trained model present"
    return "Optional URL model not trained (training pipeline ready)"

def load_url_model():
    global _model, _model_loaded
    if os.path.exists(MODEL_PATH):
        try:
            _model = joblib.load(MODEL_PATH)
            _model_loaded = True
            print("[INFO] URL Random Forest classifier loaded successfully.")
        except Exception as e:
            print(f"[WARN] Failed to load URL model: {e}")
            _model_loaded = False
    else:
        _model_loaded = False

def predict_url_ml(url: str) -> Optional[Dict[str, Any]]:
    global _model, _model_loaded
    if not _model_loaded or _model is None:
        return None
    try:
        features = extract_features_vector(url).reshape(1, -1)
        pred = _model.predict(features)[0]
        proba = _model.predict_proba(features)[0]
        # Assuming binary: 0=benign, 1=phishing
        phishing_prob = float(proba[1]) if len(proba) > 1 else float(pred)
        return {
            "prediction": "phishing" if pred == 1 else "benign",
            "phishing_probability": round(phishing_prob, 3),
            "model_type": "RandomForestClassifier"
        }
    except Exception as e:
        print(f"[WARN] URL ML prediction failed: {e}")
        return None

# Attempt initial load
load_url_model()
