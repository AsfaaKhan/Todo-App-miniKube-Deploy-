# Data Model: Cloud-Native Deployment Entities

**Feature**: Cloud-Native Deployment on Minikube
**Date**: 2026-02-07
**Purpose**: Define the deployment entities, their relationships, and configuration schema

## Overview

This data model describes the infrastructure entities involved in deploying the Todo AI Chatbot to Kubernetes. Unlike application data models that describe business entities, this model describes deployment artifacts, their configurations, and relationships.

## Deployment Entities

### 1. Docker Image

**Purpose**: Containerized application artifact that packages code, dependencies, and runtime

**Frontend Image**:
- **Name**: `todo-chatbot-frontend`
- **Tag**: `latest` (or semantic version like `1.0.0`)
- **Base**: `node:18-alpine`
- **Size Target**: < 500MB
- **Layers**:
  - Base OS and Node.js runtime
  - Application dependencies (node_modules)
  - Application source code
  - Build artifacts (Next.js production bundle)
- **Entry Point**: `npm start` or `node server.js`
- **Exposed Ports**: 3000
- **Build Context**: Repository root (includes frontend/ directory)

**Backend Image**:
- **Name**: `todo-chatbot-backend`
- **Tag**: `latest` (or semantic version like `1.0.0`)
- **Base**: `python:3.11-slim`
- **Size Target**: < 800MB
- **Layers**:
  - Base OS and Python runtime
  - System dependencies
  - Python packages (from requirements.txt)
  - Application source code
- **Entry Point**: `uvicorn main:app --host 0.0.0.0 --port 8000`
- **Exposed Ports**: 8000
- **Build Context**: Repository root (includes backend/ directory)

**Relationships**:
- Images are loaded into Minikube's local registry
- Referenced by Kubernetes Deployments via image name and tag
- Built from source code in frontend/ and backend/ directories

---

### 2. Kubernetes Namespace

**Purpose**: Logical isolation boundary for all deployment resources

**Attributes**:
- **Name**: `todo-chatbot`
- **Labels**:
  - `app`: `todo-chatbot`
  - `environment`: `dev` or `prod`
  - `managed-by`: `helm`

**Relationships**:
- Contains all Deployments, Services, ConfigMaps, Secrets
- Provides resource quota boundaries
- Enables RBAC policies scoped to namespace

---

### 3. Kubernetes Deployment

**Purpose**: Manages pod replicas, rolling updates, and desired state

**Frontend Deployment**:
- **Name**: `todo-chatbot-frontend`
- **Replicas**: 2 (configurable)
- **Selector**: `app=todo-chatbot-frontend`
- **Pod Template**:
  - **Labels**: `app=todo-chatbot-frontend`, `version=1.0.0`
  - **Container Name**: `frontend`
  - **Image**: `todo-chatbot-frontend:latest`
  - **Ports**: 3000
  - **Environment Variables**:
    - `NEXT_PUBLIC_API_URL`: From ConfigMap
    - `NODE_ENV`: `production`
    - `PORT`: `3000`
  - **Resource Requests**: 256Mi memory, 250m CPU
  - **Resource Limits**: 512Mi memory, 500m CPU
  - **Liveness Probe**: HTTP GET `/api/health` (30s interval, 3 failures)
  - **Readiness Probe**: HTTP GET `/api/health` (10s interval, 3 failures)
- **Strategy**: RollingUpdate (maxSurge: 1, maxUnavailable: 0)
- **Restart Policy**: Always

**Backend Deployment**:
- **Name**: `todo-chatbot-backend`
- **Replicas**: 2 (configurable)
- **Selector**: `app=todo-chatbot-backend`
- **Pod Template**:
  - **Labels**: `app=todo-chatbot-backend`, `version=1.0.0`
  - **Container Name**: `backend`
  - **Image**: `todo-chatbot-backend:latest`
  - **Ports**: 8000
  - **Environment Variables**:
    - `DATABASE_URL`: From Secret
    - `OPENAI_API_KEY`: From Secret
    - `MCP_CONFIG`: From Secret
    - `CORS_ORIGINS`: From ConfigMap
    - `LOG_LEVEL`: From ConfigMap
  - **Resource Requests**: 512Mi memory, 500m CPU
  - **Resource Limits**: 1Gi memory, 1000m CPU
  - **Liveness Probe**: HTTP GET `/health` (30s interval, 3 failures)
  - **Readiness Probe**: HTTP GET `/health` (10s interval, 3 failures)
