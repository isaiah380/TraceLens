# TraceLens URL Dataset Guidelines

## Expected CSV Schema
The training and evaluation scripts (`train_url_model.py` and `evaluate_url_model.py`) expect a CSV file with the following column headers:

* `url` (string): The complete URL (e.g. `https://example.com/login` or `http://192.168.1.1/admin`)
* `label` (integer):
  * `0`: Benign / Legitimate URL
  * `1`: Phishing / Malicious URL

## Example CSV Format:
```csv
url,label
https://www.google.com,0
https://github.com/flutter/flutter,0
https://wikipedia.org/wiki/Phishing,0
http://192.168.0.10/verify-bank-account,1
http://login.paypal.account-verify.xyz/update,1
http://bit.ly/secure-banking-login,1
```

## Public Benchmark Sources
You can use standard public academic benchmarks such as:
1. **PhishTank** (https://phishtank.org/)
2. **ISCXURL2016** (UNB Dataset)
3. **Mendeley Phishing URL Dataset**

## How to Train:
```bash
python ml/train_url_model.py --dataset path/to/dataset.csv
```
The trained model will be exported as `ml/url_random_forest.joblib` and automatically picked up by the TraceLens FastAPI backend.
