# TraceLens API Specification

## Base URL
Default: `http://localhost:8000` or `http://10.0.2.2:8000` (Android Emulator)

Interactive Swagger UI: `http://localhost:8000/docs`

---

### 1. Health Check
* **Endpoint**: `GET /health`
* **Description**: Verifies operational readiness of backend and reports ML model status.
* **Response**:
```json
{
  "status": "ok",
  "message_model_status": "Fallback mode active (Model uninitialized)",
  "model_name": "Horizon-Labs/phishing-scam-detector-base",
  "rule_based_fallback_available": true,
  "url_ml_status": "Optional URL model not trained (training pipeline ready)"
}
```

---

### 2. Message Analysis
* **Endpoint**: `POST /analyze/message`
* **Request**:
```json
{
  "message": "URGENT: Your account has been suspended! Verify your OTP immediately at http://bit.ly/bank"
}
```
* **Response**:
```json
{
  "scan_type": "message",
  "model_used": "rule_based",
  "classification": "fraud",
  "risk_level": "high",
  "risk_score": 75,
  "signals": [
    {
      "code": "urgent_account_blocking",
      "description": "Uses urgent account suspension, freezing, or blocking threats.",
      "severity": "high"
    },
    {
      "code": "embedded_url",
      "description": "Message contains 1 embedded web link(s).",
      "severity": "medium"
    }
  ],
  "urls_found": [
    "http://bit.ly/bank"
  ],
  "model_scores": null,
  "recommendations": [
    "Do NOT provide OTPs, passwords, banking PINs, or verify personal credentials.",
    "Do not click any embedded links in this message.",
    "Contact the organization directly using their verified website or official app."
  ],
  "disclaimer": "Automated assessment; not a guarantee of safety. Independent human verification recommended."
}
```

---

### 3. URL Analysis
* **Endpoint**: `POST /analyze/url`
* **Request**:
```json
{
  "url": "http://192.168.1.100/login/bank"
}
```
* **Response**:
```json
{
  "scan_type": "url",
  "original_url": "http://192.168.1.100/login/bank",
  "normalized_url": "http://192.168.1.100/login/bank",
  "hostname": "192.168.1.100",
  "risk_level": "critical",
  "risk_score": 90,
  "signals": [
    {
      "code": "ip_address_host",
      "description": "The URL uses a raw numeric IP address instead of a standard domain name.",
      "severity": "critical"
    }
  ],
  "url_features": {
    "length": 31,
    "hostname": "192.168.1.100",
    "num_subdomains": 2,
    "has_ip_hostname": true,
    "is_shortener": false,
    "has_at_symbol": false,
    "is_https": false,
    "has_punycode": false,
    "suspicious_keywords_present": ["login"]
  },
  "ml_prediction": null,
  "threat_intel_result": "Threat intelligence unavailable (API key not configured)",
  "recommendations": [
    "Do NOT open or enter login credentials on this website."
  ],
  "disclaimer": "Automated structural and algorithmic analysis; does not actively load website content."
}
```
