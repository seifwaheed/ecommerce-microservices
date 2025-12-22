# Complete E-Commerce Dashboard Guide

## 🎉 New Features

The dashboard has been completely redesigned with a full e-commerce interface! You can now:

### 📊 Dashboard Tab
- View statistics (products, cart items, orders, revenue)
- See recent orders at a glance
- Quick access to all sections

### 📦 Products Tab
- Browse all products in the catalog
- View product details (name, price, description, stock, category)
- Add products directly to cart
- **Create new products** (admin feature)

### 🛒 Cart Tab
- View all items in your cart
- Adjust quantities
- Remove items
- See cart total
- **Checkout and create orders** with one click

### 📋 Orders Tab
- View all orders
- See order status and details
- **Process payments** directly from the dashboard
- View detailed order information in a modal

## 🚀 How to Deploy the New Dashboard

### Step 1: Rebuild the Dashboard

```powershell
.\scripts\rebuild-dashboard.ps1
```

This will:
- Build the new dashboard Docker image
- Load it into your KinD cluster
- Restart the dashboard deployment

### Step 2: Start Port-Forwarding

You need to port-forward all services for the dashboard to work:

```powershell
.\scripts\port-forward-all.ps1
```

Or manually:
```powershell
# Terminal 1 - Dashboard
kubectl port-forward svc/dashboard -n ecommerce 3000:80

# Terminal 2 - Services
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001
kubectl port-forward svc/cart-service -n ecommerce 8002:8002
kubectl port-forward svc/order-service -n ecommerce 8003:8003
kubectl port-forward svc/payment-service -n ecommerce 8004:8004
```

### Step 3: Access the Dashboard

Open your browser:
**http://localhost:3000**

## 🎯 Using the Dashboard

### 1. Browse Products
- Go to the **Products** tab
- See all available products
- Click "Add to Cart" on any product

### 2. Manage Cart
- Go to the **Cart** tab
- Adjust quantities with +/- buttons
- Remove items you don't want
- Click "Checkout & Create Order" when ready

### 3. Create Orders
- After checkout, your order is automatically created
- Go to the **Orders** tab to see it
- Click on an order to see details

### 4. Process Payments
- In the **Orders** tab, find orders with "pending" status
- Click "Process Payment" button
- Order status will update to "paid"

### 5. Create Products (Admin)
- Go to **Products** tab
- Scroll down to "Create New Product" form
- Fill in product details
- Click "Create Product"

## 🔧 Configuration

The dashboard uses environment variables for service URLs. In Kubernetes, these are set in the deployment. For local development, you can set them:

```powershell
$env:REACT_APP_CATALOG_URL="http://localhost:8001"
$env:REACT_APP_CART_URL="http://localhost:8002"
$env:REACT_APP_ORDER_URL="http://localhost:8003"
$env:REACT_APP_PAYMENT_URL="http://localhost:8004"
```

## 🎨 Features

- **Real-time Updates**: Dashboard refreshes every 5 seconds
- **User Persistence**: Your user ID is saved in localStorage
- **Responsive Design**: Works on desktop and mobile
- **Error Handling**: Shows helpful error messages
- **Modal Details**: Click orders to see full details
- **Status Colors**: Visual status indicators for orders

## 🐛 Troubleshooting

### Dashboard shows "Failed to connect"

Make sure all services are port-forwarded:
```powershell
.\scripts\port-forward-all.ps1
```

### Can't add products

Check catalog service is running:
```powershell
kubectl get pods -n ecommerce -l app=catalog-service
```

### Cart is empty

Make sure cart service is accessible and you've added items from the Products tab.

### Orders not showing

Check order service:
```powershell
kubectl logs -n ecommerce deployment/order-service
```

## 📱 Quick Start Workflow

1. **Start port-forwarding**: `.\scripts\port-forward-all.ps1`
2. **Open dashboard**: http://localhost:3000
3. **Browse products**: Click Products tab
4. **Add to cart**: Click "Add to Cart" on products
5. **Checkout**: Go to Cart tab, click "Checkout & Create Order"
6. **View order**: Go to Orders tab
7. **Process payment**: Click "Process Payment" on pending orders

Enjoy your complete e-commerce dashboard! 🎉

