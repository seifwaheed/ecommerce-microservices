# Complete setup script - runs all steps in order

Write-Host "🚀 Complete E-Commerce Microservices Setup" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check prerequisites
Write-Host "Step 1: Checking prerequisites..." -ForegroundColor Yellow
& ".\scripts\check-prerequisites.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Prerequisites check failed. Please install missing tools." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 2: Create KinD cluster
Write-Host "Step 2: Creating KinD cluster..." -ForegroundColor Yellow
Write-Host ""
& ".\scripts\setup-kind.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Failed to create KinD cluster." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Build and load images
Write-Host "Step 3: Building and loading Docker images..." -ForegroundColor Yellow
Write-Host ""
& ".\scripts\build-and-load-images.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Failed to build/load images." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Deploy services
Write-Host "Step 4: Deploying services..." -ForegroundColor Yellow
Write-Host ""
& ".\scripts\deploy-all.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Failed to deploy services." -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Access your services:" -ForegroundColor Cyan
Write-Host "  Dashboard: http://localhost:30000" -ForegroundColor Yellow
Write-Host ""
Write-Host "To port-forward individual services:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward svc/catalog-service -n ecommerce 8001:8001" -ForegroundColor Gray
Write-Host "  kubectl port-forward svc/cart-service -n ecommerce 8002:8002" -ForegroundColor Gray
Write-Host "  kubectl port-forward svc/order-service -n ecommerce 8003:8003" -ForegroundColor Gray
Write-Host "  kubectl port-forward svc/payment-service -n ecommerce 8004:8004" -ForegroundColor Gray
Write-Host ""
Write-Host "Check pod status:" -ForegroundColor Cyan
Write-Host "  kubectl get pods -n ecommerce" -ForegroundColor Gray

