# 2. Scheme Relaționale - MoneyShop

## 2.1 Normalizare

Toate tabelele sunt normalizate la **3NF (Third Normal Form)** pentru a elimina redundanța și a asigura integritatea datelor.

---

## 2.2 Scheme Relaționale

### UTILIZATORI (IdUtilizator, Nume, Prenume, Username, Email, Parola, NumarTelefon, EmailVerified, PhoneVerified, DataNastere, IdRol, IsDeleted, CreatedAt, UpdatedAt)

**Cheie Primară**: IdUtilizator  
**Cheie Unică**: Email, Username  
**Cheie Străină**: IdRol → ROLURI.IdRol

**Constrângeri**:
- Email: NOT NULL, UNIQUE, format valid
- Username: NOT NULL, UNIQUE
- Parola: NOT NULL, min 8 caractere, hash SHA-256
- NumarTelefon: format valid (10 cifre)
- DataNastere: NOT NULL, validare vârstă minimă 18 ani
- IsDeleted: DEFAULT 0

---

### ROLURI (IdRol, NumeRol, Descriere, CreatedAt)

**Cheie Primară**: IdRol  
**Cheie Unică**: NumeRol

**Valori posibile pentru NumeRol**: 'CLIENT', 'BROKER', 'ADMIN'

---

### APLICATII (Id, UserId, Status, TypeCredit, TipOperatiune, SalariuNet, BonuriMasa, SumaBonuriMasa, VechimeLuni, NrCrediteBanci, ListaBanciActive, NrIfn, Poprire, SoldTotal, Intarzieri, IntarzieriNumar, CardCredit, Overdraft, Codebitori, Scoring, Dti, RecommendedLevel, SumaAprobata, Comision, DataDisbursare, CreatedAt, UpdatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: UserId → UTILIZATORI.IdUtilizator

**Constrângeri**:
- Status: NOT NULL, CHECK IN ('INREGISTRAT', 'IN_PROCESARE', 'APROBAT', 'REFUZAT', 'ANULAT')
- TypeCredit: CHECK IN ('IPOTECAR', 'NEVOI_PERSONALE', 'REFINANTARE')
- TipOperatiune: CHECK IN ('NOU', 'REFINANTARE')
- SalariuNet: >= 0
- Scoring: BETWEEN 300 AND 850
- Dti: BETWEEN 0 AND 100 (procent)
- CreatedAt: NOT NULL, DEFAULT SYSTIMESTAMP
- UpdatedAt: NOT NULL, DEFAULT SYSTIMESTAMP

---

### BANCI (Id, Name, CommissionPercent, Active, CreatedAt)

**Cheie Primară**: Id  
**Cheie Unică**: Name

**Constrângeri**:
- Name: NOT NULL, UNIQUE
- CommissionPercent: BETWEEN 0 AND 100
- Active: DEFAULT 1

---

### APPLICATION_BANKS (Id, ApplicationId, BankId, Status, CreatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: ApplicationId → APLICATII.Id  
**Cheie Străină**: BankId → BANCI.Id  
**Cheie Unică**: (ApplicationId, BankId)

**Constrângeri**:
- Status: CHECK IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')

---

### DOCUMENTE (Id, ApplicationId, TipDocument, NumeFisier, Path, SizeBytes, MimeType, CreatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: ApplicationId → APLICATII.Id

**Constrângeri**:
- TipDocument: NOT NULL, CHECK IN ('CI', 'FLUTURAS', 'EXTRAS_CONT', 'CONTRACT', 'ALTUL')
- Path: NOT NULL (criptat)
- SizeBytes: > 0
- CreatedAt: DEFAULT SYSTIMESTAMP

---

### AGREEMENTS (Id, ApplicationId, TipAcord, Status, DataAcord, DataExpirare, CreatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: ApplicationId → APLICATII.Id

**Constrângeri**:
- TipAcord: CHECK IN ('TERMENI_CONDITII', 'CONSENT_GDPR', 'MANDAT_BROKER')
- Status: CHECK IN ('ACTIV', 'EXPIRAT', 'REVOCAT')
- DataExpirare: > DataAcord

---

### LEADURI (Id, Nume, Prenume, Email, NumarTelefon, Status, Source, CreatedAt)

**Cheie Primară**: Id

**Constrângeri**:
- Email: format valid
- NumarTelefon: format valid
- Status: CHECK IN ('NOU', 'CONTACTAT', 'CONVERTIT', 'RESPINS')
- CreatedAt: DEFAULT SYSTIMESTAMP

