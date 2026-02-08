# kubectl-ai Examples for Todo AI Chatbot Deployment

This document provides practical kubectl-ai examples specifically for managing the Todo AI Chatbot deployment on Minikube.

## Prerequisites

- kubectl-ai installed and configured
- OpenAI API key set: `export OPENAI_API_KEY="your-key"`
- Todo AI Chatbot deployed to Minikube

## Deployment Management

### Check Deployment Status

```bash
# Check all deployments
kubectl ai "show me all deployments in todo-chatbot namespace"

# Check specific deployment
kubectl ai "what is the status of frontend deployment" -n todo-chatbot

# Check replica counts
kubectl ai "how many replicas are running for each deployment" -n todo-chatbot
```

### Scaling Operations

```bash
# Scale frontend
kubectl ai "scale frontend deployment to 3 replicas" -n todo-chatbot

# Scale backend
kubectl ai "scale backend to 5 replicas" -n todo-chatbot

# Scale both
kubectl ai "scale all deployments to 2 replicas" -n todo-chatbot
```

## Pod Management

### Pod Status and Health

```bash
# List all pods
kubectl ai "show me all pods in todo-chatbot namespace"

# Check pod health
kubectl ai "which pods are not healthy" -n todo-chatbot

# Check pod restarts
kubectl ai "show me pods that have restarted" -n todo-chatbot

# Check resource usage
kubectl ai "which pods are using the most memory" -n todo-chatbot
```

### Pod Troubleshooting

```bash
# Why is pod crashing?
kubectl ai "why is my backend pod crashing" -n todo-chatbot

# Check pod events
kubectl ai "show me recent events for frontend pods" -n todo-chatbot

# Check pod logs
kubectl ai "show me error logs from backend pods" -n todo-chatbot

# Check pod configuration
kubectl ai "show me environment variables for backend pod" -n todo-chatbot
```

## Service and Networking

### Service Status

```bash
# List services
kubectl ai "show me all services" -n todo-chatbot

# Check service endpoints
kubectl ai "what endpoints does the frontend service have" -n todo-chatbot

# Check service type
kubectl ai "what type of service is the frontend" -n todo-chatbot
```

### Networking Issues

```bash
# Check connectivity
kubectl ai "why can't frontend connect to backend" -n todo-chatbot

# Check DNS resolution
kubectl ai "can pods resolve backend service DNS" -n todo-chatbot

# Check network policies
kubectl ai "are there any network policies blocking traffic" -n todo-chatbot
```

## Resource Management

### Resource Usage

```bash
# Check CPU usage
kubectl ai "show me CPU usage for all pods" -n todo-chatbot

# Check memory usage
kubectl ai "which pods are using the most memory" -n todo-chatbot

# Check resource limits
kubectl ai "show me resource limits for backend deployment" -n todo-chatbot
```

### Resource Optimization

```bash
# Check for over-provisioning
kubectl ai "are any pods over-provisioned" -n todo-chatbot

# Check for under-provisioning
kubectl ai "are any pods hitting resource limits" -n todo-chatbot

# Recommend resource adjustments
kubectl ai "what resource limits should I set for frontend" -n todo-chatbot
```

## Configuration Management

### ConfigMaps and Secrets

```bash
# List ConfigMaps
kubectl ai "show me all configmaps" -n todo-chatbot

# Check ConfigMap contents
kubectl ai "what's in the todo-chatbot-config configmap" -n todo-chatbot

# List Secrets
kubectl ai "show me all secrets" -n todo-chatbot

# Check which pods use a secret
kubectl ai "which pods use the todo-chatbot-secrets secret" -n todo-chatbot
```

### Environment Variables

```bash
# Check environment variables
kubectl ai "show me environment variables for backend pods" -n todo-chatbot

# Check specific variable
kubectl ai "what is the DATABASE_URL environment variable set to" -n todo-chatbot

# Check ConfigMap references
kubectl ai "which environment variables come from configmaps" -n todo-chatbot
```

## Troubleshooting Scenarios

### Scenario 1: Pod Won't Start

```bash
# Check pod status
kubectl ai "why won't my backend pod start" -n todo-chatbot

# Check image pull
kubectl ai "is there an image pull error" -n todo-chatbot

# Check events
kubectl ai "show me events for pods that won't start" -n todo-chatbot
```

