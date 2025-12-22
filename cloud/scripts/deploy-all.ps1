# PowerShell script for Windows

Write-Host "🚀 Deploying all services to Kubernetes..." -ForegroundColor Cyan

# Create namespace
Write-Host "📁 Creating namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# Deploy Kafka first
Write-Host "📦 Deploying Kafka..." -ForegroundColor Yellow
kubectl apply -f kafka/

# Wait for Kafka to be ready
Write-Host "⏳ Waiting for Kafka to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 10
$kafkaReady = $false
$maxAttempts = 30
$attempt = 0

while (-not $kafkaReady -and $attempt -lt $maxAttempts) {
    $kafkaStatus = kubectl get deployment kafka -n ecommerce -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>$null
    if ($kafkaStatus -eq "True") {
        $kafkaReady = $true
        Write-Host "✅ Kafka is ready" -ForegroundColor Green
    } else {
        $attempt++
        Write-Host "  Waiting for Kafka... ($attempt/$maxAttempts)" -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }
}

# Deploy all services
Write-Host "📦 Deploying microservices..." -ForegroundColor Yellow
kubectl apply -f k8s/catalog/
kubectl apply -f k8s/cart/
kubectl apply -f k8s/order/
kubectl apply -f k8s/payment/
kubectl apply -f k8s/dashboard/

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Cyan
kubectl wait --for=condition=available --timeout=300s deployment/catalog-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/cart-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/order-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/payment-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/dashboard -n ecommerce

Write-Host "✅ All services deployed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Service endpoints:" -ForegroundColor Yellow
Write-Host "  Catalog Service: http://localhost:8001 (port-forward needed)"
Write-Host "  Cart Service: http://localhost:8002 (port-forward needed)"
Write-Host "  Order Service: http://localhost:8003 (port-forward needed)"
Write-Host "  Payment Service: http://localhost:8004 (port-forward needed)"
Write-Host "  Dashboard: http://localhost:30000"
Write-Host ""
Write-Host "To port-forward services:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward svc/catalog-service -n ecommerce 8001:8001"
Write-Host "  kubectl port-forward svc/cart-service -n ecommerce 8002:8002"
Write-Host "  kubectl port-forward svc/order-service -n ecommerce 8003:8003"
Write-Host "  kubectl port-forward svc/payment-service -n ecommerce 8004:8004"

