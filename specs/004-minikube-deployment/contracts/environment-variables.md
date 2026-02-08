# Environment Variables Reference

**Feature**: Cloud-Native Deployment on Minikube
**Date**: 2026-02-07
**Purpose**: Document all environment variables used by frontend and backend containers

## Overview

This document defines all environment variables required for the Todo AI Chatbot deployment. Variables are categorized by service (frontend/backend) and sensitivity (configuration/secrets).

## Frontend Environment Variables

### Required Variables

| Variable | Type | Source | Example | Description |
|----------|------|--------|---------|-------------|
| `NEXT_PUBLIC_API_URL` | Config | ConfigMap | `http://todo-chatbot-backend:8000` | Backend API base URL for frontend to connect |
| `NODE_ENV` | Config | ConfigMap | `production` | Node.js environment mode |
| `PORT` | Config | Hardcoded | `3000` | Port for Next.js server to listen on |

### Optional Variables

| Variable | Type | Source | Example | Description |
|----------|------|--------|---------|-------------|
| `NEXT_PUBLIC_APP_NAME` | Config | ConfigMap | `Todo AI Chatbot` | Application display name |
| `NEXT_PUBLIC_FEATURE_FLAGS` | Config | ConfigMap | `{"darkMode":true}` | Feature flags as JSON string |

### Variable Details

#### NEXT_PUBLIC_API_URL
- **Purpose**: Tells frontend where to send API requests
- **Format**: `http://<service-name>:<port>` or `http://<service-name>.<namespace>.svc.cluster.local:<port>`
- **Kubernetes Value**: `http://todo-chatbot-backend:8000` (uses cluster DNS)
- **Local Development**: `http://localhost:8000`
- **Validation**: Must be valid HTTP/HTTPS URL
- **Impact**: Frontend cannot communicate with backend if incorrect

#### NODE_ENV
- **Purpose**: Controls Next.js build optimizations and behavior
- **Format**: String enum
- **Allowed Values**: `development`, `production`, `test`
- **Kubernetes Value**: `production`
- **Impact**: Affects logging, error handling, performance optimizations

#### PORT
- **Purpose**: Port for Next.js server to bind to
- **Format**: Integer (1-65535)
- **Kubernetes Value**: `3000`
- **Impact**: Must match container port in Deployment and Service targetPort

---

## Backend Environment Variables

### Required Variables (Secrets)

| Variable | Type | Source | Example | Description |
|----------|------|--------|---------|-------------|
| `DATABASE_URL` | Secret | Secret | `postgresql://user:pass@host:5432/db` | PostgreSQL connection string |
| `OPENAI_API_KEY` | Secret | Secret | `sk-proj-xxxxxxxxxxxxx` | OpenAI API key for AI features |

### Required Variables (Configuration)

| Variable | Type | Source | Example | Description |
|----------|------|--------|---------|-------------|
| `CORS_ORIGINS` | Config | ConfigMap | `http://localhost:30080` | Comma-separated allowed CORS origins |
| `LOG_LEVEL` | Config | ConfigMap | `info` | Application logging level |

### Optional Variables (Secrets)

| Variable | Type | Source | Example | Description |
|----------|------|--------|---------|-------------|
| `MCP_CONFIG` | Secret | Secret | `{"servers":[...]}` | MCP server configuration as JSON |
| `JWT_SECRET` | Secret | Secret | `random-secret-string` | Secret for JWT token signing |

### Optional Variables (Configuration)

| Variable | Type | Source | Example | Description |
|----------|------|--------|---------|-------------|
| `UVICORN_HOST` | Config | Hardcoded | `0.0.0.0` | Host for Uvicorn to bind to |
| `UVICORN_PORT` | Config | Hardcoded | `8000` | Port for Uvicorn to bind to |
| `WORKERS` | Config | ConfigMap | `1` | Number of Uvicorn worker processes |

### Variable Details

#### DATABASE_URL
- **Purpose**: Connection string for PostgreSQL database
- **Format**: `postgresql://[user[:password]@][host][:port][/dbname][?param1=value1&...]`
- **Example**: `postgresql://todouser:securepass@neon.tech:5432/tododb?sslmode=require`
- **Validation**: Must start with `postgresql://`, must include host and database name
- **Security**: Stored in Kubernetes Secret, never in ConfigMap or values files
- **Impact**: Backend cannot access database if incorrect or missing

