# Deployment Rapid - HW4

## Problema: Deployment ZIP Failed

Dacă deployment-ul ZIP eșuează, încearcă aceste soluții:

## Soluția 1: Script PowerShell (Recomandat)

```powershell
cd HW4
.\deploy.ps1
```

Scriptul va:
- Builda aplicația
- Crea ZIP-ul corect
- Deploya în Azure

## Soluția 2: Deployment Manual

### Pasul 1: Build Local

```powershell
cd HW4
dotnet publish MoneyShop\MoneyShop.csproj -c Release -o publish
```

### Pasul 2: Verifică Build-ul

```powershell
cd publish
Get-ChildItem
```

Ar trebui să vezi:
- `MoneyShop.dll`
- `appsettings.json`
- Alte DLL-uri

### Pasul 3: Creează ZIP

```powershell
cd ..
Compress-Archive -Path "publish\*" -DestinationPath "publish.zip" -Force
```

### Pasul 4: Deploy

```powershell
az webapp deployment source config-zip `
  --resource-group "MoneyShop" `
  --name "MoneyShop20260107220205" `
  --src "publish.zip"
```

## Soluția 3: Verifică Logurile

Accesează logurile de deployment:
```
https://moneyshop20260107220205-adbnf8c7a2fec4d4.scm.canadacentral-01.azurewebsites.net/api/deployments
```

Sau:
- Azure Portal → App Service → **Deployment Center** → **Logs**

## Soluția 4: Deployment prin Visual Studio

1. Deschide `HW4\MoneyShop\MoneyShop.csproj` în Visual Studio
2. Click dreapta pe proiect → **Publish**
3. Selectează **Azure** → **Azure App Service (Linux)**
4. Selectează `MoneyShop20260107220205`
5. Click **Publish**

## Soluția 5: Verifică Runtime Stack

Azure Portal → App Service → **Configuration** → **Stack settings**:
- **Stack:** .NET
- **Version:** 6.0

## După Deployment

1. **Configurează App Settings:**
   - Vezi `AZURE_CONFIGURATION_GUIDE.md`

2. **Testează:**
   ```powershell
   Invoke-RestMethod -Uri "https://moneyshop20260107220205-adbnf8c7a2fec4d4.canadacentral-01.azurewebsites.net/api/openai-plugin/info"
   ```

## Probleme Comune

### "Build failed"
- Verifică că toate fișierele sunt prezente
- Verifică că `.csproj` este corect

### "ZIP deployment failed"
- Verifică că ZIP-ul conține `MoneyShop.dll`
- Verifică dimensiunea ZIP-ului (nu trebuie să fie prea mare)

### "Application not starting"
- Verifică logurile: Azure Portal → **Log stream**
- Verifică App Settings (Azure OpenAI configurat)

---

**Cel mai sigur:** Folosește Visual Studio Publish sau Git deployment!

