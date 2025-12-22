#!/bin/bash

set -e

echo "🚀 Deploying all services to Kubernetes..."

# Create namespace
echo "📁 Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Deploy Kafka first
echo "📦 Deploying Kafka..."
kubectl apply -f kafka/

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kafka -n ecommerce || true
kubectl wait --for=condition=available --timeout=300s deployment/zookeeper -n ecommerce || true

# Deploy all services
echo "📦 Deploying microservices..."
kubectl apply -f k8s/catalog/
kubectl apply -f k8s/cart/
kubectl apply -f k8s/order/
kubectl apply -f k8s/payment/
kubectl apply -f k8s/dashboard/

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/catalog-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/cart-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/order-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/payment-service -n ecommerce
kubectl wait --for=condition=available --timeout=300s deployment/dashboard -n ecommerce

echo "✅ All services deployed successfully!"
echo ""
echo "📊 Service endpoints:"
echo "  Catalog Service: http://localhost:8001 (port-forward needed)"
echo "  Cart Service: http://localhost:8002 (port-forward needed)"
echo "  Order Service: http://localhost:8003 (port-forward needed)"
echo "  Payment Service: http://localhost:8004 (port-forward needed)"
echo "  Dashboard: http://localhost:30000"
echo ""
echo "To port-forward services:"
echo "  kubectl port-forward svc/catalog-service -n ecommerce 8001:8001"
echo "  kubectl port-forward svc/cart-service -n ecommerce 8002:8002"
echo "  kubectl port-forward svc/order-service -n ecommerce 8003:8003"
echo "  kubectl port-forward svc/payment-service -n ecommerce 8004:8004"

