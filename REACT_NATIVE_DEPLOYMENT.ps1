# Deployment Script pentru React Native App în Azure Storage
# Similar cu Homework 1, dar pentru aplicația React Native

# Configurare
$resourceGroupName = "moneyshop-react-native-rg"
$storageAccountName = "moneyshoprn" + (Get-Random -Minimum 1000 -Maximum 9999)  # Numele trebuie să fie unic global
$location = "West Europe"
$staticWebsiteContainer = "$web"
$backendApiUrl = "https://moneyshop20260107220205-adbnf8c7a2fec4d4.azurewebsites.net/api"  # URL-ul backend-ului Azure

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "React Native App - Azure Storage Deployment" -ForegroundColor Cyan
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

# Verifică dacă aplicația este buildată
Write-Host "1. Verificare build aplicație..." -ForegroundColor Yellow
$webBuildPath = "MoneyShopMobile\dist"
if (-not (Test-Path $webBuildPath)) {
    Write-Host "⚠ Folder 'dist' nu există!" -ForegroundColor Yellow
    Write-Host "   Rulează mai întâi: cd MoneyShopMobile && npm run build:web" -ForegroundColor Yellow
    Write-Host ""
    $build = Read-Host "Vrei să build aplicația acum? (y/n)"
    if ($build -eq "y" -or $build -eq "Y") {
        Write-Host "   Building aplicație..." -ForegroundColor Gray
        Set-Location "MoneyShopMobile"
        $env:NODE_TLS_REJECT_UNAUTHORIZED = "0"
        npm run build:web
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Eroare la build!" -ForegroundColor Red
            Set-Location ".."
            exit 1
        }
        Set-Location ".."
        Write-Host "✓ Build completat" -ForegroundColor Green
    } else {
        Write-Host "❌ Deployment anulat - aplicația trebuie să fie buildată mai întâi" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Build găsit: $webBuildPath" -ForegroundColor Green
}
Write-Host ""

# Actualizează API URL în constants.ts (dacă e necesar)
Write-Host "2. Verificare configurare API URL..." -ForegroundColor Yellow
$constantsFile = "MoneyShopMobile\src\utils\constants.ts"
if (Test-Path $constantsFile) {
    $constantsContent = Get-Content $constantsFile -Raw
    if ($constantsContent -notmatch $backendApiUrl) {
        Write-Host "   ⚠ API URL-ul din constants.ts nu corespunde cu backend-ul Azure" -ForegroundColor Yellow
        Write-Host "   Backend URL: $backendApiUrl" -ForegroundColor Gray
        Write-Host "   Actualizează manual constants.ts dacă e necesar" -ForegroundColor Gray
    } else {
        Write-Host "✓ API URL configurat corect" -ForegroundColor Green
    }
}
Write-Host ""

# Creează Resource Group
Write-Host "3. Creare Resource Group..." -ForegroundColor Yellow
$rgExists = az group exists --name $resourceGroupName --output tsv
if ($rgExists -eq "false") {
    az group create --name $resourceGroupName --location $location
    Write-Host "✓ Resource Group creat: $resourceGroupName" -ForegroundColor Green
} else {
    Write-Host "✓ Resource Group există deja: $resourceGroupName" -ForegroundColor Green
}
Write-Host ""

# Creează Storage Account
Write-Host "4. Creare Storage Account..." -ForegroundColor Yellow
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
Write-Host "5. Activare Static Website Hosting..." -ForegroundColor Yellow
az storage blob service-properties update `
    --account-name $storageAccountName `
    --static-website `
    --404-document "index.html" `
    --index-document "index.html"

Write-Host "✓ Static Website Hosting activat" -ForegroundColor Green
Write-Host ""

# Obține cheia de acces
Write-Host "6. Obținere cheie de acces..." -ForegroundColor Yellow
$storageKey = az storage account keys list `
    --account-name $storageAccountName `
    --resource-group $resourceGroupName `
    --query "[0].value" `
    --output tsv

Write-Host "✓ Cheie de acces obținută" -ForegroundColor Green
Write-Host ""

# Upload fișierele
Write-Host "7. Upload fișiere din dist..." -ForegroundColor Yellow

$files = Get-ChildItem -Path $webBuildPath -Recurse -File
$totalFiles = $files.Count
$currentFile = 0

foreach ($file in $files) {
    $currentFile++
    $relativePath = $file.FullName.Substring((Resolve-Path $webBuildPath).Path.Length + 1)
    $blobName = $relativePath.Replace('\', '/')
    
    # Determină content type
    $contentType = "application/octet-stream"
    $extension = [System.IO.Path]::GetExtension($file.Name).ToLower()
    switch ($extension) {
        ".html" { $contentType = "text/html" }
        ".css" { $contentType = "text/css" }
        ".js" { $contentType = "application/javascript" }
        ".json" { $contentType = "application/json" }
        ".png" { $contentType = "image/png" }
        ".jpg" { $contentType = "image/jpeg" }
        ".jpeg" { $contentType = "image/jpeg" }
        ".svg" { $contentType = "image/svg+xml" }
        ".ico" { $contentType = "image/x-icon" }
        ".woff" { $contentType = "font/woff" }
        ".woff2" { $contentType = "font/woff2" }
        ".ttf" { $contentType = "font/ttf" }
    }
    
    Write-Progress -Activity "Uploading files" -Status "Uploading $blobName" -PercentComplete (($currentFile / $totalFiles) * 100)
    
    az storage blob upload `
        --account-name $storageAccountName `
        --account-key $storageKey `
        --container-name $staticWebsiteContainer `
        --name $blobName `
        --file $file.FullName `
        --content-type $contentType `
        --overwrite `
        --output none 2>$null
}

Write-Progress -Activity "Uploading files" -Completed
Write-Host "✓ $totalFiles fișiere uploadate" -ForegroundColor Green
Write-Host ""

# Obține URL-ul static website
Write-Host "8. Obținere URL static website..." -ForegroundColor Yellow
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
Write-Host "URL-ul aplicației React Native:" -ForegroundColor Cyan
Write-Host $primaryEndpoint -ForegroundColor Yellow
Write-Host ""
Write-Host "Backend API URL:" -ForegroundColor Cyan
Write-Host $backendApiUrl -ForegroundColor Yellow
Write-Host ""
Write-Host "Resource Group: $resourceGroupName" -ForegroundColor Cyan
Write-Host "Storage Account: $storageAccountName" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "1. Verifica ca backend-ul permite CORS pentru: $primaryEndpoint" -ForegroundColor Yellow
Write-Host "2. Actualizeaza API URL in constants.ts daca e necesar" -ForegroundColor Yellow
Write-Host "3. Testeaza aplicatia la URL-ul de mai sus" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pentru a sterge resursele, ruleaza:" -ForegroundColor Yellow
Write-Host ('az group delete --name ' + $resourceGroupName + ' --yes') -ForegroundColor Gray
Write-Host ""

