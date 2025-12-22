# Comprehensive status display script

Write-Host "📊 E-Commerce System Status" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

# Docker Images
Write-Host "🐳 Docker Images:" -ForegroundColor Yellow
Write-Host ""
$images = docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | Select-String -Pattern "catalog|cart|order|payment|dashboard|kindest"
if ($images) {
    Write-Host $images -ForegroundColor Green
} else {
    Write-Host "  ⚠️  No service images found. Run: .\scripts\build-and-load-images.ps1" -ForegroundColor Yellow
}
Write-Host ""

# Kubernetes Cluster
Write-Host "☸️  Kubernetes Cluster:" -ForegroundColor Yellow
Write-Host ""
try {
    $cluster = kubectl cluster-info 2>&1 | Select-String -Pattern "Kubernetes control plane"
    if ($cluster) {
        Write-Host "  ✅ Cluster is running" -ForegroundColor Green
        $context = kubectl config current-context 2>&1
        Write-Host "  Context: $context" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ Cluster not accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Cluster not found" -ForegroundColor Red
}
Write-Host ""

# Pods Status
Write-Host "📦 Pods Status:" -ForegroundColor Yellow
Write-Host ""
try {
    $pods = kubectl get pods -n ecommerce --no-headers 2>&1
    if ($pods -and $pods -notmatch "NotFound") {
        $running = ($pods | Select-String -Pattern "Running").Matches.Count
        $total = ($pods | Select-String -Pattern "catalog|cart|order|payment|dashboard|kafka|zookeeper").Matches.Count
        Write-Host "  Running: $running/$total pods" -ForegroundColor $(if ($running -eq $total) { "Green" } else { "Yellow" })
        Write-Host ""
        kubectl get pods -n ecommerce --no-headers | ForEach-Object {
            $parts = $_ -split '\s+'
            $name = $parts[0]
            $ready = $parts[1]
            $status = $parts[2]
            $color = if ($status -eq "Running" -and $ready -match "1/1|2/2") { "Green" } elseif ($status -eq "Running") { "Yellow" } else { "Red" }
            Write-Host "    $name : $status ($ready)" -ForegroundColor $color
        }
    } else {
        Write-Host "  ⚠️  No pods found. Run: .\scripts\deploy-all.ps1" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Cannot check pods. Namespace might not exist." -ForegroundColor Yellow
}
Write-Host ""

# Services Status
Write-Host "🔌 Services:" -ForegroundColor Yellow
Write-Host ""
try {
    $services = kubectl get services -n ecommerce --no-headers 2>&1
    if ($services -and $services -notmatch "NotFound") {
        $serviceCount = ($services | Select-String -Pattern "catalog|cart|order|payment|dashboard|kafka|zookeeper").Matches.Count
        Write-Host "  ✅ $serviceCount services configured" -ForegroundColor Green
        kubectl get services -n ecommerce --no-headers | ForEach-Object {
            $parts = $_ -split '\s+'
            $name = $parts[0]
            $type = $parts[1]
            $ports = $parts[4]
            Write-Host "    $name : $type ($ports)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ⚠️  No services found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Cannot check services" -ForegroundColor Yellow
}
Write-Host ""

# Port Forwarding Status
Write-Host "🔗 Port Forwarding:" -ForegroundColor Yellow
Write-Host ""
$ports = @(8001, 8002, 8003, 8004, 3000)
$accessible = 0
foreach ($port in $ports) {
    try {
        $test = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet
        if ($test) {
            Write-Host "  ✅ Port $port is accessible" -ForegroundColor Green
            $accessible++
        } else {
            Write-Host "  ❌ Port $port is NOT accessible" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ❌ Port $port is NOT accessible" -ForegroundColor Red
    }
}

if ($accessible -eq 0) {
    Write-Host ""
    Write-Host "  ⚠️  No services are port-forwarded!" -ForegroundColor Yellow
    Write-Host "  Run: .\scripts\port-forward-all.ps1" -ForegroundColor Cyan
}
Write-Host ""

# GitHub CI/CD Status
Write-Host "🐙 GitHub CI/CD:" -ForegroundColor Yellow
Write-Host ""
if (Test-Path ".github/workflows/ci-cd.yml") {
    Write-Host "  ✅ CI/CD workflow file exists" -ForegroundColor Green
    $workflow = Get-Content ".github/workflows/ci-cd.yml" -Raw
    if ($workflow -match "IMAGE_PREFIX:\s*yourusername") {
        Write-Host "  ⚠️  Update IMAGE_PREFIX in workflow file" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Workflow configured" -ForegroundColor Green
    }
} else {
    Write-Host "  ❌ CI/CD workflow file not found" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "===========================" -ForegroundColor Cyan
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check images
$imageCount = (docker images --format "{{.Repository}}" | Select-String -Pattern "catalog-service|cart-service|order-service|payment-service|dashboard").Matches.Count
if ($imageCount -ge 5) {
    Write-Host "  ✅ Docker Images: $imageCount/5 built" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Docker Images: $imageCount/5 built" -ForegroundColor Yellow
    $allGood = $false
}

# Check pods
try {
    $pods = kubectl get pods -n ecommerce --no-headers 2>&1
    if ($pods -and $pods -notmatch "NotFound") {
        $running = ($pods | Select-String -Pattern "Running").Matches.Count
        $total = ($pods | Select-String -Pattern "catalog|cart|order|payment|dashboard|kafka|zookeeper").Matches.Count
        if ($running -ge 5) {
            Write-Host "  ✅ Kubernetes Pods: $running/$total running" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Kubernetes Pods: $running/$total running" -ForegroundColor Yellow
            $allGood = $false
        }
    } else {
        Write-Host "  ⚠️  Kubernetes Pods: Not deployed" -ForegroundColor Yellow
        $allGood = $false
    }
} catch {
    Write-Host "  ⚠️  Kubernetes Pods: Cannot check" -ForegroundColor Yellow
    $allGood = $false
}

# Check port-forwarding
if ($accessible -ge 3) {
    Write-Host "  ✅ Port Forwarding: $accessible/5 services accessible" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Port Forwarding: $accessible/5 services accessible" -ForegroundColor Yellow
    Write-Host "     Run: .\scripts\port-forward-all.ps1" -ForegroundColor Gray
}

Write-Host ""
if ($allGood -and $accessible -ge 3) {
    Write-Host "✅ System is ready to use!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Access dashboard: http://localhost:3000" -ForegroundColor Yellow
    Write-Host "  2. Create test order: .\scripts\create-sample-order.ps1" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Some components need attention" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run setup:" -ForegroundColor Cyan
    Write-Host "  .\scripts\setup-kind.ps1" -ForegroundColor Gray
    Write-Host "  .\scripts\build-and-load-images.ps1" -ForegroundColor Gray
    Write-Host "  .\scripts\deploy-all.ps1" -ForegroundColor Gray
    Write-Host "  .\scripts\port-forward-all.ps1" -ForegroundColor Gray
}

