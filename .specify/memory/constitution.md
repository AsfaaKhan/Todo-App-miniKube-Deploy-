<!-- SYNC IMPACT REPORT:
Version change: 1.0.0 → 1.1.0
Modified principles: Phase IV — Local Cloud-Native Deployment (materially expanded with 7 detailed sub-principles)
Added sections:
  - Phase IV: Spec-Driven Infrastructure
  - Phase IV: AI-First DevOps
  - Phase IV: Cloud-Native Architecture
  - Phase IV: Service Separation
  - Phase IV: Reproducibility
  - Phase IV: Reliability & Observability
  - Phase IV: Security & Configuration
  - Phase IV: Technology Governance
  - Phase IV: Definition of Done
Removed sections: None
Templates requiring updates:
  ✅ .specify/templates/plan-template.md (reviewed - Constitution Check section aligns)
  ✅ .specify/templates/spec-template.md (reviewed - user story prioritization aligns)
  ✅ .specify/templates/tasks-template.md (reviewed - phase-based task organization aligns)
Follow-up TODOs: None
Rationale: Phase IV deployment principles now provide comprehensive guidance for containerization, Kubernetes orchestration, AI-assisted DevOps workflows, and cloud-native architecture standards. This expansion enables teams to execute Phase IV with clear, testable requirements.
-->
# Todo Evolution Project Constitution

## Mission
Build a production-grade, cloud-native Todo platform that evolves across five phases using Spec-Driven Development. Every feature must be defined through Markdown specifications before implementation and generated exclusively via Claude Code. Manual coding is strictly prohibited.

## Core Principles

### 1. Spec-Driven Development First
Every feature must begin with a written spec. Specs must define behavior, constraints, data flow, and acceptance criteria. If generated output is incorrect, refine the spec — never manually edit the code. The spec is the single source of truth.

### 2. No Manual Coding
Developers must not write implementation code directly. All application logic must be produced through Claude Code. Iteration happens by improving the spec, not modifying generated files.

### 3. Incremental Evolution Architecture
The system must grow progressively across five phases without breaking prior functionality.

#### Phase I — Console Foundation
Python in-memory todo application. Support core CRUD operations. Establish clean modular architecture that can transition to a web backend.

#### Phase II — Full Stack Web App
Stack: Next.js, FastAPI, SQLModel, Neon PostgreSQL.
Requirements:
- Multi-user architecture.
- Persistent database.
- Secure authentication.
- RESTful API design.
- Frontend must consume backend APIs only.

#### Phase III — AI Conversational Interface
Stack: OpenAI ChatKit, OpenAI Agents SDK, Official MCP SDK.
Requirements:
- Natural language todo management.
- Agent-based architecture.
- MCP-compliant tool usage.
- Examples:
  - "Reschedule my meeting to 2 PM"
  - "Show my high priority tasks"
  - "Delete tomorrow's reminders"
The chatbot must act as an intelligent execution layer over the todo system.

#### Phase IV — Local Cloud-Native Deployment
Deploy the Phase III Todo AI Chatbot as a fully containerized, cloud-native system on a local Kubernetes cluster using Minikube, Helm, and AI-assisted DevOps tools while strictly following Spec-Driven Development.

**Stack**: Docker Desktop, Docker AI Agent (Gordon), Kubernetes via Minikube, Helm Charts, kubectl-ai, kagent.

**Core Principles**:

##### 1. Spec-Driven Infrastructure
- All infrastructure must begin with a written spec.
- No manual configuration or scripting is allowed.
- Refine the spec until Claude Code generates correct deployment artifacts.
- Treat infrastructure as code.

##### 2. AI-First DevOps
- Prefer AI-assisted workflows over manual commands.
- Use Docker AI Agent (Gordon) for containerization and runtime guidance.
- Use kubectl-ai and kagent for Kubernetes deployment, scaling, debugging, and optimization.
- If Gordon is unavailable, generate Dockerfiles and commands via Claude Code.

##### 3. Cloud-Native Architecture
The system must follow modern cloud-native standards:
- Containerized services
- Declarative deployments
- Helm-based package management
- Stateless application design
- Horizontally scalable workloads
- Environment-driven configuration

##### 4. Service Separation
- Frontend and backend must run in separate containers.
- Services must communicate reliably inside the cluster.
- Deployments must support multiple replicas without breaking functionality.

##### 5. Reproducibility
- Deployment must be repeatable on any local machine running Minikube.
- Helm charts act as the single source of deployment truth.
- Avoid hardcoded values.

##### 6. Reliability & Observability
- Pods must self-heal via Kubernetes restart policies.
- Failures should be diagnosable using AI tools.
- Resource requests and limits should prevent cluster instability.

##### 7. Security & Configuration
- Secrets must be environment-based.
- Never hardcode API keys, tokens, or database URLs.
- Follow least-privilege access patterns.

**Technology Governance**:
Mandatory stack: Docker Desktop (container runtime), Docker AI Agent (Gordon), Kubernetes via Minikube, Helm Charts, kubectl-ai, kagent.

Application Source: Phase III Todo AI Chatbot must remain fully functional after deployment.

**Definition of Done**:
Phase IV is complete only when:
- ✅ Frontend and backend are containerized
- ✅ Helm charts deploy successfully
- ✅ Application is accessible via Minikube
- ✅ Pods are healthy and scalable
- ✅ AI tools assist deployment and troubleshooting
- ✅ Chatbot works without regression
- ✅ Deployment is reproducible

**Guiding Philosophy**: "Refine the spec until the infrastructure deploys itself."

#### Phase V — Advanced Cloud Deployment
Stack: Kafka, Dapr, DigitalOcean Kubernetes (DOKS).
Requirements:
- Event-driven architecture.
- Service-to-service communication via Dapr.
- Scalable cloud deployment.
- Production-grade reliability.

## Feature Evolution Rules

### Basic Features (MVP Foundation)
Must exist across all applicable phases:
- Add Task
- Delete Task
- Update Task
- View Task List
- Mark as Complete

### Intermediate Features
Improve usability and organization:
- Priorities (high/medium/low)
- Tags / Categories
- Search & Filter
- Sort Tasks

### Advanced Intelligent Features
Enable automation and smart workflows:
- Recurring Tasks
- Due Dates
- Time-based Reminders
- Notification support

## Architecture Standards
Follow clean architecture principles. Prefer modular, loosely coupled services. Design for horizontal scalability. Maintain strict API contracts. Ensure backward compatibility between phases.

## AI & Agent Requirements
Use the Agentic Dev Stack. Agents must be deterministic, tool-driven, and spec-aligned. MCP must act as the standard communication protocol. Avoid hardcoded logic inside agents.

## Security Standards
Enforce authentication for multi-user systems. Validate all inputs. Protect user data. Follow least-privilege access patterns.

## Deployment Standards
Everything must be container-ready. Infrastructure must be reproducible. Configurations should support both local and cloud environments.

## Definition of Done
A phase is complete only when:
✅ Specs are written
✅ Claude Code generates working implementation
✅ Features match acceptance criteria
✅ System integrates with previous phases
✅ Deployment (if required) succeeds

## Guiding Philosophy
> "Refine the spec until the machine builds the system correctly."

This constitution governs all specs, plans, and generated implementations for the Todo Evolution Hackathon Project.

## Governance
Constitution supersedes all other practices. Amendments require documentation, approval, and migration plan. All PRs/reviews must verify compliance. Complexity must be justified.

**Version**: 1.1.0 | **Ratified**: 2026-02-03 | **Last Amended**: 2026-02-07
