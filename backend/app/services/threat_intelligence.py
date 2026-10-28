import os
import requests
from typing import Optional

def check_url_reputation(url: str) -> Optional[str]:
    """
    Checks URL threat intelligence (Google Safe Browsing API v4) if API key is provided.
    Never fails or throws; returns descriptive status.
    """
    api_key = os.getenv("SAFE_BROWSING_API_KEY", "").strip()
    if not api_key:
        return "Threat intelligence unavailable (API key not configured)"

    api_url = f"https://safebrowsing.googleapis.com/v4/threatMatches:find?key={api_key}"
    payload = {
        "client": {
            "clientId": "TraceLens-Security",
            "clientVersion": "1.0.0"
        },
        "threatInfo": {
            "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE", "POTENTIALLY_HARMFUL_APPLICATION"],
            "platformTypes": ["ANY_PLATFORM"],
            "threatEntryTypes": ["URL"],
            "threatEntries": [{"url": url}]
        }
    }

    try:
        response = requests.post(api_url, json=payload, timeout=3.0)
        if response.status_code == 200:
            data = response.json()
            matches = data.get("matches", [])
            if matches:
                types = [m.get("threatType") for m in matches]
                return f"CONFIRMED THREAT: Flagged by Safe Browsing as {', '.join(types)}"
            return "No threats detected in known threat intelligence feeds."
        else:
            return f"Threat intelligence check returned status code {response.status_code}"
    except Exception as e:
        return f"Threat intelligence lookup timed out or failed: {str(e)}"
