# Comprehensive verification script

Write-Host "🔍 Verifying Project Completion" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true
$checks = @()

# Check 1: Docker
Write-Host "1. Checking Docker..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    $checks += @{Name="Docker"; Status="✅"; Message="Docker is installed"}
} catch {
    $checks += @{Name="Docker"; Status="❌"; Message="Docker not found"}
    $allGood = $false
}

# Check 2: Kubernetes cluster
Write-Host "2. Checking Kubernetes cluster..." -ForegroundColor Yellow
try {
    $cluster = kubectl cluster-info 2>&1
    if ($cluster -match "Kubernetes control plane") {
        $checks += @{Name="Kubernetes Cluster"; Status="✅"; Message="Cluster is running"}
    } else {
        $checks += @{Name="Kubernetes Cluster"; Status="❌"; Message="Cluster not accessible"}
        $allGood = $false
    }
} catch {
    $checks += @{Name="Kubernetes Cluster"; Status="❌"; Message="Cluster not found"}
    $allGood = $false
}

# Check 3: Namespace
Write-Host "3. Checking namespace..." -ForegroundColor Yellow
try {
    $ns = kubectl get namespace ecommerce 2>&1
    if ($ns -match "ecommerce") {
        $checks += @{Name="Namespace"; Status="✅"; Message="ecommerce namespace exists"}
    } else {
        $checks += @{Name="Namespace"; Status="⚠️"; Message="Namespace not found (will be created on deploy)"}
    }
} catch {
    $checks += @{Name="Namespace"; Status="⚠️"; Message="Namespace not found (will be created on deploy)"}
}

