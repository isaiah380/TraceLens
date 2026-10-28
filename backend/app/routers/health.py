from fastapi import APIRouter
from app.schemas.analysis import HealthResponse
from app.config import settings
from app.services.message_model import get_message_model_status
from ml.url_model import get_url_ml_status

router = APIRouter(tags=["Health"])

@router.get("/health", response_model=HealthResponse)
def get_health():
    return HealthResponse(
        status="ok",
        message_model_status=get_message_model_status(),
        model_name=settings.model_name,
        rule_based_fallback_available=True,
        url_ml_status=get_url_ml_status()
    )
