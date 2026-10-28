import pytest
import sys
import os
from fastapi.testclient import TestClient

# Add app to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from app.main import app
from app.services.message_rules import analyze_message_rules, extract_urls_from_text
from app.services.url_analyzer import extract_url_features, normalize_url

client = TestClient(app)

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "message_model_status" in data
    assert data["rule_based_fallback_available"] is True

def test_empty_message_validation():
    response = client.post("/analyze/message", json={"message": "   "})
    assert response.status_code == 400

def test_empty_url_validation():
    response = client.post("/analyze/url", json={"url": "   "})
    assert response.status_code == 400

def test_rule_based_message_urgent_threat():
    msg = "Your bank account has been suspended! Verify your OTP and PIN immediately."
    signals, score, category = analyze_message_rules(msg)
    assert score >= 60
    assert category == "fraud"
    codes = [s.code for s in signals]
    assert "urgent_account_blocking" in codes
    assert "credential_otp_request" in codes

def test_legitimate_security_alert_not_falsely_flagged():
    msg = "Dear customer, your OTP is 849201. Remember: NEVER share your OTP with anyone, including bank staff."
    signals, score, category = analyze_message_rules(msg)
    # Shouldn't trigger credential theft because it's a protective advisory
    codes = [s.code for s in signals]
    assert "credential_otp_request" not in codes

def test_url_normalization():
    assert normalize_url("google.com/test") == "http://google.com/test"
    assert normalize_url("https://secure.site.org") == "https://secure.site.org"

def test_suspicious_url_ip_hostname():
    features, signals, score, risk_level = extract_url_features("http://192.168.1.100/login/bank")
    assert features.has_ip_hostname is True
    assert risk_level in ["high", "critical"]
    codes = [s.code for s in signals]
    assert "ip_address_host" in codes

def test_suspicious_url_punycode():
    features, signals, score, risk_level = extract_url_features("http://xn--gogle-pra.com/signin")
    assert features.has_punycode is True
    codes = [s.code for s in signals]
    assert "punycode_domain" in codes

def test_suspicious_url_shortener():
    features, signals, score, risk_level = extract_url_features("https://bit.ly/3xY8Z9")
    assert features.is_shortener is True
    codes = [s.code for s in signals]
    assert "url_shortener" in codes

def test_analyze_message_api():
    response = client.post("/analyze/message", json={
        "message": "URGENT: Click http://bit.ly/bank to claim your $1000 prize now!"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["scan_type"] == "message"
    assert "risk_score" in data
    assert "signals" in data
    assert len(data["urls_found"]) > 0

def test_analyze_url_api():
    response = client.post("/analyze/url", json={
        "url": "http://192.168.1.100@phishing.xyz/verify"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["scan_type"] == "url"
    assert data["risk_level"] in ["high", "critical"]
    assert "recommendations" in data


if __name__ == "__main__":
    print("[*] Running TraceLens backend unit tests...")
    test_health_endpoint()
    print("  [+] test_health_endpoint passed")
    test_empty_message_validation()
    print("  [+] test_empty_message_validation passed")
    test_empty_url_validation()
    print("  [+] test_empty_url_validation passed")
    test_rule_based_message_urgent_threat()
    print("  [+] test_rule_based_message_urgent_threat passed")
    test_legitimate_security_alert_not_falsely_flagged()
    print("  [+] test_legitimate_security_alert_not_falsely_flagged passed")
    test_url_normalization()
    print("  [+] test_url_normalization passed")
    test_suspicious_url_ip_hostname()
    print("  [+] test_suspicious_url_ip_hostname passed")
    test_suspicious_url_punycode()
    print("  [+] test_suspicious_url_punycode passed")
    test_suspicious_url_shortener()
    print("  [+] test_suspicious_url_shortener passed")
    test_analyze_message_api()
    print("  [+] test_analyze_message_api passed")
    test_analyze_url_api()
    print("  [+] test_analyze_url_api passed")
    print("\n[SUCCESS] ALL 11 BACKEND UNIT TESTS PASSED!")
