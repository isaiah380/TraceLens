# TraceLens Setup & Installation Guide

## 1. Prerequisites
* **Python**: Python 3.10+ (Tested on Python 3.14)
* **Flutter SDK**: 3.16+ (Dart 3.2+)
* **Android Studio & SDK**: With an Android Emulator or physical phone with USB debugging enabled.

---

## 2. Backend Setup (FastAPI)

Open a Windows PowerShell terminal in the project root:

```powershell
# Navigate to backend directory
cd d:\isaiah\TraceLens\backend

# Install required Python packages
pip install -r requirements.txt

# Start the FastAPI server using Uvicorn
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

* Test Swagger Documentation: Open your browser to `http://localhost:8000/docs`
* Verify Health Endpoint: Open `http://localhost:8000/health`

---

## 3. Flutter Mobile Setup

In a new terminal window:

```powershell
# Navigate to mobile directory
cd d:\isaiah\TraceLens\mobile

# Get Flutter dependencies
flutter pub get

# Run on connected Android device or emulator
flutter run
```

### Networking Guide:
* **Android Emulator**: Uses `http://10.0.2.2:8000` by default to reach your development PC.
* **Physical Device**:
  1. Find your computer's local Wi-Fi IP address in PowerShell via `ipconfig` (e.g. `192.168.1.15`).
  2. In the TraceLens Mobile App, tap **Settings (Gear Icon)**.
  3. Enter `http://192.168.1.15:8000` and tap **Save & Reconnect**.
