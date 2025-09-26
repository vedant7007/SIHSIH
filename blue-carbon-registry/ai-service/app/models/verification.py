from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

class PhotoAnalysis(BaseModel):
    filename: str
    file_size: int
    integrity_score: float = Field(..., ge=0, le=1, description="Photo integrity score (0-1)")
    content_score: float = Field(..., ge=0, le=1, description="Mangrove likelihood score (0-1)")
    has_exif: bool
    has_gps: bool
    timestamp: Optional[datetime] = None
    issues: List[str] = []

class VerificationResponse(BaseModel):
    project_id: str
    authenticity: float = Field(..., ge=0, le=1, description="Overall authenticity score")
    mangrove_likelihood: float = Field(..., ge=0, le=1, description="Mangrove classification confidence")
    context_fit: float = Field(..., ge=0, le=1, description="Context appropriateness score")
    confidence: int = Field(..., ge=0, le=100, description="Overall confidence percentage")
    issues: List[str] = []
    photo_analyses: List[PhotoAnalysis] = []
    processing_time: float
    processed_at: datetime

class SinglePhotoResponse(BaseModel):
    filename: str
    integrity_check: Dict[str, Any]
    content_check: Dict[str, Any]
    overall_score: float
    processing_time: float

class ModelInfo(BaseModel):
    classifier_model: str
    integrity_checks: List[str]
    content_checks: List[str]
    last_updated: datetime
    status: str