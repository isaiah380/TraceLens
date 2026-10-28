from fastapi import APIRouter, HTTPException
from app.schemas.analysis import MessageAnalysisRequest, MessageAnalysisResponse
from app.services.message_rules import analyze_message_rules, extract_urls_from_text
from app.services.message_model import predict_message_ml
from app.services.risk_assessment import combine_message_evidence

router = APIRouter(prefix="/analyze", tags=["Message Analysis"])

@router.post("/message", response_model=MessageAnalysisResponse)
def analyze_message(req: MessageAnalysisRequest):
    text = req.message.strip()
    if not text:
        raise HTTPException(status_code=400, detail="Message text cannot be empty.")
    
    # 1. Extract URLs present in message
    urls = extract_urls_from_text(text)
    
    # 2. Run rule-based analysis
    rule_signals, rule_score, rule_category = analyze_message_rules(text)
    
    # 3. Run pretrained Hugging Face ML inference if loaded
    ml_result = predict_message_ml(text)
    
    # 4. Synthesize final explainable response
    response = combine_message_evidence(
        text=text,
        rule_signals=rule_signals,
        rule_score=rule_score,
        rule_category=rule_category,
        urls_found=urls,
        ml_result=ml_result
    )
    
    return response
