# TraceLens Machine Learning Documentation & Evaluation

## Pretrained Message Classifier

* **Model Identifier**: `Horizon-Labs/phishing-scam-detector-base`
* **Hugging Face Model Page**: [Horizon-Labs/phishing-scam-detector-base](https://huggingface.co/Horizon-Labs/phishing-scam-detector-base)
* **Architecture**: Transformer Sequence Classification
* **Output Labels**:
  * `fraud`: Phishing, credential harvesting, malware delivery, banking extortion.
  * `spam`: Unsolicited advertisements, casino lures, sweepstakes.
  * `legitimate`: Normal personal and benign business communication.
* **Execution**: Runs on CPU via PyTorch in `eval()` mode with `torch.no_grad()` to conserve memory.

### Reliability & Resilient Fallback
If the model weights cannot be downloaded (such as during offline scenarios or restricted network environments), TraceLens gracefully falls back to its transparent rule-based heuristic security engine without crashing. The API response explicitly tags `model_used: "rule_based"` or `model_used: "pretrained_transformer"` for complete transparency.

---

## URL Machine Learning Classifier (Level 3)

TraceLens includes an optional `RandomForestClassifier` trained on 14 extracted structural lexical features:
1. `url_length`: Overall character count.
2. `hostname_length`: Host component length.
3. `num_dots`: Number of dot separators.
4. `num_hyphens`: Number of hyphen characters.
5. `num_digits`: Digit count in URL.
6. `num_subdomains`: Subdomain nesting level.
7. `has_ip_hostname`: Binary flag for raw IPv4 hosts.
8. `has_at_symbol`: Binary flag for `@` symbol in authority.
9. `is_https`: Scheme check.
10. `is_shortener`: Known URL shortener match (bit.ly, tinyurl.com, etc.).
11. `num_path_segments`: Depth of path directories.
12. `query_length`: Length of query string.
13. `has_punycode`: Internationalized domain spoofing indicator (`xn--`).
14. `has_sensitive_keywords`: Presence of security terms (`login`, `verify`, `bank`).

### Training the URL Model:
```bash
python ml/train_url_model.py --dataset path/to/dataset.csv
```
The trained model is exported via Joblib to `ml/url_random_forest.joblib` and automatically utilized by the FastAPI server when available.
