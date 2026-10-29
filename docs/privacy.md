# Privacy & Threat Analysis Philosophy

## Defensive Architecture
TraceLens is built exclusively for defensive security assessment and user fraud-awareness. It strictly adheres to privacy-by-design guidelines:

1. **Zero Raw Secret Collection**:
   * The scanner should not be given OTPs, PINs, passwords, or payment card data. The prototype's email/password sign-in is device-local and is not a production identity service; scan history is local and not cloud-synced.
   * Legitimate warning advisories containing phrases like "Do not share OTP" are distinguished from active credential theft attempts.

2. **No Automatic Network Fetching of Untrusted Targets**:
   * The backend does **not** follow HTTP redirects, scrape HTML, or initiate TCP handshakes with suspicious destination hosts.
   * All link inspections are strictly structural (lexical parsing, RFC hostname analysis, Punycode detection).

3. **Client-Side History Privacy**:
   * Scans are saved in the client's local SQLite database.
   * Inputs are truncated to 60-character previews to safeguard sensitive personal context.
   * Users can individually delete records or purge the entire local history at any time.

4. **Threat Intelligence Safeguards**:
   * External threat intelligence feeds (such as Google Safe Browsing) require explicit server environment variable activation (`SAFE_BROWSING_API_KEY`).
   * If not configured, the app gracefully returns `"Threat intelligence unavailable"` without leaking unverified assumptions.