### Scenario 2: Application Not Accessible

```bash
# Check service
kubectl ai "is the frontend service working" -n todo-chatbot

# Check endpoints
kubectl ai "does the frontend service have any endpoints" -n todo-chatbot

# Check NodePort
kubectl ai "what NodePort is the frontend service using" -n todo-chatbot
```

### Scenario 3: High Resource Usage

```bash
# Identify high usage
kubectl ai "which pods are using too much memory" -n todo-chatbot

# Check for memory leaks
kubectl ai "are any pods constantly increasing memory usage" -n todo-chatbot

# Check OOMKilled pods
kubectl ai "have any pods been killed due to out of memory" -n todo-chatbot
```

### Scenario 4: Deployment Update Issues

```bash
# Check rollout status
kubectl ai "what is the rollout status of frontend deployment" -n todo-chatbot

# Check rollout history
kubectl ai "show me the rollout history" -n todo-chatbot

# Rollback if needed
kubectl ai "rollback frontend deployment to previous version" -n todo-chatbot
```

## Monitoring and Observability

### Health Checks

```bash
# Check liveness probes
kubectl ai "are liveness probes passing for all pods" -n todo-chatbot

# Check readiness probes
kubectl ai "which pods are not ready" -n todo-chatbot

# Check probe configuration
kubectl ai "show me the health check configuration for backend" -n todo-chatbot
```

### Logs Analysis

```bash
# Get recent logs
kubectl ai "show me the last 50 lines of backend logs" -n todo-chatbot

# Search for errors
kubectl ai "find error messages in backend logs" -n todo-chatbot

# Search for specific patterns
kubectl ai "find database connection errors in logs" -n todo-chatbot

# Follow logs
kubectl ai "follow logs from frontend pods" -n todo-chatbot
```

## Advanced Operations

### Rolling Updates

```bash
# Update image
kubectl ai "update frontend deployment to use image version 1.1.0" -n todo-chatbot

# Check update progress
kubectl ai "show me the progress of the frontend rollout" -n todo-chatbot

# Pause rollout
kubectl ai "pause the frontend deployment rollout" -n todo-chatbot

# Resume rollout
kubectl ai "resume the frontend deployment rollout" -n todo-chatbot
```

### Resource Cleanup

```bash
# Delete failed pods
kubectl ai "delete all failed pods" -n todo-chatbot

# Delete completed pods
kubectl ai "delete all completed pods" -n todo-chatbot

# Clean up old replica sets
kubectl ai "delete old replica sets" -n todo-chatbot
```

### Backup and Export

```bash
# Export deployment YAML
kubectl ai "export frontend deployment as YAML" -n todo-chatbot

# Export all resources
kubectl ai "export all resources in todo-chatbot namespace as YAML"

# Backup configuration
kubectl ai "show me all configmaps and secrets" -n todo-chatbot
```

## Tips and Best Practices

### 1. Be Specific

```bash
# Good: Specific and clear
kubectl ai "scale frontend deployment to 3 replicas" -n todo-chatbot

# Less good: Vague
kubectl ai "make frontend bigger" -n todo-chatbot
```

### 2. Use Namespace Flag

```bash
# Always specify namespace for clarity
kubectl ai "show me pods" -n todo-chatbot

# Without namespace, it uses default
kubectl ai "show me pods"  # May not show your pods
```

### 3. Review Generated Commands

```bash
# kubectl-ai shows the command it will run
# Review it before confirming execution
kubectl ai "delete all pods" -n todo-chatbot
# Review: kubectl delete pods --all -n todo-chatbot
# Confirm: yes/no
```

### 4. Combine with Standard kubectl

```bash
# Use kubectl-ai for discovery
kubectl ai "which pod is using the most CPU" -n todo-chatbot

# Use standard kubectl for precise operations
kubectl delete pod <specific-pod-name> -n todo-chatbot
```

## Limitations

- kubectl-ai may not understand very complex queries
- Always review generated commands before execution
- Some operations may require standard kubectl for precision
- Requires OpenAI API credits

## See Also

- [AI Tools Overview](./ai-tools.md)
- [kagent Examples](./kagent-examples.md)
- [Troubleshooting Guide](./troubleshooting.md)
