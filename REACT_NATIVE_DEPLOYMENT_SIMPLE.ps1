# Simple Deployment Script for React Native App
# Run this script after building the app with: npm run build:web

$resourceGroupName = "moneyshop-react-native-rg"
$storageAccountName = "moneyshoprn" + (Get-Random -Minimum 1000 -Maximum 9999)
$location = "West Europe"
$webBuildPath = "MoneyShopMobile\dist"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "React Native Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if build exists
if (-not (Test-Path $webBuildPath)) {
    Write-Host "ERROR: Build folder not found!" -ForegroundColor Red
    Write-Host "Run: cd MoneyShopMobile && npm run build:web" -ForegroundColor Yellow
    exit 1
}

Write-Host "Build found: $webBuildPath" -ForegroundColor Green
Write-Host ""

# Create Resource Group
Write-Host "Creating Resource Group..." -ForegroundColor Yellow
az group create --name $resourceGroupName --location $location
Write-Host ""

# Create Storage Account
Write-Host "Creating Storage Account: $storageAccountName" -ForegroundColor Yellow
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS --kind StorageV2
Write-Host ""

# Enable static website
Write-Host "Enabling Static Website Hosting..." -ForegroundColor Yellow
az storage blob service-properties update --account-name $storageAccountName --static-website --404-document "index.html" --index-document "index.html"
Write-Host ""

# Get storage key
Write-Host "Getting storage key..." -ForegroundColor Yellow
$storageKey = az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" --output tsv
Write-Host ""

# Upload files
Write-Host "Uploading files..." -ForegroundColor Yellow
$files = Get-ChildItem -Path $webBuildPath -Recurse -File
foreach ($file in $files) {
    $relativePath = $file.FullName.Substring((Resolve-Path $webBuildPath).Path.Length + 1)
    $blobName = $relativePath.Replace('\', '/')
    
    $contentType = "application/octet-stream"
    $ext = [System.IO.Path]::GetExtension($file.Name).ToLower()
    if ($ext -eq ".html") { $contentType = "text/html" }
    elseif ($ext -eq ".css") { $contentType = "text/css" }
    elseif ($ext -eq ".js") { $contentType = "application/javascript" }
    elseif ($ext -eq ".json") { $contentType = "application/json" }
    elseif ($ext -eq ".png") { $contentType = "image/png" }
    elseif ($ext -eq ".jpg" -or $ext -eq ".jpeg") { $contentType = "image/jpeg" }
    elseif ($ext -eq ".svg") { $contentType = "image/svg+xml" }
    elseif ($ext -eq ".ttf" -or $ext -eq ".woff" -or $ext -eq ".woff2") { $contentType = "font/$ext" }
    
    az storage blob upload --account-name $storageAccountName --account-key $storageKey --container-name '$web' --name $blobName --file $file.FullName --content-type $contentType --overwrite --output none 2>$null
    Write-Host "  Uploaded: $blobName" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Get URL
$primaryEndpoint = az storage account show --name $storageAccountName --resource-group $resourceGroupName --query "primaryEndpoints.web" --output tsv

Write-Host "React Native App URL:" -ForegroundColor Cyan
Write-Host $primaryEndpoint -ForegroundColor Yellow
Write-Host ""
Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Cyan
Write-Host "Storage Account: $storageAccountName" -ForegroundColor Cyan
Write-Host ""

