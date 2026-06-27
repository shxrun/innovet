# ProVet Chatbot - Google Cloud Run Deployment Guide

This guide will help you deploy the ProVet Chatbot to Google Cloud Run using Docker and Git Bash.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Google Cloud CLI** - [Download here](https://cloud.google.com/sdk/docs/install)
2. **Docker Desktop** - [Download here](https://docs.docker.com/get-docker/)
3. **Git Bash** (already installed on Windows)
4. **Google Cloud Account** with billing enabled

## Project Structure

```
provet-chatbot/
├── node-server/          # Node.js Express server
├── rasa/                 # Rasa chatbot configuration
├── Dockerfile            # Multi-stage Docker configuration
├── docker-compose.yml    # Local development setup
├── cloudbuild.yaml       # Google Cloud Build configuration
├── deploy.sh            # Deployment script for Git Bash
├── .dockerignore        # Docker ignore file
└── env.example          # Environment variables template
```

## Quick Start

### 1. Set Up Google Cloud Project

1. Create a new Google Cloud project or select an existing one
2. Enable the following APIs:
   - Cloud Run API
   - Cloud Build API
   - Container Registry API

### 2. Configure Environment

1. Copy the environment template:
   ```bash
   cp env.example .env
   ```

2. Edit `.env` with your configuration:
   ```bash
   # Required: Replace with your Google Cloud Project ID
   GOOGLE_CLOUD_PROJECT_ID=your-project-id
   GOOGLE_CLOUD_REGION=us-central1
   ```

### 3. Deploy to Cloud Run

Run the deployment script in Git Bash:

```bash
./deploy.sh
```

The script will:
- Build the Docker image
- Push it to Google Container Registry
- Deploy to Cloud Run
- Provide you with the service URL

## Manual Deployment Steps

If you prefer to deploy manually:

### 1. Authenticate with Google Cloud

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth configure-docker
```

### 2. Build and Push Docker Image

```bash
# Build the image
docker build -t gcr.io/YOUR_PROJECT_ID/provet-chatbot:latest .

# Push to Google Container Registry
docker push gcr.io/YOUR_PROJECT_ID/provet-chatbot:latest
```

### 3. Deploy to Cloud Run

```bash
gcloud run deploy provet-chatbot \
    --image gcr.io/YOUR_PROJECT_ID/provet-chatbot:latest \
    --region us-central1 \
    --platform managed \
    --allow-unauthenticated \
    --port 3001 \
    --memory 2Gi \
    --cpu 2 \
    --timeout 900 \
    --max-instances 10 \
    --min-instances 0 \
    --concurrency 100
```

## Local Development

To run the application locally for development:

```bash
# Using Docker Compose
docker-compose up --build

# Or run individual services
# Terminal 1: Start Rasa action server
cd rasa && rasa run actions --port 5055

# Terminal 2: Start Rasa server
cd rasa && rasa run --enable-api --cors "*" --port 5005

# Terminal 3: Start Node.js server
cd node-server && npm start
```

## Service Endpoints

Once deployed, your chatbot will be available at:

- **Main Service**: `https://your-service-url.run.app`
- **Health Check**: `https://your-service-url.run.app/health`
- **Test Endpoint**: `https://your-service-url.run.app/test`
- **Chat API**: `POST https://your-service-url.run.app/chat`

### Chat API Usage

```bash
curl -X POST https://your-service-url.run.app/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello, I need help with my pet",
    "sender_id": "user123"
  }'
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Node.js server port | `3001` |
| `RASA_URL` | Rasa server URL | `http://localhost:5005` |
| `NODE_ENV` | Environment mode | `production` |

### Cloud Run Settings

- **Memory**: 2GB
- **CPU**: 2 cores
- **Timeout**: 15 minutes
- **Max Instances**: 10
- **Min Instances**: 0 (scales to zero)
- **Concurrency**: 100 requests per instance

## Monitoring and Logs

### View Logs

```bash
# View recent logs
gcloud run logs tail provet-chatbot --region=us-central1

# View logs from specific time
gcloud run logs read provet-chatbot --region=us-central1 --limit=50
```

### Monitor Performance

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to Cloud Run
3. Select your service
4. View metrics, logs, and performance data

## Troubleshooting

### Common Issues

1. **Build Fails**: Check Dockerfile syntax and dependencies
2. **Service Won't Start**: Check logs for errors
3. **Health Check Fails**: Ensure all services are running properly
4. **Memory Issues**: Increase memory allocation in Cloud Run settings

### Debug Commands

```bash
# Check service status
gcloud run services describe provet-chatbot --region=us-central1

# View service configuration
gcloud run services describe provet-chatbot --region=us-central1 --format="export"

# Test health endpoint
curl https://your-service-url.run.app/health
```

## Updating the Service

To update your deployed service:

1. Make your changes to the code
2. Run the deployment script again:
   ```bash
   ./deploy.sh
   ```

Or manually:

```bash
# Build new image
docker build -t gcr.io/YOUR_PROJECT_ID/provet-chatbot:latest .

# Push new image
docker push gcr.io/YOUR_PROJECT_ID/provet-chatbot:latest

# Deploy updated service
gcloud run deploy provet-chatbot \
    --image gcr.io/YOUR_PROJECT_ID/provet-chatbot:latest \
    --region us-central1
```

## Cost Optimization

- **Min Instances**: Set to 0 to scale to zero when not in use
- **Max Instances**: Adjust based on expected traffic
- **Memory/CPU**: Start with 2GB/2CPU and adjust based on performance
- **Timeout**: Set appropriate timeout to avoid unnecessary costs

## Security Considerations

1. **Firebase Keys**: Keep your Firebase service account key secure
2. **Environment Variables**: Use Google Secret Manager for sensitive data
3. **CORS**: Configure CORS properly for your frontend domain
4. **Authentication**: Consider adding authentication if needed

## Support

If you encounter issues:

1. Check the logs: `gcloud run logs tail provet-chatbot --region=us-central1`
2. Verify your Google Cloud project settings
3. Ensure all APIs are enabled
4. Check Docker build locally: `docker build -t test .`

## Next Steps

1. Set up a custom domain (optional)
2. Configure monitoring and alerting
3. Set up CI/CD pipeline with GitHub Actions
4. Add authentication and authorization
5. Implement database persistence for conversations


