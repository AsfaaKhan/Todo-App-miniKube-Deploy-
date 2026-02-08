# Quickstart Guide: Deploy Todo AI Chatbot on Minikube

**Feature**: Cloud-Native Deployment on Minikube
**Date**: 2026-02-07
**Audience**: DevOps engineers, developers
**Time to Complete**: 30-45 minutes (first time), 10-15 minutes (subsequent deployments)

## Prerequisites

Before starting, ensure you have the following installed and configured:

### Required Tools

- **Docker Desktop**: Container runtime
  - Version: 20.x or later
  - Status: Running
  - Verify: `docker --version` and `docker ps`

- **Minikube**: Local Kubernetes cluster
  - Version: 1.30.x or later
  - Verify: `minikube version`
  - Install: https://minikube.sigs.k8s.io/docs/start/

- **kubectl**: Kubernetes CLI
  - Version: 1.24.x or later
  - Verify: `kubectl version --client`
  - Install: https://kubernetes.io/docs/tasks/tools/

- **Helm**: Kubernetes package manager
  - Version: 3.x
  - Verify: `helm version`
  - Install: https://helm.sh/docs/intro/install/

### Optional AI Tools

- **kubectl-ai**: AI-assisted Kubernetes operations
  - Install: https://github.com/sozercan/kubectl-ai
  - Fallback: Standard kubectl commands work without this

- **kagent**: AI cluster analysis
  - Install: https://github.com/kubeshop/kagent
  - Fallback: Manual cluster inspection works without this

- **Gordon (Docker AI Agent)**: AI-assisted Docker operations
  - Install: https://github.com/docker/gordon
  - Fallback: Standard docker commands work without this

### Required Credentials

- **Neon PostgreSQL Database**:
  - Connection string format: `postgresql://user:password@host:port/database`
  - Database must be accessible from your local machine
  - Example: `postgresql://todouser:pass@ep-cool-name-123456.us-east-2.aws.neon.tech/tododb`

- **OpenAI API Key**:
  - Format: `sk-proj-...` or `sk-...`
  - Must have credits available
  - Get from: https://platform.openai.com/api-keys

### System Requirements

- **RAM**: Minimum 8GB total (4GB allocated to Minikube)
- **CPU**: Minimum 4 cores (2 allocated to Minikube)
- **Disk**: Minimum 20GB free space
- **Network**: Internet access for pulling images and accessing external services

---

## Step 1: Start Minikube

### 1.1 Start Minikube Cluster

```bash
# Start Minikube with recommended resources
minikube start --cpus=2 --memory=4096 --driver=docker

# Expected output:
# 😄  minikube v1.30.1 on Windows 10
# ✨  Using the docker driver based on user configuration
# 👍  Starting control plane node minikube in cluster minikube
# 🚜  Pulling base image ...
# 🔥  Creating docker container (CPUs=2, Memory=4096MB) ...
# 🐳  Preparing Kubernetes v1.26.3 on Docker 23.0.2 ...
# 🔎  Verifying Kubernetes components...
# 🌟  Enabled addons: storage-provisioner, default-storageclass
# 🏄  Done! kubectl is now configured to use "minikube" cluster
```

### 1.2 Verify Cluster Status

```bash
# Check Minikube status
minikube status

# Expected output:
# minikube
# type: Control Plane
# host: Running
# kubelet: Running
# apiserver: Running
# kubeconfig: Configured

# Check kubectl connection
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running at https://192.168.49.2:8443
# CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### 1.3 Get Minikube IP (for CORS configuration)

```bash
# Get Minikube IP address
minikube ip

# Example output: 192.168.49.2
# Save this IP - you'll need it for CORS configuration
```

---

## Step 2: Prepare Environment

### 2.1 Clone Repository (if not already done)

```bash
# Navigate to project directory
cd /path/to/chatbot-deployment-minikubes
```

### 2.2 Create Environment File

Create a `.env` file in the project root with your credentials:

```bash
# Create .env file (never commit this!)
cat > .env << 'EOF'
DATABASE_URL=postgresql://user:password@host:port/database
OPENAI_API_KEY=sk-proj-your-key-here
MCP_CONFIG={}
EOF
```

**Important**: Verify `.env` is in `.gitignore` to prevent accidental commits.

### 2.3 Verify Phase III Application

Ensure the Phase III application exists and is functional:

```bash
# Check frontend directory
ls -la frontend/

# Check backend directory
ls -la backend/

