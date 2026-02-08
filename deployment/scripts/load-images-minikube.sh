#!/bin/bash
set -e

echo "=========================================="
echo "Loading Images into Minikube"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Minikube is running
if ! minikube status > /dev/null 2>&1; then
    echo -e "${RED}Error: Minikube is not running. Please start Minikube first.${NC}"
    echo "Run: minikube start --cpus=2 --memory=4096"
    exit 1
fi

echo ""
echo "Loading frontend image..."
echo "----------------------------"

minikube image load todo-chatbot-frontend:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Frontend image loaded successfully${NC}"
else
    echo -e "${RED}✗ Frontend image load failed${NC}"
    exit 1
fi

echo ""
echo "Loading backend image..."
echo "----------------------------"

minikube image load todo-chatbot-backend:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend image loaded successfully${NC}"
else
    echo -e "${RED}✗ Backend image load failed${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "Verifying images in Minikube..."
echo "=========================================="

minikube image ls | grep todo-chatbot

echo ""
echo -e "${GREEN}✓ All images loaded successfully!${NC}"
echo ""
echo "Next step:"
echo "Deploy to Kubernetes: ./deployment/scripts/deploy.sh"
