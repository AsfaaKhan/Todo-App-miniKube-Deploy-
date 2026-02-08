# Deployment Validation Checklist

**Purpose**: Validate that the Todo AI Chatbot deployment on Minikube is complete and functional.

**Date**: 2026-02-07

**Feature**: Cloud-Native Deployment on Minikube

## Pre-Deployment Validation

### Environment Setup

- [ ] Docker Desktop installed and running
  - Verify: `docker --version` and `docker ps`
- [ ] Minikube installed
  - Verify: `minikube version`
- [ ] kubectl installed
  - Verify: `kubectl version --client`
- [ ] Helm 3.x installed
  - Verify: `helm version`
- [ ] Minikube started with sufficient resources
  - Command: `minikube start --cpus=2 --memory=4096`
  - Verify: `minikube status`
- [ ] System has minimum 8GB RAM total
- [ ] System has minimum 4 CPU cores total

### Credentials

- [ ] `.env` file created from `.env.example`
- [ ] `DATABASE_URL` set with valid PostgreSQL connection string
- [ ] `OPENAI_API_KEY` set with valid OpenAI API key
- [ ] Database is accessible from local machine
- [ ] OpenAI API key has available credits

## Build Validation

### Docker Images

- [ ] Frontend Dockerfile exists at `deployment/docker/frontend/Dockerfile`
- [ ] Backend Dockerfile exists at `deployment/docker/backend/Dockerfile`
- [ ] Frontend image builds successfully
  - Command: `docker build -t todo-chatbot-frontend:latest -f deployment/docker/frontend/Dockerfile .`
- [ ] Backend image builds successfully
  - Command: `docker build -t todo-chatbot-backend:latest -f deployment/docker/backend/Dockerfile .`
- [ ] Images appear in Docker: `docker images | grep todo-chatbot`
- [ ] Frontend image size is reasonable (< 1GB)
- [ ] Backend image size is reasonable (< 1.5GB)

### Image Loading

- [ ] Frontend image loaded into Minikube
  - Command: `minikube image load todo-chatbot-frontend:latest`
- [ ] Backend image loaded into Minikube
  - Command: `minikube image load todo-chatbot-backend:latest`
- [ ] Images appear in Minikube: `minikube image ls | grep todo-chatbot`

## Deployment Validation

### Helm Chart

- [ ] Chart.yaml exists with correct metadata
- [ ] values.yaml exists with default configuration
- [ ] values-dev.yaml exists with development overrides
- [ ] values-prod.yaml exists with production overrides
- [ ] All Helm templates exist in `templates/` directory
- [ ] Helm chart lints successfully: `helm lint deployment/helm/todo-chatbot`
- [ ] Helm template renders successfully: `helm template todo-chatbot deployment/helm/todo-chatbot --set secrets.databaseUrl=test --set secrets.openaiApiKey=test`

### Kubernetes Resources

- [ ] Namespace created: `kubectl get namespace todo-chatbot`
- [ ] Secrets created: `kubectl get secret todo-chatbot-secrets -n todo-chatbot`
- [ ] ConfigMap created: `kubectl get configmap todo-chatbot-config -n todo-chatbot`
- [ ] Frontend deployment created: `kubectl get deployment todo-chatbot-frontend -n todo-chatbot`
- [ ] Backend deployment created: `kubectl get deployment todo-chatbot-backend -n todo-chatbot`
- [ ] Frontend service created: `kubectl get svc todo-chatbot-frontend -n todo-chatbot`
- [ ] Backend service created: `kubectl get svc todo-chatbot-backend -n todo-chatbot`

### Pod Health

- [ ] All pods are running: `kubectl get pods -n todo-chatbot`
- [ ] Frontend pods are ready (1/1): `kubectl get pods -n todo-chatbot -l app=todo-chatbot-frontend`
- [ ] Backend pods are ready (1/1): `kubectl get pods -n todo-chatbot -l app=todo-chatbot-backend`
- [ ] No pods in CrashLoopBackOff state
- [ ] No pods in ImagePullBackOff state
- [ ] Pods started within 5 minutes of deployment
- [ ] Liveness probes passing: `kubectl describe pods -n todo-chatbot | grep Liveness`
- [ ] Readiness probes passing: `kubectl describe pods -n todo-chatbot | grep Readiness`

## Functionality Validation

### Application Access

- [ ] Frontend service URL obtained: `minikube service todo-chatbot-frontend -n todo-chatbot --url`
- [ ] Frontend accessible in browser
- [ ] Frontend loads without errors
- [ ] No console errors in browser developer tools

### Backend Connectivity

- [ ] Backend service is ClusterIP type
- [ ] Backend accessible from frontend pods
  - Test: `kubectl exec <frontend-pod> -n todo-chatbot -- curl http://todo-chatbot-backend:8000/health`
- [ ] Backend health endpoint returns 200 OK
- [ ] Backend logs show no errors: `kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=50`

### Feature Parity (SC-002)

- [ ] User can log in to the application
- [ ] User can create a new task
- [ ] User can view task list
- [ ] User can update a task
- [ ] User can delete a task
- [ ] User can mark task as complete
- [ ] AI chatbot interface is accessible
- [ ] Natural language commands work ("add a task to buy groceries")
- [ ] AI responses are received correctly
- [ ] All Phase III features work identically to non-containerized version

## Resilience Validation

### Pod Recovery (SC-006)

