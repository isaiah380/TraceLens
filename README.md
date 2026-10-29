# TraceLens

> **"Spot the scam before it gets you."**  
> AI-Powered Scam, Phishing Message and Malicious URL Detection Mobile Application.

TraceLens is a mobile application and machine learning defensive cybersecurity platform designed to protect users from fraudulent messages, phishing schemes, malicious URLs, and evasive QR code traps.

---

## 🌟 Key Features

* **Suspicious Message Scanner**: Evaluates SMS, WhatsApp, and email messages using natural language processing and heuristic rule indicators (urgency blocking, OTP harvesting, fake lottery wins).
* **Zero-Touch URL Scanner**: Inspects domain structures, Punycode spoofing (`xn--`), raw IP hosts, and URL shorteners without navigating to the target website.
* **Safe QR Code Scanner**: Decodes camera QR barcodes and assesses destination links before opening.
* **Explainable Security Assessments**: Clear risk levels (`Low`, `Medium`, `High`, `Critical`), risk scores (0–100%), and human-readable signal justifications.
* **Persistent Local History**: SQLite-backed history tracking with truncated 60-character previews for privacy.
* **Signed-in Navigation**: Home, Check, Activity, Learn and Profile sections, with bottom navigation on phones and a side rail on wide screens.
* **Activity Insights**: Seven-day scan counts, message/link/QR filters, per-item deletion, clear history and CSV copy/export.
* **Safety Guide**: In-app scam warning signs and response steps. This is an educational guide, not a live scam trends feed.
* **Android Share to Scan**: Share text or a URL from another Android app to open the matching TraceLens scanner.
* **Assessment Actions**: Contextual next steps and a copyable assessment summary that excludes the original message or link.
* **Pretrained ML + Heuristic Fallback**: Integrated with Hugging Face (`Horizon-Labs/phishing-scam-detector-base`) with an automated fallback engine.
* **Optional URL ML Pipeline**: Random Forest training and evaluation scripts for structural link features.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Mobile Frontend** | Flutter 3.16+ / Dart (Android Target) |
| **Backend API** | Python 3.10+ / FastAPI / Uvicorn / Pydantic |
| **Message Classification** | Hugging Face Transformers (`Horizon-Labs/phishing-scam-detector-base`) / PyTorch |
| **URL Analysis** | Lexical RFC Parsing & Scikit-Learn (`RandomForestClassifier`) |
| **Client Storage** | SQLite (`sqflite`) for Flutter |

---

## 🚀 Quick Start Guide

### 1. Launch Backend (FastAPI)

```powershell
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
* **Swagger Documentation**: Open `http://localhost:8000/docs`
* **Health Check**: Open `http://localhost:8000/health`

### 2. Run Backend Unit Tests

```powershell
cd backend
python tests/test_backend.py
```

### 3. Launch Mobile Application (Flutter)

```powershell
cd mobile
flutter pub get
flutter run
```

### 📱 Connecting to Backend:
* **Android Emulator**: Uses `http://10.0.2.2:8000` automatically.
* **Physical Device**: Go to app **Settings** (top right gear icon), type `http://<YOUR_PC_IP>:8000` (e.g. `http://192.168.1.15:8000`), and tap **Save & Reconnect**.

---

## 📁 Repository Structure

```
TraceLens/
|-- backend/
|   |-- app/
|   |   |-- main.py                     # FastAPI entrypoint & lifespan
|   |   |-- config.py                   # Pydantic environment settings
|   |   |-- routers/                    # Health, Message, and URL routers
|   |   |-- schemas/                    # Pydantic request/response models
|   |   |-- services/                   # Rules, ML inference, and risk synthesis
|   |-- ml/
|   |   |-- url_features.py             # 14-dim URL feature extractor
|   |   |-- train_url_model.py          # Random Forest URL training pipeline
|   |   |-- evaluate_url_model.py       # Evaluation script for URL model
|   |   |-- url_model.py                # Joblib loader & inference
|   |-- tests/
|   |   |-- test_backend.py             # Unit test suite
|   |-- requirements.txt
|   |-- .env.example
|
|-- mobile/
|   |-- lib/
|   |   |-- main.dart                   # Flutter app entry point
|   |   |-- app.dart                    # MaterialApp & theme configuration
|   |   |-- config/app_config.dart      # Dynamic backend endpoint config
|   |   |-- models/                     # AnalysisResult & ScanHistoryItem
|   |   |-- database/local_database.dart# SQLite persistent scan history
|   |   |-- services/                   # HTTP client and history services
|   |   |-- screens/                    # Home, Message, URL, QR, History, Settings
|   |   |-- widgets/                    # RiskBadge, AnalysisCard, Loading
|   |   |-- theme/app_theme.dart        # Cybersecurity dark slate theme
|   |-- pubspec.yaml
|
|-- datasets/
|   |-- README.md                       # URL ML dataset schema guidelines
|-- docs/
|   |-- architecture.md                 # System diagrams and component flow
|   |-- setup.md                        # Step-by-step installation instructions
|   |-- api.md                          # Endpoint documentation with JSON schemas
|   |-- model_evaluation.md             # Transformer & URL classifier docs
|   |-- privacy.md                      # Defensive cybersecurity principles
|-- README.md
```

---

## 🔒 Security & Privacy Notice

TraceLens is built for defensive security awareness. Never paste one-time codes, banking PINs, passwords, or payment details into a scan. Email/password accounts in this prototype are device-local and are not backed by server identity; scan history is also device-local. Do not use these demo credentials as a production account. Team/family sharing, cross-device history, screenshot OCR, live scam trend feeds, and subscription billing need additional backend and provider integrations. The app does not automatically load or visit untrusted destination URLs.
