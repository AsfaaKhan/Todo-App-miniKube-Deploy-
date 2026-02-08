# Todo AI Chatbot - Kubernetes Deployment

This directory contains all deployment artifacts for running the Todo AI Chatbot on a local Kubernetes cluster using Minikube.

## Overview

The deployment uses:
- **Docker** for containerization (frontend and backend)
- **Minikube** for local Kubernetes cluster
- **Helm** for declarative infrastructure management
- **kubectl** for Kubernetes operations

## Prerequisites

Before deploying, ensure you have:

1. **Docker Desktop** (v20.x or later)
   - Running and accessible
   - Verify: `docker --version` and `docker ps`

2. **Minikube** (v1.30.x or later)
   - Installed and configured
   - Verify: `minikube version`

3. **kubectl** (v1.24.x or later)
   - Installed and configured
   - Verify: `kubectl version --client`

4. **Helm** (v3.x)
   - Installed
   - Verify: `helm version`

5. **System Resources**
   - Minimum 8GB RAM (4GB allocated to Minikube)
   - Minimum 4 CPU cores (2 allocated to Minikube)
   - Minimum 20GB free disk space

6. **Credentials**
   - Neon PostgreSQL database connection string
   - OpenAI API key with credits

## Directory Structure

```
deployment/
├── docker/
│   ├── frontend/          # Frontend Dockerfile and build context
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   └── entrypoint.sh
│   └── backend/           # Backend Dockerfile and build context
│       ├── Dockerfile
│       ├── .dockerignore
│       └── entrypoint.sh
│
├── helm/
│   └── todo-chatbot/      # Helm chart for Kubernetes deployment
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       ├── templates/     # Kubernetes manifest templates
│       └── .helmignore
│
├── kubernetes/
│   └── namespace.yaml     # Namespace definition
│
├── scripts/               # Automation scripts
│   ├── build-images.sh
│   ├── load-images-minikube.sh
│   ├── deploy.sh
│   ├── undeploy.sh
│   ├── scale.sh
│   └── test-deployment.sh
│
├── docs/                  # Additional documentation
│   ├── ai-tools.md
│   ├── kubectl-ai-examples.md
│   ├── kagent-examples.md
│   └── troubleshooting.md
│
└── README.md             # This file
```

## Quick Start

See the comprehensive quickstart guide at:
`specs/004-minikube-deployment/quickstart.md`

### Basic Deployment Steps

1. **Start Minikube**
   ```bash
   minikube start --cpus=2 --memory=4096
   ```

2. **Build Docker Images**
   ```bash
   ./deployment/scripts/build-images.sh
   ```

3. **Load Images into Minikube**
   ```bash
   ./deployment/scripts/load-images-minikube.sh
   ```

4. **Deploy with Helm**
   ```bash
   ./deployment/scripts/deploy.sh
   ```

5. **Access Application**
   ```bash
   minikube service todo-chatbot-frontend -n todo-chatbot --url
   ```

## Configuration

### Environment Variables

Required environment variables must be provided at deployment time:

- `DATABASE_URL`: PostgreSQL connection string
- `OPENAI_API_KEY`: OpenAI API key
- `MCP_CONFIG`: MCP server configuration (optional)

See `.env.example` in the repository root for the template.

### Helm Values

Customize deployment by editing values files:

- `values.yaml`: Default configuration
- `values-dev.yaml`: Development overrides (lower resources, debug logging)
- `values-prod.yaml`: Production overrides (higher replicas, stricter limits)

## Deployment Scripts

### build-images.sh
Builds Docker images for frontend and backend.

### load-images-minikube.sh
Loads built images into Minikube's local registry.

### deploy.sh
Deploys the application using Helm charts.

### undeploy.sh
Removes the deployment and cleans up resources.

### scale.sh
Scales frontend/backend replicas up or down.

### test-deployment.sh
Runs resilience tests (pod restart, scaling).

## Resource Monitoring

Monitor resource usage of your deployed pods:

### View Pod Resource Usage

