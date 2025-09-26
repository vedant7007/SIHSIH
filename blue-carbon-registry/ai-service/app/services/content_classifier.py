import cv2
import numpy as np
from PIL import Image
import io
import logging
from typing import Dict, Any
import tensorflow as tf

logger = logging.getLogger(__name__)

class ContentClassifier:
    """Image content classifier for mangrove detection"""

    def __init__(self):
        self.model = None
        self.is_initialized = False
        self.input_size = (224, 224)

    async def initialize(self):
        """Initialize the classification model"""
        logger.info("Initializing content classifier...")

        try:
            # For demo purposes, we'll create a mock model
            # In production, load a pre-trained MobileNetV3 model
            self.model = self._create_mock_model()
            self.is_initialized = True
            logger.info("Content classifier initialized with mock model")

        except Exception as e:
            logger.error(f"Failed to initialize content classifier: {e}")
            raise

    def _create_mock_model(self):
        """Create a mock model for demonstration purposes"""
        # This would be replaced with a real trained model in production
        model = tf.keras.Sequential([
            tf.keras.layers.Input(shape=(*self.input_size, 3)),
            tf.keras.layers.Conv2D(32, 3, activation='relu'),
            tf.keras.layers.GlobalAveragePooling2D(),
            tf.keras.layers.Dense(128, activation='relu'),
            tf.keras.layers.Dense(1, activation='sigmoid')  # Binary classification
        ])
        model.compile(optimizer='adam', loss='binary_crossentropy')
        return model

    async def classify_image(self, photo_data: bytes) -> Dict[str, Any]:
        """
        Classify image content for mangrove detection

        Returns:
            Dict with mangrove_probability and additional analysis
        """
        if not self.is_initialized:
            raise RuntimeError("ContentClassifier not initialized")

        try:
            # Load and preprocess image
            image = Image.open(io.BytesIO(photo_data))
            processed_image = self._preprocess_image(image)

            # For demo, use rule-based classification combined with simple features
            mangrove_probability = self._classify_with_features(processed_image)

            # Additional vegetation analysis
            vegetation_analysis = self._analyze_vegetation(processed_image)

            return {
                'mangrove_probability': float(mangrove_probability),
                'vegetation_detected': vegetation_analysis['has_vegetation'],
                'green_coverage': vegetation_analysis['green_percentage'],
                'water_detected': vegetation_analysis['has_water'],
                'confidence': min(0.95, mangrove_probability + 0.1)  # Demo confidence
            }

        except Exception as e:
            logger.error(f"Error classifying image: {e}")
            return {
                'mangrove_probability': 0.5,
                'vegetation_detected': False,
                'green_coverage': 0.0,
                'water_detected': False,
                'confidence': 0.1,
                'error': str(e)
            }

    def _preprocess_image(self, image: Image.Image) -> np.ndarray:
        """Preprocess image for classification"""
        # Convert to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')

        # Resize to model input size
        image = image.resize(self.input_size)

        # Convert to numpy array and normalize
        img_array = np.array(image, dtype=np.float32) / 255.0

        return img_array

    def _classify_with_features(self, image: np.ndarray) -> float:
        """
        Classify using hand-crafted features (demo implementation)

        In production, this would use a trained deep learning model
        """
        # Convert to HSV for better color analysis
        hsv_image = cv2.cvtColor((image * 255).astype(np.uint8), cv2.COLOR_RGB2HSV)

        # Feature 1: Green vegetation detection
        green_score = self._detect_green_vegetation(hsv_image)

        # Feature 2: Water/mud detection
        water_score = self._detect_water_areas(hsv_image)

        # Feature 3: Texture analysis
        texture_score = self._analyze_texture(image)

        # Feature 4: Edge density (mangroves have complex edge patterns)
        edge_score = self._calculate_edge_density(image)

        # Combine features with weights
        mangrove_score = (
            green_score * 0.35 +
            water_score * 0.25 +
            texture_score * 0.25 +
            edge_score * 0.15
        )

        return min(1.0, max(0.0, mangrove_score))

    def _detect_green_vegetation(self, hsv_image: np.ndarray) -> float:
        """Detect green vegetation in the image"""
        # Define HSV range for green vegetation
        lower_green = np.array([35, 40, 40])
        upper_green = np.array([85, 255, 255])

        # Create mask for green areas
        green_mask = cv2.inRange(hsv_image, lower_green, upper_green)
        green_percentage = np.sum(green_mask > 0) / green_mask.size

        # Score based on green coverage
        if green_percentage > 0.3:
            return min(1.0, green_percentage * 2)
        else:
            return green_percentage * 0.5

    def _detect_water_areas(self, hsv_image: np.ndarray) -> float:
        """Detect water/mud areas typical in mangrove environments"""
        # Define HSV ranges for water and mud
        lower_water = np.array([100, 50, 20])
        upper_water = np.array([130, 255, 200])

        lower_mud = np.array([10, 50, 20])
        upper_mud = np.array([25, 200, 100])

        water_mask = cv2.inRange(hsv_image, lower_water, upper_water)
        mud_mask = cv2.inRange(hsv_image, lower_mud, upper_mud)

        water_percentage = np.sum(water_mask > 0) / water_mask.size
        mud_percentage = np.sum(mud_mask > 0) / mud_mask.size

        total_aquatic = water_percentage + mud_percentage

        # Mangroves typically have some water/mud visible
        if 0.1 < total_aquatic < 0.6:
            return 0.8
        elif total_aquatic > 0.05:
            return 0.5
        else:
            return 0.2

    def _analyze_texture(self, image: np.ndarray) -> float:
        """Analyze texture patterns typical of mangrove environments"""
        gray = cv2.cvtColor((image * 255).astype(np.uint8), cv2.COLOR_RGB2GRAY)

        # Calculate texture features using Local Binary Patterns (simplified)
        # This is a basic implementation
        rows, cols = gray.shape

        # Calculate local variance as a texture measure
        kernel = np.ones((5, 5), np.float32) / 25
        mean_filtered = cv2.filter2D(gray.astype(np.float32), -1, kernel)
        sqr_mean = cv2.filter2D((gray.astype(np.float32))**2, -1, kernel)
        texture_variance = sqr_mean - mean_filtered**2

        avg_variance = np.mean(texture_variance)

        # Mangroves typically have medium to high texture complexity
        if 200 < avg_variance < 2000:
            return 0.8
        elif avg_variance > 100:
            return 0.6
        else:
            return 0.3

    def _calculate_edge_density(self, image: np.ndarray) -> float:
        """Calculate edge density in the image"""
        gray = cv2.cvtColor((image * 255).astype(np.uint8), cv2.COLOR_RGB2GRAY)

        # Apply Canny edge detection
        edges = cv2.Canny(gray, 50, 150)
        edge_density = np.sum(edges > 0) / edges.size

        # Mangroves have complex branching patterns
        if 0.05 < edge_density < 0.25:
            return 0.9
        elif edge_density > 0.02:
            return 0.6
        else:
            return 0.2

    def _analyze_vegetation(self, image: np.ndarray) -> Dict[str, Any]:
        """Perform additional vegetation analysis"""
        hsv_image = cv2.cvtColor((image * 255).astype(np.uint8), cv2.COLOR_RGB2HSV)

        # Detect overall vegetation
        lower_vegetation = np.array([25, 30, 30])
        upper_vegetation = np.array([95, 255, 255])

        vegetation_mask = cv2.inRange(hsv_image, lower_vegetation, upper_vegetation)
        vegetation_percentage = np.sum(vegetation_mask > 0) / vegetation_mask.size

        # Detect water
        lower_water = np.array([100, 50, 20])
        upper_water = np.array([130, 255, 255])
        water_mask = cv2.inRange(hsv_image, lower_water, upper_water)
        water_detected = np.sum(water_mask > 0) / water_mask.size > 0.05

        return {
            'has_vegetation': vegetation_percentage > 0.2,
            'green_percentage': float(vegetation_percentage),
            'has_water': water_detected
        }