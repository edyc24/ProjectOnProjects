# NORMALIZARE FN1 → FN2 → FN3
## Proiect SBD - Cerința 5

**Data:** 2025-01-08  
**Baza de date:** MoneyShop - Oracle Database

---

## 1. EXEMPLU DE ATRIBUT REPETITIV (MULTIVALOARE)

### 1.1 Identificare Atribut Repetitiv

În tabelul **APLICATII**, există atributul **`ListaBanciActive`** de tip **CLOB** care stochează un JSON array cu ID-urile băncilor active:

```sql
CREATE TABLE APLICATII (
    ...
    ListaBanciActive CLOB, -- JSON array: [1, 2, 3]
    ...
);
```

**Problema:** Acest atribut este multivaloare - o aplicație poate avea mai multe bănci active asociate.

**Soluție:** Atributul repetitiv a fost deja rezolvat prin crearea tabelului asociativ **APPLICATION_BANKS** care elimină multivaloarea:

```sql
CREATE TABLE APPLICATION_BANKS (
    Id NUMBER PRIMARY KEY,
    ApplicationId NUMBER NOT NULL,
    BankId NUMBER NOT NULL,
    Status VARCHAR2(50),
    FOREIGN KEY (ApplicationId) REFERENCES APLICATII(Id),
    FOREIGN KEY (BankId) REFERENCES BANCI(Id),
    UNIQUE (ApplicationId, BankId)
);
```

**Rezultat:** Fiecare bancă asociată unei aplicații este o înregistrare separată în `APPLICATION_BANKS`, eliminând atributul repetitiv.

---

## 2. EXEMPLU: TABEL ÎN FN1 DAR NU ÎN FN2

### 2.1 Creare Tabel în FN1 (First Normal Form)

Vom crea un tabel temporar **`APLICATII_TEMP_FN1`** care este în FN1 dar nu în FN2:

```sql
-- Tabel în FN1 (are dependențe funcționale parțiale)
CREATE TABLE APLICATII_TEMP_FN1 (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    NumeUtilizator VARCHAR2(100),  -- Depinde de UserId, nu de Id
    PrenumeUtilizator VARCHAR2(100), -- Depinde de UserId, nu de Id
    EmailUtilizator VARCHAR2(255),   -- Depinde de UserId, nu de Id
    Status VARCHAR2(50),
    TypeCredit VARCHAR2(50),
    SumaAprobata NUMBER(18,2),
    CreatedAt TIMESTAMP
);
```

**Problema FN1:** 
- Tabelul este în FN1 (toate valorile sunt atomice, nu există grupuri repetitive)
- **DAR** există dependențe funcționale parțiale:
  - `NumeUtilizator`, `PrenumeUtilizator`, `EmailUtilizator` depind de `UserId`, nu de cheia primară `Id`
  - Acestea ar trebui să fie în tabelul `UTILIZATORI`, nu în `APLICATII`

### 2.2 Aducere la FN2 (Second Normal Form)

Pentru a aduce tabelul la FN2, trebuie să eliminăm dependențele funcționale parțiale:

```sql
-- Tabel în FN2 (eliminăm dependențele parțiale)
CREATE TABLE APLICATII_TEMP_FN2 (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    Status VARCHAR2(50),
    TypeCredit VARCHAR2(50),
    SumaAprobata NUMBER(18,2),
    CreatedAt TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator)
);

-- Datele utilizatorului rămân în tabelul UTILIZATORI
-- (care este deja în FN2)
```

**Rezultat FN2:**
- Toate atributele non-cheie depind complet de cheia primară `Id`
- Datele utilizatorului sunt referențiate prin `UserId` către tabelul `UTILIZATORI`
- Nu mai există dependențe funcționale parțiale

**Demonstrație:**
```sql
-- Verificare: toate atributele depind complet de Id
-- Id → Status, TypeCredit, SumaAprobata, CreatedAt, UserId ✓
-- UserId → (referință către UTILIZATORI) ✓
```

---

## 3. EXEMPLU: TABEL ÎN FN2 DAR NU ÎN FN3

### 3.1 Creare Tabel în FN2 (Second Normal Form)