#### OPENAI_API_KEY
- **Purpose**: Authenticate with OpenAI API for AI chatbot features
- **Format**: String starting with `sk-` or `sk-proj-`
- **Example**: `sk-proj-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz`
- **Validation**: Must start with `sk-`, must be valid OpenAI key
- **Security**: Stored in Kubernetes Secret, never logged or exposed
- **Impact**: AI features will not work if incorrect or missing

#### CORS_ORIGINS
- **Purpose**: Whitelist of origins allowed to make cross-origin requests
- **Format**: Comma-separated list of URLs
- **Example**: `http://localhost:30080,http://192.168.49.2:30080`
- **Kubernetes Value**: Should include Minikube IP and NodePort
- **Validation**: Each origin must be valid URL
- **Impact**: Frontend requests blocked if origin not in list

#### LOG_LEVEL
- **Purpose**: Control verbosity of application logs
- **Format**: String enum
- **Allowed Values**: `debug`, `info`, `warning`, `error`, `critical`
- **Kubernetes Value**: `info` (production), `debug` (development)
- **Impact**: Affects log volume and troubleshooting capability

#### MCP_CONFIG
- **Purpose**: Configuration for MCP (Model Context Protocol) servers
- **Format**: JSON string with server definitions
- **Example**: `{"servers":[{"name":"todo","url":"http://localhost:3001"}]}`
- **Security**: May contain sensitive URLs or tokens, stored in Secret
- **Impact**: MCP features unavailable if incorrect

---

## Environment Variable Injection

### ConfigMap Injection

ConfigMap variables are injected into pods via `envFrom` or `env` in Deployment spec:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-chatbot-frontend
spec:
  template:
    spec:
      containers:
      - name: frontend
        env:
        - name: NEXT_PUBLIC_API_URL
          valueFrom:
            configMapKeyRef:
              name: todo-chatbot-config
              key: BACKEND_SERVICE_URL
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "3000"
```

### Secret Injection

Secret variables are injected similarly but from Secret resource:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-chatbot-backend
spec:
  template:
    spec:
      containers:
      - name: backend
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: todo-chatbot-secrets
              key: databaseUrl
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: todo-chatbot-secrets
              key: openaiApiKey
```

---

## Configuration Management

### Creating ConfigMap

```bash
kubectl create configmap todo-chatbot-config \
  --from-literal=BACKEND_SERVICE_URL="http://todo-chatbot-backend:8000" \
  --from-literal=CORS_ORIGINS="http://localhost:30080" \
  --from-literal=LOG_LEVEL="info" \
  --namespace todo-chatbot
```

### Creating Secret

```bash
kubectl create secret generic todo-chatbot-secrets \
  --from-literal=databaseUrl="postgresql://user:pass@host:5432/db" \
  --from-literal=openaiApiKey="sk-xxxxxxxxxxxxx" \
  --from-literal=mcpConfig='{"servers":[]}' \
  --namespace todo-chatbot
```

### Using Environment Variables from File

Create `.env` file (never commit to Git):

```bash
DATABASE_URL=postgresql://user:pass@host:5432/db
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
MCP_CONFIG={"servers":[]}
```

Create Secret from file:

```bash
kubectl create secret generic todo-chatbot-secrets \
  --from-env-file=.env \
  --namespace todo-chatbot
```

---

## Validation and Troubleshooting

### Verify Environment Variables in Pod

```bash
# List all environment variables in frontend pod
kubectl exec -it <frontend-pod-name> -n todo-chatbot -- env | sort

# Check specific variable
kubectl exec -it <backend-pod-name> -n todo-chatbot -- printenv DATABASE_URL
```

### Common Issues

**Issue**: Frontend cannot connect to backend
- **Symptom**: API requests fail with connection refused
- **Check**: `NEXT_PUBLIC_API_URL` is set correctly
- **Fix**: Update ConfigMap with correct backend service URL

**Issue**: Backend cannot connect to database
- **Symptom**: Backend pods crash with database connection error
- **Check**: `DATABASE_URL` is valid and database is accessible
- **Fix**: Verify database URL, check network connectivity from pod

