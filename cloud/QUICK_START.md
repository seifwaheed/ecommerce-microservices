# 🚀 Quick Start - Get Running in 5 Minutes

## Prerequisites Check

```powershell
# Run this first
.\scripts\check-prerequisites.ps1
```

Make sure Docker Desktop is running!

---

## Step 1: Deploy Everything (2 minutes)

```powershell
# If cluster doesn't exist
.\scripts\setup-kind.ps1

# Build and load images
.\scripts\build-and-load-images.ps1

# Deploy services
.\scripts\deploy-all.ps1
```

**Wait 1-2 minutes** for pods to start.

---

## Step 2: Start Port-Forwarding (1 minute)

**Open a PowerShell terminal** and run:

```powershell
.\scripts\port-forward-all.ps1
```

**Keep this terminal open!**

---

## Step 3: Open Dashboard (30 seconds)

1. Open browser
2. Go to: **http://localhost:3000**
3. You should see the dashboard!

---

## Step 4: Test It! (1 minute)

### Quick Test:

In a **new terminal**:

```powershell
.\scripts\create-sample-order.ps1
```

Then **refresh your dashboard** - you should see an order!

### Or Test Manually:

1. Click **Products** tab
2. Click **Add to Cart** on any product
3. Click **Cart** tab
4. Click **Checkout & Create Order**
5. Click **Orders** tab to see your order!

---

## ✅ Done!

Your e-commerce system is running! 🎉

**Access:**
- Dashboard: http://localhost:3000
- Catalog API: http://localhost:8001/docs
- Cart API: http://localhost:8002/docs
- Order API: http://localhost:8003/docs

**For detailed steps, see: `NEXT_STEPS.md`**

