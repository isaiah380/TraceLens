from typing import List, Optional, Dict, Any, Tuple
from app.schemas.analysis import SignalItem, MessageAnalysisResponse

def combine_message_evidence(
    text: str,
    rule_signals: List[SignalItem],
    rule_score: int,
    rule_category: str,
    urls_found: List[str],
    ml_result: Optional[Dict[str, Any]]
) -> MessageAnalysisResponse:
    """
    Combines pretrained ML predictions, rule-based findings, and URL presence
    into an explainable, calibrated risk assessment without double-counting.
    """
    final_signals: List[SignalItem] = list(rule_signals)
    recommendations: List[str] = []

    if ml_result and "scores" in ml_result:
        model_used = "pretrained_transformer"
        scores = ml_result["scores"]
        ml_class = ml_result["classification"]
        fraud_prob = scores.get("fraud", 0.0)
        spam_prob = scores.get("spam", 0.0)
        legit_prob = scores.get("legitimate", 0.0)
        
        # Add ML signal to explainability list
        final_signals.insert(0, SignalItem(
            code="ml_model_prediction",
            description=f"Neural classifier identified message as '{ml_class}' with {round(max(fraud_prob, spam_prob, legit_prob)*100, 1)}% confidence.",
            severity="critical" if ml_class == "fraud" else ("medium" if ml_class == "spam" else "low")
        ))
        
        # Calculate combined risk score
        # Base from ML model (0-100 scale)
        if ml_class == "fraud":
            base_score = int(fraud_prob * 80) + 15
        elif ml_class == "spam":
            base_score = int(spam_prob * 50) + 10
        else:
            base_score = max(5, int((1.0 - legit_prob) * 35))

        # Adjust with rule findings if rules detect explicit credential theft
        critical_rule_present = any(s.severity == "critical" for s in rule_signals)
        high_rule_present = any(s.severity == "high" for s in rule_signals)

        if critical_rule_present and ml_class != "fraud":
            # Safety override: if model thinks it's legit but user is asked for OTP/PIN, raise warning
            final_classification = "suspicious"
            combined_score = max(base_score, 75)
            final_signals.append(SignalItem(
                code="critical_heuristic_override",
                description="Rule engine detected direct credential/OTP request despite low ML classification score.",
                severity="critical"
            ))
        else:
            final_classification = ml_class
            # Mild boost if high signals corroborate without double counting
            additive = 10 if (high_rule_present and ml_class == "fraud") else 0
            combined_score = min(98, base_score + additive)
            
    else:
        # Fallback path: Pure rule based
        model_used = "rule_based"
        final_classification = rule_category
        scores = None
        combined_score = rule_score
        final_signals.insert(0, SignalItem(
            code="fallback_analyzer_active",
            description="Analysis executed using heuristic security rules (transformer model offline).",
            severity="low"
        ))

    # Formulate risk level
    if combined_score >= 75:
        risk_level = "critical" if combined_score >= 85 else "high"
    elif combined_score >= 40:
        risk_level = "medium"
    else:
        risk_level = "low"

    # Generate actionable advice
    if final_classification in ["fraud", "suspicious"] or risk_level in ["high", "critical"]:
        recommendations.append("Do NOT provide OTPs, passwords, banking PINs, or verify personal credentials.")
        recommendations.append("Do not click any embedded links in this message.")
        recommendations.append("Contact the organization directly using their verified website or official app.")
    elif final_classification == "spam" or risk_level == "medium":
        recommendations.append("Exercise caution. Verify unexpected offers, delivery alerts, or prize notifications.")
        if urls_found:
            recommendations.append("Inspect the destination URL in our URL scanner before opening.")
    else:
        recommendations.append("No immediate fraud signals detected.")
        recommendations.append("Remain cautious as attackers frequently craft new scam variations.")

    return MessageAnalysisResponse(
        scan_type="message",
        model_used=model_used,
        classification=final_classification,
        risk_level=risk_level,
        risk_score=combined_score,
        signals=final_signals,
        urls_found=urls_found,
        model_scores=scores,
        recommendations=recommendations,
        disclaimer="Automated assessment; not a guarantee of safety. Independent human verification recommended."
    )
