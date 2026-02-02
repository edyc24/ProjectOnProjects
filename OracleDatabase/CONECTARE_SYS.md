# Conectare la Oracle CDB cu SYS

## ✅ Da, se poate conecta cu SYS!

Utilizatorul `SYS` este super-administratorul în Oracle Database și are acces complet la toate containerele (CDB și PDB-uri).

## 🔐 Metode de Conectare

### 1. SQL*Plus (Command Line)

#### Conectare ca SYSDBA:
```sql
sqlplus sys/password@localhost:1521/ORCLCDB as sysdba
```

#### Sau fără parolă în linia de comandă (mai sigur):
```sql
sqlplus / as sysdba
```
Aceasta se conectează cu autentificare OS (dacă utilizatorul OS este în grupul `dba`).

### 2. SQL Developer

1. Deschide SQL Developer
2. Click pe **New Connection** (iconul verde +)
3. Completează:
   - **Name**: `SYS_CDB` (sau orice nume)
   - **Username**: `SYS`
   - **Password**: parola ta
   - **Role**: Selectează **SYSDBA** (important!)
   - **Connection Type**: `Basic`
   - **Hostname**: `localhost`
   - **Port**: `1521`
   - **Service name**: `ORCLCDB` (sau numele CDB-ului tău)

### 3. Connection String pentru Aplicații

**⚠️ ATENȚIE**: Nu recomand să folosești SYS în aplicații! Folosește utilizatorul `moneyshop`.

Dacă totuși vrei să testezi:
```
Data Source=localhost:1521/ORCLCDB;User Id=SYS;Password=parola;DBA Privilege=SYSDBA;
```

## 📋 Verificare Conexiune

După conectare, verifică:

```sql
-- Verifică utilizatorul curent
SELECT USER FROM DUAL;

-- Verifică containerul curent
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM DUAL;

-- Verifică privilegii
SELECT * FROM USER_SYS_PRIVS WHERE USERNAME = 'SYS';

-- Listează toate containerele
SELECT name, open_mode FROM v$containers;
```

## 🔄 Comutare între Containere

### Din CDB$ROOT în PDB:
```sql
ALTER SESSION SET CONTAINER = ORCLPDB;
-- SAU
ALTER SESSION SET CONTAINER = XEPDB1;
```

### Înapoi în CDB$ROOT:
```sql
ALTER SESSION SET CONTAINER = CDB$ROOT;
```

### Verifică PDB-uri disponibile:
```sql
SELECT name, open_mode FROM v$pdbs;
```

### Deschide un PDB:
```sql
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
```

## ⚠️ Precauții Importante

### 1. **NU folosi SYS pentru operațiuni normale!**
- SYS este pentru administrare
- Folosește utilizatorul `moneyshop` pentru aplicație
- SYS are privilegii prea mari pentru aplicații

### 2. **Backup înainte de modificări**
- Dacă faci modificări ca SYS, asigură-te că ai backup
- Testează pe un mediu de dezvoltare mai întâi

### 3. **Parola SYS**
- Parola SYS este setată la instalare
- Poți schimba parola:
  ```sql
  ALTER USER SYS IDENTIFIED BY "noua_parola";
  ```

## 🎯 Pentru Aplicația MoneyShop

**Recomandare**: Folosește utilizatorul `moneyshop` (nu SYS) în `appsettings.json`:

```json
"DefaultConnection": "Data Source=localhost:1521/ORCLPDB;User Id=moneyshop;Password=moneyshop123;"
```

### De ce?
- ✅ Mai sigur (principiul privilegiilor minime)
- ✅ Mai ușor de auditat
- ✅ Mai ușor de gestionat
- ✅ Nu riscă să afecteze structura CDB-ului

## 📝 Exemple de Comenzi ca SYS

### Creare utilizator în PDB:
```sql
-- Mută-te în PDB
ALTER SESSION SET CONTAINER = ORCLPDB;

-- Creează utilizator
CREATE USER moneyshop IDENTIFIED BY moneyshop123;
GRANT CONNECT, RESOURCE TO moneyshop;
GRANT QUOTA UNLIMITED ON USERS TO moneyshop;
```

### Verificare privilegii utilizator:
```sql
-- Ca SYS, poți verifica privilegiile oricărui utilizator
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'MONEYSHOP';
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'MONEYSHOP';
```

### Verificare tabele în schema utilizator:
```sql
-- Ca SYS, poți vedea toate tabelele
SELECT owner, table_name FROM dba_tables WHERE owner = 'MONEYSHOP';
```

## 🔍 Troubleshooting

### Eroare: "ORA-01031: insufficient privileges"
**Cauză**: Nu ești conectat ca SYSDBA
**Soluție**: Adaugă `as sysdba` la comandă:
```sql
sqlplus sys/password as sysdba
```

### Eroare: "ORA-28009: connection as SYS should be as SYSDBA or SYSOPER"
**Cauză**: SYS trebuie să se conecteze cu privilegii speciale
**Soluție**: Folosește `as sysdba` sau `as sysoper`

### Eroare: "ORA-65011: Pluggable database does not exist"
**Cauză**: PDB-ul nu există sau nu este deschis
**Soluție**: 
```sql
-- Verifică PDB-uri disponibile
SELECT name, open_mode FROM v$pdbs;

-- Deschide PDB-ul
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
```

## 📚 Resurse

- [Oracle Documentation: SYS User](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-users-and-securing-the-database.html)
- [Oracle Documentation: SYSDBA and SYSOPER](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-authentication.html)

