# Configurare Oracle Database pentru MoneyShop

## Pași Completați ✅

### 1. Pachet Oracle.EntityFrameworkCore
- ✅ Adăugat `Oracle.EntityFrameworkCore` versiunea 9.23.30 în `MoneyShop.csproj`

### 2. Connection String
- ✅ Actualizat `appsettings.json` cu connection string Oracle:
  ```json
  "DefaultConnection": "Data Source=localhost:1521/ORCLPDB;User Id=moneyshop;Password=moneyshop123;"
  ```

### 3. Program.cs
- ✅ Modificat `Program.cs` pentru a detecta automat Oracle vs SQL Server
- ✅ Adăugat `using Oracle.EntityFrameworkCore;`

## Pași Următori

### 4. Instalare Pachet
Rulează în terminal:
```bash
cd MoneyShop
dotnet restore
```

### 5. Verificare Connection String
Asigură-te că connection string-ul este corect:
- **Data Source**: `localhost:1521/ORCLPDB` (sau PDB-ul tău)
- **User Id**: `moneyshop` (sau `c##moneyshop` dacă ești în CDB$ROOT)
- **Password**: Parola ta

### 6. Testare Conexiune
Rulează aplicația și verifică dacă se conectează:
```bash
dotnet run
```

## Diferențe Oracle vs SQL Server

### Tipuri de Date
- `NVARCHAR` → `VARCHAR2` în Oracle
- `DATETIME2` → `TIMESTAMP` în Oracle
- `UNIQUEIDENTIFIER` → `RAW(16)` sau `VARCHAR2(36)` în Oracle

### Secvențe
- Oracle folosește secvențe pentru IDENTITY columns
- Entity Framework Core gestionează automat acest lucru

### Nume Tabele/Coloane
- Oracle face diferența între majuscule și minuscule
- Entity Framework Core mapează automat la UPPERCASE

## Troubleshooting

### Eroare: "ORA-12154: TNS:could not resolve the connect identifier"
**Soluție**: Verifică că Oracle Listener rulează:
```bash
# Windows
lsnrctl status

# Sau verifică serviciul Oracle
services.msc → OracleServiceXE (sau numele instanței tale)
```

### Eroare: "ORA-01017: invalid username/password"
**Soluție**: Verifică utilizatorul și parola în connection string

### Eroare: "ORA-65011: Pluggable database does not exist"
**Soluție**: Verifică numele PDB-ului:
```sql
SELECT name, open_mode FROM v$pdbs;
```

### Eroare: "Table or view does not exist"
**Soluție**: Asigură-te că tabelele există în schema utilizatorului:
```sql
SELECT table_name FROM user_tables;
```

## Comutare Înapoi la SQL Server

Dacă vrei să revii la SQL Server, modifică `appsettings.json`:
```json
"DefaultConnection": "Server=tcp:moneyshop.database.windows.net,1433;Initial Catalog=moneyshop;..."
```

Aplicația va detecta automat tipul de bază de date din connection string.

## Note Importante

1. **Migrații**: Dacă ai migrații Entity Framework, poate fi necesar să le regenerezi pentru Oracle
2. **Performance**: Oracle poate avea comportament diferit la queries complexe
3. **Case Sensitivity**: Oracle face diferența între majuscule și minuscule pentru numele obiectelor

## Verificare Finală

După configurare, testează:
1. Rulează aplicația: `dotnet run`
2. Verifică log-urile pentru erori de conexiune
3. Testează un endpoint API care accesează baza de date
4. Verifică în Oracle că datele sunt create corect

