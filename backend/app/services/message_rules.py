import re
from typing import List, Tuple
from app.schemas.analysis import SignalItem

# Regex pattern for extracting URLs safely without visiting
URL_REGEX = re.compile(
    r'(?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*|'
    r'[a-zA-Z0-9.-]+\.(?:com|org|net|xyz|top|info|live|ru|cn|in|app|tech|cc|link|vip|pw|me)[^\s]*',
    re.IGNORECASE
)

# Rule definitions
RULES = [
    {
        "code": "urgent_account_blocking",
        "severity": "high",
        "description": "Uses urgent account suspension, freezing, or blocking threats.",
        "patterns": [
            r"\b(account|card|sim|access|service)\s+(will be|is|has been)?\s*(suspended|blocked|terminated|closed|locked|restricted)\b",
            r"\b(block|suspend|deactivate|freeze)\s+(your\s+)?(account|access|card)\b",
            r"\bimmediate\s+(action|verification|attention)\s+required\b",
            r"\baction\s+required\s+within\s+\d+\s*(hours?|minutes?|days?)\b",
            r"\bverify\s+(immediately|now|urgently|within\s+\d+\s*hours?)\b",
            r"\blast\s+warning\b",
            r"\burgent\s+notice\b"
        ]
    },
    {
        "code": "credential_otp_request",
        "severity": "critical",
        "description": "Explicitly requests secret credentials, passwords, PINs, or OTPs.",
        "patterns": [
            r"\b(share|send|enter|submit|provide|give)\s+(your\s+)?(otp|pin|password|cvv|passcode|secret\s+code)\b",
            r"\bnever\s+share\b", # Handled contextually in logic below if warning or requesting
            r"\botp\s+(is|to\s+verify|for\s+transaction)\b",
            r"\bverify\s+(your\s+)?(identity|details|credentials|password|pin|card)\b",
            r"\bupdate\s+(your\s+)?(kyc|pan|aadhaar|bank\s+details|billing\s+info)\b"
        ]
    },
    {
        "code": "lottery_reward_prize",
        "severity": "high",
        "description": "Claims unsolicited lottery wins, prize money, cashbacks, or gift cards.",
        "patterns": [
            r"\b(congratulations|congrats|winner|won)\b.*\b(lottery|prize|reward|gift\s*card|jackpot|\$\d+|rs\.?\s*\d+|\£\d+|cashback)\b",
            r"\byou\s+have\s+(been\s+selected|won|received)\b.*\b(claim|collect|redeem)\b",
            r"\bclaim\s+(your\s+)?(reward|prize|cash|gift|voucher|bonus)\b"
        ]
    },
    {
        "code": "urgent_payment_refund",
        "severity": "high",
        "description": "Demands immediate payment, fee, or dangling fake refund approval.",
        "patterns": [
            r"\b(pay|transfer|remit|deposit)\s+(now|immediately|urgently|\$\d+|rs\.?\s*\d+)\b",
            r"\brefund\s+(is\s+ready|approved|processed|pending)\b.*\b(click|claim|verify)\b",
            r"\bfailed\s+delivery\b.*\b(fee|redelivery|pay|address)\b",
            r"\belectricity\s+power\s+(will\s+be\s+cut|disconnected)\b"
        ]
    },
    {
        "code": "impersonation_authority",
        "severity": "medium",
        "description": "Mentions high-profile authorities, banks, postal services, or tech companies.",
        "patterns": [
            r"\b(income\s+tax\s+department|irs|fbi|customs|central\s+bank|rbi|police|fedex|dhl|usps|royal\s+mail|amazon|netflix|paypal|apple|microsoft|google\s+security)\b"
        ]
    },
    {
        "code": "suspicious_call_to_action",
        "severity": "medium",
        "description": "Pushes suspicious action verbs such as clicking unknown links or calling numbers.",
        "patterns": [
            r"\bclick\s+(here|the\s+link|below|link\s+to)\b",
            r"\btap\s+to\s+(update|verify|claim)\b",
            r"\bcall\s+(immediately|helpline|customer\s+care\s+at\s+\+?\d+)\b"
        ]
    }
]

def extract_urls_from_text(text: str) -> List[str]:
    """Extracts web URLs from input text without resolving them."""
    matches = URL_REGEX.findall(text)
    clean_urls = []
    for match in matches:
        u = match.strip(".,;:()[]{}<>\"'")
        if u and u not in clean_urls:
            clean_urls.append(u)
    return clean_urls

def analyze_message_rules(text: str) -> Tuple[List[SignalItem], int, str]:
    """
    Evaluates rule-based signals on message text.
    Returns: (signals_detected, base_risk_score, provisional_category)
    """
    signals: List[SignalItem] = []
    total_weight = 0
    clean_text = text.lower()
    
    # Check if this is an explicit bank warning stating "DO NOT SHARE OTP"
    legit_warning_context = bool(re.search(r"\bdo\s+not\s+share\s+(otp|password|pin)\b", clean_text))

    for rule in RULES:
        matched = False
        for pat in rule["patterns"]:
            if re.search(pat, clean_text):
                # If it's a security warning like "Do not share OTP with anyone", don't flag as credential theft
                if rule["code"] == "credential_otp_request" and legit_warning_context and "share" in pat:
                    continue
                matched = True
                break
        
        if matched:
            signals.append(SignalItem(
                code=rule["code"],
                description=rule["description"],
                severity=rule["severity"]
            ))
            if rule["severity"] == "critical":
                total_weight += 45
            elif rule["severity"] == "high":
                total_weight += 25
            elif rule["severity"] == "medium":
                total_weight += 15
            else:
                total_weight += 5

    # Check for URLs in message
    urls = extract_urls_from_text(text)
    if urls:
        signals.append(SignalItem(
            code="embedded_url",
            description=f"Message contains {len(urls)} embedded web link(s).",
            severity="medium"
        ))
        total_weight += 15

    # Bound risk score 0 to 100
    risk_score = min(total_weight, 98) if total_weight > 0 else 5
    
    # Provisional classification
    if risk_score >= 65:
        category = "fraud"
    elif risk_score >= 35:
        category = "spam"
    else:
        category = "legitimate"

    return signals, risk_score, category