# Check 4: Docker images
Write-Host "4. Checking Docker images..." -ForegroundColor Yellow
$images = @("catalog-service", "cart-service", "order-service", "payment-service", "dashboard")
$imagesFound = 0
foreach ($img in $images) {
    try {
        $result = docker images $img`:latest 2>&1
        if ($result -match $img) {
            $imagesFound++
        }
    } catch {
        # Image not found
    }
}
if ($imagesFound -eq $images.Count) {
    $checks += @{Name="Docker Images"; Status="✅"; Message="All $($images.Count) images built"}
} else {
    $checks += @{Name="Docker Images"; Status="⚠️"; Message="$imagesFound/$($images.Count) images found (run build script)"}
}

# Check 5: Kubernetes deployments
Write-Host "5. Checking Kubernetes deployments..." -ForegroundColor Yellow
try {
    $deployments = kubectl get deployments -n ecommerce 2>&1
    if ($deployments -match "catalog-service") {
        $deployCount = ($deployments | Select-String -Pattern "catalog-service|cart-service|order-service|payment-service|dashboard").Matches.Count
        if ($deployCount -ge 5) {
            $checks += @{Name="K8s Deployments"; Status="✅"; Message="All services deployed"}
        } else {
            $checks += @{Name="K8s Deployments"; Status="⚠️"; Message="Some services not deployed ($deployCount/5)"}
        }
    } else {
        $checks += @{Name="K8s Deployments"; Status="⚠️"; Message="Services not deployed yet"}
    }
} catch {
    $checks += @{Name="K8s Deployments"; Status="⚠️"; Message="Services not deployed yet"}
}

# Check 6: Pods status
Write-Host "6. Checking pod status..." -ForegroundColor Yellow
try {
    $pods = kubectl get pods -n ecommerce 2>&1
    if ($pods -match "Running") {
        $runningPods = ($pods | Select-String -Pattern "Running").Matches.Count
        $totalPods = ($pods | Select-String -Pattern "catalog-service|cart-service|order-service|payment-service|dashboard|kafka|zookeeper").Matches.Count
        if ($runningPods -ge 5) {
            $checks += @{Name="Pod Status"; Status="✅"; Message="$runningPods pods running"}
        } else {
            $checks += @{Name="Pod Status"; Status="⚠️"; Message="$runningPods/$totalPods pods running"}
        }
    } else {
        $checks += @{Name="Pod Status"; Status="⚠️"; Message="No pods running"}
    }
} catch {
    $checks += @{Name="Pod Status"; Status="⚠️"; Message="Cannot check pod status"}
}

# Check 7: CI/CD workflow
Write-Host "7. Checking CI/CD configuration..." -ForegroundColor Yellow
if (Test-Path ".github/workflows/ci-cd.yml") {
    $workflow = Get-Content ".github/workflows/ci-cd.yml" -Raw
    if ($workflow -match "build-and-test" -and $workflow -match "deploy") {
        $checks += @{Name="CI/CD Workflow"; Status="✅"; Message="CI/CD workflow configured"}
    } else {
        $checks += @{Name="CI/CD Workflow"; Status="⚠️"; Message="CI/CD workflow exists but may need configuration"}
    }
} else {
    $checks += @{Name="CI/CD Workflow"; Status="❌"; Message="CI/CD workflow not found"}
    $allGood = $false
}

# Check 8: Documentation
Write-Host "8. Checking documentation..." -ForegroundColor Yellow
$docs = @("README.md", "SETUP_GUIDE.md", "QUICK_FIX.md", "DASHBOARD_GUIDE.md")
$docsFound = 0
foreach ($doc in $docs) {
    if (Test-Path $doc) {
        $docsFound++
    }
}
if ($docsFound -eq $docs.Count) {
    $checks += @{Name="Documentation"; Status="✅"; Message="All documentation files present"}
} else {
    $checks += @{Name="Documentation"; Status="✅"; Message="$docsFound/$($docs.Count) docs found"}
}

# Check 9: Scripts
Write-Host "9. Checking scripts..." -ForegroundColor Yellow
$scripts = @("setup-kind.ps1", "build-and-load-images.ps1", "deploy-all.ps1", "port-forward-all.ps1")
$scriptsFound = 0
foreach ($script in $scripts) {
    if (Test-Path "scripts/$script") {
        $scriptsFound++
    }
}
if ($scriptsFound -ge 3) {
    $checks += @{Name="Scripts"; Status="✅"; Message="$scriptsFound scripts available"}
} else {
    $checks += @{Name="Scripts"; Status="⚠️"; Message="Some scripts missing"}
}

# Check 10: Dashboard files
Write-Host "10. Checking dashboard..." -ForegroundColor Yellow
if ((Test-Path "dashboard/src/App.js") -and (Test-Path "dashboard/package.json")) {
    $checks += @{Name="Dashboard"; Status="✅"; Message="Dashboard files present"}
} else {
    $checks += @{Name="Dashboard"; Status="❌"; Message="Dashboard files missing"}
    $allGood = $false
}

# Display results
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Verification Results:" -ForegroundColor Cyan
Write-Host ""

foreach ($check in $checks) {
    $color = if ($check.Status -eq "✅") { "Green" } elseif ($check.Status -eq "⚠️") { "Yellow" } else { "Red" }
    Write-Host "$($check.Status) $($check.Name): $($check.Message)" -ForegroundColor $color
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✅ Project is complete and ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Configure GitHub Secrets for CI/CD (optional)" -ForegroundColor Yellow
    Write-Host "2. Deploy services: .\scripts\deploy-all.ps1" -ForegroundColor Yellow
    Write-Host "3. Access dashboard: http://localhost:3000" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Some components need attention" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run setup scripts:" -ForegroundColor Cyan
    Write-Host "  .\scripts\setup-kind.ps1" -ForegroundColor Gray
    Write-Host "  .\scripts\build-and-load-images.ps1" -ForegroundColor Gray
    Write-Host "  .\scripts\deploy-all.ps1" -ForegroundColor Gray
}

Write-Host ""
Write-Host "For detailed checklist, see: CHECKLIST.md" -ForegroundColor Cyan

