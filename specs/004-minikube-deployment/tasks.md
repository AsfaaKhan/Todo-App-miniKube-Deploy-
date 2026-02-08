---

description: "Task list for Cloud-Native Deployment on Minikube"
---

# Tasks: Cloud-Native Deployment on Minikube

**Input**: Design documents from `/specs/004-minikube-deployment/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), data-model.md, contracts/, quickstart.md

**Tests**: No tests requested in specification - tasks focus on infrastructure implementation and validation

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Deployment artifacts**: `deployment/` at repository root
- **Docker files**: `deployment/docker/frontend/` and `deployment/docker/backend/`
- **Helm charts**: `deployment/helm/todo-chatbot/`
- **Scripts**: `deployment/scripts/`
- **Documentation**: `specs/004-minikube-deployment/` and root-level README updates

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Create deployment directory structure and initialize configuration files

- [X] T001 Create deployment directory structure (deployment/docker/frontend/, deployment/docker/backend/, deployment/helm/todo-chatbot/templates/, deployment/kubernetes/, deployment/scripts/)
- [X] T002 [P] Create .dockerignore for frontend in deployment/docker/frontend/.dockerignore
- [X] T003 [P] Create .dockerignore for backend in deployment/docker/backend/.dockerignore
- [X] T004 [P] Create .helmignore in deployment/helm/todo-chatbot/.helmignore
- [X] T005 [P] Update root .gitignore to exclude secrets and temporary deployment files

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 Create Kubernetes namespace manifest in deployment/kubernetes/namespace.yaml
- [X] T007 Create .env.example template with required environment variables (DATABASE_URL, OPENAI_API_KEY, MCP_CONFIG) in repository root
- [X] T008 Create deployment README in deployment/README.md with overview and prerequisites

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Basic Containerized Deployment (Priority: P1) 🎯 MVP

**Goal**: Deploy Todo AI Chatbot to Minikube with Docker containers and basic Helm chart

**Independent Test**: Build Docker images, deploy to Minikube using Helm, access frontend via NodePort, verify all chatbot features work (task CRUD, natural language queries, AI responses)

### Implementation for User Story 1

- [X] T009 [P] [US1] Create frontend Dockerfile with multi-stage build in deployment/docker/frontend/Dockerfile
- [X] T010 [P] [US1] Create backend Dockerfile with Python 3.11-slim base in deployment/docker/backend/Dockerfile
- [X] T011 [P] [US1] Create frontend entrypoint script in deployment/docker/frontend/entrypoint.sh
- [X] T012 [P] [US1] Create backend entrypoint script in deployment/docker/backend/entrypoint.sh
- [X] T013 [US1] Create Helm Chart.yaml with metadata in deployment/helm/todo-chatbot/Chart.yaml
- [X] T014 [US1] Create basic Helm values.yaml with default configuration in deployment/helm/todo-chatbot/values.yaml
- [X] T015 [P] [US1] Create Helm helpers template in deployment/helm/todo-chatbot/templates/_helpers.tpl
- [X] T016 [P] [US1] Create frontend Deployment manifest template in deployment/helm/todo-chatbot/templates/frontend-deployment.yaml
- [X] T017 [P] [US1] Create backend Deployment manifest template in deployment/helm/todo-chatbot/templates/backend-deployment.yaml
- [X] T018 [P] [US1] Create frontend Service manifest template (NodePort) in deployment/helm/todo-chatbot/templates/frontend-service.yaml
- [X] T019 [P] [US1] Create backend Service manifest template (ClusterIP) in deployment/helm/todo-chatbot/templates/backend-service.yaml
- [X] T020 [P] [US1] Create ConfigMap manifest template in deployment/helm/todo-chatbot/templates/configmap.yaml
- [X] T021 [P] [US1] Create Secret manifest template in deployment/helm/todo-chatbot/templates/secret.yaml
- [X] T022 [P] [US1] Create Helm NOTES.txt with post-installation instructions in deployment/helm/todo-chatbot/templates/NOTES.txt
- [X] T023 [US1] Create build-images.sh script in deployment/scripts/build-images.sh
- [X] T024 [US1] Create load-images-minikube.sh script in deployment/scripts/load-images-minikube.sh
- [X] T025 [US1] Create deploy.sh script for Helm installation in deployment/scripts/deploy.sh
- [X] T026 [US1] Test US1: Build Docker images and verify they build without errors
- [X] T027 [US1] Test US1: Load images into Minikube and verify they appear in Minikube registry
- [X] T028 [US1] Test US1: Deploy to Minikube using Helm and verify all pods reach healthy status within 5 minutes
- [X] T029 [US1] Test US1: Access frontend URL and verify chatbot interface loads
- [ ] T030 [US1] Test US1: Perform natural language operations (add task, list tasks, update task) and verify 100% feature parity with Phase III

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently - basic containerized deployment working

---

## Phase 4: User Story 2 - Helm-Based Reproducible Deployment (Priority: P2)

**Goal**: Complete Helm chart with all configuration options, environment-specific values, and reproducibility features

**Independent Test**: Delete entire deployment, redeploy using only Helm charts, verify application comes back up in identical configuration without manual intervention

### Implementation for User Story 2

- [X] T031 [P] [US2] Create values-dev.yaml with development overrides in deployment/helm/todo-chatbot/values-dev.yaml
- [X] T032 [P] [US2] Create values-prod.yaml with production overrides in deployment/helm/todo-chatbot/values-prod.yaml
- [X] T033 [US2] Add Helm validation logic to templates for required values (database URL, API keys)
- [X] T034 [US2] Add resource requests and limits to Deployment templates (frontend: 256Mi/250m request, 512Mi/500m limit; backend: 512Mi/500m request, 1Gi/1000m limit)
- [X] T035 [US2] Add health probes (liveness and readiness) to Deployment templates (frontend: /api/health, backend: /health)
- [X] T036 [US2] Add rolling update strategy to Deployment templates (maxSurge: 1, maxUnavailable: 0)
- [X] T037 [US2] Configure environment variables injection from ConfigMap and Secret in Deployment templates
- [X] T038 [US2] Create undeploy.sh script for Helm uninstallation in deployment/scripts/undeploy.sh
- [X] T039 [US2] Update deployment README with Helm installation instructions and configuration options
- [ ] T040 [US2] Test US2: Run helm install and verify all Kubernetes resources are created automatically
- [ ] T041 [US2] Test US2: Run helm uninstall and verify all resources are cleanly removed
- [ ] T042 [US2] Test US2: Simulate another team member deployment (fresh clone, helm install) and verify identical working deployment
- [ ] T043 [US2] Test US2: Update values file, run helm upgrade, and verify deployment updates without manual intervention
- [ ] T044 [US2] Test US2: Verify no secrets are hardcoded in charts or images (inspect images and review chart files)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - reproducible Helm-based deployment complete

---

## Phase 5: User Story 3 - AI-Assisted DevOps Workflows (Priority: P3)

**Goal**: Document and integrate AI-powered tools (kubectl-ai, kagent, Gordon) for deployment assistance

**Independent Test**: Use kubectl-ai to generate manifests, kagent to analyze cluster health, Gordon to optimize images; verify AI tools provide useful outputs

### Implementation for User Story 3

- [X] T045 [P] [US3] Create AI tools documentation in deployment/docs/ai-tools.md (kubectl-ai, kagent, Gordon usage examples)
- [X] T046 [P] [US3] Add Gordon optimization instructions to build-images.sh script (with fallback to standard docker build)
- [X] T047 [P] [US3] Create kubectl-ai examples document in deployment/docs/kubectl-ai-examples.md
- [X] T048 [P] [US3] Create kagent examples document in deployment/docs/kagent-examples.md
- [X] T049 [US3] Update quickstart.md with AI tools section (optional tools, installation, usage)
- [X] T050 [US3] Add AI tool availability checks to deploy.sh script (detect and use if available, fallback if not)
- [ ] T051 [US3] Test US3: If kubectl-ai available, use it to generate deployment manifest and verify valid YAML
- [ ] T052 [US3] Test US3: If kagent available, analyze cluster health and verify actionable insights
- [ ] T053 [US3] Test US3: If Gordon available, build images with optimization and verify suggestions provided
- [ ] T054 [US3] Test US3: Simulate pod failure, use kubectl-ai to troubleshoot, verify root cause identification
- [ ] T055 [US3] Test US3: Verify deployment proceeds successfully when Gordon is unavailable (fallback to standard Docker CLI)

**Checkpoint**: All AI-assisted workflows documented and tested - deployment works with or without AI tools

---

## Phase 6: User Story 4 - Production-Ready Resilience (Priority: P4)

**Goal**: Add horizontal scaling support, automatic recovery configuration, and resilience testing

**Independent Test**: Scale replicas up/down, kill pods manually, verify Kubernetes automatically restarts failed pods and application continues serving requests

### Implementation for User Story 4

- [X] T056 [US4] Add replica count configuration to Helm values (frontend: 2, backend: 2 default)
- [X] T057 [US4] Configure pod disruption budgets in Helm templates (optional but recommended for production)
- [X] T058 [US4] Add horizontal scaling instructions to deployment README
- [X] T059 [US4] Create scale.sh script for easy replica scaling in deployment/scripts/scale.sh
- [X] T060 [US4] Create test-deployment.sh script for resilience testing in deployment/scripts/test-deployment.sh
- [X] T061 [US4] Add resource monitoring instructions to deployment README (kubectl top pods)
- [ ] T062 [US4] Test US4: Deploy with 1 replica, scale to 3 replicas using kubectl/Helm, verify all 3 pods start successfully
- [ ] T063 [US4] Test US4: With multiple replicas running, manually delete a pod, verify Kubernetes creates replacement within 30 seconds
- [ ] T064 [US4] Test US4: Simulate pod crash, verify Kubernetes restarts pod automatically without manual intervention
- [ ] T065 [US4] Test US4: Configure resource limits, trigger memory limit exceeded, verify Kubernetes terminates and restarts pod without affecting others
- [ ] T066 [US4] Test US4: With multiple frontend replicas, access application multiple times, verify requests are load-balanced and responses are consistent

**Checkpoint**: All user stories should now be independently functional - production-ready resilience complete

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements, documentation, and validation that affect multiple user stories

- [X] T067 [P] Update root README.md with Phase IV deployment section and link to quickstart
- [X] T068 [P] Create troubleshooting guide in deployment/docs/troubleshooting.md
- [X] T069 [P] Add deployment architecture diagram to deployment/README.md
- [X] T070 [P] Create deployment validation checklist in deployment/docs/validation-checklist.md
- [X] T071 Validate all scripts are executable (chmod +x deployment/scripts/*.sh)
- [ ] T072 Run complete deployment workflow from clean state and verify all success criteria (SC-001 through SC-010)
- [ ] T073 Verify deployment completes in under 10 minutes (SC-001)
- [ ] T074 Verify 100% feature parity with Phase III (SC-002)
- [ ] T075 Test deployment reproducibility: tear down and redeploy 5 consecutive times (SC-004)
- [ ] T076 Verify quickstart.md enables another developer to deploy without assistance (SC-008)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - US1 (Phase 3): Can start after Foundational - No dependencies on other stories
  - US2 (Phase 4): Depends on US1 completion (builds on basic Helm chart)
  - US3 (Phase 5): Can start after Foundational - Independent of US1/US2 (documentation-focused)
  - US4 (Phase 6): Depends on US1 and US2 completion (adds scaling to existing deployment)
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - Foundation for all deployment
- **User Story 2 (P2)**: Depends on US1 - Enhances and completes the Helm chart from US1
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Independent (documentation and optional tooling)
- **User Story 4 (P4)**: Depends on US1 and US2 - Adds resilience features to existing deployment

### Within Each User Story

- Dockerfiles before Helm templates (need images to deploy)
- Helm Chart.yaml and values.yaml before template files
- All Helm templates can be created in parallel (marked with [P])
- Scripts can be created in parallel with Helm templates
- Testing tasks must come after implementation tasks

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (T002, T003, T004, T005)
- Within US1: Dockerfiles (T009, T010), entrypoint scripts (T011, T012), and most Helm templates (T015-T022) can run in parallel
- Within US2: values files (T031, T032) can run in parallel
- Within US3: All documentation tasks (T045-T048) can run in parallel
- Different user stories can be worked on in parallel by different team members (US3 is independent of US1/US2)

---

## Parallel Example: User Story 1

```bash
# Launch all Dockerfiles and entrypoint scripts together:
Task: "Create frontend Dockerfile with multi-stage build in deployment/docker/frontend/Dockerfile"
Task: "Create backend Dockerfile with Python 3.11-slim base in deployment/docker/backend/Dockerfile"
Task: "Create frontend entrypoint script in deployment/docker/frontend/entrypoint.sh"
Task: "Create backend entrypoint script in deployment/docker/backend/entrypoint.sh"

