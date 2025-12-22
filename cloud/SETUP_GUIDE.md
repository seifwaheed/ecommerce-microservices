# Setup Guide - Step by Step

## Prerequisites Installation

### 1. Install Docker Desktop

**Download and Install:**
- Go to: https://www.docker.com/products/docker-desktop/
- Download Docker Desktop for Windows
- Install and **start Docker Desktop**
- Wait until Docker Desktop shows "Docker Desktop is running" in the system tray

**Verify Installation:**
```powershell
docker --version
docker ps
```

### 2. Install KinD (Kubernetes in Docker)

**Option A: Using Chocolatey (Recommended)**
```powershell
# Install Chocolatey if you don't have it
# Run PowerShell as Administrator, then:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install KinD
choco install kind -y
```

**Option B: Using Go (if you have Go installed)**
```powershell
go install sigs.k8s.io/kind@v0.20.0
```

**Option C: Manual Download**
1. Download from: https://github.com/kubernetes-sigs/kind/releases
2. Extract `kind.exe` to a folder in your PATH (e.g., `C:\Windows\System32`)

**Verify Installation:**
```powershell
kind version
```

### 3. Install kubectl

**Option A: Using Chocolatey**
```powershell
choco install kubernetes-cli -y
```

**Option B: Manual Download**
1. Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
2. Extract `kubectl.exe` to a folder in your PATH

**Verify Installation:**
```powershell
kubectl version --client
```

## Step-by-Step Setup

### Step 1: Start Docker Desktop

**IMPORTANT:** Make sure Docker Desktop is running before proceeding!

Check Docker status:
```powershell
docker ps
```

If you get an error, start Docker Desktop from the Start menu.

### Step 2: Create KinD Cluster

```powershell
.\scripts\setup-kind.ps1
```

This will:
- Create a Kubernetes cluster named `ecommerce-cluster`
- Configure port mappings
- Create the `ecommerce` namespace

**Expected Output:**
```
✅ KinD cluster setup complete!
```

### Step 3: Build and Load Docker Images

```powershell
.\scripts\build-and-load-images.ps1
```

This will:
- Build Docker images for all services
- Load them into the KinD cluster

**Expected Output:**
```
✅ All images built and loaded successfully!
```

### Step 4: Deploy All Services

```powershell
.\scripts\deploy-all.ps1
```

This will:
- Deploy Kafka and Zookeeper
- Deploy all microservices
- Wait for services to be ready

**Expected Output:**
```
✅ All services deployed successfully!
```

### Step 5: Verify Deployment

```powershell
kubectl get pods -n ecommerce
```

You should see all pods in `Running` status:
```
NAME                              READY   STATUS    RESTARTS   AGE
catalog-service-xxx               1/1     Running   0          2m
cart-service-xxx                  1/1     Running   0          2m
order-service-xxx                 1/1     Running   0          2m
payment-service-xxx               1/1     Running   0          2m
dashboard-xxx                     1/1     Running   0          2m
kafka-xxx                         1/1     Running   0          3m
zookeeper-xxx                     1/1     Running   0          3m
```

### Step 6: Access the Dashboard

Open your browser and go to:
**http://localhost:30000**

## Alternative: Quick Test with Docker Compose

If you want to test the services immediately without setting up Kubernetes:

```powershell
docker-compose up -d
```

This will start all services using Docker Compose. Access:
- Dashboard: http://localhost:3000
- Catalog API: http://localhost:8001
- Cart API: http://localhost:8002
- Order API: http://localhost:8003
- Payment API: http://localhost:8004

## Troubleshooting

### Issue: "Docker Desktop is not running"

**Solution:**
1. Start Docker Desktop from the Start menu
2. Wait until it shows "Docker Desktop is running"
3. Try `docker ps` to verify

### Issue: "kind: command not found"

**Solution:**
1. Install KinD (see Prerequisites above)
2. Restart PowerShell after installation
3. Verify with `kind version`

### Issue: "kubectl: command not found"

**Solution:**
1. Install kubectl (see Prerequisites above)
2. Restart PowerShell after installation
3. Verify with `kubectl version --client`

### Issue: "Unable to connect to the server"

**Solution:**
This means the Kubernetes cluster doesn't exist. Run:
```powershell
.\scripts\setup-kind.ps1
```

### Issue: "ImagePullBackOff" or pods not starting

**Solution:**
Make sure you built and loaded images:
```powershell
.\scripts\build-and-load-images.ps1
```

### Issue: Port 30000 already in use

**Solution:**
Edit `k8s/dashboard/service.yaml` and change `nodePort: 30000` to another port (e.g., `30001`)

### Issue: PowerShell script errors

**Solution:**
Make sure you're running PowerShell (not CMD). If issues persist, run commands manually:
```powershell
# Create cluster
kind create cluster --name ecommerce-cluster --config kind-config.yaml

# Build images
docker build -t catalog-service:latest ./services/catalog
# ... (repeat for other services)

# Load images
kind load docker-image catalog-service:latest --name ecommerce-cluster
# ... (repeat for other services)

# Deploy
kubectl apply -f k8s/namespace.yaml
kubectl apply -f kafka/
kubectl apply -f k8s/
```

## Quick Commands Reference

```powershell
# Check cluster status
kubectl cluster-info --context kind-ecommerce-cluster

# View all pods
kubectl get pods -n ecommerce

# View pod logs
kubectl logs -f deployment/catalog-service -n ecommerce

# Port forward a service
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001

# Delete everything
kind delete cluster --name ecommerce-cluster
```

## Need Help?

If you encounter issues:
1. Check Docker Desktop is running
2. Verify all prerequisites are installed
3. Check the Troubleshooting section above
4. Review pod logs: `kubectl logs <pod-name> -n ecommerce`

