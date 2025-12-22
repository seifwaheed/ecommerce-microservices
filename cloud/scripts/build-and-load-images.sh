#!/bin/bash

set -e

echo "🔨 Building and loading Docker images into KinD cluster..."

CLUSTER_NAME="ecommerce-cluster"

# Build catalog service
echo "📦 Building catalog-service..."
docker build -t catalog-service:latest ./services/catalog
kind load docker-image catalog-service:latest --name $CLUSTER_NAME

# Build cart service
echo "📦 Building cart-service..."
docker build -t cart-service:latest ./services/cart
kind load docker-image cart-service:latest --name $CLUSTER_NAME

# Build order service
echo "📦 Building order-service..."
docker build -t order-service:latest ./services/order
kind load docker-image order-service:latest --name $CLUSTER_NAME

# Build payment service
echo "📦 Building payment-service..."
docker build -t payment-service:latest ./services/payment
kind load docker-image payment-service:latest --name $CLUSTER_NAME

# Build dashboard
echo "📦 Building dashboard..."
docker build -t dashboard:latest ./dashboard
kind load docker-image dashboard:latest --name $CLUSTER_NAME

echo "✅ All images built and loaded successfully!"

