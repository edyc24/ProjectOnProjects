# Configurare Baza de Date Azure SQL

## Connection String Actualizat

Connection string-ul pentru Azure SQL Database a fost actualizat în `appsettings.json`:

```
Server=tcp:moneyshop.database.windows.net,1433;Initial Catalog=moneyshop;Persist Security Info=False;User ID=alexmoore;Password=Moneyshop2026?;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

## Pași pentru Configurare

### 1. Verifică Firewall-ul Azure SQL

Azure SQL Database are un firewall care blochează conexiunile din afara Azure. Trebuie să adaugi IP-ul tău:

1. Deschide Azure Portal
2. Navighează la SQL Database → `moneyshop`
3. Click pe "Set server firewall" în meniul stâng
4. Adaugă IP-ul tău curent sau activează "Allow Azure services and resources to access this server"

**Pentru Development:**
- Adaugă IP-ul local pentru a te conecta din Visual Studio/terminal
- Poți folosi "Add client IP" pentru a adăuga automat IP-ul curent

**Pentru Production:**
- Configurează firewall-ul pentru a permite conexiuni doar din IP-urile necesare
- Sau folosește Azure App Service cu "Allow Azure services" activat

### 2. Aplică Migrațiile Entity Framework

După ce firewall-ul este configurat, aplică migrațiile la baza de date Azure:

```powershell
cd MoneyShop
dotnet ef database update --project ../DataAccess
```

Sau dacă ești în root:
```powershell
dotnet ef database update --project DataAccess --startup-project MoneyShop
```

### 3. Verifică Conexiunea

Testează conexiunea rulând aplicația:

```powershell
cd MoneyShop
dotnet run
```

### 4. Populează Datele Inițiale (dacă e necesar)

Dacă baza de date este goală, poate fi necesar să rulezi scripturile de populare:

```sql
-- Conectează-te la Azure SQL Database prin SSMS sau Azure Data Studio
-- Rulează scriptul pentru roluri (dacă e necesar)
-- DataAccess/Scripts/PopulateRoles.sql
```

## Configurare pentru Environment-uri Diferite

### Development (appsettings.Development.json)
Pentru development local, poți păstra connection string-ul local sau să folosești Azure:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MoneyShop;Integrated Security=True;TrustServerCertificate=True;MultipleActiveResultSets=True;"
  }
}
```

### Production (appsettings.json)
Connection string-ul Azure este deja configurat în `appsettings.json`.

## Securitate

⚠️ **IMPORTANT**: Connection string-ul conține credențiale sensibile!

Pentru production, folosește:
- **Azure Key Vault** pentru stocarea securizată a connection string-ului
- **Managed Identity** pentru autentificare fără parolă
- **Azure App Service Configuration** pentru variabile de mediu

### Exemplu cu Azure Key Vault:

```csharp
// În Program.cs
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{builder.Configuration["KeyVaultName"]}.vault.azure.net/"),
    new DefaultAzureCredential());
```

## Troubleshooting

### Eroare: "Cannot open server requested by the login"
- Verifică că firewall-ul Azure permite IP-ul tău
- Verifică că username-ul și parola sunt corecte
- Verifică că serverul Azure SQL este activ

### Eroare: "Connection Timeout"
- Verifică că serverul Azure SQL este accesibil
- Verifică că nu există probleme de rețea
- Mărește `Connection Timeout` în connection string dacă e necesar

### Eroare: "MultipleActiveResultSets is not supported"
- Azure SQL Database nu suportă `MultipleActiveResultSets=True`
- Connection string-ul este deja configurat cu `MultipleActiveResultSets=False`

## Note

- Parola din connection string este `Moneyshop2026?` (fără acolade)
- `Encrypt=True` este obligatoriu pentru Azure SQL
- `TrustServerCertificate=False` este recomandat pentru securitate
- `Connection Timeout=30` este setat la 30 secunde

