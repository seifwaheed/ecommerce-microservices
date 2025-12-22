# Alternative KinD setup with troubleshooting

Write-Host "🚀 Setting up KinD cluster (Alternative Method)..." -ForegroundColor Cyan
Write-Host ""

# Check Docker resources
Write-Host "Checking Docker Desktop resources..." -ForegroundColor Yellow
$dockerInfo = docker info 2>&1 | Out-String
if ($dockerInfo -match "CPUs|Memory") {
    Write-Host "✅ Docker Desktop resources OK" -ForegroundColor Green
} else {
    Write-Host "⚠️  Make sure Docker Desktop has enough resources:" -ForegroundColor Yellow
    Write-Host "   - At least 4GB RAM allocated" -ForegroundColor Gray
    Write-Host "   - At least 2 CPUs allocated" -ForegroundColor Gray
    Write-Host "   - Check: Docker Desktop > Settings > Resources" -ForegroundColor Gray
}

Write-Host ""

# Check for existing cluster and clean up
$existingClusters = kind get clusters 2>$null
if ($existingClusters -match "ecommerce-cluster") {
    Write-Host "Cleaning up existing cluster..." -ForegroundColor Yellow
    kind delete cluster --name ecommerce-cluster 2>$null
    Start-Sleep -Seconds 2
}

# Try creating cluster with explicit image version
Write-Host "Creating cluster with stable Kubernetes version..." -ForegroundColor Yellow
$clusterCreated = $false

# Try v1.28.0 first (most stable)
Write-Host "Attempting with Kubernetes v1.28.0..." -ForegroundColor Gray
$result = kind create cluster --name ecommerce-cluster --image kindest/node:v1.28.0 2>&1
if ($LASTEXITCODE -eq 0) {
    $clusterCreated = $true
    Write-Host "✅ Cluster created successfully!" -ForegroundColor Green
} else {
    Write-Host "v1.28.0 failed, trying v1.27.3..." -ForegroundColor Yellow
    # Clean up failed attempt
    kind delete cluster --name ecommerce-cluster 2>$null
    Start-Sleep -Seconds 2
    
    $result = kind create cluster --name ecommerce-cluster --image kindest/node:v1.27.3 2>&1
    if ($LASTEXITCODE -eq 0) {
        $clusterCreated = $true
        Write-Host "✅ Cluster created successfully!" -ForegroundColor Green
    } else {
        Write-Host "v1.27.3 also failed, trying v1.26.6..." -ForegroundColor Yellow
        kind delete cluster --name ecommerce-cluster 2>$null
        Start-Sleep -Seconds 2
        
        $result = kind create cluster --name ecommerce-cluster --image kindest/node:v1.26.6 2>&1
        if ($LASTEXITCODE -eq 0) {
            $clusterCreated = $true
            Write-Host "✅ Cluster created successfully!" -ForegroundColor Green
        }
    }
}

if (-not $clusterCreated) {
    Write-Host ""
    Write-Host "❌ Failed to create cluster with multiple Kubernetes versions." -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Restart Docker Desktop completely" -ForegroundColor White
    Write-Host "2. Check WSL2 is enabled:" -ForegroundColor White
    Write-Host "   wsl --status" -ForegroundColor Gray
    Write-Host "3. Increase Docker Desktop resources:" -ForegroundColor White
    Write-Host "   - Docker Desktop > Settings > Resources" -ForegroundColor Gray
    Write-Host "   - Set Memory to at least 4GB" -ForegroundColor Gray
    Write-Host "   - Set CPUs to at least 2" -ForegroundColor Gray
    Write-Host "4. Try using Docker Compose instead (no Kubernetes):" -ForegroundColor White
    Write-Host "   docker-compose up -d" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Wait for cluster
Write-Host ""
Write-Host "Waiting for cluster to be ready..." -ForegroundColor Yellow
$maxWait = 60
$waited = 0
$clusterReady = $false

while (-not $clusterReady -and $waited -lt $maxWait) {
    try {
        $nodes = kubectl get nodes 2>&1
        if ($nodes -match "Ready") {
            $clusterReady = $true
            Write-Host "✅ Cluster is ready!" -ForegroundColor Green
        } else {
            Write-Host "  Waiting... ($waited/$maxWait seconds)" -ForegroundColor Gray
            Start-Sleep -Seconds 5
            $waited += 5
        }
    } catch {
        Write-Host "  Waiting... ($waited/$maxWait seconds)" -ForegroundColor Gray
        Start-Sleep -Seconds 5
        $waited += 5
    }
}

if (-not $clusterReady) {
    Write-Host "⚠️  Cluster created but not fully ready. You may need to wait a bit more." -ForegroundColor Yellow
    Write-Host "   Run: kubectl get nodes" -ForegroundColor Gray
}

# Create namespace
Write-Host ""
Write-Host "Creating namespace..." -ForegroundColor Yellow
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f - 2>&1 | Out-Null

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Verify cluster:" -ForegroundColor Cyan
Write-Host "  kubectl get nodes" -ForegroundColor Gray

