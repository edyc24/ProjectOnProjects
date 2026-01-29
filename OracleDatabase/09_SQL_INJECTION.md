# 9. SQL Injection - Protecție și Context Aplicație

## 9.1 Contextul Aplicației

### Arhitectura Aplicației MoneyShop

MoneyShop este o aplicație web și mobilă pentru brokeraj de credite, construită cu:
- **Backend**: ASP.NET Core 6.0 Web API
- **Frontend**: React Native (mobile) + ASP.NET Core MVC (web)
- **Baza de Date**: Oracle Database 19c+
- **ORM**: Entity Framework Core (pentru SQL Server) + Oracle Data Provider (pentru Oracle)

### Fluxul de Date

1. **Utilizator** → Frontend (React Native / Web)
2. **Frontend** → Backend API (ASP.NET Core)
3. **Backend** → Oracle Database (prin Oracle Data Provider)
4. **Database** → Returnează rezultate
5. **Backend** → Procesează și returnează JSON
6. **Frontend** → Afișează datele utilizatorului

---

## 9.2 Vulnerabilități SQL Injection

### Tipuri de Atacuri SQL Injection

#### 1. **Classic SQL Injection**
```sql
-- Exemplu vulnerabil (NU FOLOSIȚI ASTA!)
SELECT * FROM UTILIZATORI 
WHERE Username = 'admin' OR '1'='1' -- 
AND Parola = 'hash123';
```

#### 2. **Union-Based SQL Injection**
```sql
-- Exemplu vulnerabil
SELECT * FROM APLICATII WHERE UserId = 1
UNION SELECT * FROM UTILIZATORI WHERE 1=1;
```

#### 3. **Blind SQL Injection**
```sql
-- Exemplu vulnerabil
SELECT * FROM APLICATII 
WHERE Id = 1 AND (SELECT COUNT(*) FROM UTILIZATORI) > 0;
```

#### 4. **Time-Based SQL Injection**
```sql
-- Exemplu vulnerabil
SELECT * FROM APLICATII 
WHERE Id = 1; WAITFOR DELAY '00:00:05' -- (SQL Server)
-- Pentru Oracle: DBMS_LOCK.SLEEP(5)
```

---

## 9.3 Protecție la Nivel de Baza de Date

### 1. Parametrizație Obligatorie

**În Oracle, toate interogările trebuie să folosească bind variables:**

```sql
-- ✅ CORECT - Parametrizat
SELECT * FROM UTILIZATORI 
WHERE Username = :username 
AND Parola = :parola;

-- ❌ GREȘIT - Concatenare string
SELECT * FROM UTILIZATORI 
WHERE Username = ' || p_username || ';
```

### 2. Proceduri Stocate pentru Operațiuni Critice

Toate operațiunile critice sunt implementate prin proceduri stocate:

```sql
-- Autentificare (securizată)
EXEC sp_autentificare_utilizator(:username, :parola_hash, :user_id, :rol, :success);

-- Creare aplicație (securizată)
EXEC sp_client_create_application(:user_id, :type_credit, :tip_operatiune, :salariu_net, :app_id);
```

### 3. Validare Input la Nivel de Baza de Date

```sql
-- Trigger pentru validare email
CREATE OR REPLACE TRIGGER trg_utilizatori_email
BEFORE INSERT OR UPDATE OF Email ON UTILIZATORI
FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(:NEW.Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20006, 'Format email invalid');
    END IF;
END;
/
```

### 4. Privilegii Minimale

Utilizatorii aplicației au privilegii minimale:
- **moneyshop_app**: Doar SELECT, INSERT, UPDATE pe tabele specifice
- **Fără privilegii DROP, ALTER, CREATE**
- **Fără acces direct la tabele sensibile** (doar prin view-uri)

### 5. View-uri cu Securitate

```sql
-- View securizat pentru clienți
CREATE OR REPLACE VIEW vw_client_own_applications AS
SELECT Id, UserId, Status, TypeCredit, Scoring
FROM APLICATII
WHERE UserId = SYS_CONTEXT('USERENV', 'SESSION_USERID');
```

---

## 9.4 Protecție la Nivel de Aplicație (ASP.NET Core)

### 1. Entity Framework Core (Parametrizare Automată)

```csharp
// ✅ CORECT - EF Core parametrizează automat
var user = await _context.Utilizatoris
    .Where(u => u.Username == username && u.Parola == passwordHash)
    .FirstOrDefaultAsync();

// ❌ GREȔIT - Raw SQL fără parametri (NU FOLOSIȚI!)
var user = await _context.Database
    .SqlQueryRaw<Utilizatori>($"SELECT * FROM UTILIZATORI WHERE Username = '{username}'")
    .FirstOrDefaultAsync();
```

### 2. Oracle Data Provider (ODP.NET)

```csharp
// ✅ CORECT - Parametrizație explicită
using (var cmd = new OracleCommand())
{
    cmd.CommandText = "SELECT * FROM UTILIZATORI WHERE Username = :username";
    cmd.Parameters.Add(":username", OracleDbType.Varchar2).Value = username;
    // ...
}

// ❌ GREȘIT - Concatenare string
cmd.CommandText = "SELECT * FROM UTILIZATORI WHERE Username = '" + username + "'";
```

