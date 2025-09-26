# Blue Carbon Registry - Deployment Guide

## SIH 25038 - Complete Setup and Deployment Instructions

This guide provides step-by-step instructions to set up and deploy the entire Blue Carbon Registry & MRV System locally and in production environments.

## 🏗️ System Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   NestJS API    │    │  FastAPI AI     │
│  (Mobile/Web)   │◄──►│   (Backend)     │◄──►│  (AI Service)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │   Redis Cache   │    │   MinIO S3      │
│   + PostGIS     │    │   + Bull Queue  │    │   (File Store)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Polygon Amoy    │    │ Google Earth    │    │   Satellite     │
│ (Blockchain)    │    │    Engine       │    │   Service       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### System Requirements
- **Node.js**: 18.x or higher
- **Flutter**: 3.16.x or higher
- **Python**: 3.11 or higher
- **Docker**: 24.x or higher
- **Git**: Latest version

### Development Tools
- **VS Code** with Flutter/Dart extensions
- **Postman** or similar API testing tool
- **MetaMask** wallet for blockchain testing

## 🚀 Quick Start (Development)

### 1. Clone the Repository

```bash
git clone https://github.com/your-repo/blue-carbon-registry.git
cd blue-carbon-registry
```

### 2. Start Infrastructure Services

```bash
# Start PostgreSQL, Redis, and MinIO
docker-compose up -d postgres redis minio
```

### 3. Backend API Setup

```bash
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials

# Generate Prisma client
npm run prisma:generate

# Run database migrations
npm run prisma:migrate

# Seed database with test data
npm run prisma:seed

# Start development server
npm run start:dev
```

The API will be available at `http://localhost:3000`

### 4. AI Service Setup

```bash
cd ai-service

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start AI service
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The AI service will be available at `http://localhost:8000`

### 5. Smart Contract Deployment

```bash
cd blockchain

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Add your private key and Polygonscan API key

# Compile contracts
npm run compile

# Run tests
npm run test

# Deploy to Polygon Amoy testnet
npm run deploy:amoy
```

### 6. Flutter Mobile App

```bash
cd mobile

# Install dependencies
flutter pub get

# Generate code (for Drift database)
flutter packages pub run build_runner build

# Run on emulator/device
flutter run
```

## 🔧 Environment Configuration

### Backend (.env)

```env
# Database
DATABASE_URL="postgresql://postgres:password@localhost:5432/blue_carbon_db"

# Redis
REDIS_URL="redis://localhost:6379"

# MinIO (S3-compatible storage)
MINIO_ENDPOINT="localhost:9000"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin"
MINIO_BUCKET="blue-carbon-files"

# JWT
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="7d"

# External Services
AI_SERVICE_URL="http://localhost:8000"
SATELLITE_SERVICE_URL="http://localhost:8001"

# Blockchain
BLOCKCHAIN_RPC_URL="https://rpc-amoy.polygon.technology/"
CONTRACT_ADDRESS="0x..." # After deployment
PRIVATE_KEY="your-private-key"

# Google Earth Engine (for satellite service)
GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
```

### AI Service (.env)

```env
AI_DEBUG=true
AI_MODEL_PATH="models/"
AI_MAX_IMAGE_SIZE=10485760
AI_BACKEND_URL="http://localhost:3000"
AI_LOG_LEVEL="INFO"
```

### Blockchain (.env)

```env
PRIVATE_KEY="your-private-key-here"
POLYGONSCAN_API_KEY="your-polygonscan-api-key"
BASE_URI="https://api.bluecarbonregistry.com/metadata/"
```

## 🌐 Production Deployment

### 1. Infrastructure Setup

#### Option A: Docker Compose (Recommended for testing)

```bash
# Build and start all services
docker-compose up -d

# Check service health
docker-compose ps

# View logs
docker-compose logs -f backend
```

#### Option B: Cloud Deployment

**Backend (Railway/Render/DigitalOcean)**

1. Set up PostgreSQL with PostGIS extension
2. Configure Redis instance
3. Set up MinIO or use AWS S3
4. Deploy backend with environment variables
5. Run database migrations

**AI Service (Google Cloud Run/AWS Lambda)**

1. Build Docker container
2. Deploy to serverless platform
3. Configure auto-scaling

**Mobile App (App Store/Play Store)**

