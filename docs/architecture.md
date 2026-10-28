# TraceLens Architecture Documentation

## System Architecture Overview

```
                      +----------------------------------------+
                      |       TraceLens Mobile App             |
                      |            (Flutter/Dart)              |
                      +-------------------+--------------------+
                                          |
                                          | HTTP REST (JSON)
                                          v
                      +----------------------------------------+
                      |       FastAPI Defense Server           |
                      |            (Python 3.14)               |
                      +-------------------+--------------------+
                                          |
            +-----------------------------+------------------------------+
            |                             |                              |
            v                             v                              v
+-----------------------+     +------------------------+     +-------------------------+
| Hugging Face Model    |     | Transparent Rule       |     | Structural URL          |
| Horizon-Labs/phishing-|     | Heuristics Engine      |     | Analyzer & ML Classifier|
| scam-detector-base    |     | (Urgency, OTP theft)   |     | (RFC parser, RF model)  |
+-----------------------+     +------------------------+     +-------------------------+
            |                             |                              |
            +-----------------------------+------------------------------+
                                          |
                                          v
                      +----------------------------------------+
                      | Evidence Combination & Explainability  |
                      | (Calibrated Risk Score & Signals)      |
                      +----------------------------------------+
```

## Component Breakdown

1. **Flutter Mobile Frontend**
   * Target: Android (Emulator & Physical Hardware)
   * Theme: Dark cybersecurity slate/teal palette
   * Modules:
     * `HomeScreen`: Dashboard showing live engine state and quick triage access.
     * `MessageScannerScreen`: Clipboard/text input with prompt verification and feedback.
     * `UrlScannerScreen`: Non-interactive structural link inspection.
     * `QrScannerScreen`: Camera link scanner with safe preview fallback for plain text.
     * `ResultScreen`: Explainable signals, probabilities, model methods, and safety disclaimers.
     * `HistoryScreen`: Local SQLite persistence of redacted (60-char) past scans.
     * `SettingsScreen`: Central dynamic API IP address configuration and health test.

2. **FastAPI Backend Service**
   * Framework: FastAPI with Uvicorn server and Pydantic schemas.
   * Endpoints:
     * `GET /health`: Engine readiness and fallback state.
     * `POST /analyze/message`: Natural language classification + signal triggers.
     * `POST /analyze/url`: Structural URL analysis + optional ML classification + reputation check.
     * `POST /analyze/qr`: QR content link safety evaluation.

3. **Machine Learning & Heuristics**
   * **Message Model**: `Horizon-Labs/phishing-scam-detector-base` (Sequence classification into `fraud`, `spam`, `legitimate`). Runs on CPU with automatic heuristic fallback if offline.
   * **Rule Engine**: Independent regular expressions analyzing urgency threats, prize scams, and credential harvesting.
   * **URL Analyzer**: Evaluates hostname composition, raw IP usage, Punycode tricks, excessive subdomains, and URL shorteners.
   * **URL ML Model**: Scikit-Learn `RandomForestClassifier` trained on extracted 14-dimension structural feature vectors.
