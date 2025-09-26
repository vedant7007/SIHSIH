# Blue Carbon Registry & MRV System
## SIH 25038 - Blockchain-Based Blue Carbon Registry & MRV System

A comprehensive mobile-first application for monitoring and verifying blue carbon projects (mangroves, seagrass, coastal plantations) with AI verification, satellite monitoring, and blockchain tokenization.

## Architecture Overview

- **Mobile App**: Flutter 3 with offline-first approach
- **Backend API**: NestJS with Prisma ORM and PostgreSQL + PostGIS
- **AI Service**: FastAPI for photo verification and authenticity checks
- **Satellite Service**: Python service using Google Earth Engine
- **Blockchain**: Solidity ERC-1155 contract on Polygon Amoy testnet
- **Storage**: MinIO (S3-compatible) for files, Redis for caching/queues

## Project Structure

```
blue-carbon-registry/
├── mobile/           # Flutter mobile app
├── backend/          # NestJS API server
├── ai-service/       # FastAPI AI microservice
├── satellite-service/# Python satellite data service
├── blockchain/       # Solidity smart contracts
└── docs/            # Documentation and diagrams
```

## Key Features

### NGO Dashboard
- 3-step project submission (Location → Details → Photos)
- Voice input with multilingual support
- Offline-first with automatic sync
- Real-time project status tracking

### Admin Dashboard
- AI-powered photo verification reports
- 5-step review workflow
- Satellite NDVI/NDWI integration
- Blockchain credit minting

### Buyer Marketplace
- Responsible purchasing with caps and multipliers
- KYC verification
- Credit retirement with certificates
- Impact portfolio tracking

## Getting Started

Each service has its own setup instructions in their respective directories.

1. Set up backend services first
2. Deploy smart contracts
3. Configure AI and satellite services
4. Build and run mobile app

## Demo Storyline

1. NGO submits project with voice input and photos (offline capable)
2. Admin reviews using AI report cards and 5-step workflow
3. Approval triggers blockchain minting of carbon credits
4. Buyer purchases and retires credits, receives certificate
5. Transparency map shows all approved projects