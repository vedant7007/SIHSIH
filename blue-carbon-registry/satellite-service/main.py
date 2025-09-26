from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import logging
from typing import Dict, Any, Optional
import json
from datetime import datetime, timedelta
import random

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Blue Carbon Satellite Service",
    description="Satellite data processing service using Google Earth Engine",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "Blue Carbon Satellite Service",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "satellite-data"}

@app.post("/analyze-ndvi")
async def analyze_ndvi(
    project_id: str,
    latitude: float,
    longitude: float,
    start_date: str,
    end_date: str
):
    """
    Analyze NDVI data for a project location

    In production, this would use Google Earth Engine API
    For demo, returns mock data with realistic values
    """
    try:
        logger.info(f"Processing NDVI analysis for project {project_id}")

        # Mock NDVI analysis with realistic data
        # Real implementation would use Google Earth Engine

        # Generate mock time series data
        start = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
        end = datetime.fromisoformat(end_date.replace('Z', '+00:00'))

        time_series = []
        current_date = start
        base_ndvi = 0.6  # Typical for healthy mangroves

        while current_date <= end:
            # Add some realistic variation
            ndvi_value = base_ndvi + random.uniform(-0.15, 0.15)
            ndvi_value = max(0.0, min(1.0, ndvi_value))  # Clamp between 0 and 1

            time_series.append({
                "date": current_date.isoformat(),
                "ndvi": round(ndvi_value, 3),
                "ndwi": round(random.uniform(0.3, 0.8), 3),  # Water index
                "cloud_coverage": round(random.uniform(0, 30), 1)
            })

            current_date += timedelta(days=16)  # Landsat revisit cycle

        # Calculate trends
        if len(time_series) >= 2:
            trend = "improving" if time_series[-1]["ndvi"] > time_series[0]["ndvi"] else "declining"
            if abs(time_series[-1]["ndvi"] - time_series[0]["ndvi"]) < 0.05:
                trend = "stable"
        else:
            trend = "insufficient_data"

        # Generate statistics
        ndvi_values = [point["ndvi"] for point in time_series]
        statistics = {
            "mean_ndvi": round(sum(ndvi_values) / len(ndvi_values), 3),
            "max_ndvi": round(max(ndvi_values), 3),
            "min_ndvi": round(min(ndvi_values), 3),
            "trend": trend,
            "data_points": len(time_series)
        }

        # Mock thumbnail URL (in production, would generate actual imagery)
        thumbnail_url = f"https://earthengine.googleapis.com/mock/thumbnail_{project_id}.png"

        result = {
            "project_id": project_id,
            "location": {
                "latitude": latitude,
                "longitude": longitude
            },
            "analysis_period": {
                "start_date": start_date,
                "end_date": end_date
            },
            "time_series": time_series,
            "statistics": statistics,
            "thumbnail_url": thumbnail_url,
            "processed_at": datetime.now().isoformat(),
            "confidence": random.uniform(0.8, 0.95)  # Mock confidence score
        }

        return result

    except Exception as e:
        logger.error(f"Error analyzing NDVI for project {project_id}: {e}")
        raise HTTPException(status_code=500, detail="NDVI analysis failed")

@app.post("/detect-vegetation-change")
async def detect_vegetation_change(
    project_id: str,
    latitude: float,
    longitude: float,
    baseline_date: str,
    analysis_date: str
):
    """
    Detect vegetation changes between two time periods
    """
    try:
        logger.info(f"Detecting vegetation change for project {project_id}")

        # Mock vegetation change detection
        # In production, would use actual satellite imagery comparison

        baseline_ndvi = random.uniform(0.3, 0.5)  # Before plantation
        current_ndvi = random.uniform(0.6, 0.8)   # After plantation

        change = current_ndvi - baseline_ndvi
        change_percent = (change / baseline_ndvi) * 100

        # Determine change classification
        if change > 0.2:
            classification = "significant_improvement"
        elif change > 0.1:
            classification = "moderate_improvement"
        elif change > -0.1:
            classification = "stable"
        else:
            classification = "decline"

        result = {
            "project_id": project_id,
            "baseline": {
                "date": baseline_date,
                "ndvi": round(baseline_ndvi, 3)
            },
            "current": {
                "date": analysis_date,
                "ndvi": round(current_ndvi, 3)
            },
            "change": {
                "absolute": round(change, 3),
                "percentage": round(change_percent, 1),
                "classification": classification
            },
            "processed_at": datetime.now().isoformat()
        }

        return result

    except Exception as e:
        logger.error(f"Error detecting vegetation change for project {project_id}: {e}")
        raise HTTPException(status_code=500, detail="Vegetation change detection failed")

@app.get("/service-info")
async def get_service_info():
    """Get information about the satellite service"""
    return {
        "service": "Blue Carbon Satellite Service",
        "capabilities": [
            "NDVI time series analysis",
            "Vegetation change detection",
            "Water index calculation",
            "Cloud coverage analysis"
        ],
        "data_sources": [
            "Landsat 8/9",
            "Sentinel-2",
            "MODIS (for large areas)"
        ],
        "temporal_resolution": "16 days (Landsat)",
        "spatial_resolution": "30m (Landsat), 10m (Sentinel-2)",
        "status": "operational"
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8001,
        reload=True,
        log_level="info"
    )