# Verify package files exist
test -f frontend/package.json && echo "Frontend OK" || echo "Frontend missing"
test -f backend/requirements.txt && echo "Backend OK" || echo "Backend missing"
```

---

## Step 3: Build Docker Images

### 3.1 Build Frontend Image

```bash
# Build frontend Docker image
docker build -t todo-chatbot-frontend:latest \
  -f deployment/docker/frontend/Dockerfile \
  .

# Expected output:
# [+] Building 45.2s (12/12) FINISHED
# => [internal] load build definition from Dockerfile
# => => transferring dockerfile: 1.23kB
# => [internal] load .dockerignore
# => [stage-1 1/5] FROM docker.io/library/node:18-alpine
# ...
# => => naming to docker.io/library/todo-chatbot-frontend:latest
```

**Using Gordon (optional)**:
```bash
# Build with AI optimization
gordon build --optimize frontend/ -t todo-chatbot-frontend:latest
```

### 3.2 Build Backend Image

```bash
# Build backend Docker image
docker build -t todo-chatbot-backend:latest \
  -f deployment/docker/backend/Dockerfile \
  .

# Expected output:
# [+] Building 32.8s (10/10) FINISHED
# => [internal] load build definition from Dockerfile
# => => transferring dockerfile: 987B
# ...
# => => naming to docker.io/library/todo-chatbot-backend:latest
```

### 3.3 Verify Images

```bash
# List Docker images
docker images | grep todo-chatbot

# Expected output:
# todo-chatbot-frontend   latest   abc123def456   2 minutes ago   450MB
# todo-chatbot-backend    latest   ghi789jkl012   1 minute ago    780MB
```

---

## Step 4: Load Images into Minikube

Minikube runs in its own Docker environment, so we need to load our images:

### 4.1 Load Frontend Image

```bash
# Load frontend image into Minikube
minikube image load todo-chatbot-frontend:latest

# Expected output:
# Loading image 'todo-chatbot-frontend:latest' into minikube...
```

### 4.2 Load Backend Image

```bash
# Load backend image into Minikube
minikube image load todo-chatbot-backend:latest

# Expected output:
# Loading image 'todo-chatbot-backend:latest' into minikube...
```

### 4.3 Verify Images in Minikube

```bash
# List images in Minikube
minikube image ls | grep todo-chatbot

# Expected output:
# docker.io/library/todo-chatbot-frontend:latest
# docker.io/library/todo-chatbot-backend:latest
```

---

## Step 5: Deploy with Helm

### 5.1 Create Namespace

```bash
# Create dedicated namespace
kubectl create namespace todo-chatbot

# Expected output:
# namespace/todo-chatbot created

# Verify namespace
kubectl get namespaces | grep todo-chatbot
```

### 5.2 Create Secrets

```bash
# Load environment variables
source .env

# Create Kubernetes Secret with credentials
kubectl create secret generic todo-chatbot-secrets \
  --from-literal=databaseUrl="$DATABASE_URL" \
  --from-literal=openaiApiKey="$OPENAI_API_KEY" \
  --from-literal=mcpConfig="$MCP_CONFIG" \
  --namespace todo-chatbot

# Expected output:
# secret/todo-chatbot-secrets created

# Verify secret (values are base64 encoded)
kubectl get secret todo-chatbot-secrets -n todo-chatbot
```

### 5.3 Install Helm Chart

```bash
# Get Minikube IP for CORS configuration
MINIKUBE_IP=$(minikube ip)

# Install Helm chart with development values
helm install todo-chatbot deployment/helm/todo-chatbot \
  --namespace todo-chatbot \
  --values deployment/helm/todo-chatbot/values-dev.yaml \
  --set config.corsOrigins="http://localhost:30080,http://${MINIKUBE_IP}:30080"

# Expected output:
# NAME: todo-chatbot
# LAST DEPLOYED: Fri Feb  7 22:00:00 2026
# NAMESPACE: todo-chatbot
# STATUS: deployed
# REVISION: 1
# NOTES:
# Thank you for installing todo-chatbot!
#
# Your release is named todo-chatbot.
#
# To access the application:
#   minikube service todo-chatbot-frontend -n todo-chatbot --url
```

### 5.4 Wait for Pods to be Ready

```bash
# Watch pod status (Ctrl+C to exit)
kubectl get pods -n todo-chatbot -w

# Or wait for all pods to be ready (timeout 5 minutes)
kubectl wait --for=condition=ready pod \
  --all \
  --namespace todo-chatbot \
  --timeout=300s

