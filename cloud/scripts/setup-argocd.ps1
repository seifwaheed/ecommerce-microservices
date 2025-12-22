# PowerShell script for Windows

Write-Host "🚀 Setting up ArgoCD..." -ForegroundColor Cyan

# Create argocd namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
Write-Host "📦 Installing ArgoCD..." -ForegroundColor Yellow
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
Write-Host "⏳ Waiting for ArgoCD to be ready..." -ForegroundColor Cyan
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get initial admin password
Write-Host ""
Write-Host "🔑 ArgoCD Admin Credentials:" -ForegroundColor Green
Write-Host "Username: admin" -ForegroundColor Yellow
Write-Host "Password:" -ForegroundColor Yellow
$password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
Write-Host ""

# Port forward ArgoCD server
Write-Host ""
Write-Host "🌐 To access ArgoCD UI, run:" -ForegroundColor Cyan
Write-Host "kubectl port-forward svc/argocd-server -n argocd 8080:443" -ForegroundColor Yellow
Write-Host ""
Write-Host "Then open: https://localhost:8080" -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 Apply ArgoCD applications:" -ForegroundColor Cyan
Write-Host "kubectl apply -f argocd\applications\" -ForegroundColor Yellow

