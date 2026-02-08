# Implementation Plan: Cloud-Native Deployment on Minikube

**Branch**: `004-minikube-deployment` | **Date**: 2026-02-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-minikube-deployment/spec.md`

## Summary

Deploy the Phase III Todo AI Chatbot as a fully containerized, cloud-native application on a local Kubernetes cluster using Minikube. The deployment will use Docker for containerization, Helm for declarative infrastructure management, and AI-assisted DevOps tools (kubectl-ai, kagent, Gordon) to accelerate deployment workflows. The system must maintain 100% feature parity with the non-containerized version while adding cloud-native capabilities including horizontal scaling, automatic pod recovery, and reproducible deployments.

## Technical Context

**Language/Version**:
- Frontend: Node.js (version from Phase III Next.js app)
- Backend: Python 3.11+ (FastAPI from Phase III)

**Primary Dependencies**:
- Docker Desktop (container runtime)
- Minikube (local Kubernetes cluster)
- Helm 3.x (package manager)
- kubectl CLI (Kubernetes control)
- kubectl-ai (optional AI-assisted Kubernetes operations)
- kagent (optional AI cluster analysis)
- Gordon/Docker AI Agent (optional AI-assisted image building)

**Storage**:
- External Neon PostgreSQL (accessed from pods via network)
- No in-cluster database deployment

**Testing**:
- Deployment validation (pod health checks, service connectivity)
- End-to-end chatbot functionality testing
- Resilience testing (pod restart, scaling operations)
- Reproducibility testing (multiple deploy/undeploy cycles)

**Target Platform**:
- Local Kubernetes cluster via Minikube
- Runs on developer workstations (Windows/macOS/Linux)

**Project Type**:
- Infrastructure/Deployment (Helm charts, Dockerfiles, Kubernetes manifests)
- Deploys existing web application (frontend + backend)

**Performance Goals**:
- Deployment completes in under 10 minutes
- Pod startup time under 2 minutes
- Pod recovery time under 60 seconds
- Zero downtime during rolling updates with multiple replicas

**Constraints**:
- Must work on local Minikube (not cloud Kubernetes)
- External database only (no in-cluster PostgreSQL)
- Minimum 4GB RAM, 2 CPUs allocated to Minikube
- No hardcoded secrets or environment-specific values
- Must support AI tool fallbacks (Gordon optional, kubectl-ai optional)

**Scale/Scope**:
- 2 services (frontend, backend)
- Support 1-5 replicas per service
- Single namespace deployment
- Local development/testing scale (not production load)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Phase IV Principles Compliance

✅ **Spec-Driven Infrastructure**: All infrastructure begins with written spec (spec.md completed and validated)

✅ **AI-First DevOps**: Plan includes kubectl-ai, kagent, and Gordon integration with fallback strategies

✅ **Cloud-Native Architecture**:
- Containerized services (Docker images for frontend/backend)
- Declarative deployments (Helm charts)
- Helm-based package management
- Stateless application design (external database)
- Horizontally scalable workloads (configurable replicas)
- Environment-driven configuration (ConfigMaps, Secrets)

✅ **Service Separation**: Frontend and backend in separate containers and Kubernetes Deployments

✅ **Reproducibility**: Helm charts as single source of truth, no hardcoded values

✅ **Reliability & Observability**:
- Kubernetes restart policies for self-healing
- Resource requests and limits
- AI tools for diagnostics (kagent)

✅ **Security & Configuration**:
- Environment-based secrets (Kubernetes Secrets)
- No hardcoded credentials
- Least-privilege access patterns

### Technology Governance Compliance

✅ **Mandatory Stack**:
- Docker Desktop ✓
- Docker AI Agent (Gordon) - optional with fallback ✓
- Kubernetes via Minikube ✓
- Helm Charts ✓
- kubectl-ai - optional ✓
- kagent - optional ✓

✅ **Application Source**: Phase III Todo AI Chatbot preserved with full functionality

### Definition of Done Alignment

- ✅ Frontend and backend containerized → FR-001, FR-002
- ✅ Helm charts deploy successfully → FR-003, FR-014
- ✅ Application accessible via Minikube → FR-005, SC-001
- ✅ Pods healthy and scalable → FR-006, FR-007, SC-006, SC-007
- ✅ AI tools assist deployment → FR-012, FR-013, SC-010
- ✅ Chatbot works without regression → FR-009, SC-002
- ✅ Deployment reproducible → FR-010, FR-014, SC-004, SC-008

**Gate Status**: ✅ PASS - All Phase IV principles satisfied, no violations

## Project Structure

### Documentation (this feature)

```text
specs/004-minikube-deployment/
├── plan.md              # This file (/sp.plan command output)
├── spec.md              # Feature specification (completed)
├── research.md          # Phase 0 output (deployment patterns, best practices)
├── data-model.md        # Phase 1 output (deployment entities and relationships)
├── quickstart.md        # Phase 1 output (deployment guide)
├── contracts/           # Phase 1 output (Helm values schema, environment variables)
│   ├── helm-values-schema.yaml
│   └── environment-variables.md
├── checklists/
│   └── requirements.md  # Quality validation (completed)
└── tasks.md             # Phase 2 output (/sp.tasks command - NOT created by /sp.plan)
```

### Deployment Artifacts (repository root)

```text
deployment/
├── docker/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   └── entrypoint.sh
│   └── backend/
│       ├── Dockerfile
│       ├── .dockerignore
│       └── entrypoint.sh
│
├── helm/
│   └── todo-chatbot/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       ├── templates/
│       │   ├── _helpers.tpl
│       │   ├── frontend-deployment.yaml
│       │   ├── frontend-service.yaml
│       │   ├── backend-deployment.yaml
│       │   ├── backend-service.yaml
│       │   ├── configmap.yaml
│       │   ├── secret.yaml
│       │   └── NOTES.txt
│       └── .helmignore
│
├── kubernetes/
│   ├── namespace.yaml
│   └── README.md
│
└── scripts/
    ├── build-images.sh
    ├── load-images-minikube.sh
    ├── deploy.sh
    ├── undeploy.sh
    ├── scale.sh
    └── test-deployment.sh
