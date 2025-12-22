# Step-by-Step Guide: What to Do Now

## 🎯 Current Status

Your e-commerce microservices project is **complete**! Here's exactly what to do next.

---

## ✅ Step 1: Verify Everything is Set Up

### Check if services are running:

```powershell
# Run the verification script
.\scripts\verify-complete.ps1
```

**Expected Result**: Should show ✅ for most items

### If services aren't deployed yet:

```powershell
# 1. Make sure KinD cluster exists
kind get clusters

# If no cluster, create it:
.\scripts\setup-kind.ps1

# 2. Build and load images
.\scripts\build-and-load-images.ps1

# 3. Deploy all services
.\scripts\deploy-all.ps1
```

**Wait 1-2 minutes** for all pods to start.

---

## ✅ Step 2: Start Port-Forwarding (REQUIRED)

The dashboard needs access to all services. Open a PowerShell terminal and run:

```powershell
.\scripts\port-forward-all.ps1
```

**Keep this terminal open!** This runs port-forwarding for all services.

**Alternative** (if script doesn't work):
```powershell
# Run each in separate terminals or use background jobs
kubectl port-forward svc/dashboard -n ecommerce 3000:80
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001
kubectl port-forward svc/cart-service -n ecommerce 8002:8002
kubectl port-forward svc/order-service -n ecommerce 8003:8003
kubectl port-forward svc/payment-service -n ecommerce 8004:8004
```

---

## ✅ Step 3: Access the Dashboard

1. **Open your web browser**
2. **Go to**: http://localhost:3000
3. **You should see**: The e-commerce dashboard with tabs (Dashboard, Products, Cart, Orders)

**If you see an error**:
- Make sure port-forwarding is running (Step 2)
- Wait 30 seconds and refresh
- Check: `kubectl get pods -n ecommerce` (all should be Running)

---

## ✅ Step 4: Test the Full E-Commerce Flow

### Option A: Use the Automated Script (Easiest)

In a **new PowerShell terminal** (keep port-forwarding running):

```powershell
.\scripts\test-ecommerce-flow.ps1
```

This will:
- Get products
- Add items to cart
- Create an order
- Process payment
- Show all orders

### Option B: Manual Testing via Dashboard

1. **Browse Products**:
   - Click "Products" tab
   - See all available products
   - Click "Add to Cart" on any product

2. **View Cart**:
   - Click "Cart" tab
   - See items you added
   - Adjust quantities with +/- buttons
   - Click "Checkout & Create Order"

3. **View Orders**:
   - Click "Orders" tab
   - See your order
   - Click "Process Payment" if status is "pending"
   - Click on order to see details

4. **Create Products** (Optional):
   - Go to Products tab
   - Scroll down to "Create New Product"
   - Fill in form and click "Create Product"

---

## ✅ Step 5: Verify Everything Works

### Check Pods:
```powershell
kubectl get pods -n ecommerce
```

**All should show**: `Running` status

### Check Services:
```powershell
kubectl get services -n ecommerce
```

**Should show**: catalog-service, cart-service, order-service, payment-service, dashboard

### Test API Endpoints (after port-forwarding):
```powershell
# Test catalog
Invoke-RestMethod http://localhost:8001/products

# Test cart
Invoke-RestMethod http://localhost:8002/cart/user123

# Test orders
Invoke-RestMethod http://localhost:8003/orders
```

---

## ✅ Step 6: (Optional) Set Up CI/CD

If you want automated deployments on GitHub:

### 6.1: Update Workflow File

1. Open `.github/workflows/ci-cd.yml`
2. Find line 11: `IMAGE_PREFIX: yourusername`
3. Change `yourusername` to your Docker Hub username
4. Save file

### 6.2: Add GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

   **Secret 1:**
   - Name: `DOCKER_USERNAME`
   - Value: Your Docker Hub username

   **Secret 2:**
   - Name: `DOCKER_PASSWORD`
   - Value: Your Docker Hub password (or access token)

### 6.3: Push to GitHub

```powershell
git add .
git commit -m "Configure CI/CD"
git push origin main
```

### 6.4: Check GitHub Actions

1. Go to your GitHub repository
2. Click **Actions** tab
3. You should see workflow running
4. Wait for it to complete (green checkmark = success)

**See `CI_CD_SETUP.md` for detailed instructions.**

---

## ✅ Step 7: Explore Advanced Features

### View API Documentation:

With port-forwarding active, visit:
- **Catalog API**: http://localhost:8001/docs
- **Cart API**: http://localhost:8002/docs
- **Order API**: http://localhost:8003/docs
- **Payment API**: http://localhost:8004/docs

These are interactive Swagger docs where you can test APIs directly!

### Check Logs:

```powershell
# View catalog service logs
kubectl logs -n ecommerce deployment/catalog-service --tail=50

# View order service logs
kubectl logs -n ecommerce deployment/order-service --tail=50
```

### Monitor Resources:

```powershell
# See resource usage
kubectl top pods -n ecommerce

# See all resources
kubectl get all -n ecommerce
```

---

## 🎯 Quick Reference Commands

### Start Everything:
```powershell
# Terminal 1: Port-forwarding
.\scripts\port-forward-all.ps1

# Terminal 2: Create test order
.\scripts\create-sample-order.ps1
```

### Check Status:
```powershell
# Verify everything
.\scripts\verify-complete.ps1

# Check pods
kubectl get pods -n ecommerce

# Check services
kubectl get services -n ecommerce
```

### Access Dashboard:
- **URL**: http://localhost:3000
- **Make sure**: Port-forwarding is running!

### Stop Everything:
```powershell
# Stop port-forwarding: Press Ctrl+C in terminal

# Delete cluster (if needed)
kind delete cluster --name ecommerce-cluster
```

---

## 📋 Checklist

- [ ] Step 1: Verified setup (ran verify script)
- [ ] Step 2: Started port-forwarding
- [ ] Step 3: Opened dashboard in browser
- [ ] Step 4: Tested e-commerce flow (added to cart, created order)
- [ ] Step 5: Verified all services working
- [ ] Step 6: (Optional) Set up CI/CD
- [ ] Step 7: (Optional) Explored API docs

---

## 🆘 Troubleshooting

### Dashboard shows "Failed to connect"
→ Make sure port-forwarding is running (Step 2)

### Can't add products to cart
→ Check catalog service: `kubectl get pods -n ecommerce -l app=catalog-service`

### Orders not showing
→ Check order service: `kubectl logs -n ecommerce deployment/order-service`

### Port-forwarding fails
→ Check pods are running: `kubectl get pods -n ecommerce`

### Need help?
→ See `TROUBLESHOOTING.md` or `QUICK_FIX.md`

---

## 🎉 You're Done!

Once you complete Steps 1-5, your e-commerce system is fully operational!

**What you can do:**
- ✅ Browse products
- ✅ Add to cart
- ✅ Create orders
- ✅ Process payments
- ✅ Track orders in real-time
- ✅ Create new products

**Next Steps (Optional):**
- Set up CI/CD for automated deployments
- Deploy to cloud (AWS/Azure/GCP)
- Add monitoring and logging
- Scale services

Enjoy your e-commerce microservices platform! 🚀