---

### CONSENTURI (Id, UserId, TipConsent, Status, DataConsent, DataExpirare, IpAddress, CreatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: UserId → UTILIZATORI.IdUtilizator

**Constrângeri**:
- TipConsent: CHECK IN ('PROCESARE_DATE', 'MARKETING', 'COMUNICARE_BANCI')
- Status: CHECK IN ('ACTIV', 'EXPIRAT', 'REVOCAT')
- DataConsent: NOT NULL, DEFAULT SYSTIMESTAMP

---

### MANDATE (Id, UserId, BrokerId, Status, DataMandat, DataExpirare, CreatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: UserId → UTILIZATORI.IdUtilizator  
**Cheie Străină**: BrokerId → UTILIZATORI.IdUtilizator (WHERE IdRol = 'BROKER')

**Constrângeri**:
- Status: CHECK IN ('ACTIV', 'EXPIRAT', 'REVOCAT')
- DataMandat: NOT NULL, DEFAULT SYSTIMESTAMP
- BrokerId: trebuie să fie utilizator cu rol BROKER

---

### USER_FINANCIAL_DATA (Id, UserId, SalariuNet, BonuriMasa, SumaBonuriMasa, VenitTotal, SoldTotal, RataTotalaLunara, NrCrediteBanci, NrIfn, Poprire, Intarzieri, IntarzieriNumar, Dti, ScoringLevel, RecommendedLevel, LastUpdated, CreatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: UserId → UTILIZATORI.IdUtilizator  
**Cheie Unică**: UserId

**Constrângeri**:
- SalariuNet: >= 0
- VenitTotal: >= SalariuNet (calculat automat)
- Dti: BETWEEN 0 AND 100
- ScoringLevel: CHECK IN ('FOARTE_BUNA', 'BUNA', 'MEDIE', 'SLABA', 'FOARTE_SLABA')
- LastUpdated: DEFAULT SYSTIMESTAMP
- CreatedAt: DEFAULT SYSTIMESTAMP

---

### AUDIT_LOG (Id, TableName, Operation, UserId, OldValues, NewValues, IpAddress, Timestamp)

**Cheie Primară**: Id

**Constrângeri**:
- Operation: CHECK IN ('INSERT', 'UPDATE', 'DELETE')
- Timestamp: DEFAULT SYSTIMESTAMP

---

### USER_SESSIONS (Id, UserId, Token, ExpiresAt, IpAddress, UserAgent, CreatedAt)

**Cheie Primară**: Id  
**Cheie Străină**: UserId → UTILIZATORI.IdUtilizator

**Constrângeri**:
- Token: NOT NULL, UNIQUE
- ExpiresAt: > CreatedAt

**Notă**: Tabela se numește USER_SESSIONS (SESSION este cuvânt rezervat în Oracle)

---

## 2.3 Indexuri Recomandate

```sql
-- Indexuri pentru performanță
CREATE INDEX idx_applications_userid ON APLICATII(UserId);
CREATE INDEX idx_applications_status ON APLICATII(Status);
CREATE INDEX idx_documents_applicationid ON DOCUMENTE(ApplicationId);
CREATE INDEX idx_consenturi_userid ON CONSENTURI(UserId);
CREATE INDEX idx_mandate_userid ON MANDATE(UserId);
CREATE INDEX idx_audit_log_timestamp ON AUDIT_LOG(Timestamp);
CREATE INDEX idx_audit_log_tablename ON AUDIT_LOG(TableName);
CREATE INDEX idx_session_token ON USER_SESSIONS(Token);
CREATE INDEX idx_session_userid ON USER_SESSIONS(UserId);
```

---

## 2.4 Dependențe Funcționale

### UTILIZATORI
- IdUtilizator → Nume, Prenume, Email, Parola, IdRol
- Email → IdUtilizator (unic)
- Username → IdUtilizator (unic)

### APLICATII
- Id → UserId, Status, TypeCredit, Scoring
- UserId → (nu determină unic Id, dar este FK)

### DOCUMENTE
- Id → ApplicationId, TipDocument, Path
- ApplicationId → (nu determină unic Id, dar este FK)

---

## 2.5 Note de Implementare

- Toate tabelele au coloane CreatedAt și UpdatedAt pentru audit
- Soft delete prin flag IsDeleted
- Timestamp-uri în format TIMESTAMP WITH TIME ZONE
- Criptare pentru coloanele sensibile (CNP, Email, Telefon)

