from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class SignalItem(BaseModel):
    code: str = Field(..., description="Stable programmatic identifier for signal")
    description: str = Field(..., description="Human readable explanation")
    severity: str = Field(..., description="low, medium, high, or critical")

class MessageAnalysisRequest(BaseModel):
    message: str = Field(..., min_length=1, description="Raw message text to be analyzed")

class UrlAnalysisRequest(BaseModel):
    url: str = Field(..., min_length=1, description="URL to be analyzed")

class QrAnalysisRequest(BaseModel):
    content: str = Field(..., min_length=1, description="Decoded QR string or URL")

class MessageAnalysisResponse(BaseModel):
    scan_type: str = "message"
    model_used: str = Field(..., description="pretrained_transformer, rule_based, or combined")
    classification: str = Field(..., description="fraud, spam, legitimate, or suspicious")
    risk_level: str = Field(..., description="low, medium, high, or critical")
    risk_score: int = Field(..., ge=0, le=100, description="Risk score 0-100")
    signals: List[SignalItem] = []
    urls_found: List[str] = []
    model_scores: Optional[Dict[str, float]] = None
    recommendations: List[str] = []
    disclaimer: str = "Automated assessment; not a guarantee of safety. Independent verification recommended."

class UrlFeatureDetails(BaseModel):
    length: int
    hostname: str
    num_subdomains: int
    has_ip_hostname: bool
    is_shortener: bool
    has_at_symbol: bool
    is_https: bool
    has_punycode: bool
    suspicious_keywords_present: List[str] = []

class UrlAnalysisResponse(BaseModel):
    scan_type: str = "url"
    original_url: str
    normalized_url: str
    hostname: str
    risk_level: str
    risk_score: int
    signals: List[SignalItem] = []
    url_features: UrlFeatureDetails
    ml_prediction: Optional[Dict[str, Any]] = None
    threat_intel_result: Optional[str] = "Threat intelligence unavailable (API key not configured)"
    recommendations: List[str] = []
    disclaimer: str = "Automated structural and algorithmic analysis; does not actively load website content."

class HealthResponse(BaseModel):
    status: str
    message_model_status: str
    model_name: str
    rule_based_fallback_available: bool
    url_ml_status: str