- [ ] Delete a backend pod: `kubectl delete pod -l app=todo-chatbot-backend -n todo-chatbot --force`
- [ ] New pod created automatically within 60 seconds
- [ ] New pod reaches ready state
- [ ] Application continues to function during recovery

### Scaling (SC-007)

- [ ] Scale frontend to 3 replicas: `kubectl scale deployment todo-chatbot-frontend --replicas=3 -n todo-chatbot`
- [ ] All 3 frontend pods start successfully
- [ ] Application remains accessible during scaling
- [ ] Scale back to 1 replica: `kubectl scale deployment todo-chatbot-frontend --replicas=1 -n todo-chatbot`
- [ ] Scaling down completes without errors
- [ ] No service interruption during scaling operations

### Rolling Updates

- [ ] Update deployment triggers rolling update
- [ ] New pods start before old pods terminate (maxUnavailable: 0)
- [ ] Application remains accessible during update
- [ ] Rollout completes successfully: `kubectl rollout status deployment/todo-chatbot-frontend -n todo-chatbot`

## Reproducibility Validation (SC-004)

### Deployment Cycle 1

- [ ] Undeploy: `helm uninstall todo-chatbot -n todo-chatbot`
- [ ] All resources removed
- [ ] Redeploy: `./deployment/scripts/deploy.sh`
- [ ] Application works correctly

### Deployment Cycle 2

- [ ] Undeploy and redeploy again
- [ ] Application works correctly

### Deployment Cycle 3

- [ ] Undeploy and redeploy again
- [ ] Application works correctly

### Deployment Cycle 4

- [ ] Undeploy and redeploy again
- [ ] Application works correctly

### Deployment Cycle 5

- [ ] Undeploy and redeploy again
- [ ] Application works correctly
- [ ] All 5 cycles completed with identical results

## Configuration Validation

### Secrets Management (SC-009)

- [ ] No secrets in Docker images
  - Verify: `docker history todo-chatbot-frontend:latest | grep -i secret` (should be empty)
  - Verify: `docker history todo-chatbot-backend:latest | grep -i secret` (should be empty)
- [ ] No secrets in Helm chart files
  - Verify: `grep -r "sk-" deployment/helm/todo-chatbot/` (should only show placeholders)
  - Verify: `grep -r "postgresql://" deployment/helm/todo-chatbot/` (should only show placeholders)
- [ ] Secrets stored in Kubernetes Secret resource
- [ ] Secrets mounted as environment variables in pods
- [ ] `.env` file in `.gitignore`

### Environment Variables

- [ ] Frontend has NEXT_PUBLIC_API_URL set correctly
- [ ] Backend has DATABASE_URL set correctly
- [ ] Backend has OPENAI_API_KEY set correctly
- [ ] ConfigMap contains non-sensitive configuration
- [ ] Secret contains sensitive configuration

## Performance Validation (SC-001)

- [ ] Deployment completes in under 10 minutes from clean Minikube
  - Start time: ___________
  - End time: ___________
  - Duration: ___________ (should be < 10 minutes)
- [ ] Pod startup time under 2 minutes
- [ ] Application responds within 3 seconds of first request

## Documentation Validation

### Required Documentation

- [ ] `deployment/README.md` exists and is complete
- [ ] `specs/004-minikube-deployment/quickstart.md` exists
- [ ] `specs/004-minikube-deployment/plan.md` exists
- [ ] `specs/004-minikube-deployment/spec.md` exists
- [ ] `deployment/docs/troubleshooting.md` exists
- [ ] `deployment/docs/ai-tools.md` exists
- [ ] `.env.example` exists in repository root
- [ ] Root README.md updated with Phase IV deployment section

### Script Documentation

- [ ] All scripts have clear descriptions
- [ ] Scripts include error handling
- [ ] Scripts provide helpful output messages
- [ ] Scripts are executable (or have instructions for Windows)

## AI Tools Validation (SC-010 - Optional)

### kubectl-ai (if available)

- [ ] kubectl-ai installed
- [ ] kubectl-ai can generate manifests
- [ ] kubectl-ai can troubleshoot issues
- [ ] kubectl-ai examples documented

### kagent (if available)

- [ ] kagent installed
- [ ] kagent can analyze cluster health
- [ ] kagent provides optimization recommendations
- [ ] kagent examples documented

### Gordon (if available)

- [ ] Gordon available in Docker Desktop
- [ ] Gordon can build images with optimization
- [ ] Gordon provides useful suggestions
- [ ] Fallback to standard docker build works

## Final Validation

### Success Criteria Met

- [ ] SC-001: Deployment completes in under 10 minutes ✓
- [ ] SC-002: 100% feature parity with Phase III ✓
- [ ] SC-003: Zero downtime during pod restarts with multiple replicas ✓
- [ ] SC-004: 5 consecutive reproducible deployments ✓
- [ ] SC-005: Frontend communicates with backend 100% ✓
- [ ] SC-006: Pods recover within 60 seconds ✓
- [ ] SC-007: Scaling works without service interruption ✓
- [ ] SC-008: Another developer can deploy using only docs ✓
- [ ] SC-009: No hardcoded secrets ✓
- [ ] SC-010: AI tools assist with 3+ operations (optional) ✓

### Overall Status

- [ ] All critical validations passed
- [ ] All documentation complete
- [ ] All scripts functional
- [ ] Deployment ready for production use

## Notes

**Issues Found**: ___________________________________________

**Resolutions**: ___________________________________________

**Recommendations**: ___________________________________________

**Validated By**: ___________________________________________

**Date**: ___________________________________________

**Sign-off**: ___________________________________________