# Expected output:
# pod/todo-chatbot-frontend-xxxxxxxxx-xxxxx condition met
# pod/todo-chatbot-backend-xxxxxxxxx-xxxxx condition met
```

---

## Step 6: Access the Application

### 6.1 Get Application URL

```bash
# Get frontend service URL
minikube service todo-chatbot-frontend -n todo-chatbot --url

# Expected output:
# http://192.168.49.2:30080
```

### 6.2 Open in Browser

```bash
# Open in default browser (macOS/Linux)
open $(minikube service todo-chatbot-frontend -n todo-chatbot --url)

# Or manually copy the URL and paste in browser
```

### 6.3 Verify Application

1. **Frontend loads**: You should see the Todo AI Chatbot interface
2. **Backend connectivity**: Try creating a task via the chatbot
3. **AI features**: Test natural language commands like "add a task to buy groceries"
4. **Database persistence**: Refresh the page and verify tasks persist

---

## Step 7: Verify Deployment

### 7.1 Check Pod Status

```bash
# List all pods
kubectl get pods -n todo-chatbot

# Expected output:
# NAME                                     READY   STATUS    RESTARTS   AGE
# todo-chatbot-frontend-xxxxxxxxx-xxxxx    1/1     Running   0          2m
# todo-chatbot-backend-xxxxxxxxx-xxxxx     1/1     Running   0          2m
```

### 7.2 Check Services

```bash
# List all services
kubectl get svc -n todo-chatbot

# Expected output:
# NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# todo-chatbot-frontend   NodePort    10.96.123.45    <none>        80:30080/TCP   2m
# todo-chatbot-backend    ClusterIP   10.96.234.56    <none>        8000/TCP       2m
```

### 7.3 Check Logs

```bash
# Frontend logs
kubectl logs -l app=todo-chatbot-frontend -n todo-chatbot --tail=50

# Backend logs
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=50

# Follow logs in real-time (Ctrl+C to exit)
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot -f
```

### 7.4 Test Backend Health Endpoint

```bash
# Port-forward backend service
kubectl port-forward svc/todo-chatbot-backend 8000:8000 -n todo-chatbot &

# Test health endpoint
curl http://localhost:8000/health

# Expected output:
# {"status":"healthy"}

# Stop port-forward
kill %1
```

---

## Step 8: Test Resilience (Optional)

### 8.1 Test Pod Auto-Recovery

```bash
# Delete a backend pod
kubectl delete pod -l app=todo-chatbot-backend -n todo-chatbot --force

# Watch Kubernetes recreate it
kubectl get pods -n todo-chatbot -w

# Verify application still works (may have brief downtime)
```

### 8.2 Test Scaling

```bash
# Scale frontend to 3 replicas
kubectl scale deployment todo-chatbot-frontend --replicas=3 -n todo-chatbot

# Verify scaling
kubectl get pods -n todo-chatbot -l app=todo-chatbot-frontend

# Expected output:
# NAME                                     READY   STATUS    RESTARTS   AGE
# todo-chatbot-frontend-xxxxxxxxx-xxxxx    1/1     Running   0          5m
# todo-chatbot-frontend-xxxxxxxxx-yyyyy    1/1     Running   0          10s
# todo-chatbot-frontend-xxxxxxxxx-zzzzz    1/1     Running   0          10s

# Scale back to 1
kubectl scale deployment todo-chatbot-frontend --replicas=1 -n todo-chatbot
```

---

## Step 9: AI-Assisted Operations (Optional)

### 9.1 Using kubectl-ai

```bash
# Generate deployment manifest
kubectl-ai "create a deployment for nginx with 3 replicas"

# Debug pod issues
kubectl-ai "why is my pod crashing" -n todo-chatbot

# Scale deployment
kubectl-ai "scale frontend to 5 replicas" -n todo-chatbot
```

### 9.2 Using kagent

```bash
# Analyze cluster health
kagent analyze cluster

# Optimize deployment
kagent optimize deployment todo-chatbot-frontend -n todo-chatbot

# Diagnose pod issues
kagent diagnose pod <pod-name> -n todo-chatbot
```

---

## Troubleshooting

### Issue: Pods stuck in "ImagePullBackOff"

**Symptom**: Pods show `ImagePullBackOff` status

**Cause**: Images not loaded into Minikube

**Solution**:
```bash
# Verify images in Minikube
minikube image ls | grep todo-chatbot

# If missing, load images again
minikube image load todo-chatbot-frontend:latest
minikube image load todo-chatbot-backend:latest

