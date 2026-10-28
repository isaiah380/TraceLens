import os
import re
from urllib.parse import urlparse
import numpy as np

# Canonical feature names in exact order
URL_FEATURE_NAMES = [
    "url_length",
    "hostname_length",
    "num_dots",
    "num_hyphens",
    "num_digits",
    "num_subdomains",
    "has_ip_hostname",
    "has_at_symbol",
    "is_https",
    "is_shortener",
    "num_path_segments",
    "query_length",
    "has_punycode",
    "has_sensitive_keywords"
]

KNOWN_SHORTENERS = {
    "bit.ly", "tinyurl.com", "t.co", "is.gd", "buff.ly", "ow.ly",
    "rb.gy", "cutt.ly", "shorturl.at", "tiny.cc", "goo.gl"
}

KEYWORDS = [
    "login", "verify", "secure", "account", "banking", "update", "wallet",
    "signin", "confirm", "support", "service", "security", "recovery", "free"
]

def extract_features_vector(raw_url: str) -> np.ndarray:
    """Extracts numeric feature vector from a single URL string."""
    url = raw_url.strip()
    if not url.startswith(("http://", "https://")):
        url = "http://" + url
    parsed = urlparse(url)
    
    hostname = (parsed.hostname or "").lower()
    path = parsed.path.lower()
    query = parsed.query.lower()

    # 1. url length
    url_length = len(url)
    # 2. hostname length
    hostname_length = len(hostname)
    # 3. num dots
    num_dots = url.count(".")
    # 4. num hyphens
    num_hyphens = url.count("-")
    # 5. num digits
    num_digits = sum(c.isdigit() for c in url)
    # 6. num subdomains
    sub_parts = hostname.split(".")
    num_subdomains = max(0, len(sub_parts) - 2)
    # 7. has IP hostname
    has_ip = 1.0 if re.match(r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$", hostname) else 0.0
    # 8. has @
    has_at = 1.0 if "@" in parsed.netloc else 0.0
    # 9. is HTTPS
    is_https = 1.0 if parsed.scheme.lower() == "https" else 0.0
    # 10. is shortener
    is_shortener = 1.0 if hostname in KNOWN_SHORTENERS else 0.0
    # 11. num path segments
    path_segments = [p for p in path.split("/") if p]
    num_path_segments = len(path_segments)
    # 12. query length
    query_length = len(query)
    # 13. has punycode
    has_punycode = 1.0 if "xn--" in hostname else 0.0
    # 14. has sensitive keywords
    has_keywords = 1.0 if any(kw in (path + query) for kw in KEYWORDS) else 0.0

    return np.array([
        url_length,
        hostname_length,
        num_dots,
        num_hyphens,
        num_digits,
        num_subdomains,
        has_ip,
        has_at,
        is_https,
        is_shortener,
        num_path_segments,
        query_length,
        has_punycode,
        has_keywords
    ], dtype=np.float32)