- **Strategy**: RollingUpdate (maxSurge: 1, maxUnavailable: 0)
- **Restart Policy**: Always

**Relationships**:
- Creates and manages Pods based on template
- References ConfigMap for non-sensitive configuration
- References Secret for sensitive configuration
- Selected by Service for traffic routing

---

### 4. Kubernetes Service

**Purpose**: Stable network endpoint for accessing pods

**Frontend Service**:
- **Name**: `todo-chatbot-frontend`
- **Type**: NodePort
- **Selector**: `app=todo-chatbot-frontend`
- **Ports**:
  - **Port**: 80 (service port)
  - **TargetPort**: 3000 (container port)
  - **NodePort**: 30080 (external access port)
- **Session Affinity**: None (stateless)
- **DNS**: `todo-chatbot-frontend.todo-chatbot.svc.cluster.local`

**Backend Service**:
- **Name**: `todo-chatbot-backend`
- **Type**: ClusterIP (internal only)
- **Selector**: `app=todo-chatbot-backend`
- **Ports**:
  - **Port**: 8000 (service port)
  - **TargetPort**: 8000 (container port)
- **Session Affinity**: None (stateless)
- **DNS**: `todo-chatbot-backend.todo-chatbot.svc.cluster.local`

**Relationships**:
- Routes traffic to Deployment pods via selector
- Frontend Service accessible from host via NodePort
- Backend Service accessible only within cluster
- Frontend pods connect to backend via backend Service DNS

---

### 5. ConfigMap

**Purpose**: Store non-sensitive configuration data

**Name**: `todo-chatbot-config`

**Data**:
```yaml
BACKEND_SERVICE_URL: "http://todo-chatbot-backend:8000"
CORS_ORIGINS: "http://localhost:30080,http://192.168.49.2:30080"
LOG_LEVEL: "info"
FEATURE_FLAGS: "{}"
NODE_ENV: "production"
```

**Relationships**:
- Mounted as environment variables in Deployments
- Updated via Helm upgrade
- Changes trigger pod restart (if configured)

---

### 6. Secret

**Purpose**: Store sensitive configuration data (encrypted at rest)

**Name**: `todo-chatbot-secrets`

**Type**: Opaque

**Data** (base64 encoded):
- `DATABASE_URL`: PostgreSQL connection string
- `OPENAI_API_KEY`: OpenAI API key
- `MCP_CONFIG`: MCP server configuration JSON
- `JWT_SECRET`: Authentication token secret (if applicable)

**Relationships**:
- Mounted as environment variables in backend Deployment
- Created manually or via Helm values
- Never committed to Git
- Rotated independently of application deployment

---

### 7. Helm Chart

**Purpose**: Package and template all Kubernetes resources

**Metadata**:
- **Name**: `todo-chatbot`
- **Version**: 1.0.0 (chart version)
- **AppVersion**: 1.0.0 (application version)
- **Type**: application
- **Description**: "Todo AI Chatbot - Cloud-Native Deployment"

**Files**:
- `Chart.yaml`: Chart metadata
- `values.yaml`: Default configuration values
- `values-dev.yaml`: Development overrides
- `values-prod.yaml`: Production overrides
- `templates/`: Kubernetes manifest templates
- `.helmignore`: Files to exclude from chart package

**Templates**:
- `_helpers.tpl`: Reusable template functions
- `frontend-deployment.yaml`: Frontend Deployment manifest
- `frontend-service.yaml`: Frontend Service manifest
- `backend-deployment.yaml`: Backend Deployment manifest
- `backend-service.yaml`: Backend Service manifest
- `configmap.yaml`: ConfigMap manifest
- `secret.yaml`: Secret manifest (optional, prefer kubectl create)
- `NOTES.txt`: Post-installation instructions

