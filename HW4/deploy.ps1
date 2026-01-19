# PowerShell Deployment Script pentru HW4 - Azure OpenAI Plugin
# Acest script build-ează și deploy-ează aplicația în Azure App Service

param(
    [string]$ResourceGroup = "MoneyShop",
    [string]$AppServiceName = "MoneyShop20260107220205",
    [string]$AppServicePlanName = "MoneyShop20260107220205Plan",
    [string]$Location = "Canada Central"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Green
Write-Host "Azure OpenAI Plugin - Deployment Script" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Verifică Azure CLI
Write-Host "Verificare Azure CLI..." -ForegroundColor Yellow
try {
    $azVersion = az --version 2>&1
    Write-Host "✓ Azure CLI detectat" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI nu este instalat!" -ForegroundColor Red
    Write-Host "Instalează Azure CLI: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Verifică autentificare
Write-Host "Verificare autentificare Azure..." -ForegroundColor Yellow
$account = az account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Autentificare necesară..." -ForegroundColor Yellow
    az login
}

# Navigare la folderul HW4
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1. Build Aplicație" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Clean previous builds
if (Test-Path "publish") {
    Remove-Item -Recurse -Force "publish"
}
if (Test-Path "publish.zip") {
    Remove-Item -Force "publish.zip"
}

# Build aplicația
Write-Host "Build aplicație..." -ForegroundColor Yellow

# Verifică dacă există proiectul
if (-not (Test-Path "MoneyShop\MoneyShop.csproj")) {
    Write-Host "❌ Nu se găsește MoneyShop.csproj!" -ForegroundColor Red
    Write-Host "Asigură-te că ești în folderul HW4 și că proiectul este complet." -ForegroundColor Yellow
    exit 1
}

# Build
dotnet publish "MoneyShop\MoneyShop.csproj" -c Release -o "publish" --self-contained false

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Build completat" -ForegroundColor Green
Write-Host ""

# Verifică că există fișierele necesare
$dllPath = "publish\MoneyShop.dll"
if (-not (Test-Path $dllPath)) {
    Write-Host "❌ Nu se găsește MoneyShop.dll în publish!" -ForegroundColor Red
    Write-Host "Verifică structura proiectului." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "2. Creare Pachet ZIP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Creează ZIP
Write-Host "Creare ZIP..." -ForegroundColor Yellow
$zipPath = Join-Path $scriptPath "publish.zip"

# Șterge ZIP vechi
if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

# Creează ZIP cu toate fișierele din publish
Compress-Archive -Path "publish\*" -DestinationPath $zipPath -Force

if (-not (Test-Path $zipPath)) {
    Write-Host "❌ Nu s-a putut crea ZIP!" -ForegroundColor Red
    exit 1
}

$zipSize = (Get-Item $zipPath).Length / 1MB
Write-Host "✓ ZIP creat: $zipPath ($([math]::Round($zipSize, 2)) MB)" -ForegroundColor Green
Write-Host ""

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "3. Deployment în Azure" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Verifică dacă App Service există
Write-Host "Verificare App Service..." -ForegroundColor Yellow
$appExists = az webapp show --name $AppServiceName --resource-group $ResourceGroup 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ App Service '$AppServiceName' nu există!" -ForegroundColor Red
    Write-Host "Creează App Service-ul mai întâi sau actualizează numele în script." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ App Service găsit" -ForegroundColor Green
Write-Host ""

# Deploy
Write-Host "Deployment în progres..." -ForegroundColor Yellow
Write-Host "Aceasta poate dura câteva minute..." -ForegroundColor Yellow
Write-Host ""

$deployResult = az webapp deployment source config-zip `
    --resource-group $ResourceGroup `
    --name $AppServiceName `
    --src $zipPath `
    2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Deployment completat cu succes!" -ForegroundColor Green
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    Write-Host "Eroare:" -ForegroundColor Yellow
    Write-Host $deployResult -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifică logurile de deployment:" -ForegroundColor Yellow
    Write-Host "https://$AppServiceName.scm.azurewebsites.net/api/deployments" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✓ DEPLOYMENT COMPLET!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Obține URL-ul aplicației
$appUrl = az webapp show `
    --name $AppServiceName `
    --resource-group $ResourceGroup `
    --query "defaultHostName" `
    --output tsv

Write-Host "Application URL: https://$appUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "API Endpoints:" -ForegroundColor Yellow
Write-Host "  - GET  https://$appUrl/api/openai-plugin/info" -ForegroundColor White
Write-Host "  - POST https://$appUrl/api/openai-plugin/prompt" -ForegroundColor White
Write-Host ""
Write-Host "Web Interface:" -ForegroundColor Yellow
Write-Host "  - https://$appUrl/openai-plugin" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: Configurează Azure App Settings!" -ForegroundColor Yellow
Write-Host "   Vezi: HW4\AZURE_CONFIGURATION_GUIDE.md" -ForegroundColor White
Write-Host ""
Write-Host "Așteaptă 1-2 minute pentru ca aplicația să pornească complet." -ForegroundColor Yellow
Write-Host ""

