from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from typing import List, Optional
import uvicorn
import asyncio
import logging

from .core.config import settings
from .services.photo_verifier import PhotoVerifier
from .models.verification import VerificationResponse

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Blue Carbon AI Verification Service",
    description="AI-powered photo verification for blue carbon projects",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

photo_verifier = PhotoVerifier()

@app.on_event("startup")
async def startup_event():
    """Initialize AI models and services on startup"""
    logger.info("Starting Blue Carbon AI Verification Service...")
    await photo_verifier.initialize()
    logger.info("AI models loaded successfully")

@app.get("/")
async def root():
    return {
        "message": "Blue Carbon AI Verification Service",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "ai-verification"}

@app.post("/verify-photos", response_model=VerificationResponse)
async def verify_photos(
    project_id: str = Form(...),
    photos: List[UploadFile] = File(...),
    location_lat: Optional[float] = Form(None),
    location_lng: Optional[float] = Form(None),
    submission_date: Optional[str] = Form(None)
):
    """
    Verify uploaded photos for a blue carbon project

    This endpoint performs:
    1. Integrity checks (EXIF, tampering detection)
    2. Content classification (mangrove vs other vegetation)
    3. Context validation (GPS, timestamp plausibility)
    """
    try:
        if not photos:
            raise HTTPException(status_code=400, detail="No photos provided")

        if len(photos) > 10:
            raise HTTPException(status_code=400, detail="Too many photos (max 10)")

        # Verify photos using AI service
        result = await photo_verifier.verify_project_photos(
            project_id=project_id,
            photos=photos,
            location=(location_lat, location_lng) if location_lat and location_lng else None,
            submission_date=submission_date
        )

        return result

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error verifying photos for project {project_id}: {e}")
        raise HTTPException(status_code=500, detail="Internal verification error")

@app.post("/analyze-single-photo")
async def analyze_single_photo(
    photo: UploadFile = File(...),
    check_integrity: bool = Form(True),
    check_content: bool = Form(True)
):
    """Analyze a single photo for development/testing purposes"""
    try:
        result = await photo_verifier.analyze_single_photo(
            photo=photo,
            check_integrity=check_integrity,
            check_content=check_content
        )
        return result

    except Exception as e:
        logger.error(f"Error analyzing single photo: {e}")
        raise HTTPException(status_code=500, detail="Analysis error")

@app.get("/model-info")
async def get_model_info():
    """Get information about loaded AI models"""
    return await photo_verifier.get_model_info()

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )