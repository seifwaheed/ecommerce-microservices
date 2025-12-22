#!/bin/bash

set -e

echo "🚀 Setting up KinD cluster for E-Commerce Microservices..."

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "❌ KinD is not installed. Please install it first:"
    echo "   Windows: choco install kind"
    echo "   macOS: brew install kind"
    echo "   Linux: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

# Check if cluster already exists
if kind get clusters | grep -q "^ecommerce-cluster$"; then
    echo "⚠️  Cluster 'ecommerce-cluster' already exists. Deleting..."
    kind delete cluster --name ecommerce-cluster
fi

# Create cluster configuration
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
EOF

# Create cluster
echo "📦 Creating KinD cluster..."
kind create cluster --name ecommerce-cluster --config kind-config.yaml

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Create namespace
echo "📁 Creating namespace..."
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -

# Cleanup config file
rm -f kind-config.yaml

echo "✅ KinD cluster setup complete!"
echo ""
echo "Next steps:"
echo "1. Build and load Docker images:"
echo "   ./scripts/build-and-load-images.sh"
echo "2. Deploy Kafka:"
echo "   kubectl apply -f kafka/"
echo "3. Deploy services:"
echo "   kubectl apply -f k8s/"
echo "4. Or use ArgoCD for GitOps deployment"

