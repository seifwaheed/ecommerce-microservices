# Quick Test Guide

Your dashboard is working! Now let's create some test orders to see it in action.

## Quick Test - Create a Sample Order

### Option 1: Automated Script (Easiest)

Make sure port-forwarding is running first:
```powershell
# In one terminal, start port-forwarding
.\scripts\port-forward-all.ps1

# In another terminal, create sample order
.\scripts\create-sample-order.ps1
```

### Option 2: Full Flow Test

Test the complete e-commerce flow:
```powershell
.\scripts\test-ecommerce-flow.ps1
```

This will:
1. Get products from catalog
2. Add items to cart
3. Create an order
4. Process payment
5. Show all orders

## Manual Testing

### Step 1: Start Port-Forwarding

```powershell
# Terminal 1 - Dashboard
kubectl port-forward svc/dashboard -n ecommerce 3000:80

# Terminal 2 - Services
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001
kubectl port-forward svc/cart-service -n ecommerce 8002:8002
kubectl port-forward svc/order-service -n ecommerce 8003:8003
kubectl port-forward svc/payment-service -n ecommerce 8004:8004
```

Or use the all-in-one script:
```powershell
.\scripts\port-forward-all.ps1
```

### Step 2: Create an Order via API

**Get Products:**
```powershell
Invoke-RestMethod -Uri "http://localhost:8001/products" | ConvertTo-Json
```

**Add to Cart:**
```powershell
$cartItem = @{
    product_id = 1
    quantity = 2
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8002/cart/user123/items" -Method Post -Body $cartItem -ContentType "application/json"
```

**Create Order:**
```powershell
$order = @{
    user_id = "user123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8003/orders" -Method Post -Body $order -ContentType "application/json"
```

**Process Payment:**
```powershell
Invoke-RestMethod -Uri "http://localhost:8003/orders/1/payment" -Method Post
```

### Step 3: View in Dashboard

Refresh your dashboard at http://localhost:3000 and you should see the order!

## Using Browser/Postman

### 1. Get Products
```
GET http://localhost:8001/products
```

### 2. Add to Cart
```
POST http://localhost:8002/cart/user123/items
Content-Type: application/json

{
  "product_id": 1,
  "quantity": 2
}
```

### 3. Create Order
```
POST http://localhost:8003/orders
Content-Type: application/json

{
  "user_id": "user123"
}
```

### 4. Process Payment
```
POST http://localhost:8003/orders/1/payment
```

### 5. View Orders
```
GET http://localhost:8003/orders
```

## Interactive API Docs

Once port-forwarding is active, you can use the interactive API docs:

- **Catalog API Docs:** http://localhost:8001/docs
- **Cart API Docs:** http://localhost:8002/docs
- **Order API Docs:** http://localhost:8003/docs
- **Payment API Docs:** http://localhost:8004/docs

These provide a web interface to test all endpoints!

## Troubleshooting

### "Cannot connect" errors

Make sure port-forwarding is running:
```powershell
kubectl get pods -n ecommerce
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001
```

### Dashboard shows "No orders"

1. Make sure you created an order (see steps above)
2. Check order service is running: `kubectl get pods -n ecommerce -l app=order-service`
3. Refresh the dashboard (it auto-refreshes every 5 seconds)

### Services not responding

Check pod logs:
```powershell
kubectl logs -n ecommerce deployment/catalog-service
kubectl logs -n ecommerce deployment/order-service
```