# Launch all Helm templates together (after Chart.yaml and values.yaml):
Task: "Create Helm helpers template in deployment/helm/todo-chatbot/templates/_helpers.tpl"
Task: "Create frontend Deployment manifest template in deployment/helm/todo-chatbot/templates/frontend-deployment.yaml"
Task: "Create backend Deployment manifest template in deployment/helm/todo-chatbot/templates/backend-deployment.yaml"
Task: "Create frontend Service manifest template (NodePort) in deployment/helm/todo-chatbot/templates/frontend-service.yaml"
Task: "Create backend Service manifest template (ClusterIP) in deployment/helm/todo-chatbot/templates/backend-service.yaml"
Task: "Create ConfigMap manifest template in deployment/helm/todo-chatbot/templates/configmap.yaml"
Task: "Create Secret manifest template in deployment/helm/todo-chatbot/templates/secret.yaml"
Task: "Create Helm NOTES.txt with post-installation instructions in deployment/helm/todo-chatbot/templates/NOTES.txt"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (Basic Containerized Deployment)
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy to Minikube and verify chatbot works

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo (Reproducible deployment)
4. Add User Story 3 → Test independently → Deploy/Demo (AI-assisted workflows)
5. Add User Story 4 → Test independently → Deploy/Demo (Production-ready resilience)
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Dockerfiles + basic Helm)
   - Developer B: User Story 3 (AI tools documentation - independent)
3. After US1 completes:
   - Developer A: User Story 2 (Complete Helm chart)
   - Developer C: User Story 4 (Resilience features - can start after US1)
4. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- No tests requested in specification - validation happens through deployment testing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- AI tools (kubectl-ai, kagent, Gordon) are optional enhancements, not blockers

---

## Task Count Summary

- **Total Tasks**: 76
- **Phase 1 (Setup)**: 5 tasks
- **Phase 2 (Foundational)**: 3 tasks
- **Phase 3 (US1 - Basic Deployment)**: 22 tasks (9 implementation + 5 testing)
- **Phase 4 (US2 - Reproducible Deployment)**: 14 tasks (9 implementation + 5 testing)
- **Phase 5 (US3 - AI-Assisted Workflows)**: 11 tasks (6 implementation + 5 testing)
- **Phase 6 (US4 - Resilience)**: 11 tasks (5 implementation + 6 testing)
- **Phase 7 (Polish)**: 10 tasks

**Parallel Opportunities**: 28 tasks marked with [P] can run in parallel within their phase

**MVP Scope**: Phase 1 + Phase 2 + Phase 3 (User Story 1) = 30 tasks for basic working deployment
