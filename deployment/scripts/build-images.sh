#!/bin/bash
set -e

echo "=========================================="
echo "Building Docker Images for Todo AI Chatbot"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

echo ""
echo "Building frontend image..."
echo "----------------------------"

# Check if Gordon (Docker AI Agent) is available
if command -v gordon &> /dev/null; then
    echo -e "${GREEN}Gordon detected! Using AI-assisted build...${NC}"
    gordon build --optimize -t todo-chatbot-frontend:latest -f deployment/docker/frontend/Dockerfile . || {
        echo -e "${YELLOW}Gordon build failed, falling back to standard docker build...${NC}"
        docker build -t todo-chatbot-frontend:latest -f deployment/docker/frontend/Dockerfile .
    }
else
    echo -e "${YELLOW}Gordon not found, using standard docker build...${NC}"
    docker build -t todo-chatbot-frontend:latest -f deployment/docker/frontend/Dockerfile .
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Frontend image built successfully${NC}"
else
    echo -e "${RED}✗ Frontend image build failed${NC}"
    exit 1
fi

echo ""
echo "Building backend image..."
echo "----------------------------"

# Check if Gordon is available for backend
if command -v gordon &> /dev/null; then
    echo -e "${GREEN}Gordon detected! Using AI-assisted build...${NC}"
    gordon build --optimize -t todo-chatbot-backend:latest -f deployment/docker/backend/Dockerfile . || {
        echo -e "${YELLOW}Gordon build failed, falling back to standard docker build...${NC}"
        docker build -t todo-chatbot-backend:latest -f deployment/docker/backend/Dockerfile .
    }
else
    echo -e "${YELLOW}Gordon not found, using standard docker build...${NC}"
    docker build -t todo-chatbot-backend:latest -f deployment/docker/backend/Dockerfile .
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend image built successfully${NC}"
else
    echo -e "${RED}✗ Backend image build failed${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "Verifying built images..."
echo "=========================================="

docker images | grep todo-chatbot

echo ""
echo -e "${GREEN}✓ All images built successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Load images into Minikube: ./deployment/scripts/load-images-minikube.sh"
echo "2. Deploy to Kubernetes: ./deployment/scripts/deploy.sh"
