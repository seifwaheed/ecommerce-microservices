# E-Commerce Microservices Project

A containerized microservices e-commerce backend with fully isolated services for catalog, carts, orders, and payments. The system is deployed on a local Kubernetes cluster using KinD and managed by ArgoCD using GitOps principles.

## 🏗️ Architecture

- **Catalog Service** (Port 8001): Products CRUD operations
- **Cart Service** (Port 8002): User cart management (add/remove items)
- **Order Service** (Port 8003): Order creation and tracking with Kafka events
- **Payment Service** (Port 8004): Fake payment confirmation
- **Order Tracking Dashboard** (Port 30000): Real-time order status monitoring

## 🛠️ Technologies

- **FastAPI**: Microservices framework (Python)
- **Docker**: Containerization
- **KinD**: Local Kubernetes cluster
- **Kubernetes**: Container orchestration
- **ArgoCD**: GitOps deployment automation
- **Kafka**: Event-driven communication
- **React**: Order tracking dashboard
- **SQLite**: Data storage (in-memory for demo)

## 📁 Project Structure

```
cloud/
├── services/
│   ├── catalog/          # Catalog microservice
│   ├── cart/             # Cart microservice
│   ├── order/            # Order microservice
│   └── payment/          # Payment microservice
├── dashboard/            # React order tracking dashboard
├── k8s/                  # Kubernetes manifests
│   ├── catalog/
│   ├── cart/
│   ├── order/
│   ├── payment/
│   └── dashboard/
├── argocd/               # ArgoCD GitOps configurations
│   └── applications/
├── kafka/                # Kafka deployment manifests
├── scripts/              # Setup and deployment scripts
└── .github/workflows/    # CI/CD pipelines
```

## 📋 Prerequisites

