Param(
    [string]$Namespace = "argocd"
)

Write-Host "=== Creating Argo CD namespace '$Namespace' (if not exists) ==="
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -

Write-Host "=== Installing Argo CD into namespace '$Namespace' ==="
kubectl apply -n $Namespace -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Write-Host "=== Waiting for Argo CD pods to be ready (this may take a few minutes) ==="
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n $Namespace
kubectl get pods -n $Namespace

Write-Host "=== Applying Argo CD Application manifests for ecommerce and kafka ==="
kubectl apply -f ./cloud/argocd/applications/ -n $Namespace

Write-Host ""
Write-Host "=== Argo CD installed and applications registered ==="
Write-Host "To open the Argo CD UI, run this in a separate PowerShell window:"
Write-Host "  kubectl port-forward svc/argocd-server -n $Namespace 8080:443"
Write-Host "Then open https://localhost:8080 in your browser (accept the certificate warning)."


