# Diagramă Stea - Data Warehouse MoneyShop

## 📊 Modelul Stea

```
                    ┌─────────────────────┐
                    │ FACT_APLICATII_CREDIT│
                    │   (Tabel de Fapte)  │
                    ├─────────────────────┤
                    │ IdFact (PK)         │
                    │ IdUtilizator (FK)   │
                    │ IdBanca (FK)        │
                    │ IdTimp (FK)        │
                    │ IdTipCredit (FK)   │
                    │ IdStatus (FK)      │
                    │ IdBroker (FK)     │
                    │                    │
                    │ SumaAprobata       │
                    │ Comision           │
                    │ Scoring            │
                    │ Dti                │
                    │ NumărAplicatii     │
                    │ DurataProcesare    │
                    └─────────┬──────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        │                     │                     │
┌───────▼────────┐  ┌────────▼────────┐  ┌────────▼────────┐
│ DIM_UTILIZATOR │  │   DIM_BANCA     │  │    DIM_TIMP     │
├────────────────┤  ├─────────────────┤  ├─────────────────┤
│ IdUtilizator   │  │ IdBanca (PK)    │  │ IdTimp (PK)     │
│ Nume           │  │ Name            │  │ DataCompleta    │
│ Prenume        │  │ CommissionPercent│  │ An              │
│ EmailMasked    │  │ Active          │  │ Trimestru       │
│ TelefonMasked  │  │ CreatedAt       │  │ Luna            │
│ IdRol          │  │                 │  │ Saptamana       │
│ DataNastere    │  │                 │  │ Zi              │
│ VechimeLuni    │  │                 │  │ ZiSaptamana     │
│ CreatedAt      │  │                 │  │ EsteWeekend     │
└────────────────┘  └─────────────────┘  └─────────────────┘

┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│ DIM_TIP_CREDIT│  │  DIM_STATUS   │  │  DIM_BROKER   │
├───────────────┤  ├───────────────┤  ├───────────────┤
│ IdTipCredit   │  │ IdStatus (PK) │  │ IdBroker (PK) │
│ TypeCredit    │  │ Status        │  │ Nume          │
│ TipOperatiune │  │ Descriere     │  │ Prenume       │
│ Descriere     │  │ Categorie     │  │ EmailMasked   │
│               │  │               │  │ CreatedAt     │
└───────────────┘  └───────────────┘  └───────────────┘
```

---

## 📋 Descrierea Tabelelor

### FACT_APLICATII_CREDIT (Tabel de Fapte)

**Granularitate:** O înregistrare per aplicație de credit

**Chei Străine:**
- `IdUtilizator` → DIM_UTILIZATOR.IdUtilizator
- `IdBanca` → DIM_BANCA.IdBanca
- `IdTimp` → DIM_TIMP.IdTimp
- `IdTipCredit` → DIM_TIP_CREDIT.IdTipCredit
- `IdStatus` → DIM_STATUS.IdStatus
- `IdBroker` → DIM_BROKER.IdBroker (NULL dacă nu are broker)

**Măsuri (Measures):**
- `SumaAprobata` - Suma aprobată pentru credit (NUMBER(18,2))
- `Comision` - Comisionul perceput (NUMBER(18,2))
- `Scoring` - Scorul de credit (NUMBER(5,2))
- `Dti` - Debt-to-Income ratio (NUMBER(5,2))
- `NumărAplicatii` - Numărul de aplicații (NUMBER) - de obicei 1, dar poate fi agregat
- `DurataProcesare` - Durata procesării în zile (NUMBER)

**Atribute Descriptive:**
- `SalariuNet` - Salariul net al utilizatorului (NUMBER(18,2))
- `SoldTotal` - Soldul total al datoriilor (NUMBER(18,2))

---

### DIM_UTILIZATOR (Dimensiune Utilizator)

**Tip:** Dimensiune lentă (Slowly Changing Dimension - SCD Type 2)

**Atribute:**
- `IdUtilizator` (PK) - ID utilizator din OLTP
- `Nume` - Nume utilizator
- `Prenume` - Prenume utilizator
- `EmailMasked` - Email mascat (pentru securitate)
- `TelefonMasked` - Telefon mascat
- `IdRol` - ID rol (CLIENT, BROKER, ADMIN)
- `DataNastere` - Data nașterii
- `VechimeLuni` - Vechime în luni (calculat)
- `CreatedAt` - Data creării contului

**Sursă OLTP:** `UTILIZATORI`

---

### DIM_BANCA (Dimensiune Bancă)

**Tip:** Dimensiune lentă (SCD Type 1)

**Atribute:**
- `IdBanca` (PK) - ID bancă din OLTP
- `Name` - Numele băncii
- `CommissionPercent` - Procent comision
- `Active` - Status activ (1/0)
- `CreatedAt` - Data adăugării

