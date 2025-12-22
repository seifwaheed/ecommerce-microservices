# Quick Docker test script

Write-Host "Testing Docker connection..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Version
Write-Host "1. Docker version:" -ForegroundColor Yellow
docker version 2>&1
Write-Host ""

# Test 2: Info
Write-Host "2. Docker info:" -ForegroundColor Yellow
docker info 2>&1 | Select-Object -First 10
Write-Host ""

# Test 3: List containers
Write-Host "3. Docker containers:" -ForegroundColor Yellow
docker ps 2>&1
Write-Host ""

# Test 4: Context
Write-Host "4. Docker context:" -ForegroundColor Yellow
docker context ls 2>&1
Write-Host ""

Write-Host "If all above work, Docker is ready!" -ForegroundColor Green
Write-Host "If you see errors, Docker Desktop needs more time or a restart." -ForegroundColor Yellow

