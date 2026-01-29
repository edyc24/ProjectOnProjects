# Configurare Data Warehouse - MoneyShop
## Ghid de instalare și configurare

---

## 📋 PREGĂTIRE

### 1. Instalare Oracle.ManagedDataAccess.Core

Pentru ca aplicația să poată accesa Oracle Database, instalează pachetul:

```bash
cd MoneyShop
dotnet add package Oracle.ManagedDataAccess.Core
```

Sau editează `MoneyShop.csproj` și adaugă:

```xml
<PackageReference Include="Oracle.ManagedDataAccess.Core" Version="23.6.0" />
```

### 2. Configurare Connection String

Editează `MoneyShop/appsettings.json` și adaugă/modifică connection string-ul pentru Oracle:

```json
"ConnectionStrings": {
  "DWConnection": "Data Source=localhost:1521/XEPDB1;User Id=moneyshop_dw_user;Password=MoneyShopDW2025!;",
  "OracleConnection": "Data Source=localhost:1521/XEPDB1;User Id=moneyshop_dw_user;Password=MoneyShopDW2025!;"
}
```

**Notă:** Adaptează connection string-ul la configurația ta Oracle:
- `localhost:1521` - host și port Oracle
- `XEPDB1` - numele database-ului (PDB)
- `moneyshop_dw_user` - utilizatorul DW
- `MoneyShopDW2025!` - parola

---

## 🚀 EXECUTARE SCRIPTURI

### Ordinea de execuție:

1. **01_CREATE_DW_SCHEMA.sql** (ca SYSDBA sau utilizator cu privilegii)
   - Creează schema DW și utilizatorul

2. **02_POPULATE_OLTP_TEST_DATA.sql** (în schema OLTP - MONEYSHOP)
   - Generează date test (dacă nu ai deja)

3. **03_CREATE_DW_TABLES.sql** (în schema DW - moneyshop_dw_user)
   - Creează toate tabelele DW

4. **04_ETL_EXTRACT.sql** (în schema DW)
   - Creează views pentru extract

5. **05_ETL_TRANSFORM.sql** (în schema DW)
   - Creează proceduri transformare

6. **06_ETL_LOAD.sql** (în schema DW)
   - Creează proceduri load

7. **Execută ETL:**
   ```sql
   EXEC SP_ETL_FULL_LOAD;
   ```

8. **07_DW_CONSTRAINTS.sql** (în schema DW)
   - Adaugă constrângeri

9. **08_DW_INDEXES.sql** (în schema DW)
   - Creează indecși

10. **09_DW_DIMENSIONS.sql** (în schema DW)
    - Creează obiecte dimensiune

11. **10_DW_PARTITIONS.sql** (în schema DW - opțional)
    - Documentație partiționare

12. **11_QUERY_OPTIMIZATION.sql** (în schema DW)
    - Testează optimizări

13. **12_REPORTS.sql** (în schema DW)
    - Creează view-uri pentru rapoarte

---

## 🔧 ACTUALIZARE CONTROLLER-E

După instalarea `Oracle.ManagedDataAccess.Core`, decomentează codul din:

- `MoneyShop/Controllers/ETLController.cs`
- `MoneyShop/Controllers/ReportsController.cs`

Înlocuiește:
```csharp
// TODO: Decomentează când instalezi Oracle.ManagedDataAccess.Core
/*
using var connection = new Oracle.ManagedDataAccess.Client.OracleConnection(connectionString);
*/
```

Cu:
```csharp
using Oracle.ManagedDataAccess.Client;
using var connection = new OracleConnection(connectionString);
```

---

## ✅ VERIFICARE

1. **Verificare ETL:**
   - Accesează: `/ETL/Status`
   - Verifică numărul de înregistrări în DW

2. **Verificare Rapoarte:**
   - Accesează: `/Reports`
   - Testează fiecare raport

3. **Verificare Validare:**
   - Accesează: `/ETL/Validate`
   - Verifică integritatea datelor

---

## 📝 NOTĂ IMPORTANTĂ

Controller-ele sunt create cu cod comentat pentru Oracle.ManagedDataAccess.Core.
După instalarea pachetului, decomentează codul și elimină simulările.

---

**Status:** Gata pentru configurare și testare