```

### Existing Application Structure (Phase III)

```text
frontend/                 # Next.js application (Phase III)
├── src/
├── public/
├── package.json
└── next.config.js

backend/                  # FastAPI application (Phase III)
├── src/
├── requirements.txt
└── main.py

.env.example             # Environment variable template
README.md                # Project documentation
```

**Structure Decision**:

This is an infrastructure feature that adds deployment capabilities to the existing Phase III application. The deployment artifacts are organized in a dedicated `deployment/` directory to separate infrastructure concerns from application code. This structure follows cloud-native best practices:

1. **docker/**: Contains Dockerfiles and build context for each service
2. **helm/**: Contains Helm chart with all Kubernetes manifests as templates
3. **kubernetes/**: Contains cluster-level resources (namespace)
4. **scripts/**: Contains automation scripts for common deployment operations

The existing `frontend/` and `backend/` directories remain unchanged, preserving Phase III functionality. Dockerfiles reference these directories as build context.

## Deployment Architecture

### Container Strategy

**Frontend Container**:
- Base image: `node:18-alpine` (lightweight, production-ready)
- Build stage: Install dependencies, build Next.js production bundle
- Runtime stage: Serve static files and SSR with Next.js server
- Exposed port: 3000
- Environment variables: `NEXT_PUBLIC_API_URL` (backend service URL)
- Health check: HTTP GET on `/api/health`

**Backend Container**:
- Base image: `python:3.11-slim` (lightweight, official Python)
- Install dependencies from `requirements.txt`
- Run FastAPI with Uvicorn server
- Exposed port: 8000
- Environment variables: `DATABASE_URL`, `OPENAI_API_KEY`, `MCP_CONFIG`
- Health check: HTTP GET on `/health`

### Kubernetes Architecture

**Namespace**: `todo-chatbot` (isolates resources)

**Frontend Deployment**:
- Replicas: 2 (configurable via Helm values)
- Strategy: RollingUpdate (maxSurge: 1, maxUnavailable: 0)
- Resource requests: 256Mi memory, 250m CPU
- Resource limits: 512Mi memory, 500m CPU
- Restart policy: Always
- Liveness probe: HTTP GET `/api/health` every 30s
- Readiness probe: HTTP GET `/api/health` every 10s
- Environment: Backend service URL via ConfigMap

**Backend Deployment**:
- Replicas: 2 (configurable via Helm values)
- Strategy: RollingUpdate (maxSurge: 1, maxUnavailable: 0)
- Resource requests: 512Mi memory, 500m CPU
- Resource limits: 1Gi memory, 1000m CPU
- Restart policy: Always
- Liveness probe: HTTP GET `/health` every 30s
- Readiness probe: HTTP GET `/health` every 10s
- Environment: Database URL, API keys via Secrets

**Frontend Service**:
- Type: NodePort (accessible from host machine)
- Port: 80 → 3000 (container port)
- NodePort: 30080 (fixed for consistency)
- Selector: `app=todo-chatbot-frontend`

**Backend Service**:
- Type: ClusterIP (internal only)
- Port: 8000 → 8000 (container port)
- DNS: `todo-chatbot-backend.todo-chatbot.svc.cluster.local`
- Selector: `app=todo-chatbot-backend`

**ConfigMap**: `todo-chatbot-config`
- Non-sensitive configuration
- Backend service URL for frontend
- Feature flags
- Log levels

**Secret**: `todo-chatbot-secrets`
- Database connection string
- OpenAI API key
- MCP configuration
- Authentication tokens

### Helm Chart Design

**Chart.yaml**:
- Name: `todo-chatbot`
- Version: 1.0.0 (chart version)
- AppVersion: 1.0.0 (application version from Phase III)
- Description: "Todo AI Chatbot - Cloud-Native Deployment"
- Type: application

**values.yaml** (default values):
```yaml
replicaCount:
  frontend: 2
  backend: 2