Vom crea un tabel temporar **`APLICATII_TEMP_FN2`** care este în FN2 dar nu în FN3:

```sql
-- Tabel în FN2 (are dependențe funcționale tranzitive)
CREATE TABLE APLICATII_TEMP_FN2 (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    Status VARCHAR2(50),
    TypeCredit VARCHAR2(50),
    IdBanca NUMBER,              -- Depinde de ApplicationId prin APPLICATION_BANKS
    NumeBanca VARCHAR2(200),     -- Depinde de IdBanca, nu direct de Id
    CommissionPercent NUMBER(5,2), -- Depinde de IdBanca, nu direct de Id
    SumaAprobata NUMBER(18,2),
    CreatedAt TIMESTAMP
);
```

**Problema FN2:**
- Tabelul este în FN2 (toate atributele non-cheie depind complet de cheia primară)
- **DAR** există dependențe funcționale tranzitive:
  - `NumeBanca` și `CommissionPercent` depind de `IdBanca`
  - `IdBanca` depinde de `Id` (prin relația many-to-many)
  - Deci: `Id` → `IdBanca` → `NumeBanca`, `CommissionPercent` (dependență tranzitivă)

### 3.2 Aducere la FN3 (Third Normal Form)

Pentru a aduce tabelul la FN3, trebuie să eliminăm dependențele tranzitive:

```sql
-- Tabel în FN3 (eliminăm dependențele tranzitive)
CREATE TABLE APLICATII_TEMP_FN3 (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER NOT NULL,
    Status VARCHAR2(50),
    TypeCredit VARCHAR2(50),
    SumaAprobata NUMBER(18,2),
    CreatedAt TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator)
);

-- Datele băncii rămân în tabelul BANCI
-- Asocierea aplicație-bancă este în APPLICATION_BANKS
CREATE TABLE APPLICATION_BANKS (
    ApplicationId NUMBER NOT NULL,
    BankId NUMBER NOT NULL,
    PRIMARY KEY (ApplicationId, BankId),
    FOREIGN KEY (ApplicationId) REFERENCES APLICATII_TEMP_FN3(Id),
    FOREIGN KEY (BankId) REFERENCES BANCI(Id)
);
```

**Rezultat FN3:**
- Nu mai există dependențe funcționale tranzitive
- `NumeBanca` și `CommissionPercent` sunt în tabelul `BANCI`
- Asocierea este în `APPLICATION_BANKS`
- Toate atributele non-cheie depind direct de cheia primară, fără dependențe tranzitive

**Demonstrație:**
```sql
-- Verificare: nu există dependențe tranzitive
-- Id → Status, TypeCredit, SumaAprobata, CreatedAt, UserId ✓
-- UserId → (referință către UTILIZATORI) ✓
-- Id → (prin APPLICATION_BANKS) → BankId → (referință către BANCI) ✓
-- Nu există: Id → BankId → NumeBanca (tranzitivă eliminată) ✓
```

---

## 4. DEMONSTRAȚIE: TOATE TABELELE EXISTENTE SUNT ÎN FN3

### 4.1 Verificare Tabel ROLURI

```sql
CREATE TABLE ROLURI (
    IdRol NUMBER PRIMARY KEY,
    NumeRol VARCHAR2(50) UNIQUE,
    Descriere VARCHAR2(500),
    CreatedAt TIMESTAMP
);
```

**Verificare FN3:**
- ✓ FN1: Toate valorile sunt atomice
- ✓ FN2: Toate atributele non-cheie depind complet de `IdRol`
- ✓ FN3: Nu există dependențe tranzitive
- **Rezultat:** Tabelul este în FN3 ✓

### 4.2 Verificare Tabel UTILIZATORI

```sql
CREATE TABLE UTILIZATORI (
    IdUtilizator NUMBER PRIMARY KEY,
    Nume VARCHAR2(100),
    Prenume VARCHAR2(100),
    Username VARCHAR2(50) UNIQUE,
    Email VARCHAR2(255) UNIQUE,
    Parola VARCHAR2(255),
    NumarTelefon VARCHAR2(20),
    DataNastere DATE,
    IdRol NUMBER,
    FOREIGN KEY (IdRol) REFERENCES ROLURI(IdRol)
);
```

