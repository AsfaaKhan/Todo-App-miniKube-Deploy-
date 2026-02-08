---
id: 0002
title: Expand Phase IV Deployment Principles
stage: constitution
date: 2026-02-07
surface: agent
model: claude-sonnet-4-5-20250929
feature: none
branch: main
user: user
command: /sp.constitution
labels: ["constitution", "phase-iv", "deployment", "kubernetes", "cloud-native"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .specify/memory/constitution.md
tests:
  - none
---

## Prompt

```text
# Constitution — Phase IV: Local Cloud-Native Deployment

## Mission
Deploy the Phase III Todo AI Chatbot as a fully containerized, cloud-native system on a local Kubernetes cluster using Minikube, Helm, and AI-assisted DevOps tools while strictly following Spec-Driven Development.

## Core Principles

### 1. Spec-Driven Infrastructure
- All infrastructure must begin with a written spec.
- No manual configuration or scripting is allowed.
- Refine the spec until Claude Code generates correct deployment artifacts.
- Treat infrastructure as code.

### 2. AI-First DevOps
- Prefer AI-assisted workflows over manual commands.
- Use Docker AI Agent (Gordon) for containerization and runtime guidance.
- Use kubectl-ai and kagent for Kubernetes deployment, scaling, debugging, and optimization.
- If Gordon is unavailable, generate Dockerfiles and commands via Claude Code.

### 3. Cloud-Native Architecture
The system must follow modern cloud-native standards:
- Containerized services
- Declarative deployments
- Helm-based package management
- Stateless application design
- Horizontally scalable workloads
- Environment-driven configuration

### 4. Service Separation
- Frontend and backend must run in separate containers.
- Services must communicate reliably inside the cluster.
- Deployments must support multiple replicas without breaking functionality.

### 5. Reproducibility
- Deployment must be repeatable on any local machine running Minikube.
- Helm charts act as the single source of deployment truth.
- Avoid hardcoded values.

### 6. Reliability & Observability
- Pods must self-heal via Kubernetes restart policies.
- Failures should be diagnosable using AI tools.
- Resource requests and limits should prevent cluster instability.

### 7. Security & Configuration
- Secrets must be environment-based.
- Never hardcode API keys, tokens, or database URLs.
- Follow least-privilege access patterns.

## Technology Governance
Mandatory stack:
- Docker Desktop (container runtime)
- Docker AI Agent — Gordon
- Kubernetes via Minikube
- Helm Charts
- kubectl-ai
- kagent

Application Source:
Phase III Todo AI Chatbot must remain fully functional after deployment.

## Definition of Done
Phase IV is complete only when:
✅ Frontend and backend are containerized
✅ Helm charts deploy successfully
✅ Application is accessible via Minikube
✅ Pods are healthy and scalable
✅ AI tools assist deployment and troubleshooting
✅ Chatbot works without regression
✅ Deployment is reproducible

## Guiding Philosophy
> "Refine the spec until the infrastructure deploys itself."
```

## Response snapshot

Updated constitution from version 1.0.0 to 1.1.0 by materially expanding Phase IV — Local Cloud-Native Deployment section with 7 detailed sub-principles covering:

1. **Spec-Driven Infrastructure**: All infrastructure begins with written specs; no manual configuration
2. **AI-First DevOps**: Prefer AI-assisted workflows using Gordon, kubectl-ai, and kagent
3. **Cloud-Native Architecture**: Containerized, declarative, Helm-based, stateless, scalable, environment-driven
4. **Service Separation**: Frontend/backend in separate containers with reliable cluster communication
5. **Reproducibility**: Repeatable deployments via Helm charts without hardcoded values
6. **Reliability & Observability**: Self-healing pods with AI-diagnosable failures and resource limits
7. **Security & Configuration**: Environment-based secrets, no hardcoded credentials, least-privilege access

Added Technology Governance section specifying mandatory stack (Docker Desktop, Gordon, Minikube, Helm, kubectl-ai, kagent) and Phase IV-specific Definition of Done with 7 acceptance criteria.

Validated template consistency across plan-template.md, spec-template.md, and tasks-template.md. All templates align with updated constitution principles.

## Outcome

- ✅ Impact: Constitution version incremented to 1.1.0 with comprehensive Phase IV deployment guidance enabling spec-driven, AI-assisted, cloud-native Kubernetes deployments
- 🧪 Tests: Template consistency validated across 3 dependent templates
- 📁 Files: Updated .specify/memory/constitution.md with sync impact report
- 🔁 Next prompts: Ready for /sp.specify to create Phase IV deployment feature spec
- 🧠 Reflection: MINOR version bump justified by material expansion of Phase IV principles (7 new sub-principles + governance + DoD)

## Evaluation notes (flywheel)

- Failure modes observed: None - constitution update completed successfully with proper versioning and template validation
- Graders run and results (PASS/FAIL): PASS - All placeholders resolved, version incremented correctly, templates validated, sync impact report generated
- Prompt variant (if applicable): Standard /sp.constitution workflow
- Next experiment (smallest change to try): None required - constitution amendment process executed as designed