- **Docker Desktop** installed and running
- **kubectl** installed ([Install Guide](https://kubernetes.io/docs/tasks/tools/))
- **KinD** installed:
  - Windows: `choco install kind`
  - macOS: `brew install kind`
  - Linux: See [KinD Installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- **Git** for cloning the repository

## 🚀 Quick Start Guide

**New to the project?** See `QUICK_START.md` for a 5-minute setup guide!

**Want detailed steps?** See `NEXT_STEPS.md` for complete instructions.

### Option 1: Manual Deployment (Recommended for First Time)

#### Quick Setup (All Steps at Once)

**Windows (PowerShell):**
```powershell
.\scripts\setup-complete.ps1
```

This will run all steps automatically: check prerequisites → create cluster → build images → deploy services.

#### Step-by-Step Setup (If you prefer manual control)

**Step 1: Create KinD Cluster**

**Windows (PowerShell):**
```powershell
.\scripts\setup-kind.ps1
```

**Linux/macOS:**
```bash
chmod +x scripts/*.sh
./scripts/setup-kind.sh
```

**Step 2: Build and Load Docker Images**

**Windows:**
```powershell
.\scripts\build-and-load-images.ps1
```

**Linux/macOS:**
```bash
./scripts/build-and-load-images.sh
```

**Step 3: Deploy All Services**

**Windows:**
```powershell
.\scripts\deploy-all.ps1
```

**Linux/macOS:**
```bash
./scripts/deploy-all.sh
```

#### Step 4: Access the Dashboard

**Option A: NodePort (may not work on Windows)**
The dashboard should be accessible at: **http://localhost:30000**

**Option B: Port-Forwarding (Recommended)**
```powershell
kubectl port-forward svc/dashboard -n ecommerce 3000:80
```
Then open: **http://localhost:3000**

**Quick Access Script:**
```powershell
.\scripts\access-dashboard.ps1
```

#### Step 5: Create Test Orders

To see the dashboard in action, create some test orders:

```powershell
# Start port-forwarding for all services
.\scripts\port-forward-all.ps1

# In another terminal, create sample order
.\scripts\create-sample-order.ps1
```

Or test the full flow:
```powershell
.\scripts\test-ecommerce-flow.ps1
```

See `QUICK_TEST.md` for detailed testing instructions.

#### Step 6: Access Individual Services

To access individual services, use port-forwarding:
```bash
# Catalog Service
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001

# Cart Service
kubectl port-forward svc/cart-service -n ecommerce 8002:8002

# Order Service
kubectl port-forward svc/order-service -n ecommerce 8003:8003

# Payment Service
kubectl port-forward svc/payment-service -n ecommerce 8004:8004
```

### Option 2: GitOps Deployment with ArgoCD

#### Step 1: Create KinD Cluster
```bash
# Windows
.\scripts\setup-kind.ps1

# Linux/macOS
./scripts/setup-kind.sh
```

#### Step 2: Install ArgoCD

**Windows:**
```powershell
.\scripts\setup-argocd.ps1
```

**Linux/macOS:**
```bash
./scripts/setup-argocd.sh
```

#### Step 3: Update ArgoCD Application Configs

Before deploying, update the repository URL in `argocd/applications/*.yaml`:
```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/cloud.git  # Update this
```

#### Step 4: Deploy via ArgoCD

```bash
kubectl apply -f argocd/applications/
```

#### Step 5: Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open: **https://localhost:8080**
- Username: `admin`
- Password: (run the setup script to get it)

## 🧪 Testing the Services

### 1. Test Catalog Service

```bash
# Get all products
curl http://localhost:8001/products

# Get a specific product
curl http://localhost:8001/products/1

# Create a product
curl -X POST http://localhost:8001/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "price": 99.99, "stock": 10, "category": "Electronics"}'
```

### 2. Test Cart Service

```bash
# Add item to cart
curl -X POST http://localhost:8002/cart/user123/items \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'

# Get cart
curl http://localhost:8002/cart/user123
```

### 3. Test Order Service

```bash
# Create an order
curl -X POST http://localhost:8003/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user123"}'

# Get all orders
curl http://localhost:8003/orders

# Process payment for an order
curl -X POST http://localhost:8003/orders/1/payment
```

### 4. Test Payment Service

```bash
# Create a payment
curl -X POST http://localhost:8004/payments \
  -H "Content-Type: application/json" \
  -d '{"order_id": 1, "amount": 199.98}'
```

## 🔧 Development

### Running Services Locally

Each service can be run locally for development:

```bash
# Catalog Service
cd services/catalog
pip install -r requirements.txt
uvicorn main:app --reload --port 8001

# Cart Service
cd services/cart
pip install -r requirements.txt
uvicorn main:app --reload --port 8002

# Order Service
cd services/order
pip install -r requirements.txt
uvicorn main:app --reload --port 8003

# Payment Service
cd services/payment
pip install -r requirements.txt
uvicorn main:app --reload --port 8004
```

### Building Docker Images Manually

```bash
docker build -t catalog-service:latest ./services/catalog
docker build -t cart-service:latest ./services/cart
docker build -t order-service:latest ./services/order
docker build -t payment-service:latest ./services/payment
docker build -t dashboard:latest ./dashboard
```

### Running Dashboard Locally

```bash
cd dashboard
npm install
npm start
```

## 🔄 CI/CD Pipeline

**Status: ✅ Configured (needs GitHub secrets)**

The project includes a GitHub Actions CI/CD pipeline (`.github/workflows/ci-cd.yml`) that:

1. **Builds** Docker images for all services
2. **Pushes** images to Docker Hub (on push to main branch)
3. **Deploys** to Kubernetes cluster (on push to main branch)

### Quick Setup (5 minutes)

1. **Update workflow file:**
   - Edit `.github/workflows/ci-cd.yml`
   - Change `IMAGE_PREFIX: yourusername` to your Docker Hub username

2. **Add GitHub Secrets** (Repository → Settings → Secrets):
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password/token

3. **Push to GitHub** - CI/CD will run automatically!

See `CI_CD_SETUP.md` for detailed instructions.

## 📊 Monitoring

### View Pod Status

```bash
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
```

### View Logs

```bash
# Catalog Service logs
kubectl logs -f deployment/catalog-service -n ecommerce

# Order Service logs
kubectl logs -f deployment/order-service -n ecommerce
```

### Check Service Health

All services expose a `/health` endpoint:
```bash
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
curl http://localhost:8004/health
```

## 🧹 Cleanup

### Delete KinD Cluster

```bash
kind delete cluster --name ecommerce-cluster
```

### Delete All Resources

```bash
kubectl delete namespace ecommerce
kubectl delete namespace argocd
```

## 🚀 Cloud Extensions (Bonus)

### AWS Deployment

- Deploy to **EKS** (Elastic Kubernetes Service)
- Use **RDS** for persistent database storage
- Use **S3** for object storage
- Use **CloudWatch** for monitoring

### Azure Deployment

- Deploy to **AKS** (Azure Kubernetes Service)
- Use **Azure SQL** for database
- Use **Azure Blob Storage** for files
- Use **Azure Monitor** for observability

### GCP Deployment

- Deploy to **GKE** (Google Kubernetes Engine)
- Use **Cloud SQL** for database
- Use **Cloud Storage** for files
- Use **Cloud Monitoring** for metrics

## 📝 API Documentation

Once services are running, access interactive API docs:
- Catalog Service: http://localhost:8001/docs
- Cart Service: http://localhost:8002/docs
- Order Service: http://localhost:8003/docs
- Payment Service: http://localhost:8004/docs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - feel free to use this project for learning and development!

## 🆘 Troubleshooting

### Services not starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n ecommerce

# Check events
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

### Images not found

Make sure you've built and loaded images into KinD:
```bash
./scripts/build-and-load-images.sh
```

### Port already in use

Change the NodePort in `k8s/dashboard/service.yaml` or stop the conflicting service.

### Kafka connection issues

Wait for Kafka to be fully ready:
```bash
kubectl wait --for=condition=ready pod -l app=kafka -n ecommerce --timeout=300s
```

