"""
Pretrained Transformer Model Evaluation Script (Level 2)
Evaluates Horizon-Labs/phishing-scam-detector-base on test examples.
"""
import sys
import os

# Sample balanced test dataset of illustrative phishing/fraud, spam, and legitimate messages
TEST_EXAMPLES = [
    {
        "text": "Your debit card has been locked due to suspicious activity. Visit http://security-update-bank.com to restore access.",
        "true_label": "fraud"
    },
    {
        "text": "URGENT: Income Tax Refund of $450 is waiting. Click here to confirm your banking details immediately.",
        "true_label": "fraud"
    },
    {
        "text": "Win big! Claim your 500 free spins today at premier casino. Tap link to start playing now.",
        "true_label": "spam"
    },
    {
        "text": "Get 50% discount on summer shoes! Limited period promotional offer. Visit shop.example.com",
        "true_label": "spam"
    },
    {
        "text": "Hey Mom, I will be home around 6 PM for dinner. See you soon!",
        "true_label": "legitimate"
    },
    {
        "text": "Your meeting with the project team has been scheduled for tomorrow at 10:00 AM in Conference Room B.",
        "true_label": "legitimate"
    }
]

def run_evaluation():
    print("=" * 60)
    print("TRACELENS PRETRAINED MESSAGE CLASSIFIER EVALUATION")
    print("Model: Horizon-Labs/phishing-scam-detector-base")
    print("=" * 60)
    
    try:
        import torch
        from transformers import AutoTokenizer, AutoModelForSequenceClassification
        print("[*] Loading Hugging Face model and tokenizer...")
        tokenizer = AutoTokenizer.from_pretrained("Horizon-Labs/phishing-scam-detector-base")
        model = AutoModelForSequenceClassification.from_pretrained("Horizon-Labs/phishing-scam-detector-base")
        model.eval()
        print("[+] Model loaded successfully.")
    except Exception as e:
        print(f"[!] Pretrained model evaluation skipped (torch/transformers not available in active environment: {e})")
        print("[+] Heuristic rule fallback evaluation running instead:")
        sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
        from app.services.message_rules import analyze_message_rules
        
        correct = 0
        for item in TEST_EXAMPLES:
            _, score, cat = analyze_message_rules(item["text"])
            print(f"- Text: '{item['text'][:45]}...' -> Predicted: {cat} | True: {item['true_label']}")
            if cat == item["true_label"]:
                correct += 1
        print(f"\nRule Fallback Accuracy on illustrative sample: {correct}/{len(TEST_EXAMPLES)} ({correct/len(TEST_EXAMPLES)*100:.1f}%)")
        return

    # If torch is available:
    correct = 0
    id2label = model.config.id2label
    for item in TEST_EXAMPLES:
        inputs = tokenizer(item["text"], return_tensors="pt", truncation=True)
        with torch.no_grad():
            logits = model(**inputs).logits
            pred_id = int(torch.argmax(logits, dim=-1))
            pred_label = id2label[pred_id].lower()
            if "fraud" in pred_label or "phish" in pred_label:
                pred_label = "fraud"
            elif "spam" in pred_label:
                pred_label = "spam"
            else:
                pred_label = "legitimate"
        
        print(f"- Text: '{item['text'][:45]}...' -> Predicted: {pred_label} | True: {item['true_label']}")
        if pred_label == item["true_label"]:
            correct += 1
            
    print(f"\nModel Accuracy on sample: {correct}/{len(TEST_EXAMPLES)} ({correct/len(TEST_EXAMPLES)*100:.1f}%)")

if __name__ == "__main__":
    run_evaluation()