1. Build release APK/IPA
2. Submit to app stores
3. Set up CI/CD pipeline

### 2. Database Setup

```sql
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Verify installation
SELECT PostGIS_Version();
```

### 3. Blockchain Deployment

```bash
# Deploy to Polygon Amoy testnet
npm run deploy:amoy

# Verify contract
npm run verify -- --network amoy <CONTRACT_ADDRESS>

# Update backend config with contract address
```

### 4. SSL/TLS Configuration

```nginx
# nginx.conf for backend
server {
    listen 443 ssl;
    server_name api.bluecarbonregistry.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🧪 Testing

### Backend API Testing

```bash
cd backend

# Run unit tests
npm run test

# Run e2e tests
npm run test:e2e

# Run test coverage
npm run test:cov
```

### Smart Contract Testing

```bash
cd blockchain

# Run all tests
npm run test

# Run specific test
npx hardhat test test/BlueCarbonRegistry.test.js

# Generate gas report
REPORT_GAS=true npm run test
```

### Mobile App Testing

```bash
cd mobile

# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📊 Monitoring and Logging

### Health Check Endpoints

- Backend: `GET http://localhost:3000/health`
- AI Service: `GET http://localhost:8000/health`

### Log Aggregation

```yaml
# docker-compose.yml logging configuration
logging:
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"
```

## 🔒 Security Considerations

### API Security

- JWT authentication with refresh tokens
- Rate limiting (10 requests/second per IP)
- Input validation and sanitization
- CORS configuration for production

### Blockchain Security

- Multi-signature wallet for admin functions
- Role-based access control
- Contract upgrade mechanisms
- Audit logs for all transactions

### Data Protection

- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Regular security audits
- GDPR compliance for user data

## 🚨 Troubleshooting

### Common Issues

**1. Database Connection Issues**

```bash
# Check PostgreSQL status
docker-compose ps postgres

# View logs
docker-compose logs postgres

# Reset database
docker-compose down -v
docker-compose up -d postgres
```

**2. Flutter Build Issues**

```bash
# Clean build
flutter clean
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for conflicts
flutter doctor
```

**3. Smart Contract Deployment Failures**

```bash
# Check network connection
curl -X POST https://rpc-amoy.polygon.technology/

# Verify account balance
npx hardhat run scripts/check-balance.js --network amoy

# Increase gas limit
# Edit hardhat.config.js gas settings
```

**4. AI Service Memory Issues**

```bash
# Monitor resource usage
docker stats

# Increase memory limits in docker-compose.yml
services:
  ai-service:
    deploy:
      resources:
        limits:
          memory: 2G
```

## 📈 Performance Optimization

### Backend Optimization

- Enable Redis caching for frequent queries
- Database query optimization and indexing
- API response compression
- Connection pooling

### Mobile App Optimization

- Image compression and caching
- Lazy loading of data
- Offline data synchronization
- Background task optimization

### AI Service Optimization

- Model quantization for smaller size
- GPU acceleration if available
- Batch processing for multiple images
- Result caching

## 📝 API Documentation

Once the backend is running, visit:

- Swagger UI: `http://localhost:3000/api/docs`
- ReDoc: `http://localhost:3000/api/redoc`
- API Schema: `http://localhost:3000/api/json`

## 🔄 CI/CD Pipeline

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
name: Deploy Blue Carbon Registry

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Test Backend
        run: |
          cd backend
          npm ci
          npm run test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: |
          # Deployment scripts
```

## 📞 Support

For deployment issues:

1. Check this documentation first
2. Review logs for specific error messages
3. Consult the troubleshooting section
4. Create an issue with detailed logs

## 🎯 Demo Preparation

### Quick Demo Setup (5 minutes)

```bash
# 1. Start all services
docker-compose up -d

# 2. Wait for services to be ready
sleep 30

# 3. Run database seeds
cd backend && npm run prisma:seed

# 4. Start mobile app
cd mobile && flutter run

# 5. Test login with demo accounts:
# NGO: ngo@demo.com / password
# Admin: admin@demo.com / password
# Buyer: buyer@demo.com / password
```

### Demo Data

The system comes pre-loaded with:
- 3 sample projects in different states
- Demo users for each role
- Sample AI verification reports
- Mock satellite data

This comprehensive setup will give you a fully functional Blue Carbon Registry system ready for demonstration and further development!