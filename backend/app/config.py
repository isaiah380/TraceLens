import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "TraceLens Backend API"
    app_version: str = "1.0.0"
    debug: bool = True
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Pretrained Hugging Face Model
    model_name: str = "Horizon-Labs/phishing-scam-detector-base"
    use_local_fallback_on_error: bool = True
    
    # Optional Threat Intelligence
    safe_browsing_api_key: str = ""
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
