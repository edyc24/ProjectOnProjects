# Setup Utilizator Oracle - MoneyShop

## 🔴 Problema Identificată

Ești conectat ca **SYS**, iar Oracle nu permite crearea de triggeri pe obiecte deținute de SYS.

## ✅ Soluție - Pași de Urmat

### Pasul 1: Creează Utilizatorul (ca SYSDBA)

Rulează scriptul de creare utilizator:

```sql
-- Conectează-te ca SYSDBA (dacă nu ești deja)
CONNECT sys AS SYSDBA;
-- SAU
CONNECT / AS SYSDBA;

-- Rulează scriptul
@00_CREARE_UTILIZATOR.sql
```

Acest script va:
- ✅ Crea utilizatorul `MONEYSHOP` cu parola `moneyshop123`
- ✅ Acorda toate privilegiile necesare
- ✅ Configura tablespace-ul

### Pasul 2: Conectează-te cu Utilizatorul Nou

```sql
CONNECT moneyshop/moneyshop123;
```

### Pasul 3: Verifică Schema

```sql
-- Verifică că ești în schema corectă
SELECT USER, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') FROM DUAL;
-- Ar trebui să vezi: MONEYSHOP
```

### Pasul 4: Rulează Scripturile în Ordine

Acum rulează scripturile în schema ta (nu în SYS):

```sql
-- 1. Creare tabele
@03_CREATE_TABLES.sql

-- 2. Populare date test
@17_POPULARE_DATE_TEST.sql

-- 3. Securitate
@04_SECURITATE.sql

-- 4. Criptare
@05_CRIPTARE.sql

-- 5. Auditare (VERSIUNE SIGURĂ)
@06_AUDITARE_SAFE.sql

-- 6. Gestiune utilizatori
@07_GESTIUNE_UTILIZATORI.sql

-- 7. Privilegii și roluri
@08_PRIVILEGII_ROLURI.sql

-- 8. Mascare date
@10_MASCARE_DATE.sql

-- 9. PL/SQL Colecții
@09_PLSQL_COLECTII.sql

-- 10. PL/SQL Cursoare
@10_PLSQL_CURSOARE.sql

-- 11. PL/SQL Funcție Excepții
@11_PLSQL_FUNCTIE_EXCEPTII.sql

-- 12. Trigger LDD
@12_TRIGGER_LDD.sql

-- 13. Pachet
@13_PACHET_MONEYSHOP.sql

-- 14. Triggeri LMD
@14_TRIGGERI_LMD_MESAJE.sql
```

## 📋 Ordine Completă (Copy-Paste)

```sql
-- 1. Ca SYSDBA
CONNECT sys AS SYSDBA;
@00_CREARE_UTILIZATOR.sql

-- 2. Conectează-te cu utilizatorul nou
CONNECT moneyshop/moneyshop123;

-- 3. Rulează scripturile
@03_CREATE_TABLES.sql
@17_POPULARE_DATE_TEST.sql
@04_SECURITATE.sql
@05_CRIPTARE.sql
@06_AUDITARE_SAFE.sql
@07_GESTIUNE_UTILIZATORI.sql
@08_PRIVILEGII_ROLURI.sql
@10_MASCARE_DATE.sql
@09_PLSQL_COLECTII.sql
@10_PLSQL_CURSOARE.sql
@11_PLSQL_FUNCTIE_EXCEPTII.sql
@12_TRIGGER_LDD.sql
@13_PACHET_MONEYSHOP.sql
@14_TRIGGERI_LMD_MESAJE.sql
```

## ⚠️ Note Importante

1. **Nu mai folosi SYS** pentru proiectul tău - folosește utilizatorul `MONEYSHOP`
2. **Parola**: `moneyshop123` (poți schimba-o dacă vrei)
3. **Script sigur**: Folosește `06_AUDITARE_SAFE.sql` în loc de `06_AUDITARE.sql`
4. **Verificare**: După fiecare script, verifică că nu sunt erori

## 🔍 Verificare Finală

După ce ai rulat toate scripturile, verifică:

```sql
-- Verificare triggeri
SELECT trigger_name, table_name, status 
FROM user_triggers 
WHERE trigger_name LIKE 'TRG_%'
ORDER BY trigger_name;

-- Verificare tabele
SELECT table_name 
FROM user_tables 
ORDER BY table_name;

-- Verificare proceduri
SELECT object_name, object_type 
FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE')
ORDER BY object_name;
```

## 🐛 Dacă ai probleme

### Eroare: "user already exists"
```sql
-- Șterge utilizatorul vechi
DROP USER moneyshop CASCADE;
-- Apoi rulează din nou 00_CREARE_UTILIZATOR.sql
```

### Eroare: "insufficient privileges"
```sql
-- Verifică privilegiile
SELECT * FROM user_sys_privs;
-- Dacă lipsesc, rulează din nou 00_CREARE_UTILIZATOR.sql ca SYSDBA
```

### Eroare: "table does not exist"
```sql
-- Verifică că ești în schema corectă
SELECT USER FROM DUAL;
-- Ar trebui să fie MONEYSHOP, nu SYS
```

## ✅ Succes!

După ce ai urmat acești pași, toate triggerii ar trebui să funcționeze corect!

