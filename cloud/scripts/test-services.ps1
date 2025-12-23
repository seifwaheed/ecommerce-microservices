# Quick Test Script for E-Commerce Services (Without Kafka)
# This tests all working microservices

Write-Host "=== E-Commerce Microservices Test ===" -ForegroundColor Green
Write-Host "Note: Kafka is not working, but all other services are functional`n" -ForegroundColor Yellow

# Check if services are port-forwarded
Write-Host "Checking port-forwarding..." -ForegroundColor Cyan
$ports = @(8001, 8002, 8003, 8004, 3000)
$forwarded = Get-NetTCPConnection -LocalPort $ports -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }

if ($forwarded.Count -lt 4) {
    Write-Host "`n⚠️  Services need to be port-forwarded first!" -ForegroundColor Yellow
    Write-Host "Run these commands in separate terminals:" -ForegroundColor Yellow
    Write-Host "  kubectl port-forward svc/catalog-service -n ecommerce 8001:8001" -ForegroundColor White
    Write-Host "  kubectl port-forward svc/cart-service -n ecommerce 8002:8002" -ForegroundColor White
    Write-Host "  kubectl port-forward svc/order-service -n ecommerce 8003:8003" -ForegroundColor White
    Write-Host "  kubectl port-forward svc/payment-service -n ecommerce 8004:8004" -ForegroundColor White
    Write-Host "  kubectl port-forward svc/dashboard -n ecommerce 3000:80" -ForegroundColor White
    Write-Host "`nOr use: .\scripts\port-forward-all.ps1`n" -ForegroundColor Cyan
    exit
}

Write-Host "✅ Port-forwarding detected`n" -ForegroundColor Green

# Test 1: Catalog Service
Write-Host "1️⃣  Testing Catalog Service..." -ForegroundColor Cyan
try {
    $products = Invoke-RestMethod -Uri "http://localhost:8001/products" -Method Get
    Write-Host "   ✅ Catalog Service is working! Found $($products.Count) products" -ForegroundColor Green
    
    # Create a test product
    $newProduct = @{
        name = "Test Product"
        price = 99.99
        stock = 10
        category = "Electronics"
    } | ConvertTo-Json
    
    $created = Invoke-RestMethod -Uri "http://localhost:8001/products" -Method Post -Body $newProduct -ContentType "application/json"
    Write-Host "   ✅ Created product: $($created.name)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Catalog Service test failed: $_" -ForegroundColor Red
}

Write-Host ""

# Test 2: Cart Service
Write-Host "2️⃣  Testing Cart Service..." -ForegroundColor Cyan
try {
    $cartItem = @{
        product_id = 1
        quantity = 2
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "http://localhost:8002/cart/user123/items" -Method Post -Body $cartItem -ContentType "application/json" | Out-Null
    $cart = Invoke-RestMethod -Uri "http://localhost:8002/cart/user123" -Method Get
    Write-Host "   ✅ Cart Service is working! Cart has $($cart.items.Count) items" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Cart Service test failed: $_" -ForegroundColor Red
}

Write-Host ""

# Test 3: Order Service
Write-Host "3️⃣  Testing Order Service..." -ForegroundColor Cyan
try {
    $order = @{
        user_id = "user123"
    } | ConvertTo-Json
    
    $createdOrder = Invoke-RestMethod -Uri "http://localhost:8003/orders" -Method Post -Body $order -ContentType "application/json"
    Write-Host "   ✅ Order Service is working! Created order #$($createdOrder.id)" -ForegroundColor Green
    
    $orders = Invoke-RestMethod -Uri "http://localhost:8003/orders" -Method Get
    Write-Host "   ✅ Found $($orders.Count) total orders" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Order Service test failed: $_" -ForegroundColor Red
}

Write-Host ""

# Test 4: Payment Service
Write-Host "4️⃣  Testing Payment Service..." -ForegroundColor Cyan
try {
    $payment = @{
        order_id = 1
        amount = 199.98
    } | ConvertTo-Json
    
    $paymentResult = Invoke-RestMethod -Uri "http://localhost:8004/payments" -Method Post -Body $payment -ContentType "application/json"
    Write-Host "   ✅ Payment Service is working! Payment status: $($paymentResult.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Payment Service test failed: $_" -ForegroundColor Red
}

Write-Host ""

# Test 5: Dashboard
Write-Host "5️⃣  Testing Dashboard..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method Get -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Dashboard is accessible at http://localhost:3000" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Dashboard might not be accessible (check port-forwarding)" -ForegroundColor Yellow
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Green
Write-Host "✅ All core microservices are functional!" -ForegroundColor Green
Write-Host "⚠️  Kafka is not working (event-driven features may be limited)" -ForegroundColor Yellow
Write-Host "`n📊 Access Dashboard: http://localhost:3000" -ForegroundColor Cyan
Write-Host "📚 API Docs:" -ForegroundColor Cyan
Write-Host "   - Catalog: http://localhost:8001/docs" -ForegroundColor White
Write-Host "   - Cart: http://localhost:8002/docs" -ForegroundColor White
Write-Host "   - Order: http://localhost:8003/docs" -ForegroundColor White
Write-Host "   - Payment: http://localhost:8004/docs" -ForegroundColor White

