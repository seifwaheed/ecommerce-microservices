# PowerShell script to check prerequisites

Write-Host "🔍 Checking Prerequisites..." -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "  ✅ Docker installed: $dockerVersion" -ForegroundColor Green
    
    # Check if Docker is running
    try {
        docker ps | Out-Null
        Write-Host "  ✅ Docker Desktop is running" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Docker Desktop is NOT running!" -ForegroundColor Red
        Write-Host "     Please start Docker Desktop and wait for it to be ready." -ForegroundColor Yellow
        $allGood = $false
    }
} catch {
    Write-Host "  ❌ Docker is not installed!" -ForegroundColor Red
    Write-Host "     Download from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

# Check kubectl
Write-Host "Checking kubectl..." -ForegroundColor Yellow
try {
    $kubectlVersion = kubectl version --client 2>&1
    Write-Host "  ✅ kubectl installed" -ForegroundColor Green
} catch {
    Write-Host "  ❌ kubectl is not installed!" -ForegroundColor Red
    Write-Host "     Install with: choco install kubernetes-cli" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

# Check KinD
Write-Host "Checking KinD..." -ForegroundColor Yellow
try {
    $kindVersion = kind version 2>&1
    Write-Host "  ✅ KinD installed: $kindVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ KinD is not installed!" -ForegroundColor Red
    Write-Host "     Install with: choco install kind" -ForegroundColor Yellow
    $allGood = $false
}

Write-Host ""

if ($allGood) {
    Write-Host "✅ All prerequisites are installed and ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. .\scripts\setup-kind.ps1" -ForegroundColor Yellow
    Write-Host "  2. .\scripts\build-and-load-images.ps1" -ForegroundColor Yellow
    Write-Host "  3. .\scripts\deploy-all.ps1" -ForegroundColor Yellow
} else {
    Write-Host "❌ Please install missing prerequisites before proceeding." -ForegroundColor Red
    Write-Host ""
    Write-Host "See SETUP_GUIDE.md for detailed installation instructions." -ForegroundColor Yellow
    exit 1
}

