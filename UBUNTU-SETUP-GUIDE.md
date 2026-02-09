# Complete Ubuntu Setup Guide for Todo AI Chatbot

This guide will help you deploy the Todo AI Chatbot on Ubuntu using Minikube.

## Step 1: Transfer Project to Ubuntu

First, transfer this project to your Ubuntu machine:

```bash
# Option A: Using Git (recommended)
git clone <your-repository-url>
cd chatbot-deployment-minikubes

# Option B: Using SCP from Windows
# On Windows PowerShell:
scp -r "E:\HACKATHON-PROJECT\chatbot-deployment(minikubes)" username@ubuntu-ip:~/

# Then on Ubuntu:
cd ~/chatbot-deployment-minikubes
```

## Step 2: Install Prerequisites on Ubuntu

Run these commands on your Ubuntu system:

### 2.1 Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 2.2 Install Docker
```bash
# Install Docker
sudo apt install -y docker.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (to run docker without sudo)
sudo usermod -aG docker $USER

# Apply group changes (or log out and back in)
newgrp docker

# Verify Docker installation
docker --version
docker ps
```

### 2.3 Install kubectl
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### 2.4 Install Minikube
```bash
# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

### 2.5 Install Helm
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

## Step 3: Configure Environment Variables

Create a `.env` file in the project root with your credentials:

```bash
# Navigate to project directory
cd ~/chatbot-deployment-minikubes

# Create .env file
nano .env
```

Add the following content (replace with your actual values):

```env
# Database Configuration
DATABASE_URL=postgresql://username:password@host:5432/database_name

# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here

# MCP Configuration (optional)
MCP_CONFIG={}

# Secret Key for JWT
SECRET_KEY=your_secret_key_here
```

Save and exit (Ctrl+X, then Y, then Enter).

**Important:** Get your credentials:
- **DATABASE_URL**: From your Neon PostgreSQL dashboard
- **OPENAI_API_KEY**: From OpenAI platform (https://platform.openai.com/api-keys)

## Step 4: Start Minikube

```bash
# Start Minikube with recommended resources
minikube start --cpus=2 --memory=4096

# Verify Minikube is running
minikube status

# Expected output:
# minikube
# type: Control Plane
# host: Running
# kubelet: Running
# apiserver: Running
# kubeconfig: Configured
```

## Step 5: Build Docker Images

```bash
# Make scripts executable
chmod +x deployment/scripts/*.sh

# Build Docker images
./deployment/scripts/build-images.sh
```

This will build:
- `todo-chatbot-frontend:latest`
- `todo-chatbot-backend:latest`

## Step 6: Load Images into Minikube

```bash
# Load images into Minikube's Docker registry
./deployment/scripts/load-images-minikube.sh
```

## Step 7: Deploy to Kubernetes

```bash
# Deploy using Helm
./deployment/scripts/deploy.sh
```

This script will:
- Create the `todo-chatbot` namespace
- Create Kubernetes secrets from your .env file
- Deploy frontend and backend pods
- Set up services and load balancing
- Wait for all pods to be ready

## Step 8: Access the Application

### Option A: Get the URL
```bash
# Get the application URL
minikube service todo-chatbot-frontend -n todo-chatbot --url
```

Copy the URL and open it in your browser.

### Option B: Open directly in browser
```bash
# This will automatically open in your default browser
minikube service todo-chatbot-frontend -n todo-chatbot
```

## Step 9: Verify Deployment

Check that everything is running:

```bash
# Check all resources
kubectl get all -n todo-chatbot

# Check pod status
kubectl get pods -n todo-chatbot

# Expected output:
# NAME                                      READY   STATUS    RESTARTS   AGE
# todo-chatbot-backend-xxxxx-xxxxx          1/1     Running   0          2m
# todo-chatbot-backend-xxxxx-yyyyy          1/1     Running   0          2m
# todo-chatbot-frontend-xxxxx-xxxxx         1/1     Running   0          2m
# todo-chatbot-frontend-xxxxx-yyyyy         1/1     Running   0          2m

# Check logs if needed
kubectl logs -l app=todo-chatbot-frontend -n todo-chatbot --tail=50
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=50
```

## Useful Commands

### View Application Logs
```bash
# Frontend logs
kubectl logs -l app=todo-chatbot-frontend -n todo-chatbot -f

# Backend logs
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot -f
```

### Scale Application
```bash
# Scale frontend to 3 replicas
./deployment/scripts/scale.sh frontend 3

# Scale backend to 3 replicas
./deployment/scripts/scale.sh backend 3
```

### Monitor Resources
```bash
# Enable metrics server
minikube addons enable metrics-server

# Wait 30 seconds, then check resource usage
kubectl top pods -n todo-chatbot
kubectl top nodes
```

### Restart Deployment
```bash
# Restart frontend
kubectl rollout restart deployment todo-chatbot-frontend -n todo-chatbot

# Restart backend
kubectl rollout restart deployment todo-chatbot-backend -n todo-chatbot
```

### Stop and Clean Up
```bash
# Undeploy application
./deployment/scripts/undeploy.sh

# Stop Minikube
minikube stop

# Delete Minikube cluster (removes everything)
minikube delete
```

## Troubleshooting

### Issue: Pods stuck in ImagePullBackOff
```bash
# Check if images are loaded
minikube image ls | grep todo-chatbot

# If not found, reload images
./deployment/scripts/load-images-minikube.sh
```

### Issue: Pods stuck in CrashLoopBackOff
```bash
# Check pod logs
kubectl logs <pod-name> -n todo-chatbot

# Common causes:
# 1. Invalid DATABASE_URL - check .env file
# 2. Invalid OPENAI_API_KEY - verify API key
# 3. Database connection issues - test database connectivity
```

### Issue: Cannot access application
```bash
# Get the correct URL
minikube service todo-chatbot-frontend -n todo-chatbot --url

# Check service status
kubectl get svc -n todo-chatbot

# Try using tunnel (alternative access method)
minikube tunnel
# Then access at http://localhost:30080
```

### Issue: Minikube won't start
```bash
# Delete and recreate cluster
minikube delete
minikube start --cpus=2 --memory=4096 --driver=docker

# If docker driver fails, try:
minikube start --cpus=2 --memory=4096 --driver=none
```

### Check Minikube Dashboard
```bash
# Open Kubernetes dashboard
minikube dashboard
```

## Next Steps

Once deployed:
1. Register a new user account
2. Log in to the dashboard
3. Try the AI chatbot with commands like:
   - "Add a task to buy groceries"
   - "Show me my tasks"
   - "Mark task 1 as complete"

## Performance Tips

- **Minimum Resources**: 2 CPUs, 4GB RAM
- **Recommended**: 4 CPUs, 8GB RAM for better performance
- **For production**: Use a real Kubernetes cluster (GKE, EKS, AKS)

## Support

For more details, see:
- `deployment/README.md` - Full deployment documentation
- `deployment/docs/troubleshooting.md` - Detailed troubleshooting
- `specs/004-minikube-deployment/quickstart.md` - Quick start guide

---

**Ready to deploy?** Start with Step 1 and follow each step in order!
