# Troubleshooting Guide

## KinD Cluster Creation Fails

### Problem: "kubelet is not healthy" or "connection refused"

This is a common issue on Windows with KinD. Here are solutions:

### Solution 1: Use Alternative Setup Script

Try the alternative setup script that uses more stable Kubernetes versions:

```powershell
.\scripts\setup-kind-fix.ps1
```

This script automatically tries multiple Kubernetes versions until one works.

### Solution 2: Fix Docker Desktop Configuration

1. **Check WSL2 is enabled:**
   ```powershell
   wsl --status
   ```
   If WSL2 is not enabled, enable it:
   ```powershell
   wsl --set-default-version 2
   ```

2. **Increase Docker Desktop Resources:**
   - Open Docker Desktop
   - Go to Settings > Resources
   - Set Memory to at least **4GB** (8GB recommended)
   - Set CPUs to at least **2**
   - Click "Apply & Restart"

3. **Enable WSL2 Integration:**
   - Docker Desktop > Settings > Resources > WSL Integration
   - Enable integration with your WSL2 distro

### Solution 3: Use Older Kubernetes Version

Manually create cluster with a stable version:

```powershell
# Delete existing cluster if any
kind delete cluster --name ecommerce-cluster

# Create with v1.28.0 (most stable)
kind create cluster --name ecommerce-cluster --image kindest/node:v1.28.0

# Or try v1.27.3
kind create cluster --name ecommerce-cluster --image kindest/node:v1.27.3

# Or try v1.26.6
kind create cluster --name ecommerce-cluster --image kindest/node:v1.26.6
```

### Solution 4: Restart Everything

1. Close all PowerShell windows
2. Restart Docker Desktop (right-click tray icon > Restart)
3. Wait 1-2 minutes for Docker to fully start
4. Open new PowerShell window
5. Try setup again

### Solution 5: Use Docker Compose Instead

If KinD continues to fail, you can use Docker Compose (no Kubernetes needed):

```powershell
docker-compose up -d
```

This will start all services directly in Docker containers. Access:
- Dashboard: http://localhost:3000
- Catalog: http://localhost:8001
- Cart: http://localhost:8002
- Order: http://localhost:8003
- Payment: http://localhost:8004

## Docker Desktop Issues

### Problem: "Docker Desktop is not running"

**Solutions:**
1. Start Docker Desktop from Start menu
2. Wait 30-60 seconds after it shows "running"
3. Verify: `docker ps` should work
4. If not, restart Docker Desktop

### Problem: "Cannot connect to Docker daemon"

**Solutions:**
1. Check Docker Desktop is running
2. Try: `docker context use desktop-linux`
3. Restart Docker Desktop
4. Check WSL2 is installed and enabled

## WSL2 Issues

### Check WSL2 Status

```powershell
wsl --status
wsl --list --verbose
```

### Install/Update WSL2

```powershell
# Install WSL2
wsl --install

# Set default version
wsl --set-default-version 2

# Update existing distro
wsl --update
```

### Common WSL2 Fixes

1. **Restart WSL2:**
   ```powershell
   wsl --shutdown
   ```
   Then restart Docker Desktop

2. **Check WSL2 kernel update:**
   - Download from: https://aka.ms/wsl2kernel
   - Install the update
   - Restart Docker Desktop

## Resource Issues

### Check Docker Resources

```powershell
docker info
```

Look for:
- Memory: Should be at least 4GB
- CPUs: Should be at least 2

### Increase Resources

1. Docker Desktop > Settings > Resources
2. Increase Memory to 6-8GB
3. Increase CPUs to 2-4
4. Click "Apply & Restart"
5. Wait for Docker to restart completely

## Network Issues

### Problem: Port already in use

**Solution:**
Change the port in `k8s/dashboard/service.yaml`:
```yaml
nodePort: 30001  # Change from 30000
```

Or stop the service using the port:
```powershell
# Find what's using port 30000
netstat -ano | findstr :30000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

## Still Having Issues?

### Diagnostic Commands

```powershell
# Check Docker
docker version
docker info
docker ps

# Check KinD
kind version
kind get clusters

# Check Kubernetes
kubectl version --client
kubectl get nodes

# Check WSL2
wsl --status
wsl --list --verbose

# Test Docker Compose (alternative)
docker-compose version
docker-compose up -d
```

### Get Help

1. Run diagnostic script:
   ```powershell
   .\scripts\fix-docker.ps1
   .\scripts\test-docker.ps1
   ```

2. Check logs:
   ```powershell
   # Docker Desktop logs
   # Docker Desktop > Settings > Troubleshoot > View logs
   
   # KinD cluster logs
   docker logs ecommerce-cluster-control-plane
   ```

3. Try Docker Compose as fallback (no Kubernetes needed)

