# Troubleshooting Deployment - HW4

## Eroare: "The attempt to publish the ZIP file... failed with HTTP status code 'Failed'"

### Cauze Posibile

1. **Proiectul nu se poate builda corect**
2. **Structura ZIP-ului este incorectă**
3. **Lipsesc dependențele necesare**
4. **Probleme cu runtime stack în Azure**

### Soluții

#### Soluția 1: Verifică Build-ul Local

```powershell
cd HW4
dotnet publish MoneyShop\MoneyShop.csproj -c Release -o publish
```

Dacă build-ul eșuează, verifică:
- Toate fișierele necesare sunt prezente
- Dependențele sunt corecte în `.csproj`
- Nu există erori de compilare

#### Soluția 2: Verifică Structura ZIP-ului

ZIP-ul trebuie să conțină:
- `MoneyShop.dll` (fișierul principal)
- `appsettings.json`
- Toate DLL-urile dependențelor
- `web.config` (dacă e necesar)

Verifică:
```powershell
cd HW4\publish
Get-ChildItem
```

#### Soluția 3: Deployment Manual prin Azure Portal

1. **Build local:**
   ```powershell
   cd HW4
   dotnet publish MoneyShop\MoneyShop.csproj -c Release -o publish
   Compress-Archive -Path "publish\*" -DestinationPath "publish.zip" -Force
   ```

2. **Deploy prin Azure Portal:**
   - Azure Portal → App Service → **Advanced Tools (Kudu)**
   - Sau: **Deployment Center** → **Local Git** / **FTP**
   - Upload manual `publish.zip`

#### Soluția 4: Deployment prin Kudu (SCM)

1. Accesează: `https://moneyshop20260107220205-adbnf8c7a2fec4d4.scm.canadacentral-01.azurewebsites.net`
2. Mergi la **Debug console** → **CMD**
3. Navighează la `site/wwwroot`
4. Upload `publish.zip` și dezarhivează-l

#### Soluția 5: Verifică Logurile de Deployment

Accesează:
```
https://moneyshop20260107220205-adbnf8c7a2fec4d4.scm.canadacentral-01.azurewebsites.net/api/deployments
```

Sau:
- Azure Portal → App Service → **Deployment Center** → **Logs**

#### Soluția 6: Deployment prin Git (Recomandat)

1. **Creează un repository Git local:**
   ```powershell
   cd HW4
   git init
   git add .
   git commit -m "Initial commit"
   ```

2. **Configurează Deployment Center:**
   - Azure Portal → App Service → **Deployment Center**
   - Selectează **Local Git**
   - Copiază Git URL-ul

3. **Push codul:**
   ```powershell
   git remote add azure [Git URL din Azure]
   git push azure main
   ```

Azure va builda și deploya automat.

#### Soluția 7: Verifică Runtime Stack

Verifică că runtime stack este corect:
- Azure Portal → App Service → **Configuration** → **Stack settings**
- **Stack:** .NET
- **Version:** 6.0

#### Soluția 8: Deployment prin Visual Studio

1. Deschide `HW4\MoneyShop\MoneyShop.csproj` în Visual Studio
2. Click dreapta pe proiect → **Publish**
3. Selectează **Azure** → **Azure App Service (Linux)**
4. Selectează App Service-ul tău
5. Click **Publish**

### Verificare Post-Deployment

După deployment, verifică:

1. **Logs:**
   - Azure Portal → App Service → **Log stream**
   - Sau: **Monitoring** → **Log stream**

2. **Test API:**
   ```powershell
   Invoke-RestMethod -Uri "https://moneyshop20260107220205-adbnf8c7a2fec4d4.canadacentral-01.azurewebsites.net/api/openai-plugin/info" -Method Get
   ```

3. **Verifică App Settings:**
   - Azure Portal → App Service → **Configuration** → **Application settings**
   - Asigură-te că toate setările Azure OpenAI sunt configurate

### Script PowerShell Complet

Folosește `deploy.ps1` din folderul HW4:

```powershell
cd HW4
.\deploy.ps1 -AppServiceName "MoneyShop20260107220205" -ResourceGroup "MoneyShop"
```

### Contact Support

Dacă problema persistă:
1. Verifică logurile detaliate în Azure Portal
2. Verifică status-ul App Service-ului
3. Verifică că toate dependențele sunt incluse în ZIP

---

**Notă:** Cel mai sigur mod de deployment este prin **Git** sau **Visual Studio Publish**, care gestionează automat build-ul și deployment-ul.

