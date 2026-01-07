# Setup Baza de Date Locală - MoneyShop

## Pași pentru crearea bazei de date locală

### 1. Deschide SQL Server Management Studio (SSMS)

- Conectează-te la serverul local: `P1-EDUARDCR` (sau `localhost`)
- Folosește Windows Authentication

### 2. Creează baza de date

**Opțiunea A: Folosind scriptul SQL**

1. Deschide fișierul `DataAccess/Scripts/CreateDatabase.sql` în SSMS
2. Verifică că calea pentru fișierele de date este corectă (poate fi diferită pe sistemul tău)
3. Rulează scriptul (F5)

**Opțiunea B: Manual în SSMS**

1. Click dreapta pe "Databases" → "New Database"
2. Nume: `MoneyShop`
3. Click "OK"

### 3. Verifică Connection String-ul

Connection string-ul este configurat în:
- **Development**: `MoneyShop/appsettings.Development.json`
- **Production**: `MoneyShop/appsettings.json`

Pentru serverul local, connection string-ul este:
```
Server=localhost;Database=MoneyShop;Integrated Security=True;TrustServerCertificate=True;MultipleActiveResultSets=True;
```

Dacă serverul tău are un nume diferit sau folosește o instanță named, actualizează connection string-ul:
- Pentru server cu nume: `Server=P1-EDUARDCR;Database=MoneyShop;...`
- Pentru instanță named: `Server=localhost\\SQLEXPRESS;Database=MoneyShop;...`

### 4. Rulează migrațiile Entity Framework

În terminal, în folderul proiectului:

```powershell
cd MoneyShop
dotnet ef database update --project ../DataAccess
```

Sau dacă ești în root:
```powershell
dotnet ef database update --project DataAccess --startup-project MoneyShop
```

### 5. Verifică că totul funcționează

Pornește aplicația:
```powershell
cd MoneyShop
dotnet run
```

Aplicația ar trebui să se conecteze la baza de date locală.

## Troubleshooting

### Eroare: "Cannot open database"

- Verifică că baza de date există: `SELECT name FROM sys.databases WHERE name = 'MoneyShop'`
- Verifică că ai permisiuni pe baza de date
- Verifică connection string-ul în `appsettings.Development.json`

### Eroare: "Login failed"

- Asigură-te că folosești Windows Authentication
- Verifică că user-ul Windows are permisiuni pe SQL Server

### Eroare: "Server not found"

- Încearcă `localhost` în loc de numele serverului
- Verifică că SQL Server rulează: `Services.msc` → "SQL Server (MSSQLSERVER)"
- Verifică că SQL Server Browser rulează (pentru instanțe named)

### Calea fișierelor de date este greșită

Pentru a găsi calea corectă:
```sql
SELECT name, physical_name 
FROM sys.master_files 
WHERE database_id = DB_ID('master');
```

Apoi actualizează scriptul `CreateDatabase.sql` cu calea corectă.

