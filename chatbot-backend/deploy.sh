#!/bin/bash

# ProVet Chatbot Deployment Script for Google Cloud Run
# This script automates the deployment process using Git Bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="innovet-node-backend"
REGION="us-central1"
SERVICE_NAME="provet-chatbot"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo -e "${BLUE}🚀 ProVet Chatbot Deployment Script${NC}"
echo "=================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ Google Cloud CLI (gcloud) is not installed.${NC}"
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed.${NC}"
    echo "Please install it from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Get project ID if not set
if [ -z "$PROJECT_ID" ]; then
    echo -e "${YELLOW}📋 Please enter your Google Cloud Project ID:${NC}"
    read -p "Project ID: " PROJECT_ID
    
    if [ -z "$PROJECT_ID" ]; then
        echo -e "${RED}❌ Project ID is required.${NC}"
        exit 1
    fi
fi

# Set the project
echo -e "${BLUE}🔧 Setting project to: $PROJECT_ID${NC}"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo -e "${BLUE}🔌 Enabling required Google Cloud APIs...${NC}"
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Authenticate with Google Cloud
echo -e "${BLUE}🔐 Authenticating with Google Cloud...${NC}"
gcloud auth login
gcloud auth configure-docker

# Build the Docker image
echo -e "${BLUE}🐳 Building Docker image...${NC}"
docker build -t $IMAGE_NAME:latest .

# Tag the image with commit SHA
COMMIT_SHA=$(git rev-parse --short HEAD)
docker tag $IMAGE_NAME:latest $IMAGE_NAME:$COMMIT_SHA

# Push the image to Google Container Registry
echo -e "${BLUE}📤 Pushing image to Google Container Registry...${NC}"
docker push $IMAGE_NAME:latest
docker push $IMAGE_NAME:$COMMIT_SHA

# Deploy to Cloud Run
echo -e "${BLUE}🚀 Deploying to Google Cloud Run...${NC}"
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME:latest \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --port 3001 \
    --memory 2Gi \
    --cpu 2 \
    --timeout 900 \
    --max-instances 10 \
    --min-instances 0 \
    --concurrency 100 \
    --set-env-vars "NODE_ENV=production,RASA_URL=http://localhost:5005"

# Get the service URL
echo -e "${BLUE}🔗 Getting service URL...${NC}"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Service URL: $SERVICE_URL${NC}"
echo -e "${GREEN}📊 Health Check: $SERVICE_URL/health${NC}"
echo -e "${GREEN}🧪 Test Endpoint: $SERVICE_URL/test${NC}"

# Test the deployment
echo -e "${BLUE}🧪 Testing the deployment...${NC}"
sleep 10  # Wait for service to be ready

if curl -f "$SERVICE_URL/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Health check passed!${NC}"
else
    echo -e "${YELLOW}⚠️  Health check failed. Service might still be starting up.${NC}"
    echo "You can check the logs with: gcloud run logs tail $SERVICE_NAME --region=$REGION"
fi

echo -e "${BLUE}📋 Useful commands:${NC}"
echo "  View logs: gcloud run logs tail $SERVICE_NAME --region=$REGION"
echo "  Update service: ./deploy.sh"
echo "  Delete service: gcloud run services delete $SERVICE_NAME --region=$REGION"
echo "  View service: gcloud run services describe $SERVICE_NAME --region=$REGION"

echo -e "${GREEN}🎉 ProVet Chatbot is now live at: $SERVICE_URL${NC}"