**Relationships**:
- Packages all Kubernetes resources as templates
- Values files provide configuration for different environments
- Installed/upgraded/uninstalled as atomic unit
- Tracks release history and enables rollback

---

## Entity Relationships Diagram

```
┌─────────────────┐
│   Helm Chart    │
│  (todo-chatbot) │
└────────┬────────┘
         │ installs/manages
         ▼
┌─────────────────────────────────────────────────────┐
│              Kubernetes Namespace                    │
│              (todo-chatbot)                          │
│                                                      │
│  ┌──────────────┐         ┌──────────────┐         │
│  │  ConfigMap   │         │    Secret    │         │
│  │              │         │              │         │
│  └──────┬───────┘         └──────┬───────┘         │
│         │                        │                  │
│         │ provides config        │ provides secrets │
│         │                        │                  │
│  ┌──────▼────────────────────────▼──────┐          │
│  │     Frontend Deployment               │          │
│  │  ┌─────────────────────────────┐     │          │
│  │  │  Pod (replica 1)            │     │          │
│  │  │  ┌─────────────────────┐    │     │          │
│  │  │  │ Frontend Container  │    │     │          │
│  │  │  │ (Docker Image)      │    │     │          │
│  │  │  └─────────────────────┘    │     │          │
│  │  └─────────────────────────────┘     │          │
│  │  ┌─────────────────────────────┐     │          │
│  │  │  Pod (replica 2)            │     │          │
│  │  └─────────────────────────────┘     │          │
│  └───────────────┬───────────────────────┘          │
│                  │ selected by                      │
│  ┌───────────────▼───────────────┐                 │
│  │   Frontend Service            │                 │
│  │   (NodePort: 30080)           │                 │
│  └───────────────────────────────┘                 │
│                                                      │
│  ┌──────▼────────────────────────▼──────┐          │
│  │     Backend Deployment                │          │
│  │  ┌─────────────────────────────┐     │          │
│  │  │  Pod (replica 1)            │     │          │
│  │  │  ┌─────────────────────┐    │     │          │
│  │  │  │ Backend Container   │    │     │          │
│  │  │  │ (Docker Image)      │    │     │          │
│  │  │  └─────────────────────┘    │     │          │
│  │  └─────────────────────────────┘     │          │
│  │  ┌─────────────────────────────┐     │          │
│  │  │  Pod (replica 2)            │     │          │
│  │  └─────────────────────────────┘     │          │
│  └───────────────┬───────────────────────┘          │
│                  │ selected by                      │
│  ┌───────────────▼───────────────┐                 │
│  │   Backend Service             │                 │
│  │   (ClusterIP: 8000)           │                 │
│  └───────────────────────────────┘                 │
│                                                      │
└─────────────────────────────────────────────────────┘
         │                        │
         │ connects to            │ connects to
         ▼                        ▼
┌─────────────────┐      ┌─────────────────┐
│  Host Machine   │      │ External Neon   │
│  (via NodePort) │      │   PostgreSQL    │
└─────────────────┘      └─────────────────┘
```

---

## Configuration Schema

### Helm Values Schema

**Root Level**:
- `replicaCount`: Object with frontend/backend replica counts
- `image`: Object with frontend/backend image configurations
- `service`: Object with frontend/backend service configurations
- `resources`: Object with frontend/backend resource limits
- `config`: Object with application configuration
- `secrets`: Object with sensitive configuration (provided at deployment)

**Validation Rules**:
- `replicaCount.frontend`: Integer, min: 1, max: 10
- `replicaCount.backend`: Integer, min: 1, max: 10
- `image.*.repository`: String, required
- `image.*.tag`: String, required
- `image.*.pullPolicy`: Enum [Always, IfNotPresent, Never]
- `service.frontend.type`: Enum [NodePort, LoadBalancer]
- `service.frontend.nodePort`: Integer, range: 30000-32767
- `service.backend.type`: Must be ClusterIP
- `resources.*.requests.memory`: String with unit (e.g., "256Mi")
- `resources.*.requests.cpu`: String with unit (e.g., "250m")
- `resources.*.limits.memory`: String with unit, must be >= requests
- `resources.*.limits.cpu`: String with unit, must be >= requests
- `secrets.databaseUrl`: String, required, must start with "postgresql://"
- `secrets.openaiApiKey`: String, required, must start with "sk-"

