# Scripturi SQL de Rulat în Azure SQL Database

## ⭐ SCRIPT COMPLET RECOMANDAT

### **Full_Setup_Azure.sql** - Script complet cu toate configurările

Acest script include TOATE configurările necesare într-un singur fișier:
- ✅ Populare roluri (Utilizator, Administrator, Broker)
- ✅ Verificare și creare constrângeri foreign key
- ✅ Verificare migrații Entity Framework
- ✅ Verificare structură baza de date
- ✅ Raport final cu statistici
- ✅ Opțional: Utilizator de test (comentat)

**Locație:** `DataAccess/Scripts/Full_Setup_Azure.sql`

**Cum să rulezi:**
1. Deschide Azure Portal → SQL Database → `moneyshop` → Query Editor
2. Autentifică-te cu: `alexmoore` / `Moneyshop2026?`
3. Deschide și rulează `Full_Setup_Azure.sql`
4. Gata! 🎉

**Notă:** Scriptul este idempotent - poate fi rulat de mai multe ori fără probleme.

---

## Scripturi Individuale (Alternative)

### 1. **PopulateRoles.sql** ⭐ OBLIGATORIU (dacă nu folosești scriptul complet)

Acest script populează tabelul `Roluri` cu rolurile necesare pentru aplicație:
- Utilizator (IdRol = 1)
- Administrator (IdRol = 2)
- Broker (IdRol = 3)

**Cum să rulezi:**
1. Conectează-te la Azure SQL Database prin:
   - Azure Portal → SQL Database → Query Editor
   - Azure Data Studio
   - SQL Server Management Studio (SSMS)
   
2. Rulează scriptul `DataAccess/Scripts/PopulateRoles.sql`

**Notă:** Scriptul este idempotent - poate fi rulat de mai multe ori fără probleme. Verifică automat dacă rolurile există deja.

---

## Scripturi Opționale

### 2. **CreateTestUser.sql** (Doar pentru Development/Testing)

Creează un utilizator de test pentru development.

**⚠️ NU rula în production!**

---

## Scripturi care NU trebuie rulate (sunt deja aplicate prin migrații)

Următoarele scripturi **NU** trebuie rulate manual, deoarece migrațiile Entity Framework le aplică automat:

- ❌ `CreateDatabase.sql` - Baza de date este deja creată în Azure
- ❌ `CreateBaseTables.sql` - Tabelele sunt create prin migrații
- ❌ `AddFileContentBase64ToKycFiles.sql` - Aplicat prin migrație `20260103140908_AddFileContentBase64ToKycFiles`
- ❌ `AddKycFormDataFields.sql` - Aplicat prin migrații
- ❌ `MarkMigrationAsApplied.sql` - Doar pentru cazuri speciale

---

## Pași pentru a Rula Scripturile în Azure

### Opțiunea 1: Azure Portal Query Editor

1. Deschide [Azure Portal](https://portal.azure.com)
2. Navighează la **SQL Database** → `moneyshop`
3. În meniul stâng, click pe **Query editor (preview)**
4. Autentifică-te cu:
   - **SQL authentication**
   - Username: `alexmoore`
   - Password: `Moneyshop2026?`
5. Copiază conținutul scriptului `PopulateRoles.sql`
6. Lipește în editor și click **Run**

### Opțiunea 2: Azure Data Studio

1. Deschide Azure Data Studio
2. Click pe **New Connection**
3. Completează:
   - **Server:** `moneyshop.database.windows.net`
   - **Authentication type:** SQL Login
   - **User name:** `alexmoore`
   - **Password:** `{Moneyshop2026?}`
   - **Database:** `moneyshop`
4. Click **Connect**
5. Deschide fișierul `PopulateRoles.sql`
6. Click **Run** (F5)

### Opțiunea 3: SQL Server Management Studio (SSMS)

1. Deschide SSMS
2. În **Connect to Server**, completează:
   - **Server name:** `moneyshop.database.windows.net`
   - **Authentication:** SQL Server Authentication
   - **Login:** `alexmoore`
   - **Password:** `{Moneyshop2026?}`
3. Click **Connect**
4. În Object Explorer, expandează **Databases** → `moneyshop`
5. Click dreapta pe `moneyshop` → **New Query**
6. Deschide fișierul `PopulateRoles.sql`
7. Click **Execute** (F5)

---

## Verificare după Rulare

După ce rulezi `PopulateRoles.sql`, verifică că rolurile au fost create:

```sql
SELECT IdRol, NumeRol FROM Roluri ORDER BY IdRol;
```

Ar trebui să vezi:
- IdRol: 1, NumeRol: Utilizator
- IdRol: 2, NumeRol: Administrator
- IdRol: 3, NumeRol: Broker

---

## Rezumat

✅ **Rulare obligatorie:**
- `PopulateRoles.sql` - Populează rolurile necesare

❌ **NU rula:**
- Scripturile de creare baza de date (deja creată)
- Scripturile de migrații (aplicate automat prin EF)

⚠️ **Doar pentru Development:**
- `CreateTestUser.sql` - Doar dacă ai nevoie de un user de test

