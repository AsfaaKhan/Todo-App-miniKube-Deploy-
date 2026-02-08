#!/bin/bash
set -e

echo "=========================================="
echo "Testing Todo AI Chatbot Deployment"
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

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name=$1
    local test_command=$2

    echo ""
    echo "Running: $test_name"
    echo "----------------------------"

    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASS: $test_name${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL: $test_name${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: Check if pods are running
run_test "Pods are running" \
    "kubectl get pods -n $NAMESPACE | grep -E 'Running|Completed' | wc -l | grep -q '[1-9]'"

# Test 2: Check if services exist
run_test "Services exist" \
    "kubectl get svc -n $NAMESPACE | grep -q $RELEASE_NAME"

# Test 3: Check frontend pod health
run_test "Frontend pods are ready" \
    "kubectl get pods -n $NAMESPACE -l app=todo-chatbot-frontend -o jsonpath='{.items[*].status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"

# Test 4: Check backend pod health
run_test "Backend pods are ready" \
    "kubectl get pods -n $NAMESPACE -l app=todo-chatbot-backend -o jsonpath='{.items[*].status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"

# Test 5: Test pod restart (resilience)
echo ""
echo "Testing pod auto-recovery..."
echo "----------------------------"

BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=todo-chatbot-backend -o jsonpath='{.items[0].metadata.name}')

if [ -n "$BACKEND_POD" ]; then
    echo "Deleting backend pod: $BACKEND_POD"
    kubectl delete pod $BACKEND_POD -n $NAMESPACE --force --grace-period=0

    echo "Waiting for new pod to be created..."
    sleep 5

    run_test "Pod auto-recovery" \
        "kubectl wait --for=condition=ready pod -l app=todo-chatbot-backend -n $NAMESPACE --timeout=60s"
else
    echo -e "${YELLOW}Warning: No backend pod found to test recovery${NC}"
fi

# Test 6: Test scaling
echo ""
echo "Testing horizontal scaling..."
echo "----------------------------"

ORIGINAL_REPLICAS=$(kubectl get deployment ${RELEASE_NAME}-frontend -n $NAMESPACE -o jsonpath='{.spec.replicas}')

echo "Original frontend replicas: $ORIGINAL_REPLICAS"
echo "Scaling to 3 replicas..."

kubectl scale deployment ${RELEASE_NAME}-frontend --replicas=3 -n $NAMESPACE

run_test "Scale up to 3 replicas" \
    "kubectl wait --for=condition=ready pod -l app=todo-chatbot-frontend -n $NAMESPACE --timeout=120s && [ \$(kubectl get pods -n $NAMESPACE -l app=todo-chatbot-frontend | grep Running | wc -l) -eq 3 ]"

echo "Scaling back to original replicas: $ORIGINAL_REPLICAS"
kubectl scale deployment ${RELEASE_NAME}-frontend --replicas=$ORIGINAL_REPLICAS -n $NAMESPACE

run_test "Scale back to original" \
    "kubectl wait --for=condition=ready pod -l app=todo-chatbot-frontend -n $NAMESPACE --timeout=120s"

# Test 7: Check ConfigMap exists
run_test "ConfigMap exists" \
    "kubectl get configmap -n $NAMESPACE | grep -q ${RELEASE_NAME}-config"

# Test 8: Check Secret exists
run_test "Secret exists" \
    "kubectl get secret -n $NAMESPACE | grep -q ${RELEASE_NAME}-secrets"

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
