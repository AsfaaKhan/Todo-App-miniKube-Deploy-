#!/bin/bash
set -e

echo "=========================================="
echo "Deploying Todo AI Chatbot to Minikube"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="todo-chatbot"
RELEASE_NAME="todo-chatbot"
CHART_PATH="deployment/helm/todo-chatbot"
VALUES_FILE="deployment/helm/todo-chatbot/values-dev.yaml"

# Check prerequisites
echo ""
echo "Checking prerequisites..."
echo "----------------------------"

# Check if Minikube is running
if ! minikube status > /dev/null 2>&1; then
    echo -e "${RED}Error: Minikube is not running.${NC}"
    echo "Run: minikube start --cpus=2 --memory=4096"
    exit 1
fi
echo -e "${GREEN}✓ Minikube is running${NC}"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: Helm is not installed.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Helm is installed${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ kubectl is installed${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env file not found. Using .env.example as template.${NC}"
    echo "Please create .env file with your actual credentials."
    echo "Copy .env.example to .env and fill in the values."
    exit 1
fi

# Load environment variables
source .env

# Validate required environment variables
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}Error: DATABASE_URL is not set in .env${NC}"
    exit 1
fi

if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${RED}Error: OPENAI_API_KEY is not set in .env${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment variables loaded${NC}"

# Get Minikube IP for CORS configuration
MINIKUBE_IP=$(minikube ip)
echo -e "${BLUE}Minikube IP: $MINIKUBE_IP${NC}"

# Create namespace if it doesn't exist
echo ""
echo "Creating namespace..."
echo "----------------------------"

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ Namespace $NAMESPACE ready${NC}"

# Create or update secrets
echo ""
echo "Creating secrets..."
echo "----------------------------"

kubectl create secret generic ${RELEASE_NAME}-secrets \
  --from-literal=databaseUrl="$DATABASE_URL" \
  --from-literal=openaiApiKey="$OPENAI_API_KEY" \
  --from-literal=mcpConfig="${MCP_CONFIG:-{}}" \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✓ Secrets created${NC}"

# Install or upgrade Helm chart
echo ""
echo "Deploying with Helm..."
echo "----------------------------"

# Check if kubectl-ai is available
if command -v kubectl-ai &> /dev/null; then
    echo -e "${GREEN}kubectl-ai detected! AI-assisted deployment available.${NC}"
fi

# Check if kagent is available
if command -v kagent &> /dev/null; then
    echo -e "${GREEN}kagent detected! AI cluster analysis available.${NC}"
fi

# Deploy with Helm
helm upgrade --install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --set config.corsOrigins="http://localhost:30080,http://${MINIKUBE_IP}:30080" \
  --wait \
  --timeout 10m

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Deployment successful!${NC}"
else
    echo -e "${RED}✗ Deployment failed${NC}"
    exit 1
fi

# Wait for pods to be ready
echo ""
echo "Waiting for pods to be ready..."
echo "----------------------------"

kubectl wait --for=condition=ready pod \
  --all \
  --namespace $NAMESPACE \
  --timeout=300s

echo ""
echo "=========================================="
echo "Deployment Status"
echo "=========================================="

kubectl get all -n $NAMESPACE

echo ""
echo "=========================================="
echo "Access Information"
echo "=========================================="

echo ""
echo -e "${GREEN}✓ Deployment complete!${NC}"
echo ""
echo "To access the application:"
echo "  minikube service ${RELEASE_NAME}-frontend -n $NAMESPACE --url"
echo ""
echo "Or open in browser:"
echo "  minikube service ${RELEASE_NAME}-frontend -n $NAMESPACE"
echo ""
echo "To view logs:"
echo "  kubectl logs -l app=todo-chatbot-frontend -n $NAMESPACE --tail=50"
echo "  kubectl logs -l app=todo-chatbot-backend -n $NAMESPACE --tail=50"
echo ""
echo "To check pod status:"
echo "  kubectl get pods -n $NAMESPACE"
