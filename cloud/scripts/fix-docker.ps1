# PowerShell script to help diagnose and fix Docker issues

Write-Host "🔍 Docker Desktop Diagnostic Tool" -ForegroundColor Cyan
Write-Host ""

# Check if Docker command exists
Write-Host "1. Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "   ✅ Docker CLI found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Docker CLI not found!" -ForegroundColor Red
    Write-Host "   Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Check Docker Desktop status
Write-Host "2. Checking Docker Desktop status..." -ForegroundColor Yellow

# Try multiple methods to check Docker
$dockerWorking = $false
$errorDetails = ""

# Method 1: docker version (fastest)
Write-Host "   Testing: docker version..." -ForegroundColor Gray
try {
    $versionOutput = docker version 2>&1 | Out-String
    if ($versionOutput -match "Server:" -and $versionOutput -match "Version") {
        Write-Host "   ✅ docker version works!" -ForegroundColor Green
        $dockerWorking = $true
    } else {
        $errorDetails += "docker version: $versionOutput`n"
    }
} catch {
    $errorDetails += "docker version failed: $_`n"
}

# Method 2: docker info (more detailed)
if (-not $dockerWorking) {
    Write-Host "   Testing: docker info..." -ForegroundColor Gray
    try {
        $infoOutput = docker info 2>&1 | Out-String
        if ($infoOutput -match "Server Version" -and $infoOutput -notmatch "error") {
            Write-Host "   ✅ docker info works!" -ForegroundColor Green
            $dockerWorking = $true
            $serverVersion = ($infoOutput | Select-String -Pattern "Server Version:\s+(.+)" | ForEach-Object { $_.Matches.Groups[1].Value })
            Write-Host "   Server Version: $serverVersion" -ForegroundColor White
        } else {
            $errorDetails += "docker info: $infoOutput`n"
        }
    } catch {
        $errorDetails += "docker info failed: $_`n"
    }
}

# Method 3: docker ps (simple test)
if (-not $dockerWorking) {
    Write-Host "   Testing: docker ps..." -ForegroundColor Gray
    try {
        $psOutput = docker ps 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ docker ps works!" -ForegroundColor Green
            $dockerWorking = $true
        } else {
            $errorDetails += "docker ps: $psOutput`n"
        }
    } catch {
        $errorDetails += "docker ps failed: $_`n"
    }
}

if ($dockerWorking) {
    Write-Host ""
    Write-Host "   ✅ Docker Desktop is running and ready!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "   ❌ Docker Desktop is NOT ready!" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Error details:" -ForegroundColor Yellow
    Write-Host "   $errorDetails" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Solutions (try in order):" -ForegroundColor Yellow
    Write-Host "   1. Check Docker Desktop is running (system tray icon)" -ForegroundColor White
    Write-Host "   2. Wait 30-60 seconds after Docker Desktop starts" -ForegroundColor White
    Write-Host "   3. Restart Docker Desktop (right-click tray icon > Restart)" -ForegroundColor White
    Write-Host "   4. Check WSL2 is installed: wsl --status" -ForegroundColor White
    Write-Host "   5. Try: docker context use desktop-linux" -ForegroundColor White
    Write-Host "   6. Check Docker Desktop Settings > General > Use WSL 2 based engine" -ForegroundColor White
    Write-Host ""
    Write-Host "   Quick test commands:" -ForegroundColor Cyan
    Write-Host "   docker version" -ForegroundColor Gray
    Write-Host "   docker ps" -ForegroundColor Gray
    Write-Host "   docker info" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# Test Docker functionality
Write-Host "3. Testing Docker functionality..." -ForegroundColor Yellow
try {
    $containers = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Docker is working correctly!" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Docker command returned an error" -ForegroundColor Yellow
        Write-Host "   $containers" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Docker test failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Docker Desktop is ready to use!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run:" -ForegroundColor Cyan
Write-Host "  .\scripts\setup-kind.ps1" -ForegroundColor Yellow

