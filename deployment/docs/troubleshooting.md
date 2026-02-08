# Troubleshooting Guide: Todo AI Chatbot on Minikube

This guide helps you diagnose and resolve common issues when deploying the Todo AI Chatbot to Minikube.

## Quick Diagnostics

### Check Overall Status

```bash
# Check all resources
kubectl get all -n todo-chatbot

# Check pod status
kubectl get pods -n todo-chatbot

# Check services
kubectl get svc -n todo-chatbot

# Check events
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'
```

### Check Logs

```bash
# Frontend logs
kubectl logs -l app=todo-chatbot-frontend -n todo-chatbot --tail=50

# Backend logs
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=50

# Follow logs in real-time
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot -f
```

## Common Issues

### Issue 1: Pods Stuck in ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods -n todo-chatbot
# NAME                                     READY   STATUS             RESTARTS   AGE
# todo-chatbot-frontend-xxx                0/1     ImagePullBackOff   0          2m
```

**Cause:** Docker images not loaded into Minikube's local registry.

**Solution:**

```bash
# 1. Verify images exist locally
docker images | grep todo-chatbot

# 2. If images don't exist, build them
./deployment/scripts/build-images.sh

# 3. Load images into Minikube
./deployment/scripts/load-images-minikube.sh

# 4. Verify images in Minikube
minikube image ls | grep todo-chatbot

# 5. Restart deployment
kubectl rollout restart deployment/todo-chatbot-frontend -n todo-chatbot
kubectl rollout restart deployment/todo-chatbot-backend -n todo-chatbot
```

**Prevention:** Always run `load-images-minikube.sh` after building images.

---

### Issue 2: Pods Stuck in CrashLoopBackOff

**Symptoms:**
```bash
kubectl get pods -n todo-chatbot
# NAME                                     READY   STATUS             RESTARTS   AGE
# todo-chatbot-backend-xxx                 0/1     CrashLoopBackOff   5          5m
```

**Cause:** Application error, missing environment variables, or database connectivity issues.

**Diagnosis:**

```bash
# 1. Check pod logs for errors
kubectl logs <pod-name> -n todo-chatbot

# 2. Describe pod for events
kubectl describe pod <pod-name> -n todo-chatbot

# 3. Check environment variables
kubectl exec <pod-name> -n todo-chatbot -- env | sort
```

**Common Causes & Solutions:**

#### Missing Environment Variables

```bash
# Check if secrets exist
kubectl get secret todo-chatbot-secrets -n todo-chatbot

# If missing, create secrets
source .env
kubectl create secret generic todo-chatbot-secrets \
  --from-literal=databaseUrl="$DATABASE_URL" \
  --from-literal=openaiApiKey="$OPENAI_API_KEY" \
  --from-literal=mcpConfig="${MCP_CONFIG:-{}}" \
  --namespace todo-chatbot
```

#### Database Connection Issues

```bash
# Test database connectivity from pod
kubectl exec <backend-pod-name> -n todo-chatbot -- \
  python -c "import psycopg2; psycopg2.connect('$DATABASE_URL')"

# If connection fails:
# - Verify DATABASE_URL is correct
# - Check if database is accessible from Minikube
# - Verify firewall rules allow connection
```

#### Application Code Errors

```bash
# Check detailed logs
kubectl logs <pod-name> -n todo-chatbot --previous

# Common errors:
# - Import errors: Missing dependencies in requirements.txt
# - Syntax errors: Check application code
# - Port conflicts: Verify port configuration
```

---

### Issue 3: Cannot Access Application from Browser

**Symptoms:**
- Browser shows "Connection refused" or timeout
- Cannot reach frontend URL

**Diagnosis:**

```bash
# 1. Check if frontend service exists
kubectl get svc todo-chatbot-frontend -n todo-chatbot

# 2. Verify service type is NodePort
kubectl get svc todo-chatbot-frontend -n todo-chatbot -o yaml | grep type

