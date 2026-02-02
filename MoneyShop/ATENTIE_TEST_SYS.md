# ⚠️ ATENȚIE: Test cu SYS

## Configurație Actuală

Aplicația este configurată să se conecteze ca **SYS** cu privilegii **SYSDBA** pentru testare rapidă.

**Connection String:**
```
Data Source=localhost:1521/ORCLCDB;User Id=SYS;Password=Eduard123?;DBA Privilege=SYSDBA;
```

## ⚠️ Precauții

1. **NU folosi această configurație în producție!**
2. **SYS are privilegii complete** - poate modifica orice în baza de date
3. **Risc de corupere date** dacă aplicația face modificări neintenționate
4. **Probleme de securitate** - parola este în clar în appsettings.json

## 🔄 Revenire la Configurație Normală

După test, revino la utilizatorul `moneyshop`:

```json
"DefaultConnection": "Data Source=localhost:1521/ORCLPDB;User Id=moneyshop;Password=moneyshop123;"
```

## ✅ Testare

1. Rulează aplicația: `dotnet run`
2. Verifică log-urile pentru erori de conexiune
3. Testează un endpoint API

## 📝 Note

- Connection string-ul folosește `ORCLCDB` (CDB) nu `ORCLPDB` (PDB)
- Dacă vrei să testezi în PDB, poți modifica la:
  ```
  Data Source=localhost:1521/ORCLPDB;User Id=SYS;Password=Eduard123?;DBA Privilege=SYSDBA;
  ```

## 🚨 Dacă Apar Probleme

1. Verifică că Oracle Listener rulează
2. Verifică că CDB-ul este deschis
3. Verifică parola SYS
4. Verifică că portul 1521 este accesibil

