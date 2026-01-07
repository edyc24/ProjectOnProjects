# 📱 Instrucțiuni Deployment React Native App

## ✅ Status

Aplicația React Native a fost **buildată cu succes**! Folder-ul `MoneyShopMobile/dist/` conține fișierele statice.

## 🚀 Deployment în Azure Storage

### Opțiunea 1: Script PowerShell (Recomandat)

**Prerequisit:** Azure CLI instalat și autentificat (`az login`)

```powershell
# Rulează scriptul simplificat
.\REACT_NATIVE_DEPLOYMENT_SIMPLE.ps1
```

### Opțiunea 2: Comenzi Manuale

Dacă scriptul nu funcționează, rulează comenzile manual:

```powershell
# 1. Setează variabilele
$resourceGroupName = "moneyshop-react-native-rg"
$storageAccountName = "moneyshoprn" + (Get-Random -Minimum 1000 -Maximum 9999)
$location = "West Europe"

# 2. Creează Resource Group
az group create --name $resourceGroupName --location $location

# 3. Creează Storage Account
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS --kind StorageV2

# 4. Activează Static Website Hosting
az storage blob service-properties update --account-name $storageAccountName --static-website --404-document "index.html" --index-document "index.html"

# 5. Obține cheia de acces
$storageKey = az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" --output tsv

# 6. Upload toate fișierele din dist/
$files = Get-ChildItem -Path "MoneyShopMobile\dist" -Recurse -File
foreach ($file in $files) {
    $relativePath = $file.FullName.Substring((Resolve-Path "MoneyShopMobile\dist").Path.Length + 1)
    $blobName = $relativePath.Replace('\', '/')
    
    # Determină content type
    $ext = [System.IO.Path]::GetExtension($file.Name).ToLower()
    $contentType = switch ($ext) {
        ".html" { "text/html" }
        ".css" { "text/css" }
        ".js" { "application/javascript" }
        ".json" { "application/json" }
        ".png" { "image/png" }
        ".jpg" { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".svg" { "image/svg+xml" }
        ".ttf" { "font/ttf" }
        ".woff" { "font/woff" }
        ".woff2" { "font/woff2" }
        default { "application/octet-stream" }
    }
    
    az storage blob upload --account-name $storageAccountName --account-key $storageKey --container-name '$web' --name $blobName --file $file.FullName --content-type $contentType --overwrite
}

# 7. Obține URL-ul
az storage account show --name $storageAccountName --resource-group $resourceGroupName --query "primaryEndpoints.web" --output tsv
```

### Opțiunea 3: Azure Portal (UI)

1. **Creează Storage Account:**
   - Azure Portal → Create a resource → Storage Account
   - Name: `moneyshoprn[random]`
   - Resource Group: `moneyshop-react-native-rg`
   - Location: `West Europe`
   - Performance: `Standard`
   - Redundancy: `LRS`

2. **Activează Static Website:**
   - Storage Account → Settings → Static website
   - Enable: `Yes`
   - Index document name: `index.html`
   - Error document path: `index.html`
   - Save

3. **Upload Fișiere:**
   - Storage Account → Containers → `$web`
   - Upload → Selectează toate fișierele din `MoneyShopMobile/dist/`
   - Upload

4. **Obține URL:**
   - Storage Account → Settings → Static website
   - Copiază **Primary endpoint**

## 🔧 Configurare CORS în Backend

După deployment, actualizează CORS în `MoneyShop/Program.cs` pentru a permite requests de la domeniul aplicației React Native:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactNative", policy =>
    {
        policy.WithOrigins(
            "https://[storage-account].z[location].web.core.windows.net", // Adaugă URL-ul aplicației React Native
            "http://localhost:8081",
            "http://localhost:19006"
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials();
    });
});
```

Apoi redeploy backend-ul în Azure App Service.

## 📍 URL-uri După Deployment

- **Frontend (React Native):** `https://[storage-account].z[location].web.core.windows.net`
- **Backend (ASP.NET Core):** `https://moneyshop20260107220205-adbnf8c7a2fec4d4.azurewebsites.net`
- **API:** `https://moneyshop20260107220205-adbnf8c7a2fec4d4.azurewebsites.net/api`

## ✅ Verificare

1. Accesează URL-ul aplicației React Native
2. Verifică că se încarcă corect
3. Testează login/register (ar trebui să se conecteze la backend-ul Azure)

## 🐛 Troubleshooting

### Azure CLI nu este instalat

Instalează Azure CLI:
```powershell
# Download de la: https://aka.ms/installazurecliwindows
# Sau folosește Azure Portal pentru deployment manual
```

### CORS Errors

Verifică că backend-ul permite CORS pentru domeniul aplicației React Native.

### API Connection Errors

Verifică că `constants.ts` folosește URL-ul corect al backend-ului Azure în production.

