#!/bin/bash
set -e

echo "=========================================="
echo "Undeploying Todo AI Chatbot from Minikube"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="todo-chatbot"
RELEASE_NAME="todo-chatbot"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: Helm is not installed.${NC}"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed.${NC}"
    exit 1
fi

echo ""
echo "Checking if release exists..."
echo "----------------------------"

if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo -e "${GREEN}Release found: $RELEASE_NAME${NC}"
else
    echo -e "${YELLOW}Release $RELEASE_NAME not found in namespace $NAMESPACE${NC}"
    echo "Nothing to undeploy."
    exit 0
fi

echo ""
echo "Uninstalling Helm release..."
echo "----------------------------"

helm uninstall $RELEASE_NAME -n $NAMESPACE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Helm release uninstalled successfully${NC}"
else
    echo -e "${RED}✗ Helm uninstall failed${NC}"
    exit 1
fi

echo ""
echo "Waiting for resources to be deleted..."
echo "----------------------------"

# Wait for pods to be deleted
kubectl wait --for=delete pod \
  --all \
  --namespace $NAMESPACE \
  --timeout=120s 2>/dev/null || true

echo ""
echo "Checking for remaining resources..."
echo "----------------------------"

REMAINING=$(kubectl get all -n $NAMESPACE 2>/dev/null | grep -v "^NAME" | wc -l)

if [ $REMAINING -eq 0 ]; then
    echo -e "${GREEN}✓ All resources cleaned up${NC}"
else
    echo -e "${YELLOW}Warning: Some resources may still exist:${NC}"
    kubectl get all -n $NAMESPACE
fi

echo ""
echo "Do you want to delete the namespace? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo "Deleting namespace..."
    echo "----------------------------"

    kubectl delete namespace $NAMESPACE

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Namespace deleted${NC}"
    else
        echo -e "${RED}✗ Namespace deletion failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Namespace $NAMESPACE preserved${NC}"
    echo "To delete manually: kubectl delete namespace $NAMESPACE"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Undeployment complete!${NC}"
echo "=========================================="
echo ""
echo "To redeploy:"
echo "  ./deployment/scripts/deploy.sh"
