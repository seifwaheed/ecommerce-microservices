# Quick Start Guide

This guide will help you get the e-commerce microservices project up and running quickly.

## Prerequisites Check

Before starting, ensure you have:
- ✅ Docker Desktop running
- ✅ kubectl installed (`kubectl version --client`)
- ✅ KinD installed (`kind version`)

## Step-by-Step Setup

### 1. Clone and Navigate

```bash
cd cloud
```

### 2. Create KinD Cluster

**Windows:**
```powershell
.\scripts\setup-kind.ps1
```

**Linux/macOS:**
```bash
chmod +x scripts/*.sh
./scripts/setup-kind.sh
```

### 3. Build and Load Images

**Windows:**
```powershell
.\scripts\build-and-load-images.ps1
```

**Linux/macOS:**
```bash
./scripts/build-and-load-images.sh
```

This step builds Docker images for all services and loads them into your KinD cluster.

### 4. Deploy Services

**Windows:**
```powershell
.\scripts\deploy-all.ps1
```

**Linux/macOS:**
```bash
./scripts/deploy-all.sh
```

### 5. Verify Deployment

Check that all pods are running:
```bash
kubectl get pods -n ecommerce
```

You should see:
- catalog-service (2 replicas)
- cart-service (2 replicas)
- order-service (2 replicas)
- payment-service (2 replicas)
- dashboard (1 replica)
- kafka (1 replica)
- zookeeper (1 replica)

### 6. Access the Dashboard

Open your browser and navigate to:
**http://localhost:30000**

## Testing the Services

### Test Catalog Service

```bash
# Port-forward catalog service
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001

# In another terminal, test it
curl http://localhost:8001/products
```

### Test Order Flow

1. **Add products to catalog** (via API or use existing sample products)
2. **Add items to cart:**
   ```bash
   kubectl port-forward svc/cart-service -n ecommerce 8002:8002
   curl -X POST http://localhost:8002/cart/user123/items \
     -H "Content-Type: application/json" \
     -d '{"product_id": 1, "quantity": 2}'
   ```
3. **Create an order:**
   ```bash
   kubectl port-forward svc/order-service -n ecommerce 8003:8003
   curl -X POST http://localhost:8003/orders \
     -H "Content-Type: application/json" \
     -d '{"user_id": "user123"}'
   ```
4. **View orders in dashboard** at http://localhost:30000

## Alternative: Docker Compose (Local Development)

For local development without Kubernetes:

```bash
docker-compose up -d
```

Services will be available at:
- Catalog: http://localhost:8001
- Cart: http://localhost:8002
- Order: http://localhost:8003
- Payment: http://localhost:8004
- Dashboard: http://localhost:3000

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n ecommerce
kubectl logs <pod-name> -n ecommerce
```

### Images not found
Make sure you ran `build-and-load-images` script and images are loaded:
```bash
docker images | grep -E "catalog|cart|order|payment|dashboard"
```

### Port conflicts
Change NodePort in `k8s/dashboard/service.yaml` if port 30000 is in use.

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Explore API documentation at http://localhost:8001/docs (after port-forwarding)
- Set up ArgoCD for GitOps deployment (see README)
- Configure CI/CD pipeline (see `.github/workflows/ci-cd.yml`)

## Cleanup

To remove everything:
```bash
kind delete cluster --name ecommerce-cluster
```

