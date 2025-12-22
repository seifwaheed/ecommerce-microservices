# Script to test the full e-commerce flow and create sample orders

Write-Host "🛒 Testing E-Commerce Flow" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if services are accessible
Write-Host "1. Checking services..." -ForegroundColor Yellow

# Set base URLs (assuming port-forwarding or services are accessible)
$catalogUrl = "http://localhost:8001"
$cartUrl = "http://localhost:8002"
$orderUrl = "http://localhost:8003"
$paymentUrl = "http://localhost:8004"

# Check if we need to start port-forwarding
Write-Host "   Checking if services are accessible..." -ForegroundColor Gray
try {
    $catalogTest = Invoke-WebRequest -Uri "$catalogUrl/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "   ✅ Catalog service is accessible" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Catalog service not accessible. Starting port-forward..." -ForegroundColor Yellow
    Write-Host "   Please run port-forwarding in another terminal:" -ForegroundColor Gray
    Write-Host "   kubectl port-forward svc/catalog-service -n ecommerce 8001:8001" -ForegroundColor Gray
    Write-Host "   kubectl port-forward svc/cart-service -n ecommerce 8002:8002" -ForegroundColor Gray
    Write-Host "   kubectl port-forward svc/order-service -n ecommerce 8003:8003" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Or run: .\scripts\port-forward-all.ps1" -ForegroundColor Cyan
    exit 1
}

Write-Host ""

# Step 1: Get available products
Write-Host "2. Getting available products..." -ForegroundColor Yellow
try {
    $products = Invoke-RestMethod -Uri "$catalogUrl/products" -Method Get
    Write-Host "   Found $($products.Count) products" -ForegroundColor Green
    foreach ($product in $products | Select-Object -First 3) {
        Write-Host "   - $($product.name): $($product.price) (Stock: $($product.stock))" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ Failed to get products: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Add items to cart
Write-Host "3. Adding items to cart for user 'testuser123'..." -ForegroundColor Yellow
$userId = "testuser123"

# Add first product
try {
    $cartItem1 = @{
        product_id = $products[0].id
        quantity = 2
    } | ConvertTo-Json
    
    $cartResponse1 = Invoke-RestMethod -Uri "$cartUrl/cart/$userId/items" -Method Post -Body $cartItem1 -ContentType "application/json"
    Write-Host "   ✅ Added $($products[0].name) x2 to cart" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to add item to cart: $_" -ForegroundColor Red
}

# Add second product if available
if ($products.Count -gt 1) {
    try {
        $cartItem2 = @{
            product_id = $products[1].id
            quantity = 1
        } | ConvertTo-Json
        
        $cartResponse2 = Invoke-RestMethod -Uri "$cartUrl/cart/$userId/items" -Method Post -Body $cartItem2 -ContentType "application/json"
        Write-Host "   ✅ Added $($products[1].name) x1 to cart" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Could not add second item" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 3: View cart
Write-Host "4. Viewing cart..." -ForegroundColor Yellow
try {
    $cart = Invoke-RestMethod -Uri "$cartUrl/cart/$userId" -Method Get
    Write-Host "   Cart Total: $($cart.total)" -ForegroundColor Green
    Write-Host "   Items in cart: $($cart.items.Count)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to get cart: $_" -ForegroundColor Red
}

Write-Host ""

# Step 4: Create order
Write-Host "5. Creating order..." -ForegroundColor Yellow
try {
    $orderData = @{
        user_id = $userId
    } | ConvertTo-Json
    
    $order = Invoke-RestMethod -Uri "$orderUrl/orders" -Method Post -Body $orderData -ContentType "application/json"
    Write-Host "   ✅ Order created! Order ID: $($order.id)" -ForegroundColor Green
    Write-Host "   Status: $($order.status)" -ForegroundColor Gray
    Write-Host "   Total: $($order.total_amount)" -ForegroundColor Gray
    $orderId = $order.id
} catch {
    Write-Host "   ❌ Failed to create order: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 5: Process payment
Write-Host "6. Processing payment..." -ForegroundColor Yellow
try {
    $payment = Invoke-RestMethod -Uri "$orderUrl/orders/$orderId/payment" -Method Post
    Write-Host "   ✅ Payment processed!" -ForegroundColor Green
    Write-Host "   Payment ID: $($payment.payment_id)" -ForegroundColor Gray
    Write-Host "   Order Status: $($payment.status)" -ForegroundColor Gray
} catch {
    Write-Host "   ⚠️  Payment processing failed or already processed: $_" -ForegroundColor Yellow
}

Write-Host ""

# Step 6: View all orders
Write-Host "7. Viewing all orders..." -ForegroundColor Yellow
try {
    $allOrders = Invoke-RestMethod -Uri "$orderUrl/orders" -Method Get
    Write-Host "   ✅ Total orders: $($allOrders.Count)" -ForegroundColor Green
    foreach ($o in $allOrders | Select-Object -First 5) {
        Write-Host "   - Order #$($o.id): $($o.status) - $($o.total_amount)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ Failed to get orders: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "✅ Test Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Check your dashboard:" -ForegroundColor Cyan
Write-Host "   http://localhost:3000 (or http://localhost:30000)" -ForegroundColor Yellow
Write-Host ""
Write-Host "The dashboard should now show your order!" -ForegroundColor Green

