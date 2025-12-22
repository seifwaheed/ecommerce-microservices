# Rebuild and redeploy dashboard

Write-Host "🔄 Rebuilding Dashboard..." -ForegroundColor Cyan
Write-Host ""

# Build new dashboard image
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t dashboard:latest ./dashboard
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build dashboard" -ForegroundColor Red
    exit 1
}

# Load into KinD
Write-Host "Loading image into KinD cluster..." -ForegroundColor Yellow
kind load docker-image dashboard:latest --name ecommerce-cluster
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to load image" -ForegroundColor Red
    exit 1
}

# Restart dashboard deployment
Write-Host "Restarting dashboard deployment..." -ForegroundColor Yellow
kubectl rollout restart deployment/dashboard -n ecommerce

Write-Host ""
Write-Host "⏳ Waiting for dashboard to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=120s deployment/dashboard -n ecommerce

Write-Host ""
Write-Host "✅ Dashboard rebuilt and redeployed!" -ForegroundColor Green
Write-Host ""
Write-Host "Access dashboard at:" -ForegroundColor Cyan
Write-Host "  http://localhost:3000 (port-forward)" -ForegroundColor Yellow
Write-Host "  or http://localhost:30000 (NodePort)" -ForegroundColor Yellow

