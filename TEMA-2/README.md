# Homework 2 - Simple Web App in Azure App Service

## Date Student
**Nume:** [Numele tău complet]  
**URL:** [URL-ul aplicației după deployment - se generează automat]  
**Tehnologii:** ASP.NET Core 6.0  
**Baza de date:** Azure SQL Database

## Despre Aplicație

Am creat o pagină simplă unde poți adăuga items într-o listă. Fiecare item se salvează în baza de date Azure SQL și rămâne acolo chiar și după ce restart aplicația.

### Ce poți face

- **Input Field**: Introduci text în câmp
- **Buton Enter**: Click și se adaugă item-ul
- **Listă Items**: Vezi toate item-urile adăugate, cele mai noi primele
- **Persistență**: Totul se salvează în Azure SQL Database

### Unde o găsești

Pagina e la: `https://[app-service-url]/Home/Simple`

## Securitate

Am configurat baza de date să NU fie accesibilă public. Doar App Service-ul poate să se conecteze la ea.

### Firewall SQL

- **"Allow Azure Services"**: DEZACTIVAT (nu vreau să fie accesibilă de orice serviciu Azure)
- **IP-ul meu personal**: NU e permis (doar temporar pentru debugging dacă e nevoie)
- **IP-urile App Service**: PERMISE - doar acestea pot accesa baza de date

### Cum găsești IP-urile App Service

- Azure Portal → App Service → Properties → Outbound IP Addresses
- Sau prin Azure CLI: `az webapp show --name [app-name] --resource-group [rg-name] --query "outboundIpAddresses"`

## Deployment

### Ce ai nevoie

- Azure CLI instalat
- .NET 6.0 SDK instalat
- Să fii autentificat în Azure (`az login`)

### Pași

1. **Rulează scriptul:**
   ```powershell
   cd TEMA-2
   .\deploy.ps1
   ```

2. **Scriptul face:**
   - Creează Resource Group
   - Creează App Service Plan (B1, Linux)
   - Creează App Service
   - Creează SQL Server
   - Configurează Firewall SQL (doar IP-urile App Service)
   - Creează SQL Database
   - Configurează Connection String în App Settings
   - Build aplicația
   - Deploy aplicația

3. **După deployment, aplică migrațiile:**
   ```powershell
   cd ..\MoneyShop
   dotnet ef database update --project ../DataAccess --connection "Server=tcp:[sql-server].database.windows.net,1433;Initial Catalog=[db-name];User ID=[admin-user];Password=[admin-password];Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
   ```

4. **Populează rolurile (dacă e nevoie):**
   - Azure Portal → SQL Database → Query Editor
   - Rulează scriptul `DataAccess/Scripts/PopulateRoles.sql`

### Deployment Manual (Alternativă)

Dacă preferi să faci totul manual prin Azure Portal:

1. Creează resursele:
   - Resource Group
   - App Service Plan
   - App Service
   - SQL Server
   - SQL Database

2. Configurează Firewall:
   - Azure Portal → SQL Server → Networking
   - Adaugă doar outbound IP-urile App Service

3. Configurează Connection String:
   - Azure Portal → App Service → Configuration
   - Adaugă: `ConnectionStrings:DefaultConnection` = `[connection-string]`

4. Deploy aplicația:
   ```powershell
   cd MoneyShop
   dotnet publish -c Release -o ./publish
   Compress-Archive -Path ".\publish\*" -DestinationPath ".\publish.zip"
   az webapp deployment source config-zip --resource-group [rg-name] --name [app-name] --src .\publish.zip
   ```

## Testare

1. **Accesează aplicația:**
   - URL: `https://[app-service-url]`
   - Pagina simplă: `https://[app-service-url]/Home/Simple`

2. **Testează:**
   - Introdu un text
   - Click pe "Enter"
   - Verifică că apare în listă
   - Refresh pagina - ar trebui să rămână

3. **Verifică securitatea:**
   - Încearcă să te conectezi la SQL Database din SSMS cu IP-ul tău
   - Ar trebui să primești eroare (dacă IP-ul tău nu e în firewall)

## Fișiere

- `deploy.ps1` - Script pentru deployment automat
- `README.md` - Acest fișier

## Ștergere resurse

```powershell
az group delete --name moneyshop-hw2-rg --yes
```

## Note importante

- **Parola SQL**: Schimbă parola `$sqlAdminPassword` în script înainte de deployment!
- **Migrații**: Nu uita să aplici migrațiile EF Core după deployment
- **Firewall**: Verifică că firewall-ul SQL permite DOAR IP-urile App Service