# 3. Get the correct URL
minikube service todo-chatbot-frontend -n todo-chatbot --url

# 4. Check if pods are ready
kubectl get pods -n todo-chatbot -l app=todo-chatbot-frontend
```

**Solutions:**

#### Service Not Exposed

```bash
# Verify NodePort is configured
kubectl get svc todo-chatbot-frontend -n todo-chatbot

# Expected output should show NodePort type with port 30080
# If not, check Helm values and redeploy
```

#### Minikube Tunnel Issues

```bash
# Try using Minikube tunnel
minikube tunnel

# Then access via: http://localhost:80
```

#### Firewall Blocking

```bash
# On Windows, check Windows Firewall
# On macOS, check System Preferences > Security & Privacy > Firewall

# Temporarily disable to test (not recommended for production)
```

---

### Issue 4: Frontend Cannot Connect to Backend

**Symptoms:**
- Frontend loads but API calls fail
- Browser console shows network errors
- 502 Bad Gateway or connection refused errors

**Diagnosis:**

```bash
# 1. Check if backend service exists
kubectl get svc todo-chatbot-backend -n todo-chatbot

# 2. Check backend pods are running
kubectl get pods -n todo-chatbot -l app=todo-chatbot-backend

# 3. Test backend connectivity from frontend pod
FRONTEND_POD=$(kubectl get pods -n todo-chatbot -l app=todo-chatbot-frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec $FRONTEND_POD -n todo-chatbot -- curl http://todo-chatbot-backend:8000/health

# 4. Check backend service DNS
kubectl exec $FRONTEND_POD -n todo-chatbot -- nslookup todo-chatbot-backend
```

**Solutions:**

#### Backend Service Not Ready

```bash
# Check backend pod status
kubectl get pods -n todo-chatbot -l app=todo-chatbot-backend

# Check backend logs
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=50

# Restart backend if needed
kubectl rollout restart deployment/todo-chatbot-backend -n todo-chatbot
```

#### Incorrect Service URL

```bash
# Check ConfigMap for backend URL
kubectl get configmap todo-chatbot-config -n todo-chatbot -o yaml

# Should show: BACKEND_SERVICE_URL: "http://todo-chatbot-backend:8000"

# If incorrect, update and redeploy
helm upgrade todo-chatbot deployment/helm/todo-chatbot -n todo-chatbot
```

#### CORS Issues

```bash
# Check CORS configuration in ConfigMap
kubectl get configmap todo-chatbot-config -n todo-chatbot -o yaml | grep CORS

# Update CORS origins if needed
MINIKUBE_IP=$(minikube ip)
helm upgrade todo-chatbot deployment/helm/todo-chatbot \
  --set config.corsOrigins="http://localhost:30080,http://${MINIKUBE_IP}:30080" \
  -n todo-chatbot
```

---

### Issue 5: Pods Running Out of Memory (OOMKilled)

**Symptoms:**
```bash
kubectl get pods -n todo-chatbot
# NAME                                     READY   STATUS      RESTARTS   AGE
# todo-chatbot-backend-xxx                 0/1     OOMKilled   3          5m
```

**Diagnosis:**

```bash
# 1. Check pod events
kubectl describe pod <pod-name> -n todo-chatbot | grep -A 10 Events

# 2. Check resource usage
kubectl top pod <pod-name> -n todo-chatbot

# 3. Check resource limits
kubectl get pod <pod-name> -n todo-chatbot -o yaml | grep -A 5 resources
```

**Solutions:**

#### Increase Memory Limits

```bash
# Edit values file to increase memory
# For backend in values-dev.yaml:
resources:
  backend:
    requests:
      memory: "512Mi"
    limits:
      memory: "1Gi"  # Increase this

# Upgrade deployment
helm upgrade todo-chatbot deployment/helm/todo-chatbot \
  -f deployment/helm/todo-chatbot/values-dev.yaml \
  -n todo-chatbot
```

#### Check for Memory Leaks

```bash
# Monitor memory usage over time
kubectl top pod -n todo-chatbot --watch

# Check application logs for memory issues
kubectl logs <pod-name> -n todo-chatbot | grep -i memory
```

---

### Issue 6: Minikube Out of Resources

**Symptoms:**
- Pods stuck in Pending state
- Error: "Insufficient cpu" or "Insufficient memory"

**Diagnosis:**

```bash
# Check node resources
kubectl top nodes

# Check pod resource requests
kubectl describe nodes | grep -A 5 "Allocated resources"

# Check pending pods
kubectl get pods -n todo-chatbot | grep Pending
kubectl describe pod <pending-pod> -n todo-chatbot
```

**Solutions:**

#### Increase Minikube Resources

```bash
# Stop Minikube
minikube stop

# Start with more resources
minikube start --cpus=4 --memory=8192

# Redeploy
./deployment/scripts/deploy.sh
```

#### Reduce Resource Requests

```bash
# Use development values with lower resources
helm upgrade todo-chatbot deployment/helm/todo-chatbot \
  -f deployment/helm/todo-chatbot/values-dev.yaml \
  -n todo-chatbot

# Or reduce replica counts
helm upgrade todo-chatbot deployment/helm/todo-chatbot \
  --set replicaCount.frontend=1 \
  --set replicaCount.backend=1 \
  -n todo-chatbot
```

---

### Issue 7: Helm Install/Upgrade Fails

**Symptoms:**
- Helm command returns error
- Validation errors
- Template rendering errors

**Common Errors & Solutions:**

#### Missing Required Values

```bash
# Error: secrets.databaseUrl is required

# Solution: Provide required values
helm install todo-chatbot deployment/helm/todo-chatbot \
  --set secrets.databaseUrl="postgresql://..." \
  --set secrets.openaiApiKey="sk-..." \
  -n todo-chatbot
```

#### Invalid Values

```bash
# Error: secrets.databaseUrl must start with postgresql://

# Solution: Fix the value format
# Correct: postgresql://user:pass@host:5432/db
# Wrong: postgres://user:pass@host:5432/db
```

#### Template Errors

```bash
# Debug template rendering
helm template todo-chatbot deployment/helm/todo-chatbot \
  --set secrets.databaseUrl="test" \
  --set secrets.openaiApiKey="test" \
  --debug

# Check for syntax errors in templates
```

---

### Issue 8: Health Checks Failing

**Symptoms:**
- Pods show as not ready
- Frequent restarts
- Liveness/readiness probe failures

**Diagnosis:**

```bash
# Check probe configuration
kubectl get pod <pod-name> -n todo-chatbot -o yaml | grep -A 10 livenessProbe

# Test health endpoint manually
kubectl exec <pod-name> -n todo-chatbot -- curl http://localhost:3000/api/health
kubectl exec <pod-name> -n todo-chatbot -- curl http://localhost:8000/health
```

**Solutions:**

#### Increase Probe Timeouts

```bash
# Edit values file
healthCheck:
  backend:
    livenessProbe:
      initialDelaySeconds: 60  # Increase if app takes long to start
      periodSeconds: 30
      timeoutSeconds: 5
      failureThreshold: 5  # Increase tolerance

# Upgrade deployment
helm upgrade todo-chatbot deployment/helm/todo-chatbot -n todo-chatbot
```

#### Fix Health Endpoints

```bash
# Verify health endpoints exist in application code
# Frontend should have: /api/health
# Backend should have: /health

# Check if endpoints return 200 OK
```

---

## Advanced Troubleshooting

### Enable Debug Logging

```bash
# Update log level to debug
helm upgrade todo-chatbot deployment/helm/todo-chatbot \
  --set config.logLevel="debug" \
  -n todo-chatbot

# Check logs
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot -f
```

### Inspect Pod Filesystem

```bash
# Get shell access to pod
kubectl exec -it <pod-name> -n todo-chatbot -- /bin/sh

# Check files
ls -la /app

# Check environment
env | sort

# Check processes
ps aux
```

### Network Debugging

```bash
# Install network tools in pod (temporary)
kubectl exec -it <pod-name> -n todo-chatbot -- sh
apk add --no-cache curl netcat-openbsd

# Test connectivity
curl http://todo-chatbot-backend:8000/health
nc -zv todo-chatbot-backend 8000
```

### Check Kubernetes Events

```bash
# All events in namespace
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'

# Events for specific pod
kubectl get events -n todo-chatbot --field-selector involvedObject.name=<pod-name>

# Watch events in real-time
kubectl get events -n todo-chatbot --watch
```

## Getting Help

### Collect Diagnostic Information

```bash
# Create diagnostic bundle
mkdir -p diagnostics

# Collect pod information
kubectl get pods -n todo-chatbot -o yaml > diagnostics/pods.yaml

# Collect logs
kubectl logs -l app=todo-chatbot-frontend -n todo-chatbot > diagnostics/frontend.log
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot > diagnostics/backend.log

# Collect events
kubectl get events -n todo-chatbot > diagnostics/events.txt

# Collect resource usage
kubectl top pods -n todo-chatbot > diagnostics/resources.txt

# Collect configuration
kubectl get configmap todo-chatbot-config -n todo-chatbot -o yaml > diagnostics/configmap.yaml
kubectl get secret todo-chatbot-secrets -n todo-chatbot -o yaml > diagnostics/secret.yaml

# Create archive
tar -czf diagnostics.tar.gz diagnostics/
```

### Use AI Tools for Diagnosis

```bash
# If kubectl-ai is available
kubectl ai "why is my backend pod crashing" -n todo-chatbot

# If kagent is available
kagent diagnose namespace todo-chatbot
```

### Check Documentation

- Quickstart Guide: `specs/004-minikube-deployment/quickstart.md`
- Deployment README: `deployment/README.md`
- Environment Variables: `specs/004-minikube-deployment/contracts/environment-variables.md`
- AI Tools: `deployment/docs/ai-tools.md`

## Prevention Tips

### 1. Always Validate Before Deploying

```bash
# Validate Helm chart
helm lint deployment/helm/todo-chatbot

# Dry-run deployment
helm install todo-chatbot deployment/helm/todo-chatbot \
  --dry-run --debug \
  --set secrets.databaseUrl="test" \
  --set secrets.openaiApiKey="test" \
  -n todo-chatbot
```

### 2. Use Development Values for Testing

```bash
# Lower resources, faster iteration
helm install todo-chatbot deployment/helm/todo-chatbot \
  -f deployment/helm/todo-chatbot/values-dev.yaml \
  -n todo-chatbot
```

### 3. Monitor Resource Usage

```bash
# Regular checks
kubectl top nodes
kubectl top pods -n todo-chatbot

# Set up alerts (if using kagent)
kagent alert setup -n todo-chatbot
```

### 4. Keep Images Updated

```bash
# Rebuild images regularly
./deployment/scripts/build-images.sh

# Reload into Minikube
./deployment/scripts/load-images-minikube.sh

# Restart deployments
kubectl rollout restart deployment -n todo-chatbot
```

### 5. Test Resilience

```bash
# Run resilience tests
./deployment/scripts/test-deployment.sh

# Manually test pod recovery
kubectl delete pod -l app=todo-chatbot-backend -n todo-chatbot
kubectl get pods -n todo-chatbot -w
```

## Still Having Issues?

If you're still experiencing problems:

1. Check the quickstart guide for step-by-step instructions
2. Verify all prerequisites are met
3. Try a clean redeployment:
   ```bash
   ./deployment/scripts/undeploy.sh
   ./deployment/scripts/deploy.sh
   ```
4. Collect diagnostic information (see above)
5. Review application logs for specific errors
6. Check Minikube status: `minikube status`
7. Restart Minikube if needed: `minikube stop && minikube start`