**Verificare FN3:**
- ✓ FN1: Toate valorile sunt atomice
- ✓ FN2: Toate atributele non-cheie depind complet de `IdUtilizator`
- ✓ FN3: `IdRol` este cheie străină, nu există dependențe tranzitive
- **Rezultat:** Tabelul este în FN3 ✓

### 4.3 Verificare Tabel APLICATII

```sql
CREATE TABLE APLICATII (
    Id NUMBER PRIMARY KEY,
    UserId NUMBER,
    Status VARCHAR2(50),
    TypeCredit VARCHAR2(50),
    SumaAprobata NUMBER(18,2),
    Scoring NUMBER(5,2),
    FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator)
);
```

**Verificare FN3:**
- ✓ FN1: Toate valorile sunt atomice (ListaBanciActive a fost eliminată prin APPLICATION_BANKS)
- ✓ FN2: Toate atributele non-cheie depind complet de `Id`
- ✓ FN3: `UserId` este cheie străină, nu există dependențe tranzitive
- **Rezultat:** Tabelul este în FN3 ✓

### 4.4 Verificare Tabel APPLICATION_BANKS

```sql
CREATE TABLE APPLICATION_BANKS (
    ApplicationId NUMBER,
    BankId NUMBER,
    PRIMARY KEY (ApplicationId, BankId),
    FOREIGN KEY (ApplicationId) REFERENCES APLICATII(Id),
    FOREIGN KEY (BankId) REFERENCES BANCI(Id)
);
```

**Verificare FN3:**
- ✓ FN1: Toate valorile sunt atomice
- ✓ FN2: Cheia primară compusă (ApplicationId, BankId) - toate atributele depind de cheia completă
- ✓ FN3: Nu există dependențe tranzitive
- **Rezultat:** Tabelul este în FN3 ✓

### 4.5 Verificare Tabel BANCI

```sql
CREATE TABLE BANCI (
    Id NUMBER PRIMARY KEY,
    Name VARCHAR2(200) UNIQUE,
    CommissionPercent NUMBER(5,2),
    Active NUMBER(1)
);
```

**Verificare FN3:**
- ✓ FN1: Toate valorile sunt atomice
- ✓ FN2: Toate atributele non-cheie depind complet de `Id`
- ✓ FN3: Nu există dependențe tranzitive
- **Rezultat:** Tabelul este în FN3 ✓

---

## 5. REZUMAT NORMALIZARE

### 5.1 Atribut Repetitiv Identificat
- **Atribut:** `ListaBanciActive CLOB` din `APLICATII`
- **Soluție:** Tabel asociativ `APPLICATION_BANKS`

### 5.2 Exemplu FN1 → FN2
- **Tabel FN1:** `APLICATII_TEMP_FN1` cu dependențe parțiale (NumeUtilizator, EmailUtilizator depind de UserId)
- **Tabel FN2:** `APLICATII_TEMP_FN2` fără dependențe parțiale (date utilizator în UTILIZATORI)

### 5.3 Exemplu FN2 → FN3
- **Tabel FN2:** `APLICATII_TEMP_FN2` cu dependențe tranzitive (NumeBanca, CommissionPercent depind de IdBanca)
- **Tabel FN3:** `APLICATII_TEMP_FN3` fără dependențe tranzitive (date bancă în BANCI)

### 5.4 Toate Tabelele Existente sunt în FN3
- ✓ ROLURI
- ✓ UTILIZATORI
- ✓ BANCI
- ✓ APLICATII
- ✓ APPLICATION_BANKS
- ✓ DOCUMENTE
- ✓ AGREEMENTS
- ✓ CONSENTURI
- ✓ MANDATE
- ✓ LEADURI
- ✓ USER_FINANCIAL_DATA
- ✓ USER_SESSIONS
- ✓ AUDIT_LOG
- ✓ MESAJE

---

**Data finalizare:** 2025-01-08  
**Status:** ✅ Toate tabelele sunt în FN3

