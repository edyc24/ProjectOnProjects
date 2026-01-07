# Homework 2 - Deploy Simple Web App to Azure App Service
# Script PowerShell pentru deployment automat

# Configurare
$resourceGroupName = "moneyshop-hw2-rg"
$appServicePlanName = "moneyshop-hw2-plan"
$appServiceName = "moneyshop-hw2-app" + (Get-Random -Minimum 1000 -Maximum 9999)  # Numele trebuie să fie unic global
$sqlServerName = "moneyshop-hw2-sql" + (Get-Random -Minimum 1000 -Maximum 9999)  # Numele trebuie să fie unic global
$sqlDatabaseName = "moneyshop-hw2-db"
$sqlAdminUser = "moneyshopadmin"
$sqlAdminPassword = "Moneyshop2026!"  # Schimbă această parolă!
$location = "West Europe"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Homework 2 - Azure App Service Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verifică dacă utilizatorul este autentificat în Azure
Write-Host "Verificare autentificare Azure..." -ForegroundColor Yellow
$account = az account show 2>$null
if (-not $account) {
    Write-Host "Nu ești autentificat în Azure. Te autentificăm..." -ForegroundColor Yellow
    az login
}

# Obține subscription ID
$subscriptionId = (az account show --query id -o tsv)
Write-Host "Subscription ID: $subscriptionId" -ForegroundColor Green
Write-Host ""

# Creează Resource Group
Write-Host "1. Creare Resource Group..." -ForegroundColor Yellow
$rgExists = az group exists --name $resourceGroupName --output tsv
if ($rgExists -eq "false") {
    az group create --name $resourceGroupName --location $location
    Write-Host "✓ Resource Group creat: $resourceGroupName" -ForegroundColor Green
} else {
    Write-Host "✓ Resource Group există deja: $resourceGroupName" -ForegroundColor Green
}
Write-Host ""

# Creează App Service Plan
Write-Host "2. Creare App Service Plan..." -ForegroundColor Yellow
$planExists = az appservice plan show --name $appServicePlanName --resource-group $resourceGroupName 2>$null
if (-not $planExists) {
    az appservice plan create `
        --name $appServicePlanName `
        --resource-group $resourceGroupName `
        --location $location `
        --sku B1 `
        --is-linux
    
    Write-Host "✓ App Service Plan creat: $appServicePlanName" -ForegroundColor Green
} else {
    Write-Host "✓ App Service Plan există deja: $appServicePlanName" -ForegroundColor Green
}
Write-Host ""

# Creează App Service
Write-Host "3. Creare App Service..." -ForegroundColor Yellow
$appExists = az webapp show --name $appServiceName --resource-group $resourceGroupName 2>$null
if (-not $appExists) {
    az webapp create `
        --name $appServiceName `
        --resource-group $resourceGroupName `
        --plan $appServicePlanName `
        --runtime "DOTNET|6.0"
    
    Write-Host "✓ App Service creat: $appServiceName" -ForegroundColor Green
} else {
    Write-Host "✓ App Service există deja: $appServiceName" -ForegroundColor Green
}
Write-Host ""

# Creează SQL Server
Write-Host "4. Creare SQL Server..." -ForegroundColor Yellow
$sqlServerExists = az sql server show --name $sqlServerName --resource-group $resourceGroupName 2>$null
if (-not $sqlServerExists) {
    az sql server create `
        --name $sqlServerName `
        --resource-group $resourceGroupName `
        --location $location `
        --admin-user $sqlAdminUser `
        --admin-password $sqlAdminPassword
    
    Write-Host "✓ SQL Server creat: $sqlServerName" -ForegroundColor Green
} else {
    Write-Host "✓ SQL Server există deja: $sqlServerName" -ForegroundColor Green
}
Write-Host ""

# Configurează SQL Server Firewall - DOAR pentru App Service
Write-Host "5. Configurare SQL Server Firewall..." -ForegroundColor Yellow

# Dezactivează "Allow Azure Services"
az sql server firewall-rule delete `
    --resource-group $resourceGroupName `
    --server $sqlServerName `
    --name "AllowAzureServices" `
    2>$null

# Obține outbound IP-urile App Service
Write-Host "   Obținere outbound IP-uri App Service..." -ForegroundColor Gray
$outboundIps = az webapp show `
    --name $appServiceName `
    --resource-group $resourceGroupName `
    --query "outboundIpAddresses" `
    --output tsv

