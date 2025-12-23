# Check if port-forwarding is active

Write-Host "🔍 Checking Port-Forwarding Status" -ForegroundColor Cyan
Write-Host ""

$services = @(
    @{Name="Catalog"; Port=8001; Url="http://localhost:8001/health"},
    @{Name="Cart"; Port=8002; Url="http://localhost:8002/health"},
    @{Name="Order"; Port=8003; Url="http://localhost:8003/health"},
    @{Name="Payment"; Port=8004; Url="http://localhost:8004/health"},
    @{Name="Dashboard"; Port=3000; Url="http://localhost:3000"}
)

$allOk = $true

foreach ($service in $services) {
    Write-Host "Checking $($service.Name) service (port $($service.Port))..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host "  ✅ $($service.Name) is accessible" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $($service.Name) is NOT accessible" -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host ""

if ($allOk) {
    Write-Host "✅ All services are accessible!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor Cyan
    Write-Host "  - Access dashboard: http://localhost:3000" -ForegroundColor Yellow
    Write-Host "  - Create orders: .\scripts\create-sample-order.ps1" -ForegroundColor Yellow
} else {
    Write-Host "❌ Some services are not accessible!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Start port-forwarding:" -ForegroundColor Cyan
    Write-Host "  .\scripts\port-forward-all.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or check if port-forwarding is running:" -ForegroundColor Gray
    Write-Host "  Get-Process | Where-Object {$_.ProcessName -like '*kubectl*'}" -ForegroundColor Gray
}