```bash
# Enable metrics-server in Minikube (if not already enabled)
minikube addons enable metrics-server

# Wait a few seconds for metrics to be collected, then view pod resource usage
kubectl top pods -n todo-chatbot

# Expected output:
# NAME                                      CPU(cores)   MEMORY(bytes)
# todo-chatbot-backend-xxxxx-xxxxx          50m          450Mi
# todo-chatbot-backend-xxxxx-yyyyy          48m          445Mi
# todo-chatbot-frontend-xxxxx-xxxxx         25m          180Mi
# todo-chatbot-frontend-xxxxx-yyyyy         23m          175Mi
```

### View Node Resource Usage

```bash
# View node resource usage
kubectl top nodes

# Expected output:
# NAME       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
# minikube   500m         25%    2048Mi          51%
```

### Monitor Resource Limits

```bash
# Check configured resource requests and limits
kubectl describe deployment todo-chatbot-frontend -n todo-chatbot | grep -A 5 "Limits\|Requests"
kubectl describe deployment todo-chatbot-backend -n todo-chatbot | grep -A 5 "Limits\|Requests"
```

### Continuous Monitoring

```bash
# Watch pod resource usage in real-time
watch -n 2 kubectl top pods -n todo-chatbot

# Watch pod status in real-time
kubectl get pods -n todo-chatbot -w
```

## Horizontal Scaling

Scale your deployment up or down based on load:

### Using the Scale Script

```bash
# Scale frontend to 3 replicas
./deployment/scripts/scale.sh frontend 3

# Scale backend to 5 replicas
./deployment/scripts/scale.sh backend 5

# Scale both to 2 replicas
./deployment/scripts/scale.sh all 2
```

### Using kubectl Directly

```bash
# Scale frontend deployment
kubectl scale deployment todo-chatbot-frontend --replicas=3 -n todo-chatbot

# Scale backend deployment
kubectl scale deployment todo-chatbot-backend --replicas=5 -n todo-chatbot

# Verify scaling
kubectl get pods -n todo-chatbot
```

### Using Helm Upgrade

```bash
# Update replica count via Helm values
helm upgrade todo-chatbot deployment/helm/todo-chatbot \
  -n todo-chatbot \
  --set replicaCount.frontend=3 \
  --set replicaCount.backend=5
```

### Scaling Considerations

- **Minimum replicas**: 1 (for development/testing)
- **Recommended replicas**: 2 (for high availability)
- **Maximum replicas**: Limited by Minikube resources (typically 5-10)
- **Resource requirements**: Each replica consumes CPU and memory as defined in values.yaml
- **Stateless design**: Application is stateless, so scaling is seamless

## Troubleshooting

Common issues and solutions:

### Pods stuck in ImagePullBackOff
- Verify images are loaded into Minikube: `minikube image ls | grep todo-chatbot`
- Reload images: `./deployment/scripts/load-images-minikube.sh`

### Pods stuck in CrashLoopBackOff
- Check logs: `kubectl logs <pod-name> -n todo-chatbot`
- Verify environment variables: `kubectl get secret todo-chatbot-secrets -n todo-chatbot`
- Test database connectivity from pod

### Cannot access application
- Get correct URL: `minikube service todo-chatbot-frontend -n todo-chatbot --url`
- Verify service type is NodePort: `kubectl get svc -n todo-chatbot`
- Try tunnel: `minikube tunnel`

For more troubleshooting, see `deployment/docs/troubleshooting.md`

## AI-Assisted DevOps (Optional)

This deployment supports AI-powered tools for enhanced DevOps workflows:

- **kubectl-ai**: Natural language Kubernetes operations
- **kagent**: AI-powered cluster analysis
- **Gordon**: Docker AI Agent for image optimization

