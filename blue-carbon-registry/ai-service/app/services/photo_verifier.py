import cv2
import numpy as np
import imagehash
from PIL import Image, ExifTags
import io
import logging
import time
from datetime import datetime
from typing import List, Optional, Tuple, Dict, Any
from fastapi import UploadFile

from ..models.verification import VerificationResponse, PhotoAnalysis, SinglePhotoResponse, ModelInfo
from .integrity_checker import IntegrityChecker
from .content_classifier import ContentClassifier

logger = logging.getLogger(__name__)

class PhotoVerifier:
    def __init__(self):
        self.integrity_checker = IntegrityChecker()
        self.content_classifier = ContentClassifier()
        self.is_initialized = False

    async def initialize(self):
        """Initialize AI models and verification components"""
        try:
            logger.info("Initializing photo verification components...")

            await self.integrity_checker.initialize()
            await self.content_classifier.initialize()

            self.is_initialized = True
            logger.info("Photo verifier initialized successfully")

        except Exception as e:
            logger.error(f"Failed to initialize photo verifier: {e}")
            raise

    async def verify_project_photos(
        self,
        project_id: str,
        photos: List[UploadFile],
        location: Optional[Tuple[float, float]] = None,
        submission_date: Optional[str] = None
    ) -> VerificationResponse:
        """Verify all photos for a project submission"""

        if not self.is_initialized:
            raise RuntimeError("PhotoVerifier not initialized")

        start_time = time.time()
        photo_analyses = []
        all_issues = []

        authenticity_scores = []
        mangrove_scores = []
        context_scores = []

        for photo in photos:
            try:
                # Read photo data
                photo_data = await photo.read()
                await photo.seek(0)  # Reset file pointer

                # Analyze individual photo
                analysis = await self._analyze_photo(
                    photo_data,
                    photo.filename or "unknown",
                    photo.size or len(photo_data)
                )

                photo_analyses.append(analysis)
                all_issues.extend(analysis.issues)

                authenticity_scores.append(analysis.integrity_score)
                mangrove_scores.append(analysis.content_score)

                # Context score based on EXIF and other factors
                context_score = self._calculate_context_score(
                    analysis, location, submission_date
                )
                context_scores.append(context_score)

            except Exception as e:
                logger.error(f"Error analyzing photo {photo.filename}: {e}")
                all_issues.append(f"Failed to analyze {photo.filename}: {str(e)}")

        # Calculate overall scores
        overall_authenticity = np.mean(authenticity_scores) if authenticity_scores else 0.0
        overall_mangrove = np.mean(mangrove_scores) if mangrove_scores else 0.0
        overall_context = np.mean(context_scores) if context_scores else 0.0

        # Calculate confidence based on consistency and scores
        confidence = self._calculate_confidence(
            authenticity_scores, mangrove_scores, context_scores
        )

        processing_time = time.time() - start_time

        return VerificationResponse(
            project_id=project_id,
            authenticity=overall_authenticity,
            mangrove_likelihood=overall_mangrove,
            context_fit=overall_context,
            confidence=confidence,
            issues=list(set(all_issues)),  # Remove duplicates
            photo_analyses=photo_analyses,
            processing_time=processing_time,
            processed_at=datetime.now()
        )

    async def _analyze_photo(
        self,
        photo_data: bytes,
        filename: str,
        file_size: int
    ) -> PhotoAnalysis:
        """Analyze a single photo for integrity and content"""

        issues = []

        # Integrity checks
        integrity_result = await self.integrity_checker.check_integrity(photo_data, filename)
        integrity_score = integrity_result.get('score', 0.0)
        issues.extend(integrity_result.get('issues', []))

        # Content classification
        content_result = await self.content_classifier.classify_image(photo_data)
        content_score = content_result.get('mangrove_probability', 0.0)

        # EXIF analysis
        exif_data = self._extract_exif_data(photo_data)
        has_exif = bool(exif_data)
        has_gps = 'GPS' in exif_data if exif_data else False
        timestamp = exif_data.get('DateTime') if exif_data else None

        if not has_exif:
            issues.append(f"No EXIF metadata found in {filename}")

        if not has_gps:
            issues.append(f"No GPS data found in {filename}")

        return PhotoAnalysis(
            filename=filename,
            file_size=file_size,
            integrity_score=integrity_score,
            content_score=content_score,
            has_exif=has_exif,
            has_gps=has_gps,
            timestamp=timestamp,
            issues=issues
        )

    def _extract_exif_data(self, photo_data: bytes) -> Dict[str, Any]:
        """Extract EXIF metadata from photo"""
        try:
            image = Image.open(io.BytesIO(photo_data))
            exif_dict = {}

            if hasattr(image, '_getexif') and image._getexif():
                exif = image._getexif()
                for tag_id, value in exif.items():
                    tag = ExifTags.TAGS.get(tag_id, tag_id)
                    exif_dict[tag] = value

            return exif_dict

        except Exception as e:
            logger.error(f"Error extracting EXIF data: {e}")
            return {}

    def _calculate_context_score(
        self,
        analysis: PhotoAnalysis,
        location: Optional[Tuple[float, float]],
        submission_date: Optional[str]
    ) -> float:
        """Calculate context appropriateness score"""

        score = 1.0

        # Penalize missing EXIF data
        if not analysis.has_exif:
            score -= 0.3

        # Penalize missing GPS data
        if not analysis.has_gps:
            score -= 0.2

        # Check timestamp plausibility
        if analysis.timestamp:
            try:
                if submission_date:
                    # Add timestamp validation logic here
                    pass
            except Exception:
                score -= 0.1

        return max(0.0, score)

    def _calculate_confidence(
        self,
        authenticity_scores: List[float],
        mangrove_scores: List[float],
        context_scores: List[float]
    ) -> int:
        """Calculate overall confidence percentage"""

        if not authenticity_scores:
            return 0

        # Base confidence from average scores
        avg_auth = np.mean(authenticity_scores)
        avg_mangrove = np.mean(mangrove_scores)
        avg_context = np.mean(context_scores)

        base_confidence = (avg_auth * 0.4 + avg_mangrove * 0.4 + avg_context * 0.2) * 100

        # Reduce confidence based on score variance (inconsistency penalty)
        auth_variance = np.var(authenticity_scores)
        mangrove_variance = np.var(mangrove_scores)

        variance_penalty = (auth_variance + mangrove_variance) * 50
        final_confidence = max(0, min(100, base_confidence - variance_penalty))

        return int(final_confidence)

    async def analyze_single_photo(
        self,
        photo: UploadFile,
        check_integrity: bool = True,
        check_content: bool = True
    ) -> SinglePhotoResponse:
        """Analyze a single photo for testing purposes"""

        start_time = time.time()

        photo_data = await photo.read()
        filename = photo.filename or "unknown"

        integrity_result = {}
        content_result = {}

        if check_integrity:
            integrity_result = await self.integrity_checker.check_integrity(
                photo_data, filename
            )

        if check_content:
            content_result = await self.content_classifier.classify_image(photo_data)

        # Calculate overall score
        integrity_score = integrity_result.get('score', 1.0) if check_integrity else 1.0
        content_score = content_result.get('mangrove_probability', 0.5) if check_content else 0.5
        overall_score = (integrity_score + content_score) / 2

        processing_time = time.time() - start_time

        return SinglePhotoResponse(
            filename=filename,
            integrity_check=integrity_result,
            content_check=content_result,
            overall_score=overall_score,
            processing_time=processing_time
        )

    async def get_model_info(self) -> ModelInfo:
        """Get information about loaded models"""

        return ModelInfo(
            classifier_model="MobileNetV3-Mangrove-Classifier",
            integrity_checks=["EXIF Analysis", "Error Level Analysis", "Hash Comparison"],
            content_checks=["Mangrove Classification", "Vegetation Detection"],
            last_updated=datetime.now(),
            status="active" if self.is_initialized else "not_initialized"
        )