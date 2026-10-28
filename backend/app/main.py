import logging
import threading
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routers import health, message, url
from app.services.message_model import init_message_model

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("tracelens.main")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: trigger pretrained model loading in a background worker thread
    logger.info("TraceLens FastAPI starting up...")
    loader_thread = threading.Thread(target=init_message_model, daemon=True)
    loader_thread.start()
    yield
    # Shutdown
    logger.info("TraceLens FastAPI shutting down...")

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="AI-Powered Scam, Phishing Message and Malicious URL Detection Backend API",
    lifespan=lifespan
)

# Enable CORS for Flutter mobile emulator and physical devices
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount endpoints
app.include_router(health.router)
app.include_router(message.router)
app.include_router(url.router)

@app.get("/")
def root():
    return {
        "app": "TraceLens",
        "description": "AI-Powered Scam, Phishing and Malicious URL Detection",
        "docs": "/docs"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host=settings.host, port=settings.port, reload=settings.debug)
