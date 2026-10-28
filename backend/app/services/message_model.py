import os
import logging
from typing import Optional, Dict

logger = logging.getLogger("tracelens.message_model")

MODEL_ID = "Horizon-Labs/phishing-scam-detector-base"

_tokenizer = None
_model = None
_status = "uninitialized"  # "loading", "ready", "failed"
_error_message: Optional[str] = None

def get_message_model_status() -> str:
    if _status == "ready":
        return f"Loaded ({MODEL_ID})"
    elif _status == "loading":
        return "Loading weights in background"
    elif _status == "failed":
        return f"Fallback mode active (Load error: {_error_message})"
    return "Fallback mode active (Model uninitialized)"

def init_message_model(lazy: bool = False):
    """
    Initializes tokenizer and model on CPU without retaining excessive gradients.
    """
    global _tokenizer, _model, _status, _error_message
    
    if _status == "ready":
        return

    _status = "loading"
    logger.info(f"Initiating load for model {MODEL_ID} on CPU...")
    
    try:
        import importlib.util
        if importlib.util.find_spec("transformers") is None or importlib.util.find_spec("torch") is None:
            _status = "failed"
            _error_message = "torch and transformers libraries not installed; running in fallback mode"
            logger.info("ML libraries not installed. Fallback rule engine active.")
            return

        import torch
        from transformers import AutoTokenizer, AutoModelForSequenceClassification
        
        torch.set_grad_enabled(False)
        _tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
        _model = AutoModelForSequenceClassification.from_pretrained(
            MODEL_ID,
            torch_dtype=torch.float32,
            low_cpu_mem_usage=True
        )
        _model.eval()
        _status = "ready"
        logger.info(f"Model {MODEL_ID} successfully loaded into memory.")
    except Exception as e:
        _status = "failed"
        _error_message = str(e)
        logger.warning(f"Failed to load Hugging Face model {MODEL_ID}: {e}. Fallback engine will be used.")

def predict_message_ml(text: str) -> Optional[Dict[str, Any]]:
    """
    Runs model inference on CPU.
    Returns:
        Dict with 'classification' ('fraud', 'spam', 'legitimate'), 'scores' dict, and 'model_used'.
    """
    global _tokenizer, _model, _status
    if _status != "ready" or _model is None or _tokenizer is None:
        return None
    
    try:
        import torch
        inputs = _tokenizer(text, return_tensors="pt", truncation=True, max_length=256)
        with torch.no_grad():
            outputs = _model(**inputs)
            logits = outputs.logits[0]
            probs = torch.softmax(logits, dim=-1).cpu().numpy()
            
        id2label = _model.config.id2label if hasattr(_model.config, "id2label") else {0: "legitimate", 1: "spam", 2: "fraud"}
        
        # Build score dictionary
        scores = {}
        for idx, prob in enumerate(probs):
            label = str(id2label.get(idx, f"class_{idx}")).lower()
            # Normalize label terms if needed
            if "phish" in label or "fraud" in label:
                norm_label = "fraud"
            elif "spam" in label:
                norm_label = "spam"
            elif "legit" in label or "ham" in label:
                norm_label = "legitimate"
            else:
                norm_label = label
            scores[norm_label] = round(float(prob), 4)

        # Determine winner
        best_label = max(scores, key=scores.get)
        
        return {
            "model_used": "pretrained_transformer",
            "classification": best_label,
            "scores": scores
        }
    except Exception as e:
        logger.error(f"Inference error with Hugging Face model: {e}")
        return None
