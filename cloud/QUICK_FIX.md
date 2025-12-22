# Quick Fix Guide

## Current Issues

Based on your error messages, you need to:

1. ✅ **Install KinD** - Not installed
2. ⚠️ **Docker Desktop** - Appears running but Linux engine not ready
3. ✅ **Fix PowerShell scripts** - Already fixed!

**The main issue:** Docker Desktop shows as "running" but the Linux engine isn't actually ready. This is common when Docker Desktop is still starting up.

## Immediate Actions

### Step 1: Install Prerequisites

Run this command to check what's missing:
```powershell
.\scripts\check-prerequisites.ps1
```

### Step 2: Install Missing Tools

**Install KinD:**
```powershell
# If you have Chocolatey:
choco install kind -y

# If not, download manually from:
# https://github.com/kubernetes-sigs/kind/releases
```

**Install kubectl (if missing):**
```powershell
choco install kubernetes-cli -y
```

### Step 3: Start Docker Desktop (IMPORTANT!)

**Docker Desktop needs to be FULLY started, not just opened!**

1. Open Docker Desktop from Start menu
2. Wait until you see "Docker Desktop is running" in system tray
3. **Wait an additional 30-60 seconds** for the Linux engine to start
4. Verify with: `docker info` (should show Server Version)
5. Or run: `.\scripts\fix-docker.ps1` to diagnose

**Common issue:** The script says Docker is running, but the Linux engine isn't ready yet. Wait longer!

### Step 4: Run Setup Again

Once prerequisites are installed and Docker is running:

```powershell
# Check prerequisites
.\scripts\check-prerequisites.ps1

# Create cluster
.\scripts\setup-kind.ps1

# Build and load images
.\scripts\build-and-load-images.ps1

# Deploy services
.\scripts\deploy-all.ps1
```

## Alternative: Use Docker Compose (No Kubernetes Needed)

If you want to test immediately without setting up Kubernetes:

```powershell
docker-compose up -d
```

Then access:
- Dashboard: http://localhost:3000
- Catalog API: http://localhost:8001/docs
- Cart API: http://localhost:8002/docs
- Order API: http://localhost:8003/docs
- Payment API: http://localhost:8004/docs

## What Was Fixed

I've updated the PowerShell scripts to:
- ✅ Check if Docker is running before proceeding
- ✅ Check if cluster exists before loading images
- ✅ Better error handling
- ✅ More informative error messages

## KinD Cluster Creation Fails

If you get "kubelet is not healthy" or cluster creation fails:

### Quick Fix:
```powershell
.\scripts\setup-kind-fix.ps1
```

This uses more stable Kubernetes versions and has better error handling.

### Common Causes:
1. **Kubernetes version too new** - The fix script uses older stable versions
2. **Not enough Docker resources** - Need at least 4GB RAM
3. **WSL2 not properly configured** - Check `wsl --status`
4. **Docker Desktop not fully started** - Wait 1-2 minutes after restart

### Alternative: Use Docker Compose
If KinD keeps failing, use Docker Compose (no Kubernetes):
```powershell
docker-compose up -d
```

See `TROUBLESHOOTING.md` for detailed solutions.

## Still Having Issues?

### Docker Desktop Not Ready?

**First, try these quick tests:**
```powershell
# Quick test
.\scripts\test-docker.ps1

# Full diagnostic
.\scripts\fix-docker.ps1
```

**If Docker Desktop is running but script says it's not:**

1. **Wait longer** - Docker Desktop Linux engine takes 30-60 seconds to start
2. **Check Docker context:**
   ```powershell
   docker context ls
   docker context use desktop-linux
   ```
3. **Restart Docker Desktop** - Right-click tray icon > Restart
4. **Check WSL2:**
   ```powershell
   wsl --status
   ```
   If WSL2 is not installed, Docker Desktop won't work properly.

### Common Docker Issues:

1. **Docker Desktop is starting but not ready:**
   - Wait 1-2 minutes after seeing "Docker Desktop is running"
   - Run `docker info` - should show "Server Version"
   - If it shows errors, wait longer or restart Docker Desktop

2. **Docker Desktop won't start:**
   - Check Windows WSL2 is installed: `wsl --status`
   - Restart Docker Desktop
   - Check Docker Desktop logs in Settings > Troubleshoot

3. **"Cannot connect to Docker daemon":**
   - Docker Desktop Linux engine isn't running
   - Restart Docker Desktop
   - Wait for full initialization

### Other Steps:

1. Run `.\scripts\check-prerequisites.ps1` to verify everything
2. Run `.\scripts\fix-docker.ps1` to diagnose Docker issues
3. Check SETUP_GUIDE.md for detailed instructions
4. Restart PowerShell after installing new tools