### 3. Validare Input

```csharp
// Validare în ASP.NET Core
[Required]
[StringLength(50)]
[RegularExpression(@"^[a-zA-Z0-9_]+$")]
public string Username { get; set; }

[Required]
[EmailAddress]
public string Email { get; set; }
```

### 4. Sanitizare Input

```csharp
// Sanitizare pentru prevenirea XSS și SQL Injection
public static string SanitizeInput(string input)
{
    if (string.IsNullOrEmpty(input))
        return string.Empty;
    
    // Eliminare caractere speciale SQL
    return input.Replace("'", "''")
                .Replace(";", "")
                .Replace("--", "")
                .Replace("/*", "")
                .Replace("*/", "");
}
```

### 5. Whitelisting pentru Input

```csharp
// Whitelist pentru status aplicație
public enum ApplicationStatus
{
    INREGISTRAT,
    IN_PROCESARE,
    APROBAT,
    REFUZAT,
    ANULAT
}

// Validare că status-ul este în whitelist
if (!Enum.IsDefined(typeof(ApplicationStatus), status))
{
    throw new ValidationException("Status invalid");
}
```

---

## 9.5 Testare Protecție SQL Injection

### Test 1: Autentificare
```sql
-- Încercare SQL Injection în username
Username: admin' OR '1'='1' --
Parola: orice

-- Rezultat așteptat: Eșec autentificare (nu ar trebui să funcționeze)
```

### Test 2: Căutare Aplicații
```sql
-- Încercare SQL Injection în filtru
UserId: 1 UNION SELECT * FROM UTILIZATORI --

-- Rezultat așteptat: Eroare sau rezultat gol (nu ar trebui să funcționeze)
```

### Test 3: Actualizare Date
```sql
-- Încercare SQL Injection în actualizare
UPDATE APLICATII SET Status = 'APROBAT' WHERE Id = 1; DROP TABLE UTILIZATORI; --

-- Rezultat așteptat: Eroare (nu ar trebui să funcționeze)
```

---

## 9.6 Best Practices

### ✅ DO

1. **Folosiți întotdeauna parametri** în interogări
2. **Folosiți proceduri stocate** pentru operațiuni critice
3. **Validați input-ul** la nivel de aplicație și baza de date
4. **Folosiți whitelisting** în loc de blacklisting
5. **Limitați privilegiile** utilizatorilor bazei de date
6. **Folosiți ORM-uri** (Entity Framework, Dapper) care parametrizează automat
7. **Auditați toate interogările** suspecte
8. **Folosiți prepared statements** în toate limbajele

### ❌ DON'T

1. **Nu concatenați** string-uri în interogări SQL
2. **Nu folosiți** `EXEC()` sau `EXECUTE IMMEDIATE` cu input din utilizator
3. **Nu permiteți** caractere speciale SQL în input fără validare
4. **Nu dați** privilegii DBA utilizatorilor aplicației
5. **Nu logați** parole sau date sensibile
6. **Nu afișați** mesaje de eroare detaliate utilizatorilor finali

---

## 9.7 Monitorizare și Alertare

### Trigger pentru Detectare SQL Injection

```sql
CREATE OR REPLACE TRIGGER trg_detect_sql_injection
AFTER SERVERERROR ON DATABASE
DECLARE
    v_error_code NUMBER;
    v_error_msg VARCHAR2(4000);
BEGIN
    v_error_code := ORA_SERVER_ERROR(1);
    v_error_msg := ORA_SERVER_ERROR_MSG(1);
    
    -- Detectare pattern-uri suspecte
    IF INSTR(v_error_msg, 'ORA-00933') > 0 OR -- SQL command not properly ended
       INSTR(v_error_msg, 'ORA-00936') > 0 OR -- missing expression
       INSTR(v_error_msg, 'ORA-00942') > 0 THEN -- table or view does not exist
        
        -- Log alertă
        INSERT INTO AUDIT_LOG (TableName, Operation, NewValues, Timestamp)
        VALUES ('SECURITY', 'SQL_INJECTION_ATTEMPT', 
                'Error: ' || v_error_msg, SYSTIMESTAMP);
        
        COMMIT;
    END IF;
END;
/
```

---

## 9.8 Concluzie

Protecția împotriva SQL Injection în MoneyShop este implementată la multiple niveluri:

1. **Baza de Date**: Proceduri stocate, view-uri securizate, privilegii minimale
2. **Aplicație**: Entity Framework Core, validare input, sanitizare
3. **Infrastructură**: Firewall, WAF (Web Application Firewall), monitoring

**Toate interogările SQL trebuie să fie parametrizate!**

---

## 9.9 Referințe

- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [Oracle SQL Injection Prevention](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/dynamic-sql.html)
- [ASP.NET Core Security](https://docs.microsoft.com/en-us/aspnet/core/security/)

