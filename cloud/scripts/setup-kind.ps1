# PowerShell script for Windows

Write-Host "🚀 Setting up KinD cluster for E-Commerce Microservices..." -ForegroundColor Cyan

# Check if Docker is running and ready
Write-Host "Checking Docker Desktop..." -ForegroundColor Yellow
$dockerReady = $false
$maxAttempts = 10
$attempt = 0

while (-not $dockerReady -and $attempt -lt $maxAttempts) {
    try {
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0 -and $dockerInfo -notmatch "error" -and $dockerInfo -match "Server Version") {
            $dockerReady = $true
            Write-Host "✅ Docker Desktop is running and ready" -ForegroundColor Green
        } else {
            $attempt++
            Write-Host "  Waiting for Docker Desktop to be ready... ($attempt/$maxAttempts)" -ForegroundColor Yellow
            Start-Sleep -Seconds 3
        }
    } catch {
        $attempt++
        Write-Host "  Waiting for Docker Desktop to be ready... ($attempt/$maxAttempts)" -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
}

if (-not $dockerReady) {
    Write-Host "❌ Docker Desktop is not running or not ready!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "  1. Start Docker Desktop from the Start menu" -ForegroundColor Yellow
    Write-Host "  2. Wait until you see 'Docker Desktop is running' in the system tray" -ForegroundColor Yellow
    Write-Host "  3. Wait a few more seconds for it to fully initialize" -ForegroundColor Yellow
    Write-Host "  4. Try running this script again" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can verify Docker is ready by running: docker ps" -ForegroundColor Cyan
    exit 1
}

# Check if kind is installed
if (-not (Get-Command kind -ErrorAction SilentlyContinue)) {
    Write-Host "❌ KinD is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "   choco install kind" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or see SETUP_GUIDE.md for installation instructions." -ForegroundColor Yellow
    exit 1
}

# Check if cluster already exists
$existingClusters = kind get clusters 2>$null
if ($existingClusters -match "ecommerce-cluster") {
    Write-Host "⚠️  Cluster 'ecommerce-cluster' already exists. Deleting..." -ForegroundColor Yellow
    kind delete cluster --name ecommerce-cluster
}

# Create cluster configuration with an older, more stable Kubernetes version
Write-Host "Using Kubernetes v1.28.0 for better compatibility..." -ForegroundColor Gray
@"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ecommerce-cluster
nodes:
- role: control-plane
  image: kindest/node:v1.28.0@sha256:f2881c2061e86c46553cc2cd2fd43e96de3672968d5c0562a4db59348c8b69a1
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
        system-reserved: "memory=512Mi"
        eviction-hard: "memory.available<128Mi"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
"@ | Out-File -FilePath kind-config.yaml -Encoding utf8

# Create cluster
Write-Host "📦 Creating KinD cluster..." -ForegroundColor Cyan
kind create cluster --name ecommerce-cluster --config kind-config.yaml

# Wait for cluster to be ready
Write-Host "⏳ Waiting for cluster to be ready..." -ForegroundColor Cyan
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Create namespace
Write-Host "📁 Creating namespace..." -ForegroundColor Cyan
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -

# Cleanup config file
Remove-Item kind-config.yaml -ErrorAction SilentlyContinue

Write-Host "✅ KinD cluster setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Build and load Docker images:"
Write-Host "   .\scripts\build-and-load-images.ps1"
Write-Host "2. Deploy Kafka:"
Write-Host "   kubectl apply -f kafka\"
Write-Host "3. Deploy services:"
Write-Host "   kubectl apply -f k8s\"
Write-Host "4. Or use ArgoCD for GitOps deployment"