**Issue**: AI features not working
- **Symptom**: Chatbot responses fail or return errors
- **Check**: `OPENAI_API_KEY` is valid and has credits
- **Fix**: Update Secret with valid API key

**Issue**: CORS errors in browser
- **Symptom**: Browser blocks API requests with CORS error
- **Check**: `CORS_ORIGINS` includes frontend URL
- **Fix**: Add frontend URL to CORS_ORIGINS in ConfigMap

---

## Security Best Practices

### Never Commit Secrets

- Add `.env` to `.gitignore`
- Never commit `values.yaml` with real secrets
- Use `values-secrets.yaml` (gitignored) for local secrets
- Use CI/CD secret management for production

### Rotate Secrets Regularly

```bash
# Update secret
kubectl create secret generic todo-chatbot-secrets \
  --from-literal=openaiApiKey="sk-new-key" \
  --namespace todo-chatbot \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to pick up new secret
kubectl rollout restart deployment/todo-chatbot-backend -n todo-chatbot
```

### Least Privilege Access

- Use Kubernetes RBAC to restrict Secret access
- Only backend pods should access database credentials
- Frontend should never have access to backend secrets

### Audit Secret Access

```bash
# View secret (base64 encoded)
kubectl get secret todo-chatbot-secrets -n todo-chatbot -o yaml

# Decode secret value
kubectl get secret todo-chatbot-secrets -n todo-chatbot -o jsonpath='{.data.openaiApiKey}' | base64 -d
```

---

## Environment-Specific Configurations

### Development (values-dev.yaml)

```yaml
config:
  logLevel: "debug"
  corsOrigins: "http://localhost:30080,http://192.168.49.2:30080"
```

### Production (values-prod.yaml)

```yaml
config:
  logLevel: "info"
  corsOrigins: "https://todo.example.com"
```

### Testing

```yaml
config:
  logLevel: "warning"
  corsOrigins: "*"  # Allow all origins for testing (not recommended for production)
```

---

## Reference: Complete Environment Variable List

### Frontend

| Variable | Required | Type | Default | Source |
|----------|----------|------|---------|--------|
| NEXT_PUBLIC_API_URL | Yes | Config | - | ConfigMap |
| NODE_ENV | Yes | Config | production | Hardcoded |
| PORT | Yes | Config | 3000 | Hardcoded |
| NEXT_PUBLIC_APP_NAME | No | Config | Todo AI Chatbot | ConfigMap |
| NEXT_PUBLIC_FEATURE_FLAGS | No | Config | {} | ConfigMap |

### Backend

| Variable | Required | Type | Default | Source |
|----------|----------|------|---------|--------|
| DATABASE_URL | Yes | Secret | - | Secret |
| OPENAI_API_KEY | Yes | Secret | - | Secret |
| CORS_ORIGINS | Yes | Config | - | ConfigMap |
| LOG_LEVEL | Yes | Config | info | ConfigMap |
| MCP_CONFIG | No | Secret | {} | Secret |
| JWT_SECRET | No | Secret | - | Secret |
| UVICORN_HOST | No | Config | 0.0.0.0 | Hardcoded |
| UVICORN_PORT | No | Config | 8000 | Hardcoded |
| WORKERS | No | Config | 1 | ConfigMap |

---

## Helm Integration

Environment variables are managed through Helm values:

```yaml
# values.yaml
config:
  backendServiceUrl: "http://todo-chatbot-backend:8000"
  corsOrigins: "http://localhost:30080"
  logLevel: "info"

secrets:
  databaseUrl: ""  # Provided via --set
  openaiApiKey: ""  # Provided via --set
```

Helm templates inject these into ConfigMap and Secret:

```yaml
# templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: todo-chatbot-config
data:
  BACKEND_SERVICE_URL: {{ .Values.config.backendServiceUrl | quote }}
  CORS_ORIGINS: {{ .Values.config.corsOrigins | quote }}
  LOG_LEVEL: {{ .Values.config.logLevel | quote }}
```

```yaml
# templates/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: todo-chatbot-secrets
type: Opaque
stringData:
  databaseUrl: {{ .Values.secrets.databaseUrl | quote }}
  openaiApiKey: {{ .Values.secrets.openaiApiKey | quote }}
```
