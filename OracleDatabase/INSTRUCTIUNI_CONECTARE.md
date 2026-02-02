# Instrucțiuni Conectare Oracle

## 🔴 Problema: "Connection Failed" / "Not connected"

Dacă primești erori de conectare, urmează acești pași:

## 📋 Pași de Conectare

### Opțiunea 1: Oracle SQL Developer

1. **Deschide Oracle SQL Developer**

2. **Creează o conexiune nouă:**
   - Click dreapta pe "Connections" → "New Connection"
   - Sau click pe iconița "+" verde

3. **Completează detaliile:**
   ```
   Connection Name: SYSDBA (sau orice nume)
   Username: sys
   Password: [parola ta SYSDBA]
   Role: SYSDBA
   Hostname: localhost (sau IP-ul serverului)
   Port: 1521 (sau portul tău Oracle)
   SID/Service Name: ORCL (sau SID-ul tău)
   ```

4. **Testează conexiunea:**
   - Click pe "Test" → ar trebui să vezi "Success"
   - Click "Save" și apoi "Connect"

5. **Pentru utilizatorul MONEYSHOP:**
   ```
   Connection Name: MONEYSHOP
   Username: c##moneyshop (sau moneyshop dacă ești în PDB)
   Password: moneyshop123
   Role: Default
   Hostname: localhost
   Port: 1521
   SID/Service Name: ORCL (sau ORCLPDB dacă folosești PDB)
   ```

### Opțiunea 2: SQL*Plus (Command Line)

1. **Deschide Command Prompt sau Terminal**

2. **Conectează-te ca SYSDBA:**
   ```bash
   sqlplus sys AS SYSDBA
   ```
   Sau:
   ```bash
   sqlplus / AS SYSDBA
   ```

3. **Sau conectează-te cu utilizatorul MONEYSHOP:**
   ```bash
   sqlplus c##moneyshop/moneyshop123
   ```

### Opțiunea 3: SQL*Plus din Oracle SQL Developer

1. **În Oracle SQL Developer:**
   - Click pe "View" → "SQL*Plus"
   - Sau folosește fereastra SQL Worksheet

2. **Rulează comenzile:**
   ```sql
   CONNECT sys AS SYSDBA;
   -- SAU
   CONNECT c##moneyshop/moneyshop123;
   ```

## 🔍 Verificare Conexiune

După ce te-ai conectat, rulează:

```sql
@00_TEST_CONEXIUNE.sql
```

Acest script va arăta:
- Utilizatorul curent
- Schema curentă
- Container-ul (dacă e CDB)
- Numele bazei de date

## ⚠️ Probleme Comune

### Eroare: "ORA-01017: invalid username/password"
- **Soluție**: Verifică parola. Pentru SYSDBA, poate fi parola setată la instalare.

### Eroare: "ORA-12541: TNS:no listener"
- **Soluție**: 
  - Verifică dacă Oracle Listener rulează:
    ```bash
    lsnrctl status
    ```
  - Dacă nu rulează:
    ```bash
    lsnrctl start
    ```

### Eroare: "ORA-12514: TNS:listener does not currently know of service"
- **Soluție**: 
  - Folosește SID în loc de Service Name
  - SAU verifică `tnsnames.ora` pentru service name corect

### Eroare: "SP2-0640: Not connected"
- **Soluție**: 
  - Conectează-te mai întâi (vezi pașii de mai sus)
  - Verifică că conexiunea este activă

## 📝 Comenzi Rapide

### Conectare SYSDBA
```sql
CONNECT sys AS SYSDBA;
-- SAU
CONNECT / AS SYSDBA;
```

### Conectare MONEYSHOP (CDB)
```sql
CONNECT c##moneyshop/moneyshop123;
```

### Conectare MONEYSHOP (PDB)
```sql
CONNECT moneyshop/moneyshop123@ORCLPDB;
-- SAU dacă ești deja în PDB:
CONNECT moneyshop/moneyshop123;
```

### Verificare Conexiune
```sql
SELECT USER FROM DUAL;
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') FROM DUAL;
```

## ✅ După Conectare

Odată conectat, poți rula scripturile:

```sql
-- Verifică conexiunea
@00_TEST_CONEXIUNE.sql

-- Creează/utilizează utilizatorul
@00_CREARE_UTILIZATOR.sql

-- Rulează scripturile proiectului
@03_CREATE_TABLES.sql
-- etc.
```

## 🆘 Dacă tot nu funcționează

1. **Verifică serviciile Oracle:**
   - Windows: Services → OracleServiceORCL, OracleTNSListener
   - Linux: `systemctl status oracle`

2. **Verifică listener-ul:**
   ```bash
   lsnrctl status
   ```

3. **Verifică configurația:**
   - Fișier `tnsnames.ora`
   - Fișier `listener.ora`

4. **Contactează administratorul bazei de date** dacă nu ai acces local

