# Quick script to create a sample order

Write-Host "🛒 Creating Sample Order" -ForegroundColor Cyan
Write-Host ""

$catalogUrl = "http://localhost:8001"
$cartUrl = "http://localhost:8002"
$orderUrl = "http://localhost:8003"
$userId = "user" + (Get-Random -Minimum 1000 -Maximum 9999)

Write-Host "User ID: $userId" -ForegroundColor Gray
Write-Host ""

# Check if services are accessible
Write-Host "Checking service connectivity..." -ForegroundColor Yellow
$servicesOk = $true

try {
    $test = Invoke-WebRequest -Uri "$catalogUrl/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
} catch {
    Write-Host "❌ Catalog service not accessible!" -ForegroundColor Red
    $servicesOk = $false
}

try {
    $test = Invoke-WebRequest -Uri "$cartUrl/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
} catch {
    Write-Host "❌ Cart service not accessible!" -ForegroundColor Red
    $servicesOk = $false
}

try {
    $test = Invoke-WebRequest -Uri "$orderUrl/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
} catch {
    Write-Host "❌ Order service not accessible!" -ForegroundColor Red
    $servicesOk = $false
}

if (-not $servicesOk) {
    Write-Host ""
    Write-Host "⚠️  Services are not accessible!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please start port-forwarding first:" -ForegroundColor Cyan
    Write-Host "  .\scripts\port-forward-all.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or manually in separate terminals:" -ForegroundColor Gray
    Write-Host "  kubectl port-forward svc/catalog-service -n ecommerce 8001:8001" -ForegroundColor Gray
    Write-Host "  kubectl port-forward svc/cart-service -n ecommerce 8002:8002" -ForegroundColor Gray
    Write-Host "  kubectl port-forward svc/order-service -n ecommerce 8003:8003" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ All services are accessible" -ForegroundColor Green
Write-Host ""

# Get products
Write-Host "Getting products..." -ForegroundColor Yellow
try {
    $products = Invoke-RestMethod -Uri "$catalogUrl/products" -Method Get
    if ($products.Count -eq 0) {
        Write-Host "❌ No products found!" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Found $($products.Count) products" -ForegroundColor Green
} catch {
    Write-Host "❌ Cannot connect to catalog service!" -ForegroundColor Red
    Write-Host "Make sure port-forwarding is running:" -ForegroundColor Yellow
    Write-Host "  kubectl port-forward svc/catalog-service -n ecommerce 8001:8001" -ForegroundColor Gray
    exit 1
}

# Add to cart
Write-Host "Adding items to cart..." -ForegroundColor Yellow
$firstProduct = $products[0]
$cartItem = @{
    product_id = $firstProduct.id
    quantity = 1
} | ConvertTo-Json

try {
    $cart = Invoke-RestMethod -Uri "$cartUrl/cart/$userId/items" -Method Post -Body $cartItem -ContentType "application/json"
    Write-Host "✅ Added $($firstProduct.name) to cart" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to add to cart. Make sure cart service is port-forwarded." -ForegroundColor Red
    exit 1
}

# Create order
Write-Host "Creating order..." -ForegroundColor Yellow
$orderData = @{
    user_id = $userId
} | ConvertTo-Json

try {
    $order = Invoke-RestMethod -Uri "$orderUrl/orders" -Method Post -Body $orderData -ContentType "application/json"
    Write-Host "✅ Order created! ID: $($order.id)" -ForegroundColor Green
    Write-Host "   Status: $($order.status)" -ForegroundColor Gray
    Write-Host "   Total: $($order.total_amount)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to create order. Make sure order service is port-forwarded." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Sample order created!" -ForegroundColor Green
Write-Host ""
Write-Host "Refresh your dashboard to see the order:" -ForegroundColor Cyan
Write-Host "  http://localhost:3000" -ForegroundColor Yellow

