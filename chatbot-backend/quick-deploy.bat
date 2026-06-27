@echo off
REM ProVet Chatbot Quick Deploy Script for Windows
REM This script provides a Windows batch file alternative to the bash script

echo 🚀 ProVet Chatbot Deployment Script
echo ==================================

REM Check if gcloud is installed
where gcloud >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Google Cloud CLI (gcloud) is not installed.
    echo Please install it from: https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)

REM Check if docker is installed
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Docker is not installed.
    echo Please install it from: https://docs.docker.com/get-docker/
    pause
    exit /b 1
)

REM Get project ID
set /p PROJECT_ID="Please enter your Google Cloud Project ID: "
if "%PROJECT_ID%"=="" (
    echo ❌ Project ID is required.
    pause
    exit /b 1
)

echo 🔧 Setting project to: %PROJECT_ID%
gcloud config set project %PROJECT_ID%

echo 🔌 Enabling required Google Cloud APIs...
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

echo 🔐 Authenticating with Google Cloud...
gcloud auth login
gcloud auth configure-docker

echo 🐳 Building Docker image...
docker build -t gcr.io/%PROJECT_ID%/provet-chatbot:latest .

echo 📤 Pushing image to Google Container Registry...
docker push gcr.io/%PROJECT_ID%/provet-chatbot:latest

echo 🚀 Deploying to Google Cloud Run...
gcloud run deploy provet-chatbot ^
    --image gcr.io/%PROJECT_ID%/provet-chatbot:latest ^
    --region us-central1 ^
    --platform managed ^
    --allow-unauthenticated ^
    --port 3001 ^
    --memory 2Gi ^
    --cpu 2 ^
    --timeout 900 ^
    --max-instances 10 ^
    --min-instances 0 ^
    --concurrency 100

echo 🔗 Getting service URL...
for /f "tokens=*" %%i in ('gcloud run services describe provet-chatbot --region=us-central1 --format="value(status.url)"') do set SERVICE_URL=%%i

echo ✅ Deployment completed successfully!
echo 🌐 Service URL: %SERVICE_URL%
echo 📊 Health Check: %SERVICE_URL%/health
echo 🧪 Test Endpoint: %SERVICE_URL%/test

echo.
echo 📋 Useful commands:
echo   View logs: gcloud run logs tail provet-chatbot --region=us-central1
echo   Update service: quick-deploy.bat
echo   Delete service: gcloud run services delete provet-chatbot --region=us-central1

echo.
echo 🎉 ProVet Chatbot is now live at: %SERVICE_URL%
pause


