from pydantic import BaseSettings
from typing import List

class Settings(BaseSettings):
    # API Configuration
    api_title: str = "Blue Carbon AI Verification Service"
    api_version: str = "1.0.0"
    debug: bool = True

    # CORS Configuration
    cors_origins: List[str] = ["*"]  # Configure for production

    # Model Configuration
    model_path: str = "models/"
    max_image_size: int = 10 * 1024 * 1024  # 10MB
    supported_formats: List[str] = ["JPEG", "PNG", "WEBP"]

    # Processing Configuration
    max_concurrent_requests: int = 10
    processing_timeout: int = 30  # seconds

    # Backend Integration
    backend_url: str = "http://localhost:3000"
    backend_api_key: str = "demo-key"

    # Logging
    log_level: str = "INFO"
    log_format: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

    class Config:
        env_file = ".env"
        env_prefix = "AI_"

settings = Settings()