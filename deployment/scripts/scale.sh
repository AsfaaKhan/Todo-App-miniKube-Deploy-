#!/bin/bash
set -e

echo "=========================================="
echo "Scaling Todo AI Chatbot Replicas"
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

# Parse arguments
COMPONENT=""
REPLICAS=""

usage() {
    echo "Usage: $0 <component> <replicas>"
    echo ""
    echo "Components:"
    echo "  frontend  - Scale frontend deployment"
    echo "  backend   - Scale backend deployment"
    echo "  all       - Scale both frontend and backend"
    echo ""
    echo "Examples:"
    echo "  $0 frontend 3"
    echo "  $0 backend 5"
    echo "  $0 all 2"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

COMPONENT=$1
REPLICAS=$2

# Validate replicas is a number
if ! [[ "$REPLICAS" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Replicas must be a number${NC}"
    exit 1
fi

# Validate replicas range
if [ "$REPLICAS" -lt 0 ] || [ "$REPLICAS" -gt 10 ]; then
    echo -e "${RED}Error: Replicas must be between 0 and 10${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed.${NC}"
    exit 1
fi

# Check if deployment exists
if ! kubectl get deployment -n $NAMESPACE > /dev/null 2>&1; then
    echo -e "${RED}Error: No deployments found in namespace $NAMESPACE${NC}"
    echo "Deploy first: ./deployment/scripts/deploy.sh"
    exit 1
fi

scale_deployment() {
    local component=$1
    local replicas=$2
    local deployment_name="${RELEASE_NAME}-${component}"

    echo ""
    echo "Scaling $component to $replicas replicas..."
    echo "----------------------------"

    kubectl scale deployment $deployment_name \
        --replicas=$replicas \
        --namespace $NAMESPACE

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $component scaled to $replicas replicas${NC}"
    else
        echo -e "${RED}✗ Failed to scale $component${NC}"
        return 1
    fi

    # Wait for rollout
    echo "Waiting for rollout to complete..."
    kubectl rollout status deployment/$deployment_name -n $NAMESPACE --timeout=300s

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Rollout complete${NC}"
    else
        echo -e "${RED}✗ Rollout failed or timed out${NC}"
        return 1
    fi
}

# Scale based on component
case $COMPONENT in
    frontend)
        scale_deployment "frontend" $REPLICAS
        ;;
    backend)
        scale_deployment "backend" $REPLICAS
        ;;
    all)
        scale_deployment "frontend" $REPLICAS
        scale_deployment "backend" $REPLICAS
        ;;
    *)
        echo -e "${RED}Error: Invalid component '$COMPONENT'${NC}"
        usage
        ;;
esac

echo ""
echo "=========================================="
echo "Current Deployment Status"
echo "=========================================="

kubectl get deployments -n $NAMESPACE
echo ""
kubectl get pods -n $NAMESPACE

echo ""
echo -e "${GREEN}✓ Scaling complete!${NC}"
echo ""
echo "To verify:"
echo "  kubectl get pods -n $NAMESPACE -w"
