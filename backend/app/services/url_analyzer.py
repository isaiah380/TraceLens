import re
from urllib.parse import urlparse
from typing import List, Tuple
from app.schemas.analysis import SignalItem, UrlFeatureDetails

KNOWN_SHORTENERS = {
    "bit.ly", "tinyurl.com", "t.co", "is.gd", "buff.ly", "ow.ly",
    "rb.gy", "cutt.ly", "shorturl.at", "tiny.cc", "goo.gl"
}

SUSPICIOUS_TLDS = {
    "xyz", "top", "work", "click", "link", "gq", "ml", "cf", "ga", "tk",
    "buzz", "fit", "rest", "surf", "cam", "loan", "stream", "live", "vip", "pw"
}

SUSPICIOUS_URL_KEYWORDS = [
    "login", "verify", "secure", "account", "banking", "update", "wallet",
    "signin", "confirm", "support", "service", "security", "recovery", "free"
]

def normalize_url(raw_url: str) -> str:
    """Safely normalizes input URL without connecting to network."""
    url = raw_url.strip()
    if not url.startswith(("http://", "https://")):
        # Default to http:// for parsing purposes
        url = "http://" + url
    return url

def extract_url_features(raw_url: str) -> Tuple[UrlFeatureDetails, List[SignalItem], int, str]:
    """
    Analyzes structural features of the URL safely.
    Returns: (features, signals, risk_score, risk_level)
    """
    norm_url = normalize_url(raw_url)
    parsed = urlparse(norm_url)
    
    hostname = (parsed.hostname or "").lower()
    path = parsed.path.lower()
    query = parsed.query.lower()
    
    signals: List[SignalItem] = []
    score = 0
    
    # 1. IP address hostname check (e.g. http://192.168.1.1/login)
    ip_match = re.match(r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", hostname)
    has_ip_hostname = bool(ip_match)
    if has_ip_hostname:
        signals.append(SignalItem(
            code="ip_address_host",
            description="The URL uses a raw numeric IP address instead of a standard domain name.",
            severity="critical"
        ))
        score += 45

    # 2. Punycode check (internationalized domain spoofing, e.g. xn--)
    has_punycode = "xn--" in hostname
    if has_punycode:
        signals.append(SignalItem(
            code="punycode_domain",
            description="The domain uses Punycode encoding, often used for homograph character spoofing.",
            severity="high"
        ))
        score += 30

    # 3. Known URL Shortener
    is_shortener = hostname in KNOWN_SHORTENERS
    if is_shortener:
        signals.append(SignalItem(
            code="url_shortener",
            description="URL uses a redirection/shortening service which conceals the real final destination.",
            severity="medium"
        ))
        score += 20

    # 4. @ symbol in URL (userinfo spoofing, e.g. http://google.com@evil.com)
    has_at_symbol = "@" in parsed.netloc
    if has_at_symbol:
        signals.append(SignalItem(
            code="at_symbol_in_authority",
            description="URL contains '@' in the authority component, commonly used to trick users about destination.",
            severity="critical"
        ))
        score += 40

    # 5. Excessive subdomains
    subdomain_parts = hostname.split(".")
    num_subdomains = max(0, len(subdomain_parts) - 2)
    if num_subdomains >= 3:
        signals.append(SignalItem(
            code="excessive_subdomains",
            description=f"Hostname contains {num_subdomains} subdomains, which is typical for domain evasion.",
            severity="high"
        ))
        score += 25
    elif num_subdomains == 2:
        score += 10

    # 6. Suspicious TLD
    tld = subdomain_parts[-1] if subdomain_parts else ""
    if tld in SUSPICIOUS_TLDS:
        signals.append(SignalItem(
            code="suspicious_tld",
            description=f"Domain uses high-abuse top-level domain (.{tld}).",
            severity="medium"
        ))
        score += 20

    # 7. Overall URL length
    total_len = len(norm_url)
    if total_len > 100:
        signals.append(SignalItem(
            code="excessive_url_length",
            description=f"Unusually long URL ({total_len} characters) often used to conceal malicious parameters.",
            severity="medium"
        ))
        score += 15
    elif total_len > 75:
        score += 8

    # 8. Suspicious security keywords in non-standard context
    found_keywords = [kw for kw in SUSPICIOUS_URL_KEYWORDS if kw in (path + query)]
    if found_keywords and (is_shortener or num_subdomains >= 2 or has_ip_hostname or tld in SUSPICIOUS_TLDS):
        signals.append(SignalItem(
            code="deceptive_keywords",
            description=f"URL path or query contains sensitive security terms ({', '.join(found_keywords)}) on an untrusted structure.",
            severity="high"
        ))
        score += 25

    # 9. HTTPS vs HTTP
    is_https = parsed.scheme.lower() == "https"
    if not is_https:
        signals.append(SignalItem(
            code="unencrypted_http",
            description="URL uses unencrypted plaintext HTTP connection.",
            severity="low"
        ))
        score += 10

    # 10. Suspicious hex or percent encoding in host
    if "%" in hostname:
        signals.append(SignalItem(
            code="obfuscated_host_encoding",
            description="Hostname contains URL percent-encoding obfuscation.",
            severity="high"
        ))
        score += 30

    final_score = min(max(score, 5), 98) if score > 0 else 5
    
    if final_score >= 65:
        risk_level = "critical" if final_score >= 80 else "high"
    elif final_score >= 35:
        risk_level = "medium"
    else:
        risk_level = "low"

    features = UrlFeatureDetails(
        length=total_len,
        hostname=hostname,
        num_subdomains=num_subdomains,
        has_ip_hostname=has_ip_hostname,
        is_shortener=is_shortener,
        has_at_symbol=has_at_symbol,
        is_https=is_https,
        has_punycode=has_punycode,
        suspicious_keywords_present=found_keywords
    )

    return features, signals, final_score, risk_level
