# Script to port-forward all services

Write-Host "🔌 Setting up port-forwarding for all services..." -ForegroundColor Cyan
Write-Host ""
Write-Host "This will start port-forwarding in the background." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop all port-forwards." -ForegroundColor Yellow
Write-Host ""

# Start port-forwards in background jobs
Write-Host "Starting port-forwards..." -ForegroundColor Yellow

# Dashboard
Write-Host "  Dashboard: http://localhost:3000" -ForegroundColor Gray
Start-Job -ScriptBlock { kubectl port-forward svc/dashboard -n ecommerce 3000:80 } | Out-Null

# Catalog
Write-Host "  Catalog: http://localhost:8001" -ForegroundColor Gray
Start-Job -ScriptBlock { kubectl port-forward svc/catalog-service -n ecommerce 8001:8001 } | Out-Null

# Cart
Write-Host "  Cart: http://localhost:8002" -ForegroundColor Gray
Start-Job -ScriptBlock { kubectl port-forward svc/cart-service -n ecommerce 8002:8002 } | Out-Null

# Order
Write-Host "  Order: http://localhost:8003" -ForegroundColor Gray
Start-Job -ScriptBlock { kubectl port-forward svc/order-service -n ecommerce 8003:8003 } | Out-Null

# Payment
Write-Host "  Payment: http://localhost:8004" -ForegroundColor Gray
Start-Job -ScriptBlock { kubectl port-forward svc/payment-service -n ecommerce 8004:8004 } | Out-Null

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "✅ Port-forwarding started!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Access your services:" -ForegroundColor Cyan
Write-Host "  Dashboard: http://localhost:3000" -ForegroundColor Yellow
Write-Host "  Catalog API: http://localhost:8001/docs" -ForegroundColor Yellow
Write-Host "  Cart API: http://localhost:8002/docs" -ForegroundColor Yellow
Write-Host "  Order API: http://localhost:8003/docs" -ForegroundColor Yellow
Write-Host "  Payment API: http://localhost:8004/docs" -ForegroundColor Yellow
Write-Host ""
Write-Host "To stop port-forwarding, run:" -ForegroundColor Cyan
Write-Host "  Get-Job | Stop-Job" -ForegroundColor Gray
Write-Host "  Get-Job | Remove-Job" -ForegroundColor Gray
Write-Host ""
Write-Host "Or close this PowerShell window." -ForegroundColor Gray