**Sursă OLTP:** `BANCI`

---

### DIM_TIMP (Dimensiune Timp)

**Tip:** Dimensiune standard (pre-populată)

**Atribute:**
- `IdTimp` (PK) - ID timp (surrogate key)
- `DataCompleta` - Data completă (DATE)
- `An` - Anul (NUMBER)
- `Trimestru` - Trimestrul (1-4)
- `Luna` - Luna (1-12)
- `Saptamana` - Săptămâna (1-53)
- `Zi` - Ziua (1-31)
- `ZiSaptamana` - Ziua săptămânii (1=Luni, 7=Duminică)
- `EsteWeekend` - Flag weekend (1/0)

**Populare:** Pre-populat pentru toate datele relevante (ex: 2020-2030)

**Sursă:** Generat din `APLICATII.CreatedAt`

---

### DIM_TIP_CREDIT (Dimensiune Tip Credit)

**Tip:** Dimensiune standard (lookup table)

**Atribute:**
- `IdTipCredit` (PK) - ID tip credit
- `TypeCredit` - Tip credit (IPOTECAR, NEVOI_PERSONALE, REFINANTARE)
- `TipOperatiune` - Tip operațiune (NOU, REFINANTARE)
- `Descriere` - Descriere tip credit

**Sursă OLTP:** `APLICATII.TypeCredit`, `APLICATII.TipOperatiune`

**Valori posibile:**
- IPOTECAR + NOU
- IPOTECAR + REFINANTARE
- NEVOI_PERSONALE + NOU
- NEVOI_PERSONALE + REFINANTARE
- REFINANTARE + NOU
- REFINANTARE + REFINANTARE

---

### DIM_STATUS (Dimensiune Status)

**Tip:** Dimensiune standard (lookup table)

**Atribute:**
- `IdStatus` (PK) - ID status
- `Status` - Status aplicație (INREGISTRAT, IN_PROCESARE, APROBAT, REFUZAT, ANULAT)
- `Descriere` - Descriere status
- `Categorie` - Categorie (IN_PROCES, FINALIZAT, ANULAT)

**Sursă OLTP:** `APLICATII.Status`

**Valori:**
- INREGISTRAT → Categorie: IN_PROCES
- IN_PROCESARE → Categorie: IN_PROCES
- APROBAT → Categorie: FINALIZAT
- REFUZAT → Categorie: FINALIZAT
- ANULAT → Categorie: ANULAT

---

### DIM_BROKER (Dimensiune Broker)

**Tip:** Dimensiune lentă (SCD Type 1)

**Atribute:**
- `IdBroker` (PK) - ID broker (IdUtilizator din OLTP unde IdRol = 'BROKER')
- `Nume` - Nume broker
- `Prenume` - Prenume broker
- `EmailMasked` - Email mascat
- `CreatedAt` - Data creării

**Sursă OLTP:** `UTILIZATORI` WHERE `IdRol` = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'BROKER')

**Notă:** Poate fi NULL în FACT_APLICATII_CREDIT dacă aplicația nu are broker asociat

---

## 🔄 Mapping OLTP → DW

### FACT_APLICATII_CREDIT
```
APLICATII.Id                    → FACT_APLICATII_CREDIT.IdFact
APLICATII.UserId                → FACT_APLICATII_CREDIT.IdUtilizator (FK)
APPLICATION_BANKS.BankId        → FACT_APLICATII_CREDIT.IdBanca (FK)
APLICATII.CreatedAt             → FACT_APLICATII_CREDIT.IdTimp (FK)
APLICATII.TypeCredit + TipOperatiune → FACT_APLICATII_CREDIT.IdTipCredit (FK)
APLICATII.Status                → FACT_APLICATII_CREDIT.IdStatus (FK)
MANDATE.BrokerId                → FACT_APLICATII_CREDIT.IdBroker (FK, poate fi NULL)

APLICATII.SumaAprobata         → FACT_APLICATII_CREDIT.SumaAprobata
APLICATII.Comision              → FACT_APLICATII_CREDIT.Comision
APLICATII.Scoring               → FACT_APLICATII_CREDIT.Scoring
APLICATII.Dti                   → FACT_APLICATII_CREDIT.Dti
1                                → FACT_APLICATII_CREDIT.NumărAplicatii
(APLICATII.UpdatedAt - APLICATII.CreatedAt) → FACT_APLICATII_CREDIT.DurataProcesare
APLICATII.SalariuNet            → FACT_APLICATII_CREDIT.SalariuNet
APLICATII.SoldTotal             → FACT_APLICATII_CREDIT.SoldTotal
```

