#!/bin/bash

set -e

echo "🚀 Setting up ArgoCD..."

# Create argocd namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get initial admin password
echo ""
echo "🔑 ArgoCD Admin Credentials:"
echo "Username: admin"
echo "Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""

# Port forward ArgoCD server
echo ""
echo "🌐 To access ArgoCD UI, run:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then open: https://localhost:8080"
echo ""
echo "📝 Apply ArgoCD applications:"
echo "kubectl apply -f argocd/applications/"

