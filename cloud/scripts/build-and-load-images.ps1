# PowerShell script for Windows

Write-Host "🔨 Building and loading Docker images into KinD cluster..." -ForegroundColor Cyan

# Check if Docker is running and ready
Write-Host "Checking Docker Desktop..." -ForegroundColor Yellow

# First check if docker command exists
try {
    docker --version | Out-Null
} catch {
    Write-Host "❌ Docker CLI not found!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Check Docker with retries
$dockerReady = $false
$maxAttempts = 5
$attempt = 0

while (-not $dockerReady -and $attempt -lt $maxAttempts) {
    try {
        # Try docker version first (faster check)
        $versionOutput = docker version --format '{{.Server.Version}}' 2>&1
        if ($LASTEXITCODE -eq 0 -and $versionOutput -notmatch "error" -and $versionOutput.Length -gt 0) {
            $dockerReady = $true
            Write-Host "✅ Docker Desktop is ready (Server: $versionOutput)" -ForegroundColor Green
            break
        }
        
        # Fallback to docker info
        $dockerInfo = docker info 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -and $dockerInfo -match "Server Version" -and $dockerInfo -notmatch "error") {
            $dockerReady = $true
            Write-Host "✅ Docker Desktop is ready" -ForegroundColor Green
            break
        }
    } catch {
        # Continue to retry
    }
    
    if (-not $dockerReady) {
        $attempt++
        if ($attempt -lt $maxAttempts) {
            Write-Host "  Waiting for Docker Desktop... ($attempt/$maxAttempts)" -ForegroundColor Yellow
            Write-Host "  (This may take 30-60 seconds after Docker Desktop starts)" -ForegroundColor Gray
            Start-Sleep -Seconds 5
        }
    }
}

if (-not $dockerReady) {
    Write-Host ""
    Write-Host "❌ Docker Desktop is not ready!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "  1. Make sure Docker Desktop is running (check system tray)" -ForegroundColor White
    Write-Host "  2. Wait 30-60 seconds after Docker Desktop starts" -ForegroundColor White
    Write-Host "  3. Try running: docker ps" -ForegroundColor White
    Write-Host "  4. If that fails, restart Docker Desktop" -ForegroundColor White
    Write-Host "  5. Run diagnostic: .\scripts\fix-docker.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Cyan
    Write-Host "  - WSL2 not installed or not running" -ForegroundColor Gray
    Write-Host "  - Docker Desktop Linux engine not started" -ForegroundColor Gray
    Write-Host "  - Docker Desktop needs a restart" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Check if cluster exists
$CLUSTER_NAME = "ecommerce-cluster"
$clusterExists = kind get clusters 2>$null | Select-String -Pattern $CLUSTER_NAME

if (-not $clusterExists) {
    Write-Host "❌ KinD cluster '$CLUSTER_NAME' does not exist!" -ForegroundColor Red
    Write-Host "Please run: .\scripts\setup-kind.ps1" -ForegroundColor Yellow
    exit 1
}

# Build catalog service
Write-Host "📦 Building catalog-service..." -ForegroundColor Yellow
docker build -t catalog-service:latest ./services/catalog
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build catalog-service" -ForegroundColor Red
    exit 1
}
kind load docker-image catalog-service:latest --name $CLUSTER_NAME

# Build cart service
Write-Host "📦 Building cart-service..." -ForegroundColor Yellow
docker build -t cart-service:latest ./services/cart
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build cart-service" -ForegroundColor Red
    exit 1
}
kind load docker-image cart-service:latest --name $CLUSTER_NAME

# Build order service
Write-Host "📦 Building order-service..." -ForegroundColor Yellow
docker build -t order-service:latest ./services/order
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build order-service" -ForegroundColor Red
    exit 1
}
kind load docker-image order-service:latest --name $CLUSTER_NAME

# Build payment service
Write-Host "📦 Building payment-service..." -ForegroundColor Yellow
docker build -t payment-service:latest ./services/payment
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build payment-service" -ForegroundColor Red
    exit 1
}
kind load docker-image payment-service:latest --name $CLUSTER_NAME

# Build dashboard
Write-Host "📦 Building dashboard..." -ForegroundColor Yellow
docker build -t dashboard:latest ./dashboard
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build dashboard" -ForegroundColor Red
    exit 1
}
kind load docker-image dashboard:latest --name $CLUSTER_NAME

Write-Host "✅ All images built and loaded successfully!" -ForegroundColor Green