---

## State Transitions

### Deployment Lifecycle

**States**:
1. **Not Deployed**: No resources exist in cluster
2. **Installing**: Helm is creating resources
3. **Deployed**: All resources created, pods may be starting
4. **Running**: All pods healthy and ready
5. **Degraded**: Some pods unhealthy or not ready
6. **Upgrading**: Helm is updating resources
7. **Uninstalling**: Helm is deleting resources

**Transitions**:
- Not Deployed → Installing: `helm install`
- Installing → Deployed: Resources created successfully
- Deployed → Running: All pods pass readiness probes
- Running → Degraded: Pod crashes or fails health check
- Degraded → Running: Pod restarts and becomes healthy
- Running → Upgrading: `helm upgrade`
- Upgrading → Running: Rolling update completes successfully
- Running → Uninstalling: `helm uninstall`
- Uninstalling → Not Deployed: All resources deleted

### Pod Lifecycle

**States**:
1. **Pending**: Pod created, waiting for scheduling
2. **ContainerCreating**: Pulling image, creating container
3. **Running**: Container started, may not be ready
4. **Ready**: Container running and passed readiness probe
5. **Terminating**: Pod being gracefully shut down
6. **Failed**: Container exited with error
7. **CrashLoopBackOff**: Container repeatedly crashing

**Transitions**:
- Pending → ContainerCreating: Scheduled to node
- ContainerCreating → Running: Container started
- Running → Ready: Passed readiness probe
- Ready → Terminating: Pod deleted or deployment scaled down
- Running → Failed: Container exited with non-zero code
- Failed → Pending: Restart policy triggers new pod
- Failed → CrashLoopBackOff: Multiple rapid failures

---

## Data Validation

### Image Tags
- Must follow semantic versioning or be "latest"
- Must exist in Minikube's local registry before deployment
- Should be immutable (don't reuse tags for different images)

### Resource Limits
- Requests must be less than or equal to limits
- Total requests must fit within Minikube's available resources
- Recommended: requests = 50-75% of limits for burstable QoS

### Environment Variables
- DATABASE_URL must be valid PostgreSQL connection string
- OPENAI_API_KEY must be valid OpenAI API key format
- Service URLs must use cluster DNS format for internal communication
- No secrets in ConfigMap (only in Secret)

### Service Configuration
- Frontend NodePort must be in range 30000-32767
- Backend must use ClusterIP (not exposed externally)
- Service selectors must match Deployment labels exactly
- Port numbers must not conflict with other services

---

## Dependencies

**External Dependencies**:
- Neon PostgreSQL database (must be accessible from Minikube)
- OpenAI API (must be accessible from Minikube)
- Docker Hub or local registry (for base images)

**Internal Dependencies**:
- Frontend depends on Backend Service DNS resolution
- Backend depends on Secret containing database credentials
- All pods depend on ConfigMap for non-sensitive configuration
- Services depend on Deployments creating pods with matching labels

**Deployment Order**:
1. Namespace (first)
2. ConfigMap and Secret (before Deployments)
3. Deployments (creates pods)
4. Services (after Deployments, but can be concurrent)

---

## Scalability Considerations

**Horizontal Scaling**:
- Frontend: Stateless, scales linearly (1-10 replicas)
- Backend: Stateless, scales linearly (1-10 replicas)
- Database: External, not scaled by this deployment

**Resource Scaling**:
- Increase replica count for more throughput
- Increase resource limits for more per-pod capacity
- Monitor with `kubectl top pods` to identify bottlenecks

**Limitations**:
- Minikube single-node limits total resources
- No persistent volumes (stateless design)
- No horizontal pod autoscaling (manual scaling only)
