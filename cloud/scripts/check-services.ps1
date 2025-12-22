# Script to check service status and access

Write-Host "🔍 Checking E-Commerce Services Status" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check pods
Write-Host "1. Checking Pod Status..." -ForegroundColor Yellow
kubectl get pods -n ecommerce
Write-Host ""

# Check services
Write-Host "2. Checking Services..." -ForegroundColor Yellow
kubectl get services -n ecommerce
Write-Host ""

# Check dashboard specifically
Write-Host "3. Checking Dashboard Service..." -ForegroundColor Yellow
$dashboardSvc = kubectl get service dashboard -n ecommerce -o jsonpath='{.spec.type}' 2>&1
$dashboardPort = kubectl get service dashboard -n ecommerce -o jsonpath='{.spec.ports[0].nodePort}' 2>&1

Write-Host "   Service Type: $dashboardSvc" -ForegroundColor Gray
Write-Host "   NodePort: $dashboardPort" -ForegroundColor Gray
Write-Host ""

# Check if pods are ready
Write-Host "4. Checking Pod Readiness..." -ForegroundColor Yellow
$pods = kubectl get pods -n ecommerce -o json | ConvertFrom-Json
foreach ($pod in $pods.items) {
    $ready = ($pod.status.containerStatuses | Where-Object { $_.ready -eq $true }).Count
    $total = $pod.status.containerStatuses.Count
    $status = $pod.status.phase
    Write-Host "   $($pod.metadata.name): $status ($ready/$total ready)" -ForegroundColor $(if ($status -eq "Running" -and $ready -eq $total) { "Green" } else { "Yellow" })
    
    if ($status -ne "Running" -or $ready -ne $total) {
        Write-Host "      Logs:" -ForegroundColor Gray
        kubectl logs $($pod.metadata.name) -n ecommerce --tail=5 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
    }
}
Write-Host ""

# Check dashboard pod logs
Write-Host "5. Dashboard Pod Logs (last 10 lines)..." -ForegroundColor Yellow
$dashboardPod = kubectl get pods -n ecommerce -l app=dashboard -o jsonpath='{.items[0].metadata.name}' 2>&1
if ($dashboardPod) {
    kubectl logs $dashboardPod -n ecommerce --tail=10
} else {
    Write-Host "   No dashboard pod found!" -ForegroundColor Red
}
Write-Host ""

# Access instructions
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "📊 Access Instructions:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dashboard (NodePort):" -ForegroundColor Yellow
Write-Host "  http://localhost:30000" -ForegroundColor White
Write-Host ""
Write-Host "If dashboard doesn't work, try port-forwarding:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/dashboard -n ecommerce 3000:80" -ForegroundColor White
Write-Host "  Then access: http://localhost:3000" -ForegroundColor Gray
Write-Host ""
Write-Host "Other services (port-forward needed):" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/catalog-service -n ecommerce 8001:8001" -ForegroundColor White
Write-Host "  kubectl port-forward svc/cart-service -n ecommerce 8002:8002" -ForegroundColor White
Write-Host "  kubectl port-forward svc/order-service -n ecommerce 8003:8003" -ForegroundColor White
Write-Host "  kubectl port-forward svc/payment-service -n ecommerce 8004:8004" -ForegroundColor White