image:
  frontend:
    repository: todo-chatbot-frontend
    tag: latest
    pullPolicy: IfNotPresent
  backend:
    repository: todo-chatbot-backend
    tag: latest
    pullPolicy: IfNotPresent

service:
  frontend:
    type: NodePort
    port: 80
    nodePort: 30080
  backend:
    type: ClusterIP
    port: 8000

resources:
  frontend:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  backend:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "1Gi"
      cpu: "1000m"

config:
  logLevel: "info"
  featureFlags: {}

secrets:
  databaseUrl: ""  # Provided at deployment time
  openaiApiKey: ""  # Provided at deployment time
```

**values-dev.yaml** (development overrides):
- Single replica for faster iteration
- Lower resource limits
- Debug log level

**values-prod.yaml** (production-ready overrides):
- Higher replica counts (3-5)
- Stricter resource limits
- Info log level
- Additional security settings

### AI-Assisted DevOps Integration

**Gordon (Docker AI Agent)**:
- Use for Dockerfile generation and optimization
- Command: `gordon build --optimize frontend/`
- Fallback: Standard `docker build` with manually crafted Dockerfiles
- Benefits: Optimized layer caching, smaller image sizes, security recommendations

**kubectl-ai**:
- Use for manifest generation: `kubectl-ai create deployment todo-frontend`
- Use for troubleshooting: `kubectl-ai debug pod todo-frontend-xxx`
- Use for scaling: `kubectl-ai scale deployment todo-frontend --replicas=3`
- Fallback: Standard `kubectl` commands
- Benefits: Natural language interface, intelligent suggestions

**kagent**:
- Use for cluster health analysis: `kagent analyze cluster`
- Use for resource optimization: `kagent optimize deployment todo-frontend`
- Use for failure diagnosis: `kagent diagnose pod todo-backend-xxx`
- Fallback: Manual `kubectl describe`, `kubectl logs`, `kubectl top`
- Benefits: AI-powered insights, proactive recommendations

### Deployment Workflow

**Phase 1: Environment Setup**
1. Verify Minikube running: `minikube status`
2. Verify Docker Desktop running
3. Install Helm if needed
4. Optionally install kubectl-ai, kagent, Gordon

**Phase 2: Image Building**
1. Build frontend image: `docker build -t todo-chatbot-frontend:latest -f deployment/docker/frontend/Dockerfile .`
2. Build backend image: `docker build -t todo-chatbot-backend:latest -f deployment/docker/backend/Dockerfile .`
3. Load images into Minikube: `minikube image load todo-chatbot-frontend:latest`
4. Load images into Minikube: `minikube image load todo-chatbot-backend:latest`

**Phase 3: Helm Deployment**
1. Create namespace: `kubectl create namespace todo-chatbot`
2. Create secrets: `kubectl create secret generic todo-chatbot-secrets --from-literal=databaseUrl=$DATABASE_URL --from-literal=openaiApiKey=$OPENAI_API_KEY -n todo-chatbot`
3. Install Helm chart: `helm install todo-chatbot deployment/helm/todo-chatbot -n todo-chatbot -f deployment/helm/todo-chatbot/values-dev.yaml`
4. Wait for pods: `kubectl wait --for=condition=ready pod -l app=todo-chatbot -n todo-chatbot --timeout=300s`

**Phase 4: Verification**
1. Check pod status: `kubectl get pods -n todo-chatbot`
2. Check services: `kubectl get svc -n todo-chatbot`
3. Get frontend URL: `minikube service todo-chatbot-frontend -n todo-chatbot --url`
4. Test chatbot functionality: Access URL and perform CRUD operations
5. Check logs: `kubectl logs -l app=todo-chatbot-backend -n todo-chatbot`

**Phase 5: Scaling & Resilience Testing**
1. Scale frontend: `kubectl scale deployment todo-chatbot-frontend --replicas=3 -n todo-chatbot`
2. Delete pod: `kubectl delete pod -l app=todo-chatbot-backend -n todo-chatbot --force`
3. Verify auto-recovery: `kubectl get pods -n todo-chatbot -w`

**Phase 6: Cleanup**
1. Uninstall: `helm uninstall todo-chatbot -n todo-chatbot`
2. Delete namespace: `kubectl delete namespace todo-chatbot`

### Configuration Management

**Environment Variables (Frontend)**:
- `NEXT_PUBLIC_API_URL`: Backend service URL (from ConfigMap)
- `NODE_ENV`: production
- `PORT`: 3000

**Environment Variables (Backend)**:
- `DATABASE_URL`: PostgreSQL connection string (from Secret)
- `OPENAI_API_KEY`: OpenAI API key (from Secret)
- `MCP_CONFIG`: MCP server configuration (from Secret)
- `CORS_ORIGINS`: Allowed origins (from ConfigMap)
- `LOG_LEVEL`: Logging level (from ConfigMap)

**Secrets Management**:
- Never commit secrets to Git
- Use `.env.example` as template
- Provide secrets via Helm values or kubectl create secret
- Secrets mounted as environment variables in pods
- Use Kubernetes RBAC to restrict secret access

### Resilience & Observability

**Health Checks**:
- Liveness probes detect crashed containers → restart
- Readiness probes prevent traffic to unhealthy pods
- Startup probes allow slow-starting containers time to initialize

**Resource Management**:
- Requests guarantee minimum resources
- Limits prevent resource exhaustion
- Kubernetes scheduler places pods based on requests
- OOMKilled pods restart automatically

**Scaling Strategy**:
- Manual scaling via `kubectl scale` or Helm upgrade
- Horizontal Pod Autoscaler (HPA) out of scope for Phase IV
- Frontend scales independently from backend
- Stateless design enables seamless scaling

**Failure Scenarios**:
- Pod crash → Kubernetes restarts automatically
- Node failure → Pods rescheduled to healthy nodes (N/A for single-node Minikube)
- Image pull failure → Retry with backoff
- Database connection failure → Application retry logic + liveness probe restart
- Resource exhaustion → Pod eviction + restart on available resources

## Complexity Tracking

> **No violations detected - Constitution Check passed**

This deployment feature fully complies with Phase IV principles. No complexity justification required.

## Risk Analysis

### Technical Risks

**Risk 1: Image Size and Build Time**
- Impact: Large images slow deployment, consume disk space
- Mitigation: Multi-stage Docker builds, Alpine base images, .dockerignore
- Contingency: Use Gordon for optimization suggestions

**Risk 2: Database Connectivity from Pods**
- Impact: Pods cannot reach external Neon PostgreSQL
- Mitigation: Test connectivity before deployment, document network requirements
- Contingency: Use Kubernetes NetworkPolicy if needed, verify Minikube network mode

**Risk 3: Resource Constraints on Local Machine**
- Impact: Minikube crashes or pods fail to schedule
- Mitigation: Document minimum requirements (4GB RAM, 2 CPUs), provide resource tuning guide
- Contingency: Reduce replica counts, lower resource limits in values-dev.yaml

**Risk 4: AI Tool Availability**
- Impact: Gordon, kubectl-ai, kagent not installed or not working
- Mitigation: Provide fallback instructions for standard Docker/kubectl commands
- Contingency: All operations work without AI tools (AI is enhancement, not requirement)

**Risk 5: Secrets Management**
- Impact: Secrets accidentally committed or exposed
- Mitigation: .gitignore for secrets, use Kubernetes Secrets, document best practices
- Contingency: Rotate compromised secrets immediately

### Operational Risks

**Risk 6: Deployment Reproducibility**
- Impact: Deployment works on one machine but fails on another
- Mitigation: Helm charts with explicit versions, comprehensive quickstart.md
- Contingency: Troubleshooting guide with common issues

**Risk 7: Phase III Regression**
- Impact: Chatbot features break after containerization
- Mitigation: Comprehensive end-to-end testing, feature parity validation
- Contingency: Rollback to non-containerized version, debug in isolation

## Next Steps

After this planning phase completes:

1. **Phase 0: Research** (if needed)
   - Research Docker best practices for Next.js and FastAPI
   - Research Helm chart patterns for multi-service applications
   - Research Minikube networking and service exposure

2. **Phase 1: Design**
   - Create data-model.md (deployment entities and relationships)
   - Create contracts/ (Helm values schema, environment variables)
   - Create quickstart.md (step-by-step deployment guide)

3. **Phase 2: Task Generation**
   - Run `/sp.tasks` to generate actionable task list
   - Tasks will be organized by user story (P1-P4)
   - Each task will reference specific files and acceptance criteria

4. **Phase 3: Implementation**
   - Run `/sp.implement` to execute tasks
   - Generate Dockerfiles, Helm charts, scripts
   - Test deployment on local Minikube
   - Validate all acceptance criteria

## Success Metrics

This plan will be considered successful when:

✅ All 15 functional requirements (FR-001 through FR-015) are satisfied
✅ All 10 success criteria (SC-001 through SC-010) are met
✅ All 4 user stories (P1-P4) are independently testable and working
✅ Deployment is reproducible across different machines
✅ Zero regression from Phase III functionality
✅ AI tools successfully assist with at least 3 operations
✅ Documentation enables another developer to deploy without assistance

---

**Plan Status**: ✅ Complete - Ready for Phase 0 Research (if needed) or Phase 1 Design
