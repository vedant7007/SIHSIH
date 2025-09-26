import cv2
import numpy as np
import imagehash
from PIL import Image
import io
import logging
from typing import Dict, Any, List

logger = logging.getLogger(__name__)

class IntegrityChecker:
    """Photo integrity and authenticity checker"""

    def __init__(self):
        self.is_initialized = False

    async def initialize(self):
        """Initialize integrity checking components"""
        logger.info("Initializing integrity checker...")
        self.is_initialized = True
        logger.info("Integrity checker initialized")

    async def check_integrity(self, photo_data: bytes, filename: str) -> Dict[str, Any]:
        """
        Perform comprehensive integrity checks on a photo

        Returns:
            Dict with score (0-1) and list of issues
        """
        if not self.is_initialized:
            raise RuntimeError("IntegrityChecker not initialized")

        issues = []
        checks = {}

        try:
            # Convert to PIL Image and OpenCV format
            pil_image = Image.open(io.BytesIO(photo_data))
            cv_image = cv2.imdecode(
                np.frombuffer(photo_data, np.uint8),
                cv2.IMREAD_COLOR
            )

            # 1. File format and corruption check
            format_score = self._check_file_format(pil_image, filename)
            checks['format'] = format_score
            if format_score < 1.0:
                issues.append(f"File format issues detected in {filename}")

            # 2. Error Level Analysis (simplified)
            ela_score = self._error_level_analysis(cv_image)
            checks['error_level'] = ela_score
            if ela_score < 0.7:
                issues.append(f"Potential tampering detected in {filename}")

            # 3. Perceptual hash for duplicate detection
            phash = self._calculate_perceptual_hash(pil_image)
            checks['phash'] = str(phash)

            # 4. Basic noise analysis
            noise_score = self._analyze_noise(cv_image)
            checks['noise'] = noise_score
            if noise_score < 0.5:
                issues.append(f"Unusual noise patterns in {filename}")

            # 5. Compression artifacts check
            compression_score = self._check_compression_artifacts(cv_image)
            checks['compression'] = compression_score

            # Calculate overall integrity score
            score_components = [format_score, ela_score, noise_score, compression_score]
            overall_score = np.mean(score_components)

        except Exception as e:
            logger.error(f"Error during integrity check: {e}")
            overall_score = 0.0
            issues.append(f"Failed to process {filename}: {str(e)}")
            checks['error'] = str(e)

        return {
            'score': float(overall_score),
            'issues': issues,
            'details': checks
        }

    def _check_file_format(self, image: Image.Image, filename: str) -> float:
        """Check if file format is valid and uncorrupted"""
        try:
            # Verify image can be loaded and has expected properties
            if image.format not in ['JPEG', 'PNG', 'WEBP']:
                return 0.5

            # Check if image has reasonable dimensions
            width, height = image.size
            if width < 100 or height < 100:
                return 0.6
            if width > 10000 or height > 10000:
                return 0.7

            return 1.0

        except Exception:
            return 0.0

    def _error_level_analysis(self, image: np.ndarray) -> float:
        """Simplified Error Level Analysis for tampering detection"""
        try:
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            # Apply Laplacian edge detection
            laplacian = cv2.Laplacian(gray, cv2.CV_64F)
            laplacian_var = laplacian.var()

            # Analyze histogram distribution
            hist = cv2.calcHist([gray], [0], None, [256], [0, 256])
            hist_uniformity = np.std(hist)

            # Simple scoring based on edge consistency
            # Real images typically have consistent edge characteristics
            if 50 < laplacian_var < 2000 and hist_uniformity > 10:
                return min(1.0, laplacian_var / 1000)
            else:
                return 0.6

        except Exception:
            return 0.5

    def _calculate_perceptual_hash(self, image: Image.Image) -> str:
        """Calculate perceptual hash for duplicate detection"""
        try:
            # Convert to RGB if necessary
            if image.mode != 'RGB':
                image = image.convert('RGB')

            # Calculate average hash
            avg_hash = imagehash.average_hash(image)
            return str(avg_hash)

        except Exception:
            return "error"

    def _analyze_noise(self, image: np.ndarray) -> float:
        """Analyze noise characteristics in the image"""
        try:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            # Apply Gaussian blur and subtract from original
            blurred = cv2.GaussianBlur(gray, (5, 5), 0)
            noise = cv2.absdiff(gray, blurred)

            # Calculate noise statistics
            noise_mean = np.mean(noise)
            noise_std = np.std(noise)

            # Natural images have certain noise characteristics
            # This is a simplified check
            if 2 < noise_mean < 15 and 5 < noise_std < 25:
                return 1.0
            else:
                return max(0.3, 1.0 - abs(noise_mean - 8) / 20)

        except Exception:
            return 0.5

    def _check_compression_artifacts(self, image: np.ndarray) -> float:
        """Check for unusual compression artifacts"""
        try:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            # Apply DCT to detect JPEG compression patterns
            # This is a simplified version
            height, width = gray.shape
            blocks_checked = 0
            artifact_score = 0

            # Check 8x8 blocks for JPEG artifacts
            for i in range(0, height - 8, 8):
                for j in range(0, width - 8, 8):
                    block = gray[i:i+8, j:j+8].astype(np.float32)

                    # Apply DCT
                    dct_block = cv2.dct(block)

                    # Check for typical JPEG quantization patterns
                    high_freq_energy = np.sum(np.abs(dct_block[4:, 4:]))
                    total_energy = np.sum(np.abs(dct_block))

                    if total_energy > 0:
                        ratio = high_freq_energy / total_energy
                        if 0.1 < ratio < 0.4:  # Typical for natural JPEG images
                            artifact_score += 1

                    blocks_checked += 1
                    if blocks_checked > 100:  # Limit computation
                        break

                if blocks_checked > 100:
                    break

            if blocks_checked > 0:
                return artifact_score / blocks_checked
            else:
                return 0.5

        except Exception:
            return 0.5