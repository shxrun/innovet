# Multi-stage Dockerfile for ProVet Chatbot
# This builds both the Node.js server and Rasa chatbot in a single container

# Stage 1: Build Node.js application
FROM node:18-alpine AS node-builder

WORKDIR /app

# Copy package files
COPY node-server/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Stage 2: Python/Rasa setup
FROM python:3.8-slim AS python-builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gcc \
    g++ \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Upgrade pip and install wheel with compatible versions
RUN pip install --upgrade pip
RUN pip install "setuptools<70.0.0" wheel

# Copy requirements and install Python dependencies with retry logic
COPY requirements.txt .

# Install dependencies in smaller chunks to avoid JSON parsing errors
RUN pip install --no-cache-dir --timeout=1000 --retries=5 rasa==3.6.2 rasa-sdk==3.6.2
RUN pip install --no-cache-dir --timeout=1000 --retries=5 firebase-admin==6.2.0
RUN pip install --no-cache-dir --timeout=1000 --retries=5 python-dotenv==1.0.0 requests==2.31.0

# Stage 3: Final production image
FROM python:3.8-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy Python dependencies from builder
COPY --from=python-builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=python-builder /usr/local/bin /usr/local/bin

# Install Node.js using Debian packages (more reliable)
RUN apt-get update && apt-get install -y nodejs npm

# Copy Node.js application
COPY --from=node-builder /app/node_modules ./node-server/node_modules
COPY node-server/ ./node-server/

# Copy Rasa application
COPY rasa/ ./rasa/

# Copy configuration files
COPY requirements.txt ./
COPY env.example ./.env

# Set environment variables
ENV PORT=3001
ENV RASA_URL=http://127.0.0.1:5005
ENV NODE_ENV=production
ENV PYTHONPATH=/app/rasa
ENV RASA_ACTIONS_PORT=5055
ENV RASA_SERVER_PORT=5005
ENV GEMINI_API_KEY=AIzaSyBqAW39u5D6RwW0LJ2qqJQTtIOEwgDQBmA

# Create startup script
RUN echo '#!/bin/bash\n\
# Start Rasa action server in background with debug\n\
cd /app/rasa && rasa run actions --port 5055 --debug &\n\
\n\
# List available models for debugging\n\
echo "Available models:"\n\
ls -la /app/rasa/models/\n\
echo "Current directory:"\n\
pwd\n\
\n\
# Start Rasa server in background with debug (auto-detect latest model)\n\
cd /app/rasa && rasa run --enable-api --cors "*" --port 5005 --debug --model models &\n\
\n\
# Wait for Rasa to be ready\n\
echo "Waiting for Rasa to start..."\n\
sleep 15\n\
\n\
# Check if Rasa is responding\n\
for i in {1..10}; do\n\
  if curl -f http://127.0.0.1:5005/ >/dev/null 2>&1; then\n\
    echo "Rasa is ready!"\n\
    break\n\
  fi\n\
  echo "Waiting for Rasa... attempt $i"\n\
  sleep 5\n\
done\n\
\n\
# Start Node.js server\n\
echo "Starting Node.js server..."\n\
cd /app/node-server && npm start\n\
' > /app/start.sh && chmod +x /app/start.sh

# Expose ports
EXPOSE 3001 5005 5055

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3001/health || exit 1

# Start the application
CMD ["/app/start.sh"]
