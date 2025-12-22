# Quick script to access dashboard

Write-Host "🌐 Accessing Dashboard..." -ForegroundColor Cyan
Write-Host ""

# Check if dashboard pod is running
$dashboardPod = kubectl get pods -n ecommerce -l app=dashboard -o jsonpath='{.items[0].metadata.name}' 2>&1

if (-not $dashboardPod -or $dashboardPod -match "error") {
    Write-Host "❌ Dashboard pod not found!" -ForegroundColor Red
    Write-Host "Checking pod status..." -ForegroundColor Yellow
    kubectl get pods -n ecommerce -l app=dashboard
    exit 1
}

Write-Host "✅ Dashboard pod found: $dashboardPod" -ForegroundColor Green
Write-Host ""

# Try NodePort first
Write-Host "Trying NodePort access (http://localhost:30000)..." -ForegroundColor Yellow
$nodePortTest = Test-NetConnection -ComputerName localhost -Port 30000 -WarningAction SilentlyContinue
if ($nodePortTest.TcpTestSucceeded) {
    Write-Host "✅ NodePort is accessible!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Open in browser: http://localhost:30000" -ForegroundColor Cyan
    Start-Process "http://localhost:30000"
} else {
    Write-Host "⚠️  NodePort not accessible, using port-forward..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Starting port-forward..." -ForegroundColor Yellow
    Write-Host "Dashboard will be available at: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop port-forwarding" -ForegroundColor Gray
    Write-Host ""
    
    # Start port-forward and open browser after a delay
    Start-Job -ScriptBlock {
        Start-Sleep -Seconds 3
        Start-Process "http://localhost:3000"
    } | Out-Null
    
    kubectl port-forward svc/dashboard -n ecommerce 3000:80
}

