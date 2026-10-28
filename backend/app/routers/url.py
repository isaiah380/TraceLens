from fastapi import APIRouter, HTTPException
from app.schemas.analysis import UrlAnalysisRequest, UrlAnalysisResponse, QrAnalysisRequest, SignalItem
from app.services.url_analyzer import extract_url_features, normalize_url
from app.services.threat_intelligence import check_url_reputation
from ml.url_model import predict_url_ml

router = APIRouter(prefix="/analyze", tags=["URL Analysis"])

@router.post("/url", response_model=UrlAnalysisResponse)
def analyze_url(req: UrlAnalysisRequest):
    raw_url = req.url.strip()
    if not raw_url:
        raise HTTPException(status_code=400, detail="URL cannot be empty.")
    
    # 1. Structural feature extraction and heuristics
    features, signals, score, risk_level = extract_url_features(raw_url)
    
    # 2. Optional Random Forest ML URL classifier (Level 3)
    ml_pred = predict_url_ml(raw_url)
    if ml_pred:
        if ml_pred["prediction"] == "phishing":
            signals.append(SignalItem(
                code="ml_url_phishing_flag",
                description=f"URL structural classifier flagged URL as phishing ({int(ml_pred['phishing_probability']*100)}% risk).",
                severity="high"
            ))
            score = max(score, int(ml_pred["phishing_probability"] * 85))
            if score >= 65:
                risk_level = "critical" if score >= 85 else "high"

    # 3. Optional Threat Intelligence reputation check (Level 3)
    threat_intel = check_url_reputation(raw_url)
    if threat_intel and "CONFIRMED THREAT" in threat_intel:
        signals.insert(0, SignalItem(
            code="confirmed_threat_intel",
            description=threat_intel,
            severity="critical"
        ))
        score = 99
        risk_level = "critical"

    # Formulate recommendations
    recommendations = []
    if risk_level in ["high", "critical"]:
        recommendations.append("Do NOT open or enter login credentials on this website.")
        recommendations.append("The domain structure exhibits characteristics commonly associated with malicious phishing.")
    elif risk_level == "medium":
        recommendations.append("Proceed with caution. Verify the full domain before entering any personal details.")
    else:
        recommendations.append("No abnormal structural anomalies detected.")
        recommendations.append("Always verify you are connected over HTTPS to the intended brand.")

    return UrlAnalysisResponse(
        scan_type="url",
        original_url=raw_url,
        normalized_url=normalize_url(raw_url),
        hostname=features.hostname,
        risk_level=risk_level,
        risk_score=score,
        signals=signals,
        url_features=features,
        ml_prediction=ml_pred,
        threat_intel_result=threat_intel,
        recommendations=recommendations,
        disclaimer="Automated structural and algorithmic analysis; does not actively load website content."
    )

@router.post("/qr", response_model=UrlAnalysisResponse)
def analyze_qr(req: QrAnalysisRequest):
    content = req.content.strip()
    if not content:
        raise HTTPException(status_code=400, detail="QR content cannot be empty.")
    # Check if content looks like a URL
    return analyze_url(UrlAnalysisRequest(url=content))