See `deployment/docs/ai-tools.md` for installation and usage.

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         User's Browser                          │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Minikube Cluster                           │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Namespace: todo-chatbot                     │  │
│  │                                                          │  │
│  │  ┌────────────────────────────────────────────────┐     │  │
│  │  │  Frontend Service (NodePort :30080)           │     │  │
│  │  │  Exposes: http://<minikube-ip>:30080          │     │  │
│  │  └──────────────┬─────────────────────────────────┘     │  │
│  │                 │                                        │  │
│  │                 ▼                                        │  │
│  │  ┌────────────────────────────────────────────────┐     │  │
│  │  │  Frontend Deployment (2 replicas)             │     │  │
│  │  │  ┌──────────────┐  ┌──────────────┐           │     │  │
│  │  │  │ Frontend Pod │  │ Frontend Pod │           │     │  │
│  │  │  │ Next.js:3000 │  │ Next.js:3000 │           │     │  │
│  │  │  │ 256Mi/250m   │  │ 256Mi/250m   │           │     │  │
│  │  │  └──────┬───────┘  └──────┬───────┘           │     │  │
│  │  └─────────┼──────────────────┼───────────────────┘     │  │
│  │            │                  │                          │  │
│  │            └──────────┬───────┘                          │  │
│  │                       │ Internal HTTP                    │  │
│  │                       ▼                                  │  │
│  │  ┌────────────────────────────────────────────────┐     │  │
│  │  │  Backend Service (ClusterIP :8000)            │     │  │
│  │  │  DNS: todo-chatbot-backend.todo-chatbot.svc   │     │  │
│  │  └──────────────┬─────────────────────────────────┘     │  │
│  │                 │                                        │  │
│  │                 ▼                                        │  │
│  │  ┌────────────────────────────────────────────────┐     │  │
│  │  │  Backend Deployment (2 replicas)              │     │  │
│  │  │  ┌──────────────┐  ┌──────────────┐           │     │  │
│  │  │  │ Backend Pod  │  │ Backend Pod  │           │     │  │
│  │  │  │ FastAPI:8000 │  │ FastAPI:8000 │           │     │  │
│  │  │  │ 512Mi/500m   │  │ 512Mi/500m   │           │     │  │
│  │  │  └──────┬───────┘  └──────┬───────┘           │     │  │
│  │  └─────────┼──────────────────┼───────────────────┘     │  │
│  │            │                  │                          │  │
│  │            └──────────┬───────┘                          │  │
│  │                       │                                  │  │
│  │  ┌────────────────────┴────────────────────────────┐    │  │
│  │  │         ConfigMap: todo-chatbot-config         │    │  │
│  │  │  - BACKEND_SERVICE_URL                         │    │  │
│  │  │  - CORS_ORIGINS                                │    │  │
│  │  │  - LOG_LEVEL                                   │    │  │
│  │  └────────────────────────────────────────────────┘    │  │
│  │                                                         │  │
│  │  ┌────────────────────────────────────────────────┐    │  │
│  │  │         Secret: todo-chatbot-secrets           │    │  │
│  │  │  - DATABASE_URL (encrypted)                    │    │  │
│  │  │  - OPENAI_API_KEY (encrypted)                  │    │  │
│  │  │  - MCP_CONFIG (encrypted)                      │    │  │
│  │  └────────────────────────────────────────────────┘    │  │
│  │                                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                │
└────────────────────────────┬───────────────────────────────────┘
                             │ External Network
                             ▼
                  ┌──────────────────────┐
                  │  Neon PostgreSQL DB  │
                  │  (External Service)  │
                  └──────────────────────┘
```

### Component Details

- **Frontend**: Next.js application in Node.js Alpine container
- **Backend**: FastAPI application in Python 3.11-slim container
- **Services**: Frontend (NodePort), Backend (ClusterIP)
- **Configuration**: ConfigMap (non-sensitive), Secret (sensitive)
- **Scaling**: Horizontal pod autoscaling supported
- **Resilience**: Automatic pod restart, rolling updates

### Key Features

- **High Availability**: Multiple replicas per service
- **Load Balancing**: Kubernetes service load balancing
- **Health Checks**: Liveness and readiness probes
- **Resource Management**: CPU and memory limits
- **Rolling Updates**: Zero-downtime deployments
- **Auto-Recovery**: Failed pods restart automatically

## Support

For detailed documentation:
- Quickstart: `specs/004-minikube-deployment/quickstart.md`
- Planning: `specs/004-minikube-deployment/plan.md`
- Data Model: `specs/004-minikube-deployment/data-model.md`
- Environment Variables: `specs/004-minikube-deployment/contracts/environment-variables.md`

## License

See repository root for license information.