$possibleOutboundIps = az webapp show `
    --name $appServiceName `
    --resource-group $resourceGroupName `
    --query "possibleOutboundIpAddresses" `
    --output tsv

# Adaugă fiecare IP în firewall
$allIps = ($outboundIps + " " + $possibleOutboundIps).Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object -Unique

foreach ($ip in $allIps) {
    $ruleName = "AppService-$($ip.Replace('.', '-'))"
    az sql server firewall-rule create `
        --resource-group $resourceGroupName `
        --server $sqlServerName `
        --name $ruleName `
        --start-ip-address $ip `
        --end-ip-address $ip `
        2>$null | Out-Null
}

Write-Host "✓ Firewall configurat - doar App Service IP-uri permise" -ForegroundColor Green
Write-Host "   IP-uri permise: $($allIps -join ', ')" -ForegroundColor Gray
Write-Host ""

# Creează SQL Database
Write-Host "6. Creare SQL Database..." -ForegroundColor Yellow
$dbExists = az sql db show --name $sqlDatabaseName --server $sqlServerName --resource-group $resourceGroupName 2>$null
if (-not $dbExists) {
    az sql db create `
        --resource-group $resourceGroupName `
        --server $sqlServerName `
        --name $sqlDatabaseName `
        --service-objective Basic
    
    Write-Host "✓ SQL Database creat: $sqlDatabaseName" -ForegroundColor Green
} else {
    Write-Host "✓ SQL Database există deja: $sqlDatabaseName" -ForegroundColor Green
}
Write-Host ""

# Construiește connection string
$connectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Initial Catalog=$sqlDatabaseName;Persist Security Info=False;User ID=$sqlAdminUser;Password=$sqlAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Configurează App Settings
Write-Host "7. Configurare App Settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $appServiceName `
    --resource-group $resourceGroupName `
    --settings "ConnectionStrings:DefaultConnection=$connectionString" `
    --output none

Write-Host "✓ App Settings configurate" -ForegroundColor Green
Write-Host ""

# Build și deploy aplicația
Write-Host "8. Build aplicație..." -ForegroundColor Yellow
Set-Location "..\MoneyShop"
dotnet publish -c Release -o ./publish
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Eroare la build!" -ForegroundColor Red
    Set-Location "..\TEMA-2"
    exit 1
}
Write-Host "✓ Build completat" -ForegroundColor Green
Write-Host ""

# Creează ZIP pentru deployment
Write-Host "9. Creare ZIP pentru deployment..." -ForegroundColor Yellow
$zipPath = ".\publish.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath
}
Compress-Archive -Path ".\publish\*" -DestinationPath $zipPath -Force
Write-Host "✓ ZIP creat: $zipPath" -ForegroundColor Green
Write-Host ""

# Deploy aplicația
Write-Host "10. Deployment aplicație..." -ForegroundColor Yellow
az webapp deployment source config-zip `
    --resource-group $resourceGroupName `
    --name $appServiceName `
    --src $zipPath `
    --output none

Write-Host "✓ Aplicație deployată" -ForegroundColor Green
Write-Host ""

# Obține URL-ul aplicației
$appUrl = az webapp show `
    --name $appServiceName `
    --resource-group $resourceGroupName `
    --query "defaultHostName" `
    --output tsv

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "✓ DEPLOYMENT COMPLET!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URL-ul aplicației:" -ForegroundColor Cyan
Write-Host "https://$appUrl" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pagina simplă (Homework 2):" -ForegroundColor Cyan
Write-Host "https://$appUrl/Home/Simple" -ForegroundColor Yellow
Write-Host ""
Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Cyan
Write-Host "App Service: $appServiceName" -ForegroundColor Cyan
Write-Host "SQL Server: $sqlServerName.database.windows.net" -ForegroundColor Cyan
Write-Host "SQL Database: $sqlDatabaseName" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️ IMPORTANT:" -ForegroundColor Yellow
Write-Host "1. Aplică migrațiile EF Core la baza de date Azure SQL" -ForegroundColor Yellow
Write-Host "2. Rulează scriptul PopulateRoles.sql pentru a crea rolurile" -ForegroundColor Yellow
Write-Host "3. Verifică că firewall-ul SQL permite DOAR IP-urile App Service" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pentru a șterge resursele, rulează:" -ForegroundColor Yellow
Write-Host "az group delete --name $resourceGroupName --yes" -ForegroundColor Gray
Write-Host ""

Set-Location "..\TEMA-2"