# Restart deployment
kubectl rollout restart deployment/todo-chatbot-frontend -n todo-chatbot
kubectl rollout restart deployment/todo-chatbot-backend -n todo-chatbot
```

### Issue: Pods stuck in "CrashLoopBackOff"

**Symptom**: Pods repeatedly crash and restart

**Cause**: Application error, missing environment variables, or database connectivity

**Solution**:
```bash
# Check pod logs for errors
kubectl logs <pod-name> -n todo-chatbot

# Check environment variables
kubectl exec <pod-name> -n todo-chatbot -- env | sort

# Verify secrets exist
kubectl get secret todo-chatbot-secrets -n todo-chatbot

# Test database connectivity from pod
kubectl exec <backend-pod-name> -n todo-chatbot -- \
  python -c "import psycopg2; psycopg2.connect('$DATABASE_URL')"
```

### Issue: Frontend cannot connect to backend

**Symptom**: API requests fail with connection errors

**Cause**: Incorrect backend service URL or CORS configuration

**Solution**:
```bash
# Check ConfigMap
kubectl get configmap todo-chatbot-config -n todo-chatbot -o yaml

# Verify backend service DNS
kubectl exec <frontend-pod-name> -n todo-chatbot -- \
  nslookup todo-chatbot-backend

# Test backend connectivity from frontend pod
kubectl exec <frontend-pod-name> -n todo-chatbot -- \
  curl http://todo-chatbot-backend:8000/health
```

### Issue: Cannot access application from browser

**Symptom**: Browser shows "connection refused" or timeout

**Cause**: Minikube service not exposed or firewall blocking

**Solution**:
```bash
# Verify service type is NodePort
kubectl get svc todo-chatbot-frontend -n todo-chatbot

# Get correct URL
minikube service todo-chatbot-frontend -n todo-chatbot --url

# Try tunnel (alternative method)
minikube tunnel

# Then access via: http://localhost:80
```

### Issue: Insufficient resources

**Symptom**: Pods stuck in "Pending" state

**Cause**: Minikube doesn't have enough CPU/memory

**Solution**:
```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n todo-chatbot

# Increase Minikube resources (requires restart)
minikube stop
minikube start --cpus=4 --memory=8192

# Or reduce replica counts in values-dev.yaml
```

---

## Cleanup

### Uninstall Application

```bash
# Uninstall Helm release
helm uninstall todo-chatbot -n todo-chatbot

# Delete namespace (removes all resources)
kubectl delete namespace todo-chatbot

# Verify cleanup
kubectl get all -n todo-chatbot
# Expected: No resources found
```

### Stop Minikube

```bash
# Stop Minikube cluster
minikube stop

# Delete Minikube cluster (removes all data)
minikube delete
```

### Remove Docker Images

```bash
# Remove local Docker images
docker rmi todo-chatbot-frontend:latest
docker rmi todo-chatbot-backend:latest
```

---

## Next Steps

After successful deployment:

1. **Explore Scaling**: Try scaling replicas up and down
2. **Test Resilience**: Delete pods and watch auto-recovery
3. **Monitor Resources**: Use `kubectl top` to monitor resource usage
4. **Update Configuration**: Try `helm upgrade` with different values
5. **Experiment with AI Tools**: Use kubectl-ai and kagent for operations

---

## Quick Reference Commands

```bash
# Start Minikube
minikube start --cpus=2 --memory=4096

# Build and load images
docker build -t todo-chatbot-frontend:latest -f deployment/docker/frontend/Dockerfile .
docker build -t todo-chatbot-backend:latest -f deployment/docker/backend/Dockerfile .
minikube image load todo-chatbot-frontend:latest
minikube image load todo-chatbot-backend:latest

# Deploy
kubectl create namespace todo-chatbot
kubectl create secret generic todo-chatbot-secrets --from-env-file=.env -n todo-chatbot
helm install todo-chatbot deployment/helm/todo-chatbot -n todo-chatbot -f deployment/helm/todo-chatbot/values-dev.yaml

# Access
minikube service todo-chatbot-frontend -n todo-chatbot --url

# Monitor
kubectl get pods -n todo-chatbot -w
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot -f

# Cleanup
helm uninstall todo-chatbot -n todo-chatbot
kubectl delete namespace todo-chatbot
minikube stop
```

---

## Support

For issues or questions:
- Check logs: `kubectl logs <pod-name> -n todo-chatbot`
- Describe resources: `kubectl describe pod <pod-name> -n todo-chatbot`
- Review documentation in `specs/004-minikube-deployment/`
- Consult Phase IV constitution principles in `.specify/memory/constitution.md`
