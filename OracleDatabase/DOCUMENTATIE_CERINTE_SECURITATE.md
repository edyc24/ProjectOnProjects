# Documentație Completă - Cerințe Securitate
## Proiect MoneyShop - Oracle Database
## Student: Cristea Eduard | Grupa: 505

---

## 📋 Cuprins

1. [Cerința 1: Introducere](#cerinta-1)
2. [Cerința 2: Criptarea Datelor](#cerinta-2)
3. [Cerința 3: Auditarea Activităților](#cerinta-3)
4. [Cerința 4: Gestiunea Utilizatorilor și Resurselor](#cerinta-4)
5. [Cerința 5: Privilegii și Roluri](#cerinta-5)
6. [Cerința 6: Aplicațiile și Securitatea Datelor (SQL Injection)](#cerinta-6)
7. [Cerința 7: Mascarea Datelor](#cerinta-7)

---

## <a name="cerinta-1"></a>1. Cerința 1: Introducere

### 📄 Ce cere cerința:
- Prezentarea modelului proiectat și regulilor sale
- Diagrama conceptuală (ERD)
- Schemele relaționale
- Crearea tabelelor (script separat)
- Prezentarea regulilor de securitate care vor fi aplicate

### ✅ Ce am implementat:

#### 1.1 Diagrama Conceptuală (ERD)
**Fișier:** `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`

**Conținut:**
- Diagramă entitate-relație completă pentru MoneyShop
- Entități principale:
  - **ROLURI** - Rolurile utilizatorilor (CLIENT, BROKER, ADMIN)
  - **UTILIZATORI** - Utilizatorii sistemului
  - **APLICATII** - Cererile de credit
  - **BANCI** - Băncile partenere
  - **DOCUMENTE** - Documentele încărcate
  - **CONSENTURI** - Consimțământurile GDPR
  - **MANDATE** - Mandatele de brokeraj
  - **AUDIT_LOG** - Log-ul de auditare
  - **MESAJE** - Mesajele sistemului

#### 1.2 Scheme Relaționale
**Fișier:** `OracleDatabase/02_SCHEME_RELATIONALE.md`

**Conținut:**
- Scheme relaționale normalizate (FN3)
- Atribute pentru fiecare tabel
- Chei primare și străine
- Constrainte de integritate

#### 1.3 Script de Creare Tabele
**Fișier:** `OracleDatabase/03_CREATE_TABLES.sql`

**Ce face:**
- Creează toate tabelele cu structura completă
- Definește constrainte (CHECK, FOREIGN KEY, UNIQUE)
- Creează indexuri pentru performanță
- Creează secvențe (seq_mesaje)
- Inserează date inițiale (roluri: CLIENT, BROKER, ADMIN)

**Tabele create:**
- ROLURI, UTILIZATORI, BANCI, APLICATII
- APPLICATION_BANKS, DOCUMENTE, CONSENTURI, MANDATE
- AUDIT_LOG, MESAJE, USER_FINANCIAL_DATA, USER_SESSIONS

#### 1.4 Reguli de Securitate
**Fișier:** `OracleDatabase/04_SECURITATE.sql`

**Reguli implementate:**
- Validare parolă puternică (minim 8 caractere, cifre, litere mari/mici)
- Validare vârstă minimă (18 ani)
- Validare format email (regex)
- Validare format telefon (10 cifre)
- Validare scoring (300-850)
- Validare DTI (0-100%)
- Validare rol broker pentru mandate

**Implementare:** Triggeri BEFORE INSERT/UPDATE

---

## <a name="cerinta-2"></a>2. Cerința 2: Criptarea Datelor

### 📄 Ce cere cerința:
- Criptarea datelor sensibile în baza de date
- Protecția confidențialității utilizatorilor

### ✅ Ce am implementat:

#### 2.1 Funcții de Criptare/Decriptare
**Fișier:** `OracleDatabase/05_CRIPTARE.sql`

**Funcții create:**

1. **`fn_encrypt_column(p_data, p_key)`**
   - Criptează date VARCHAR2 folosind AES-256
   - Returnează RAW (date criptate)
   - Folosește DBMS_CRYPTO
   - Algoritm: AES256 + CBC + PKCS5

2. **`fn_decrypt_column(p_encrypted, p_key)`**
   - Decriptează date RAW
   - Returnează VARCHAR2 (date originale)
   - Folosește aceeași cheie ca la criptare

**Exemplu de utilizare:**
```sql
-- Criptare
UPDATE UTILIZATORI 
SET Email_Encrypted = fn_encrypt_column(Email)
WHERE IdUtilizator = 1;

-- Decriptare
SELECT fn_decrypt_column(Email_Encrypted) AS Email_Decrypted
FROM UTILIZATORI
WHERE IdUtilizator = 1;
```

#### 2.2 Coloane Criptate
**Tabele modificate:**
- `UTILIZATORI.Email_Encrypted` (RAW) - Email criptat
- `UTILIZATORI.Telefon_Encrypted` (RAW) - Telefon criptat
- `UTILIZATORI.CNP_Encrypted` (RAW) - CNP criptat

#### 2.3 Proceduri de Criptare
- `sp_encrypt_user_email(p_user_id)` - Criptează email utilizator
- `sp_encrypt_user_telefon(p_user_id)` - Criptează telefon utilizator

#### 2.4 View pentru Decriptare
- `vw_utilizatori_decrypted` - View care afișează datele decriptate

**Securitate:**
- Cheia de criptare: 'MONEYSHOP_ENCRYPT_KEY_2025' (configurabilă)
- Algoritm puternic: AES-256
- Datele sensibile sunt protejate chiar dacă baza de date este compromisă

---

## <a name="cerinta-3"></a>3. Cerința 3: Auditarea Activităților

### 📄 Ce cere cerința:
- Auditare standard Oracle
- Trigger-i de auditare
- Politici de auditare (Fine-Grained Audit)

### ✅ Ce am implementat:

#### 3.1 Tabel de Audit
**Tabel:** `AUDIT_LOG`
- `Id` - ID înregistrare
- `TableName` - Numele tabelului
- `Operation` - INSERT, UPDATE, DELETE
- `UserId` - ID utilizator afectat
- `OldValues` - Valori vechi (JSON)
- `NewValues` - Valori noi (JSON)
- `IpAddress` - IP-ul clientului
- `Timestamp` - Data și ora operației

#### 3.2 Trigger-i de Auditare
**Fișier:** `OracleDatabase/06_AUDITARE.sql`

**Triggeri creați:**

1. **`trg_audit_utilizatori`**
   - Se declanșează: AFTER INSERT/UPDATE/DELETE pe UTILIZATORI
   - Înregistrează: Email, IdRol, IdUtilizator
   - Scop: Urmărire modificări utilizatori

2. **`trg_audit_aplicatii`**
   - Se declanșează: AFTER INSERT/UPDATE/DELETE pe APLICATII
   - Înregistrează: Status, Scoring, UserId
   - Scop: Urmărire modificări aplicații

3. **`trg_audit_documente`**
   - Se declanșează: AFTER INSERT/UPDATE/DELETE pe DOCUMENTE
   - Înregistrează: TipDocument, ApplicationId
   - Scop: Urmărire acces documente

4. **`trg_audit_consenturi`**
   - Se declanșează: AFTER INSERT/UPDATE/DELETE pe CONSENTURI
   - Înregistrează: TipConsent, Status
   - Scop: Urmărire consimțământuri GDPR

**Funcționalitate:**
- Fiecare trigger înregistrează automat în AUDIT_LOG
- Captează IP-ul clientului
- Salvează valorile vechi și noi în format JSON
- Nu blochează operațiile (excepții gestionate)

#### 3.3 Fine-Grained Audit (FGA)
**Politici FGA create:**

1. **`FGA_APLICATII_FINANCIARE`**
   - Tabel: APLICATII
   - Condiție: Scoring IS NOT NULL OR SumaAprobata IS NOT NULL
   - Coloane monitorizate: Scoring, SumaAprobata, SalariuNet
   - Operații: SELECT, UPDATE
   - Scop: Auditare acces la date financiare sensibile

2. **`FGA_UTILIZATORI_SENSIBILE`**
   - Tabel: UTILIZATORI
   - Condiție: Email IS NOT NULL OR NumarTelefon IS NOT NULL
   - Coloane monitorizate: Email, NumarTelefon, DataNastere
   - Operații: SELECT, UPDATE
   - Scop: Auditare acces la date personale

3. **`FGA_DOCUMENTE_ACCES`**
   - Tabel: DOCUMENTE
   - Condiție: 1=1 (toate accesările)
   - Coloane monitorizate: Path
   - Operații: SELECT
   - Scop: Auditare acces la documente

#### 3.4 View-uri pentru Raportare
- `vw_audit_log_recent` - Înregistrări din ultimele 30 zile
- `vw_audit_statistics` - Statistici pe tabel/operație
- `vw_audit_top_users` - Utilizatori cu cele mai multe operații

#### 3.5 Proceduri de Raportare
- `sp_audit_report_user(p_user_id, p_days_back)` - Raport pentru un utilizator
- `sp_cleanup_audit_log(p_days_to_keep)` - Curățare log-uri vechi

**Rezultat:**
- Toate modificările sunt înregistrate automat
- Se poate urmări cine, ce, când și de unde
- Respectă cerințele GDPR pentru auditare

---

## <a name="cerinta-4"></a>4. Cerința 4: Gestiunea Utilizatorilor și Resurselor Computaționale

### 📄 Ce cere cerința:
- Proiectarea configurației de management a identităților
- Matrici proces-utilizator
- Matrici entitate-proces
- Matrici entitate-utilizator

### ✅ Ce am implementat:

#### 4.1 Tabel PROCESE
**Fișier:** `OracleDatabase/07_GESTIUNE_UTILIZATORI.sql`

**Structură:**
- `IdProces` - ID proces
- `NumeProces` - Nume proces (ex: VIEW_OWN_APPLICATIONS)
- `Descriere` - Descriere proces
- `TipProces` - READ, WRITE, DELETE, ADMIN, EXECUTE

**Procese definite:**
- VIEW_OWN_APPLICATIONS - Vizualizare propriile aplicații
- CREATE_APPLICATION - Creare aplicație nouă
- UPDATE_OWN_APPLICATION - Actualizare propria aplicație
- DELETE_OWN_APPLICATION - Ștergere propria aplicație
- VIEW_ALL_APPLICATIONS - Vizualizare toate aplicațiile (broker)
- PROCESS_APPLICATION - Procesare aplicație (broker)
- VIEW_USERS - Vizualizare utilizatori (admin)
- MANAGE_USERS - Gestionare utilizatori (admin)

#### 4.2 Matrice Proces-Utilizator
**Tabel:** `PROCES_UTILIZATOR`

**Structură:**
- `Id` - ID înregistrare
- `IdProces` - FK la PROCESE
- `IdUtilizator` - FK la UTILIZATORI
- `Status` - ACTIV, INACTIV, EXPIRAT
- `DataAsignare` - Data când a fost acordat
- `DataExpirare` - Data expirării (opțional)

**Funcționalitate:**
- Asociază utilizatorii cu procesele pe care le pot executa
- Permite expirare automată a accesului
- Permite activare/dezactivare granulară

#### 4.3 Matrice Entitate-Proces
**Tabel:** `ENTITATE_PROCES`

**Structură:**
- `Id` - ID înregistrare
- `NumeEntitate` - Numele entității (ex: APLICATII, UTILIZATORI)
- `IdProces` - FK la PROCESE
- `Permisiune` - ALLOW, DENY

**Funcționalitate:**
- Definește ce procese pot accesa ce entități
- Permite control granular: ALLOW sau DENY
- Exemple: Procesul VIEW_OWN_APPLICATIONS → Entitatea APLICATII → ALLOW

#### 4.4 Matrice Entitate-Utilizator
**Tabel:** `ENTITATE_UTILIZATOR`

**Structură:**
- `Id` - ID înregistrare
- `NumeEntitate` - Numele entității
- `IdUtilizator` - FK la UTILIZATORI
- `TipAcces` - READ, WRITE, DELETE, ALL
- `ConditieWhere` - Condiție WHERE pentru filtrare (opțional)
- `Status` - ACTIV, INACTIV, EXPIRAT

**Funcționalitate:**
- Definește accesul direct al utilizatorilor la entități
- Permite filtrare prin condiții WHERE (ex: doar propriile aplicații)
- Exemple: Utilizator X → Entitatea APLICATII → READ → WHERE UserId = X

#### 4.5 Funcție de Verificare Acces
**Funcție:** `fn_utilizator_poate_proces(p_user_id, p_nume_proces)`

**Ce face:**
- Verifică dacă un utilizator are acces la un proces
- Verifică matricea proces-utilizator
- Verifică rolul utilizatorului (ADMIN are acces la tot)
- Returnează 1 dacă are acces, 0 dacă nu

**Exemplu:**
```sql
-- Verifică dacă utilizatorul 1 poate vizualiza aplicațiile
SELECT fn_utilizator_poate_proces(1, 'VIEW_OWN_APPLICATIONS') AS HasAccess FROM DUAL;
```

**Rezultat:**
- Control granular al accesului
- Separare clară între procese, entități și utilizatori
- Permite implementarea unui sistem RBAC (Role-Based Access Control)

---

## <a name="cerinta-5"></a>5. Cerința 5: Privilegii și Roluri

### 📄 Ce cere cerința:
- Privilegii sistem și obiect
- Ierarhii de privilegii
- Privilegii asupra obiectelor dependente

### ✅ Ce am implementat:

#### 5.1 Roluri Oracle
**Fișier:** `OracleDatabase/08_PRIVILEGII_ROLURI.sql`

**Roluri create:**

1. **`moneyshop_client_role`**
   - Pentru utilizatori CLIENT
   - Privilegii: SELECT pe UTILIZATORI, SELECT/INSERT/UPDATE pe APLICATII
   - Privilegii: SELECT/INSERT pe DOCUMENTE, CONSENTURI, MANDATE

2. **`moneyshop_broker_role`**
   - Pentru utilizatori BROKER
   - Include toate privilegiile CLIENT
   - Privilegii suplimentare: SELECT/UPDATE pe APLICATII (toate)
   - Privilegii: SELECT/INSERT/UPDATE pe DOCUMENTE

3. **`moneyshop_admin_role`**
   - Pentru utilizatori ADMIN
   - Include toate privilegiile BROKER
   - Privilegii: SELECT/INSERT/UPDATE/DELETE pe toate tabelele
   - Privilegii: SELECT pe AUDIT_LOG

4. **`moneyshop_readonly_role`**
   - Pentru utilizatori care doar citesc
   - Privilegii: SELECT pe toate tabelele (fără modificare)

#### 5.2 Ierarhie Privilegii
**Structură ierarhică:**
```
moneyshop_client_role
    ↓ (granted to)
moneyshop_broker_role
    ↓ (granted to)
moneyshop_admin_role
```

**Implementare:**
```sql
GRANT moneyshop_client_role TO moneyshop_broker_role;
GRANT moneyshop_broker_role TO moneyshop_admin_role;
```

**Rezultat:**
- ADMIN are toate privilegiile BROKER și CLIENT
- BROKER are toate privilegiile CLIENT
- Separare clară a responsabilităților

#### 5.3 Privilegii Obiect (pe Tabele)
**Privilegii acordate pe tabele:**

**CLIENT:**
- UTILIZATORI: SELECT
- APLICATII: SELECT, INSERT, UPDATE
- DOCUMENTE: SELECT, INSERT
- CONSENTURI: SELECT, INSERT
- MANDATE: SELECT, INSERT

**BROKER:**
- UTILIZATORI: SELECT
- APLICATII: SELECT, UPDATE (toate aplicațiile)
- DOCUMENTE: SELECT, INSERT, UPDATE
- CONSENTURI: SELECT
- MANDATE: SELECT

**ADMIN:**
- Toate tabelele: SELECT, INSERT, UPDATE, DELETE
- AUDIT_LOG: SELECT (doar citire pentru audit)

#### 5.4 Privilegii pe Proceduri/Funcții
**Proceduri:**
- `sp_autentificare_utilizator` - Acordat tuturor rolurilor
- `sp_schimbare_parola` - Acordat tuturor rolurilor
- `fn_utilizator_poate_proces` - Acordat tuturor rolurilor

**Implementare:**
```sql
GRANT EXECUTE ON sp_autentificare_utilizator 
    TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
```

#### 5.5 Privilegii pe View-uri
**View-uri securizate:**
- `vw_utilizatori_public` - Date publice utilizatori (toate rolurile)
- `vw_aplicatii_public` - Date publice aplicații (toate rolurile)
- `vw_utilizatori_decrypted` - Date decriptate (doar ADMIN)
- `vw_client_own_applications` - Doar propriile aplicații (CLIENT)

**Privilegii:**
- View-uri publice: SELECT pentru toate rolurile
- View-uri sensibile: SELECT doar pentru ADMIN

**Rezultat:**
- Control granular al accesului
- Separare privilegii pe niveluri
- Respectă principiul "least privilege"

---

## <a name="cerinta-6"></a>6. Cerința 6: Aplicațiile pe Baza de Date și Securitatea Datelor (SQL Injection)

### 📄 Ce cere cerința:
- Contextul aplicației
- SQL Injection - prevenire și protecție

### ✅ Ce am implementat:

#### 6.1 Procedură Securizată de Autentificare
**Fișier:** `OracleDatabase/04_SECURITATE.sql`

**Procedură:** `sp_autentificare_utilizator(p_username, p_parola_hash, p_user_id OUT, p_rol OUT, p_success OUT)`

**Caracteristici de securitate:**
- ✅ Folosește parametri (nu concatenare SQL)
- ✅ Previne SQL Injection prin parametrizare
- ✅ Validează parola hash-uită
- ✅ Înregistrează în AUDIT_LOG (succes/eșec)
- ✅ Returnează erori generice (nu dezvăluie dacă utilizatorul există)

**Exemplu utilizare:**
```sql
DECLARE
    v_user_id NUMBER;
    v_rol VARCHAR2(50);
    v_success NUMBER;
BEGIN
    sp_autentificare_utilizator(
        'username', 
        'hash_parola', 
        v_user_id, 
        v_rol, 
        v_success
    );
END;
```

**Protecție SQL Injection:**
- ❌ **NU face asta:** `'SELECT * FROM UTILIZATORI WHERE Username = ''' || p_username || ''''`
- ✅ **Face asta:** `SELECT * FROM UTILIZATORI WHERE Username = p_username` (parametru)

#### 6.2 Trigger de Validare Email
**Trigger:** `trg_utilizatori_email`

**Ce face:**
- Se declanșează: BEFORE INSERT/UPDATE pe UTILIZATORI.Email
- Validează formatul email cu regex
- Previne inserarea de cod SQL în email
- Format validat: `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$`

**Protecție:**
- Blochează: `test'; DROP TABLE UTILIZATORI; --`
- Acceptă: `test@example.com`

#### 6.3 View Securizat pentru Clienți
**View:** `vw_client_own_applications`

**Caracteristici:**
- Afișează doar aplicațiile utilizatorului curent
- Folosește `SYS_CONTEXT('USERENV', 'SESSION_USERID')`
- Previne accesul la datele altor utilizatori

**Implementare:**
```sql
CREATE VIEW vw_client_own_applications AS
SELECT * FROM APLICATII
WHERE UserId = SYS_CONTEXT('USERENV', 'SESSION_USERID');
```

**Securitate:**
- Utilizatorul nu poate modifica condiția WHERE
- Oracle aplică automat filtrarea
- Previne accesul neautorizat

#### 6.4 Procedură Securizată de Schimbare Parolă
**Procedură:** `sp_schimbare_parola(p_user_id, p_parola_veche, p_parola_noua, p_success OUT)`

**Caracteristici:**
- Validare parolă veche
- Validare parolă nouă (conform regulilor)
- Parametrizație completă
- Auditare automată

#### 6.5 Best Practices Implementate

**1. Parametrizare obligatorie:**
- Toate procedurile folosesc parametri
- Nu se face concatenare SQL niciodată

**2. Validare input:**
- Triggeri pentru validare format
- Constrainte CHECK în tabele
- Validare la nivel de bază de date

**3. Mesaje de eroare generice:**
- Nu dezvăluie dacă utilizatorul există
- Nu dezvăluie structura bazei de date

**4. Separare privilegii:**
- Utilizatorii au doar privilegii necesare
- Nu au acces direct la tabele sensibile

**Rezultat:**
- Protecție completă împotriva SQL Injection
- Validare la multiple niveluri
- Respectă best practices Oracle

---

## <a name="cerinta-7"></a>7. Cerința 7: Mascarea Datelor

### 📄 Ce cere cerința:
- Mascarea datelor sensibile pentru protecția confidențialității
- Utilizare în medii non-producție
- Protecție pentru utilizatori neautorizați

### ✅ Ce am implementat:

#### 7.1 Funcții de Mascare
**Fișier:** `OracleDatabase/10_MASCARE_DATE.sql`

**Funcții create:**

1. **`fn_mask_email(p_email)`**
   - Mascare email: `test@example.com` → `t***@example.com`
   - Păstrează primul caracter și domeniul
   - Mascare partea locală

2. **`fn_mask_telefon(p_telefon)`**
   - Mascare telefon: `0712345678` → `071***78`
   - Păstrează primele 3 și ultimele 2 cifre
   - Mascare mijlocul

3. **`fn_mask_cnp(p_cnp)`**
   - Mascare CNP: `1234567890123` → `12***23`
   - Păstrează primele 2 și ultimele 2 cifre
   - Mascare restul (conform GDPR)

4. **`fn_mask_nume(p_nume)`**
   - Mascare nume: `Popescu` → `P***u`
   - Păstrează prima și ultima literă
   - Mascare mijlocul

**Exemplu utilizare:**
```sql
SELECT 
    Email AS Original,
    fn_mask_email(Email) AS Mascat
FROM UTILIZATORI;
```

#### 7.2 View-uri cu Date Mascate

**1. `vw_utilizatori_masked`**
- Afișează toți utilizatorii cu datele mascate
- Email, telefon, nume, prenume - toate mascate
- Utilizare: Pentru rapoarte, testare, demo

**Structură:**
```sql
SELECT 
    IdUtilizator,
    fn_mask_nume(Nume) AS Nume_Masked,
    fn_mask_email(Email) AS Email_Masked,
    fn_mask_telefon(NumarTelefon) AS Telefon_Masked
FROM UTILIZATORI;
```

**2. `vw_broker_clients_masked`**
- Afișează clienții pentru brokeri cu date mascate
- Protejează confidențialitatea clienților
- Brokerii văd doar datele necesare (mascate)

**Structură:**
```sql
SELECT 
    IdUtilizator,
    fn_mask_nume(Nume) AS Nume,
    fn_mask_email(Email) AS Email,
    fn_mask_telefon(NumarTelefon) AS Telefon
FROM UTILIZATORI
WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'CLIENT');
```

#### 7.3 Utilizare în Medii Non-Producție

**Scenarii:**
1. **Testare aplicație:**
   - Dezvoltatorii văd date mascate
   - Nu au acces la date reale
   - Respectă GDPR

2. **Demo pentru clienți:**
   - Prezentări cu date mascate
   - Nu expun informații reale
   - Profesional și sigur

3. **Rapoarte pentru management:**
   - Statistici fără date personale
   - Agregare cu date mascate
   - Respectă confidențialitatea

#### 7.4 Integrare cu Privilegii

**Control acces:**
- Utilizatorii normali: Văd date mascate (view-uri mascate)
- ADMIN: Văd date complete (view-uri normale)
- BROKER: Văd date mascate ale clienților

**Implementare:**
```sql
-- Clienții văd doar date mascate
GRANT SELECT ON vw_utilizatori_masked TO moneyshop_client_role;

-- Admin văd date complete
GRANT SELECT ON UTILIZATORI TO moneyshop_admin_role;
```

**Rezultat:**
- Protecție confidențialitate
- Respectă GDPR
- Permite testare fără risc
- Flexibilitate în controlul accesului

---

## 📊 Rezumat Implementare

### Fișiere SQL Create:

1. **`03_CREATE_TABLES.sql`** - Structura bazei de date
2. **`04_SECURITATE.sql`** - Reguli și validări securitate
3. **`05_CRIPTARE.sql`** - Criptare date sensibile
4. **`06_AUDITARE.sql`** - Auditare activități
5. **`07_GESTIUNE_UTILIZATORI.sql`** - Matrici proces/entitate/utilizator
6. **`08_PRIVILEGII_ROLURI.sql`** - Roluri și privilegii
7. **`10_MASCARE_DATE.sql`** - Mascare date

### Componente Create:

- **15+ Tabele** cu structură completă
- **10+ Triggeri** pentru validare și auditare
- **20+ Funcții/Proceduri** PL/SQL
- **10+ View-uri** pentru securitate și raportare
- **4 Roluri Oracle** cu ierarhie
- **3 Politici FGA** pentru auditare granulară
- **4 Funcții de mascare** pentru protecție GDPR

### Securitate Implementată:

✅ Criptare AES-256 pentru date sensibile  
✅ Auditare completă a tuturor operațiunilor  
✅ Control granular al accesului (RBAC)  
✅ Protecție SQL Injection  
✅ Mascare date pentru GDPR  
✅ Validare la nivel de bază de date  
✅ Separare privilegii pe roluri  

---

## 🎯 Concluzie

Toate cele 7 cerințe au fost implementate complet:
- ✅ Diagramă și scheme relaționale
- ✅ Criptare date sensibile
- ✅ Auditare activități
- ✅ Gestiune utilizatori și resurse
- ✅ Privilegii și roluri
- ✅ Protecție SQL Injection
- ✅ Mascare date

**Proiectul respectă toate cerințele de securitate și este gata pentru prezentare!**

---

**Data:** 2025-01-08  
**Autor:** Cristea Eduard - Grupa 505

