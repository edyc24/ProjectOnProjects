# Homework 1 - Deploy Static Web Page to Azure Storage
# Script PowerShell pentru deployment automat

# Configurare
$resourceGroupName = "moneyshop-hw1-rg"
$storageAccountName = "moneyshophw1" + (Get-Random -Minimum 1000 -Maximum 9999)  # Numele trebuie să fie unic global
$location = "West Europe"
$staticWebsiteContainer = "$web"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Homework 1 - Azure Storage Static Website" -ForegroundColor Cyan
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

# Creează Storage Account
Write-Host "2. Creare Storage Account..." -ForegroundColor Yellow
$storageExists = az storage account show --name $storageAccountName --resource-group $resourceGroupName 2>$null
if (-not $storageExists) {
    az storage account create `
        --name $storageAccountName `
        --resource-group $resourceGroupName `
        --location $location `
        --sku Standard_LRS `
        --kind StorageV2
    
    Write-Host "✓ Storage Account creat: $storageAccountName" -ForegroundColor Green
} else {
    Write-Host "✓ Storage Account există deja: $storageAccountName" -ForegroundColor Green
}
Write-Host ""

# Activează static website hosting
Write-Host "3. Activare Static Website Hosting..." -ForegroundColor Yellow
az storage blob service-properties update `
    --account-name $storageAccountName `
    --static-website `
    --404-document "404.html" `
    --index-document "index.html"

Write-Host "✓ Static Website Hosting activat" -ForegroundColor Green
Write-Host ""

# Obține cheia de acces
Write-Host "4. Obținere cheie de acces..." -ForegroundColor Yellow
$storageKey = az storage account keys list `
    --account-name $storageAccountName `
    --resource-group $resourceGroupName `
    --query "[0].value" `
    --output tsv

Write-Host "✓ Cheie de acces obținută" -ForegroundColor Green
Write-Host ""

# Upload fișierele
Write-Host "5. Upload fișiere..." -ForegroundColor Yellow

# Upload index.html
if (Test-Path "index.html") {
    az storage blob upload `
        --account-name $storageAccountName `
        --account-key $storageKey `
        --container-name $staticWebsiteContainer `
        --name "index.html" `
        --file "index.html" `
        --content-type "text/html" `
        --overwrite

    Write-Host "✓ index.html uploadat" -ForegroundColor Green
} else {
    Write-Host "⚠ index.html nu a fost găsit!" -ForegroundColor Yellow
}

# Upload 404.html (dacă există)
if (Test-Path "404.html") {
    az storage blob upload `
        --account-name $storageAccountName `
        --account-key $storageKey `
        --container-name $staticWebsiteContainer `
        --name "404.html" `
        --file "404.html" `
        --content-type "text/html" `
        --overwrite
    
    Write-Host "✓ 404.html uploadat" -ForegroundColor Green
}

# Upload CSS (dacă există)
if (Test-Path "styles.css") {
    az storage blob upload `
        --account-name $storageAccountName `
        --account-key $storageKey `
        --container-name $staticWebsiteContainer `
        --name "styles.css" `
        --file "styles.css" `
        --content-type "text/css" `
        --overwrite
    
    Write-Host "✓ styles.css uploadat" -ForegroundColor Green
}

Write-Host ""

# Obține URL-ul static website
Write-Host "6. Obținere URL static website..." -ForegroundColor Yellow
$primaryEndpoint = az storage account show `
    --name $storageAccountName `
    --resource-group $resourceGroupName `
    --query "primaryEndpoints.web" `
    --output tsv

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "✓ DEPLOYMENT COMPLET!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URL-ul paginii tale statice:" -ForegroundColor Cyan
Write-Host $primaryEndpoint -ForegroundColor Yellow
Write-Host ""
Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Cyan
Write-Host "Storage Account: $storageAccountName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pentru a șterge resursele, rulează:" -ForegroundColor Yellow
Write-Host "az group delete --name $resourceGroupName --yes" -ForegroundColor Gray
Write-Host ""

