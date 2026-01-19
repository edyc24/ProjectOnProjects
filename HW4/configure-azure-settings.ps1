# PowerShell script pentru configurare rapidă Azure App Settings
# Rulează acest script pentru a configura Azure OpenAI în Azure App Service

Write-Host "Configurare Azure App Settings pentru Azure OpenAI..." -ForegroundColor Green

# Variabile - MODIFICĂ ACESTE VALORI!
$resourceGroup = "MoneyShop"
$appServiceName = "MoneyShop20260107220205"  # Numele App Service-ului tău

# Credențiale Azure OpenAI
$endpoint = "https://openaimoneyshop.openai.azure.com"
$apiKey = Read-Host "Introdu API Key Azure OpenAI" -AsSecureString
$deploymentName = "gpt-4o-mini"
$apiVersion = "2024-02-15-preview"

# Convertește SecureString la string
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey)
$plainApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host "`nConfigurare App Settings pentru: $appServiceName" -ForegroundColor Yellow
Write-Host "Resource Group: $resourceGroup" -ForegroundColor Yellow

# Verifică dacă Azure CLI este instalat
try {
    $azVersion = az --version 2>&1
    Write-Host "Azure CLI detectat" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI nu este instalat!" -ForegroundColor Red
    Write-Host "Instalează Azure CLI: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Verifică dacă utilizatorul este autentificat
try {
    $account = az account show 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Autentificare Azure necesară..." -ForegroundColor Yellow
        az login
    }
} catch {
    Write-Host "Autentificare Azure necesară..." -ForegroundColor Yellow
    az login
}

# Configurează App Settings
Write-Host "`nConfigurare App Settings..." -ForegroundColor Yellow

az webapp config appsettings set `
  --resource-group $resourceGroup `
  --name $appServiceName `
  --settings `
    AzureOpenAI__Endpoint=$endpoint `
    AzureOpenAI__ApiKey=$plainApiKey `
    AzureOpenAI__DeploymentName=$deploymentName `
    AzureOpenAI__ApiVersion=$apiVersion

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ App Settings configurate cu succes!" -ForegroundColor Green
    
    # Restart aplicația
    Write-Host "`nRestart aplicație..." -ForegroundColor Yellow
    az webapp restart --resource-group $resourceGroup --name $appServiceName
    
    Write-Host "`n✅ Aplicație restartată!" -ForegroundColor Green
    Write-Host "`nApp Settings configurate:" -ForegroundColor Cyan
    Write-Host "  - AzureOpenAI__Endpoint = $endpoint"
    Write-Host "  - AzureOpenAI__ApiKey = [HIDDEN]"
    Write-Host "  - AzureOpenAI__DeploymentName = $deploymentName"
    Write-Host "  - AzureOpenAI__ApiVersion = $apiVersion"
    Write-Host "`nAșteaptă 1-2 minute pentru ca aplicația să pornească complet." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ Eroare la configurare!" -ForegroundColor Red
    Write-Host "Verifică:" -ForegroundColor Yellow
    Write-Host "  1. Numele resource group-ului este corect: $resourceGroup"
    Write-Host "  2. Numele App Service-ului este corect: $appServiceName"
    Write-Host "  3. Ai permisiuni pentru a modifica App Settings"
}