### DIM_UTILIZATOR
```
UTILIZATORI.IdUtilizator        → DIM_UTILIZATOR.IdUtilizator
UTILIZATORI.Nume                → DIM_UTILIZATOR.Nume
UTILIZATORI.Prenume             → DIM_UTILIZATOR.Prenume
fn_mask_email(UTILIZATORI.Email) → DIM_UTILIZATOR.EmailMasked
fn_mask_telefon(UTILIZATORI.NumarTelefon) → DIM_UTILIZATOR.TelefonMasked
UTILIZATORI.IdRol               → DIM_UTILIZATOR.IdRol
UTILIZATORI.DataNastere         → DIM_UTILIZATOR.DataNastere
MONTHS_BETWEEN(SYSDATE, UTILIZATORI.CreatedAt) → DIM_UTILIZATOR.VechimeLuni
UTILIZATORI.CreatedAt            → DIM_UTILIZATOR.CreatedAt
```

### DIM_BANCA
```
BANCI.Id                        → DIM_BANCA.IdBanca
BANCI.Name                      → DIM_BANCA.Name
BANCI.CommissionPercent         → DIM_BANCA.CommissionPercent
BANCI.Active                    → DIM_BANCA.Active
BANCI.CreatedAt                 → DIM_BANCA.CreatedAt
```

### DIM_TIMP
```
APLICATII.CreatedAt             → DIM_TIMP.DataCompleta
EXTRACT(YEAR FROM CreatedAt)    → DIM_TIMP.An
EXTRACT(QUARTER FROM CreatedAt) → DIM_TIMP.Trimestru
EXTRACT(MONTH FROM CreatedAt)   → DIM_TIMP.Luna
TO_CHAR(CreatedAt, 'WW')        → DIM_TIMP.Saptamana
EXTRACT(DAY FROM CreatedAt)     → DIM_TIMP.Zi
TO_NUMBER(TO_CHAR(CreatedAt, 'D')) → DIM_TIMP.ZiSaptamana
CASE WHEN TO_CHAR(CreatedAt, 'D') IN (1,7) THEN 1 ELSE 0 END → DIM_TIMP.EsteWeekend
```

### DIM_TIP_CREDIT
```
APLICATII.TypeCredit + APLICATII.TipOperatiune → DIM_TIP_CREDIT (lookup)
```

### DIM_STATUS
```
APLICATII.Status                → DIM_STATUS (lookup)
```

### DIM_BROKER
```
UTILIZATORI.IdUtilizator (WHERE IdRol = BROKER) → DIM_BROKER.IdBroker
UTILIZATORI.Nume                → DIM_BROKER.Nume
UTILIZATORI.Prenume             → DIM_BROKER.Prenume
fn_mask_email(UTILIZATORI.Email) → DIM_BROKER.EmailMasked
UTILIZATORI.CreatedAt            → DIM_BROKER.CreatedAt
```

---

## 📊 Exemple de Cereri Analitice

### 1. Suma totală aprobată pe bancă și tip credit
```sql
SELECT 
    b.Name AS Banca,
    tc.TypeCredit AS TipCredit,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    COUNT(*) AS NumărAplicatii
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
GROUP BY b.Name, tc.TypeCredit
ORDER BY SumaTotalaAprobata DESC;
```

### 2. Evoluția aplicațiilor în timp
```sql
SELECT 
    t.An,
    t.Trimestru,
    COUNT(*) AS NumărAplicatii,
    AVG(f.Scoring) AS ScoringMediu,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
GROUP BY t.An, t.Trimestru
ORDER BY t.An, t.Trimestru;
```

### 3. Top utilizatori după volum credit
```sql
SELECT 
    u.Nume || ' ' || u.Prenume AS Utilizator,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Scoring) AS ScoringMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_UTILIZATOR u ON f.IdUtilizator = u.IdUtilizator
GROUP BY u.Nume, u.Prenume
ORDER BY SumaTotalaAprobata DESC
FETCH FIRST 10 ROWS ONLY;
```

---

## 🔧 Constrângeri și Optimizări

### Constrângeri
- Foreign keys între fact și toate dimensiunile
- Check constraints pentru măsuri (Scoring BETWEEN 300-850, Dti BETWEEN 0-100)
- NOT NULL pentru toate cheile străine

### Indecși
- Bitmap indexes pe coloane dimensiune (IdStatus, IdTipCredit)
- B-tree indexes pe coloane fact (IdTimp, IdUtilizator, IdBanca)
- Composite index pe (IdTimp, IdStatus) pentru rapoarte temporale

### Partiționare
- FACT_APLICATII_CREDIT partizionat pe IdTimp (RANGE partition pe an)
- DIM_TIMP poate fi partizionat pe An (LIST partition)

---

**Data creării:** 2025-01-08  
**Status:** Diagramă stea completă - Ready for implementation

