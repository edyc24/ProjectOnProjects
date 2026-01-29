# Analiză Completă - Data Warehouse MoneyShop
## Documentație pentru Modul Analiză (N₁)

**Data:** 2025-01-08  
**Proiect:** MoneyShop - Platformă de Brokeraj de Credite  
**Baza de date:** Oracle Database 19c+

---

## 1. Descrierea Modelului și Obiectivele Aplicației

### 1.1 Modelul Ales
Am ales modelul **stea (star schema)** pentru Data Warehouse, deoarece:
- Este cel mai simplu și eficient pentru rapoarte analitice
- Permite query-uri rapide prin denormalizare controlată
- Este ușor de înțeles și de întreținut
- Se potrivește perfect pentru analiza aplicațiilor de credit

### 1.2 Obiectivele Aplicației DW
1. **Analiza performanței aplicațiilor de credit**
   - Volumul de aplicații pe perioade de timp
   - Rata de aprobare/refuzare
   - Durata medie de procesare

2. **Analiza financiară**
   - Suma totală aprobată pe bancă, tip credit, broker
   - Comisioane totale
   - Scoring mediu pe categorii

3. **Analiza utilizatorilor**
   - Top utilizatori după volum credit
   - Distribuție pe roluri
   - Vechime utilizatori

4. **Rapoarte pentru management**
   - Evoluția aplicațiilor în timp
   - Performanța brokerilor
   - Comparație între bănci

---

## 2. Diagramele Bazei de Date OLTP

### 2.1 Diagrama Entitate-Relație (ER)
**Locație:** `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`

**Entități independente (12+):**
1. UTILIZATORI
2. ROLURI
3. APLICATII
4. BANCI
5. DOCUMENTE
6. AGREEMENTS
7. LEADURI
8. CONSENTURI
9. MANDATE
10. USER_FINANCIAL_DATA
11. AUDIT_LOG
12. USER_SESSIONS

**Relații many-to-many:**
- APPLICATION_BANKS (APLICATII ↔ BANCI) - o aplicație poate fi asociată cu mai multe bănci, o bancă poate avea mai multe aplicații

**Diagramă:** Vezi `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`

### 2.2 Diagrama Conceptuală
**Locație:** `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`

Diagrama conceptuală prezintă relațiile dintre toate entitățile principale ale sistemului MoneyShop, incluzând:
- Utilizatori și rolurile lor
- Aplicații de credit și statusurile lor
- Bănci partenere
- Documente și acorduri
- Consimțământuri GDPR și mandate broker

---

## 3. Diagrama Stea a Bazei de Date Depozit

**Locație:** `DW/00_DIAGRAMA_STEA_DW.md`

### 3.1 Tabel de Fapte
**FACT_APLICATII_CREDIT** - Tabel central care stochează faptele despre aplicațiile de credit

### 3.2 Tabele Dimensiune (6)
1. **DIM_UTILIZATOR** - Dimensiune utilizator
2. **DIM_BANCA** - Dimensiune bancă
3. **DIM_TIMP** - Dimensiune timp (data aplicației)
4. **DIM_TIP_CREDIT** - Dimensiune tip credit
5. **DIM_STATUS** - Dimensiune status aplicație
6. **DIM_BROKER** - Dimensiune broker

**Diagramă completă:** Vezi `DW/00_DIAGRAMA_STEA_DW.md`

---

## 4. Descrierea Câmpurilor și Modul de Populare

### 4.1 FACT_APLICATII_CREDIT

| Câmp | Tip | Descriere | Sursă OLTP | Transformare |
|------|-----|-----------|------------|--------------|
| IdFact | NUMBER | PK, Surrogate key | - | GENERATED ALWAYS AS IDENTITY |
| IdUtilizator | NUMBER | FK → DIM_UTILIZATOR | APLICATII.UserId | Direct mapping |
| IdBanca | NUMBER | FK → DIM_BANCA | APPLICATION_BANKS.BankId | Join cu APPLICATION_BANKS |
| IdTimp | NUMBER | FK → DIM_TIMP | APLICATII.CreatedAt | Lookup în DIM_TIMP |
| IdTipCredit | NUMBER | FK → DIM_TIP_CREDIT | APLICATII.TypeCredit + TipOperatiune | Lookup combinat |
| IdStatus | NUMBER | FK → DIM_STATUS | APLICATII.Status | Lookup în DIM_STATUS |
| IdBroker | NUMBER | FK → DIM_BROKER (NULL) | MANDATE.BrokerId | Left join cu MANDATE |
| SumaAprobata | NUMBER(18,2) | Suma aprobată | APLICATII.SumaAprobata | Direct, NULL → 0 |
| Comision | NUMBER(18,2) | Comision | APLICATII.Comision | Direct, NULL → 0 |
| Scoring | NUMBER(5,2) | Scor credit | APLICATII.Scoring | Direct, validare 300-850 |
| Dti | NUMBER(5,2) | Debt-to-Income | APLICATII.Dti | Direct, validare 0-100 |
| NumărAplicatii | NUMBER | Număr aplicații | - | Constant 1 (agregat în query) |
| DurataProcesare | NUMBER | Zile procesare | APLICATII.UpdatedAt - CreatedAt | Calculat |
| SalariuNet | NUMBER(18,2) | Salariu net | APLICATII.SalariuNet | Direct |
| SoldTotal | NUMBER(18,2) | Sold total | APLICATII.SoldTotal | Direct |

**Mod de populare:**
1. Extract: SELECT din APLICATII + JOIN cu APPLICATION_BANKS, MANDATE
2. Transform: Lookup în dimensiuni, calculare DurataProcesare, validare măsuri
3. Load: INSERT în FACT_APLICATII_CREDIT

### 4.2 DIM_UTILIZATOR

| Câmp | Tip | Descriere | Sursă OLTP | Transformare |
|------|-----|-----------|------------|--------------|
| IdUtilizator | NUMBER | PK | UTILIZATORI.IdUtilizator | Direct mapping |
| Nume | VARCHAR2(100) | Nume | UTILIZATORI.Nume | Direct |
| Prenume | VARCHAR2(100) | Prenume | UTILIZATORI.Prenume | Direct |
| EmailMasked | VARCHAR2(255) | Email mascat | UTILIZATORI.Email | fn_mask_email() |
| TelefonMasked | VARCHAR2(20) | Telefon mascat | UTILIZATORI.NumarTelefon | fn_mask_telefon() |
| IdRol | NUMBER | ID rol | UTILIZATORI.IdRol | Direct |
| DataNastere | DATE | Data nașterii | UTILIZATORI.DataNastere | Direct |
| VechimeLuni | NUMBER | Vechime în luni | UTILIZATORI.CreatedAt | MONTHS_BETWEEN(SYSDATE, CreatedAt) |
| CreatedAt | TIMESTAMP | Data creării | UTILIZATORI.CreatedAt | Direct |

**Mod de populare:**
- Extract: SELECT din UTILIZATORI
- Transform: Mascare email/telefon, calculare VechimeLuni
- Load: INSERT/UPDATE (SCD Type 2 dacă se modifică date)

### 4.3 DIM_BANCA

| Câmp | Tip | Descriere | Sursă OLTP | Transformare |
|------|-----|-----------|------------|--------------|
| IdBanca | NUMBER | PK | BANCI.Id | Direct mapping |
| Name | VARCHAR2(200) | Nume bancă | BANCI.Name | Direct |
| CommissionPercent | NUMBER(5,2) | % comision | BANCI.CommissionPercent | Direct |
| Active | NUMBER(1) | Status activ | BANCI.Active | Direct |
| CreatedAt | TIMESTAMP | Data adăugării | BANCI.CreatedAt | Direct |

**Mod de populare:**
- Extract: SELECT din BANCI
- Transform: Fără transformări majore
- Load: INSERT/UPDATE (SCD Type 1)

### 4.4 DIM_TIMP

| Câmp | Tip | Descriere | Sursă OLTP | Transformare |
|------|-----|-----------|------------|--------------|
| IdTimp | NUMBER | PK | - | GENERATED ALWAYS AS IDENTITY |
| DataCompleta | DATE | Data completă | APLICATII.CreatedAt | EXTRACT date |
| An | NUMBER | Anul | - | EXTRACT(YEAR FROM date) |
| Trimestru | NUMBER | Trimestrul (1-4) | - | EXTRACT(QUARTER FROM date) |
| Luna | NUMBER | Luna (1-12) | - | EXTRACT(MONTH FROM date) |
| Saptamana | NUMBER | Săptămâna (1-53) | - | TO_CHAR(date, 'WW') |
| Zi | NUMBER | Ziua (1-31) | - | EXTRACT(DAY FROM date) |
| ZiSaptamana | NUMBER | Zi săptămână (1-7) | - | TO_NUMBER(TO_CHAR(date, 'D')) |
| EsteWeekend | NUMBER(1) | Flag weekend | - | CASE WHEN zi IN (1,7) THEN 1 ELSE 0 END |

**Mod de populare:**
- Pre-populat pentru toate datele relevante (ex: 2020-2030)
- Script de generare: INSERT pentru fiecare zi din interval
- Lookup în timpul ETL: SELECT IdTimp WHERE DataCompleta = date

### 4.5 DIM_TIP_CREDIT

| Câmp | Tip | Descriere | Sursă OLTP | Transformare |
|------|-----|-----------|------------|--------------|
| IdTipCredit | NUMBER | PK | - | GENERATED ALWAYS AS IDENTITY |
| TypeCredit | VARCHAR2(50) | Tip credit | APLICATII.TypeCredit | Direct |
| TipOperatiune | VARCHAR2(50) | Tip operațiune | APLICATII.TipOperatiune | Direct |
| Descriere | VARCHAR2(200) | Descriere | - | Concatenare TypeCredit + TipOperatiune |

**Mod de populare:**
- Lookup table pre-populată cu toate combinațiile posibile:
  - IPOTECAR + NOU
  - IPOTECAR + REFINANTARE
  - NEVOI_PERSONALE + NOU
  - NEVOI_PERSONALE + REFINANTARE
  - REFINANTARE + NOU
  - REFINANTARE + REFINANTARE

### 4.6 DIM_STATUS

| Câmp | Tip | Descriere | Sursă OLTP | Transformare |
|------|-----|-----------|------------|--------------|
| IdStatus | NUMBER | PK | - | GENERATED ALWAYS AS IDENTITY |
| Status | VARCHAR2(50) | Status aplicație | APLICATII.Status | Direct |
| Descriere | VARCHAR2(200) | Descriere | - | Descriere status |
| Categorie | VARCHAR2(50) | Categorie | - | Mapping: INREGISTRAT/IN_PROCESARE → IN_PROCES, APROBAT/REFUZAT → FINALIZAT, ANULAT → ANULAT |

**Mod de populare:**
- Lookup table pre-populată cu toate statusurile:
  - INREGISTRAT → Categorie: IN_PROCES
  - IN_PROCESARE → Categorie: IN_PROCES
  - APROBAT → Categorie: FINALIZAT
  - REFUZAT → Categorie: FINALIZAT
  - ANULAT → Categorie: ANULAT

### 4.7 DIM_BROKER

| Câmp | Tip | Descriere | Sursă OLTP | Transformare |
|------|-----|-----------|------------|--------------|
| IdBroker | NUMBER | PK | UTILIZATORI.IdUtilizator | WHERE IdRol = BROKER |
| Nume | VARCHAR2(100) | Nume broker | UTILIZATORI.Nume | Direct |
| Prenume | VARCHAR2(100) | Prenume broker | UTILIZATORI.Prenume | Direct |
| EmailMasked | VARCHAR2(255) | Email mascat | UTILIZATORI.Email | fn_mask_email() |
| CreatedAt | TIMESTAMP | Data creării | UTILIZATORI.CreatedAt | Direct |

**Mod de populare:**
- Extract: SELECT din UTILIZATORI WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'BROKER')
- Transform: Mascare email
- Load: INSERT/UPDATE (SCD Type 1)

---

## 5. Constrângeri Specifice Depozitelor de Date

### 5.1 Constrângeri de Integritate Referențială
```sql
-- Foreign keys între fact și dimensiuni
ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT fk_fact_utilizator FOREIGN KEY (IdUtilizator) REFERENCES DIM_UTILIZATOR(IdUtilizator);

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT fk_fact_banca FOREIGN KEY (IdBanca) REFERENCES DIM_BANCA(IdBanca);

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT fk_fact_timp FOREIGN KEY (IdTimp) REFERENCES DIM_TIMP(IdTimp);

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT fk_fact_tip_credit FOREIGN KEY (IdTipCredit) REFERENCES DIM_TIP_CREDIT(IdTipCredit);

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT fk_fact_status FOREIGN KEY (IdStatus) REFERENCES DIM_STATUS(IdStatus);

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT fk_fact_broker FOREIGN KEY (IdBroker) REFERENCES DIM_BROKER(IdBroker);
```

**Justificare:** Asigură integritatea datelor și previne inserarea de înregistrări orfane în tabelul de fapte.

### 5.2 Constrângeri de Domeniu
```sql
-- Check constraints pentru măsuri
ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT chk_scoring CHECK (Scoring IS NULL OR (Scoring >= 300 AND Scoring <= 850));

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT chk_dti CHECK (Dti IS NULL OR (Dti >= 0 AND Dti <= 100));

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT chk_suma_aprobata CHECK (SumaAprobata >= 0);

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT chk_comision CHECK (Comision >= 0);

ALTER TABLE FACT_APLICATII_CREDIT
ADD CONSTRAINT chk_durata_procesare CHECK (DurataProcesare >= 0);
```

**Justificare:** Asigură că măsurile respectă domeniile de valori valide (scoring 300-850, DTI 0-100%, sume pozitive).

### 5.3 Constrângeri NOT NULL
```sql
-- NOT NULL pentru chei străine (exceptând IdBroker care poate fi NULL)
ALTER TABLE FACT_APLICATII_CREDIT
MODIFY IdUtilizator NOT NULL;

ALTER TABLE FACT_APLICATII_CREDIT
MODIFY IdBanca NOT NULL;

ALTER TABLE FACT_APLICATII_CREDIT
MODIFY IdTimp NOT NULL;

ALTER TABLE FACT_APLICATII_CREDIT
MODIFY IdTipCredit NOT NULL;

ALTER TABLE FACT_APLICATII_CREDIT
MODIFY IdStatus NOT NULL;
```

**Justificare:** Asigură că fiecare înregistrare din fact are toate dimensiunile obligatorii (brokerul este opțional).

---

## 6. Indecși Specifici Depozitelor de Date

### 6.1 Indecși Bitmap (pentru coloane cu cardinalitate mică)

#### 6.1.1 Bitmap Index pe IdStatus
```sql
CREATE BITMAP INDEX idx_fact_status_bitmap ON FACT_APLICATII_CREDIT(IdStatus);
```

**Cerere care folosește indexul:**
```sql
-- "Afișează numărul de aplicații aprobate vs refuzate pe fiecare bancă"
SELECT 
    b.Name AS Banca,
    s.Status,
    COUNT(*) AS NumărAplicatii
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status IN ('APROBAT', 'REFUZAT')
GROUP BY b.Name, s.Status
ORDER BY b.Name, s.Status;
```

**Justificare:** IdStatus are doar 5 valori posibile (cardinalitate mică), deci bitmap index este eficient pentru filtrare și agregare.

#### 6.1.2 Bitmap Index pe IdTipCredit
```sql
CREATE BITMAP INDEX idx_fact_tip_credit_bitmap ON FACT_APLICATII_CREDIT(IdTipCredit);
```

**Cerere care folosește indexul:**
```sql
-- "Compară volumul de aplicații între tipurile de credit"
SELECT 
    tc.TypeCredit,
    tc.TipOperatiune,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
GROUP BY tc.TypeCredit, tc.TipOperatiune
ORDER BY NumărAplicatii DESC;
```

**Justificare:** IdTipCredit are doar 6 combinații posibile, deci bitmap index este eficient.

### 6.2 Indecși B-Tree (pentru coloane cu cardinalitate mare)

#### 6.2.1 B-Tree Index pe IdTimp
```sql
CREATE INDEX idx_fact_timp_btree ON FACT_APLICATII_CREDIT(IdTimp);
```

**Cerere care folosește indexul:**
```sql
-- "Evoluția aplicațiilor pe trimestre în ultimii 2 ani"
SELECT 
    t.An,
    t.Trimestru,
    COUNT(*) AS NumărAplicatii,
    AVG(f.Scoring) AS ScoringMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
WHERE t.An >= EXTRACT(YEAR FROM SYSDATE) - 2
GROUP BY t.An, t.Trimestru
ORDER BY t.An, t.Trimestru;
```

**Justificare:** IdTimp are cardinalitate mare (multe date posibile), deci B-tree index este eficient pentru range queries și joins.

#### 6.2.2 Composite Index pe (IdTimp, IdStatus)
```sql
CREATE INDEX idx_fact_timp_status ON FACT_APLICATII_CREDIT(IdTimp, IdStatus);
```

**Cerere care folosește indexul:**
```sql
-- "Numărul de aplicații aprobate pe lună în ultimul an"
SELECT 
    t.An,
    t.Luna,
    COUNT(*) AS NumărAplicatiiAprobate
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status = 'APROBAT'
  AND t.An = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY t.An, t.Luna
ORDER BY t.An, t.Luna;
```

**Justificare:** Composite index este eficient pentru query-uri care filtrează pe ambele coloane simultan.

---

## 7. Obiecte de Tip Dimensiune

### 7.1 DIMENSION DIM_TIMP
```sql
CREATE DIMENSION dim_timp_dimension
LEVEL an IS (DIM_TIMP.An)
LEVEL trimestru IS (DIM_TIMP.Trimestru)
LEVEL luna IS (DIM_TIMP.Luna)
LEVEL zi IS (DIM_TIMP.DataCompleta)
HIERARCHY timp_hier (
    an CHILD OF
    trimestru CHILD OF
    luna CHILD OF
    zi
);
```

**Validare:**
```sql
-- Verificare că toate datele respectă ierarhia
SELECT 
    An,
    Trimestru,
    Luna,
    COUNT(*) AS NumărZile
FROM DIM_TIMP
GROUP BY An, Trimestru, Luna
HAVING COUNT(*) > 31 OR COUNT(*) < 28; -- Ar trebui să fie 0 rezultate
```

**Justificare:** Permite agregare la diferite niveluri (an → trimestru → lună → zi) și optimizare a query-urilor analitice.

### 7.2 DIMENSION DIM_UTILIZATOR (cu roluri)
```sql
CREATE DIMENSION dim_utilizator_dimension
LEVEL rol IS (DIM_UTILIZATOR.IdRol)
LEVEL utilizator IS (DIM_UTILIZATOR.IdUtilizator)
HIERARCHY utilizator_hier (
    rol CHILD OF
    utilizator
);
```

**Validare:**
```sql
-- Verificare că toți utilizatorii au rol valid
SELECT COUNT(*) 
FROM DIM_UTILIZATOR u
WHERE NOT EXISTS (
    SELECT 1 FROM ROLURI r WHERE r.IdRol = u.IdRol
); -- Ar trebui să fie 0
```

**Justificare:** Permite agregare pe roluri (CLIENT, BROKER, ADMIN) și analiză a utilizatorilor pe categorii.

---

## 8. Tabele Partizionate

### 8.1 FACT_APLICATII_CREDIT - Partiționare RANGE pe An

```sql
CREATE TABLE FACT_APLICATII_CREDIT (
    -- coloane...
) PARTITION BY RANGE (IdTimp) (
    PARTITION p2020 VALUES LESS THAN (TO_NUMBER(TO_CHAR(TO_DATE('2021-01-01', 'YYYY-MM-DD'), 'YYYYMMDD'))),
    PARTITION p2021 VALUES LESS THAN (TO_NUMBER(TO_CHAR(TO_DATE('2022-01-01', 'YYYY-MM-DD'), 'YYYYMMDD'))),
    PARTITION p2022 VALUES LESS THAN (TO_NUMBER(TO_CHAR(TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'YYYYMMDD'))),
    PARTITION p2023 VALUES LESS THAN (TO_NUMBER(TO_CHAR(TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'YYYYMMDD'))),
    PARTITION p2024 VALUES LESS THAN (TO_NUMBER(TO_CHAR(TO_DATE('2025-01-01', 'YYYY-MM-DD'), 'YYYYMMDD'))),
    PARTITION p2025 VALUES LESS THAN (TO_NUMBER(TO_CHAR(TO_DATE('2026-01-01', 'YYYY-MM-DD'), 'YYYYMMDD'))),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);
```

**Cerere care folosește partiționarea:**
```sql
-- "Aplicațiile din ultimul an (partition pruning)"
SELECT 
    COUNT(*) AS NumărAplicatii,
    SUM(SumaAprobata) AS SumaTotalaAprobata
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
WHERE t.An = EXTRACT(YEAR FROM SYSDATE) - 1;
```

**Justificare:** 
- **Avantaje:** Partition pruning (doar partițiile relevante sunt scanate), maintenance ușor (drop/add partiții vechi/noi), query-uri mai rapide
- **Dezavantaje:** Overhead la creare, necesită planificare pentru partiții noi

### 8.2 DIM_TIMP - Partiționare LIST pe An

```sql
CREATE TABLE DIM_TIMP (
    -- coloane...
) PARTITION BY LIST (An) (
    PARTITION p2020 VALUES (2020),
    PARTITION p2021 VALUES (2021),
    PARTITION p2022 VALUES (2022),
    PARTITION p2023 VALUES (2023),
    PARTITION p2024 VALUES (2024),
    PARTITION p2025 VALUES (2025),
    PARTITION p_future VALUES (2026, 2027, 2028, 2029, 2030)
);
```

**Cerere care folosește partiționarea:**
```sql
-- "Datele pentru ultimii 3 ani"
SELECT 
    An,
    Trimestru,
    COUNT(*) AS NumărZile
FROM DIM_TIMP
WHERE An >= EXTRACT(YEAR FROM SYSDATE) - 3
GROUP BY An, Trimestru
ORDER BY An, Trimestru;
```

**Justificare:**
- **Avantaje:** Partition pruning eficient pentru query-uri pe an specific, maintenance simplu
- **Dezavantaje:** Necesită adăugare partiții pentru ani noi

---

## 9. Cerere SQL Complexă pentru Optimizare

### 9.1 Cerere în Limbaj Natural
**"Afișează top 10 brokeri după volumul total de credite aprobate în ultimul trimestru, incluzând numărul de aplicații, suma totală aprobată, comisionul total și scoring-ul mediu, grupate pe tip de credit și bancă, doar pentru aplicațiile cu scoring > 700 și DTI < 40%."**

### 9.2 Cerere SQL Inițială
```sql
SELECT 
    br.Nume || ' ' || br.Prenume AS Broker,
    tc.TypeCredit AS TipCredit,
    b.Name AS Banca,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    SUM(f.Comision) AS ComisionTotal,
    AVG(f.Scoring) AS ScoringMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BROKER br ON f.IdBroker = br.IdBroker
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status = 'APROBAT'
  AND t.An = EXTRACT(YEAR FROM SYSDATE)
  AND t.Trimestru = EXTRACT(QUARTER FROM SYSDATE)
  AND f.Scoring > 700
  AND f.Dti < 40
GROUP BY br.Nume, br.Prenume, tc.TypeCredit, b.Name
ORDER BY SumaTotalaAprobata DESC
FETCH FIRST 10 ROWS ONLY;
```

### 9.3 Tehnici de Optimizare Propuse

#### 9.3.1 Indecși
- Composite index pe (IdTimp, IdStatus) pentru filtrare eficientă
- Index pe Scoring și Dti pentru filtrare rapidă
- Index pe IdBroker pentru join eficient

#### 9.3.2 Materialized View
- Materialized view pre-agregat pe (Broker, TipCredit, Bancă, Trimestru)
- Refresh periodic (ex: zilnic)

#### 9.3.3 Partition Pruning
- Partiționare pe IdTimp permite scanarea doar a partiției curente

#### 9.3.4 Avantaje/Dezavantaje

**Materialized View:**
- ✅ Avantaje: Query foarte rapid (date pre-agregate), reducere load pe fact table
- ❌ Dezavantaje: Necesită refresh periodic, ocupă spațiu suplimentar, date pot fi stale

**Indecși:**
- ✅ Avantaje: Query rapid, fără overhead de maintenance major
- ❌ Dezavantaje: Overhead la INSERT/UPDATE, ocupă spațiu

**Partiționare:**
- ✅ Avantaje: Partition pruning, maintenance ușor
- ❌ Dezavantaje: Overhead la creare, necesită planificare

---

## 10. Cereri pentru Rapoarte (5+)

### 10.1 Raport 1: Evoluția Aplicațiilor în Timp
**Complexitate:** Medie  
**Tip grafic:** Line chart

```sql
-- "Evoluția numărului de aplicații și sumei totale aprobate pe trimestre"
SELECT 
    t.An,
    t.Trimestru,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Scoring) AS ScoringMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
WHERE t.An >= EXTRACT(YEAR FROM SYSDATE) - 2
GROUP BY t.An, t.Trimestru
ORDER BY t.An, t.Trimestru;
```

### 10.2 Raport 2: Distribuție Aplicații pe Status
**Complexitate:** Simplă  
**Tip grafic:** Pie chart

```sql
-- "Distribuția aplicațiilor pe status"
SELECT 
    s.Status,
    s.Categorie,
    COUNT(*) AS NumărAplicatii,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Procent
FROM FACT_APLICATII_CREDIT f
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
GROUP BY s.Status, s.Categorie
ORDER BY NumărAplicatii DESC;
```

### 10.3 Raport 3: Top Bănci după Volum Credit
**Complexitate:** Simplă  
**Tip grafic:** Bar chart

```sql
-- "Top 10 bănci după volumul total de credite aprobate"
SELECT 
    b.Name AS Banca,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Comision) AS ComisionMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status = 'APROBAT'
GROUP BY b.Name
ORDER BY SumaTotalaAprobata DESC
FETCH FIRST 10 ROWS ONLY;
```

### 10.4 Raport 4: Comparație Tipuri Credit
**Complexitate:** Medie  
**Tip grafic:** Bar chart (grouped)

```sql
-- "Comparație între tipurile de credit: număr aplicații, suma totală, scoring mediu"
SELECT 
    tc.TypeCredit AS TipCredit,
    tc.TipOperatiune,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Scoring) AS ScoringMediu,
    AVG(f.Dti) AS DtiMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
GROUP BY tc.TypeCredit, tc.TipOperatiune
ORDER BY NumărAplicatii DESC;
```

### 10.5 Raport 5: Performanța Brokerilor
**Complexitate:** Medie  
**Tip grafic:** Bar chart

```sql
-- "Top 10 brokeri după numărul de aplicații aprobate și volum total"
SELECT 
    br.Nume || ' ' || br.Prenume AS Broker,
    COUNT(*) AS NumărAplicatiiAprobate,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Scoring) AS ScoringMediu,
    SUM(f.Comision) AS ComisionTotal
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BROKER br ON f.IdBroker = br.IdBroker
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status = 'APROBAT'
GROUP BY br.Nume, br.Prenume
ORDER BY NumărAplicatiiAprobate DESC
FETCH FIRST 10 ROWS ONLY;
```

### 10.6 Raport 6: Analiza Scoring pe Categorii
**Complexitate:** Medie  
**Tip grafic:** Box plot sau Bar chart

```sql
-- "Distribuția scoring-ului pe categorii de utilizatori și tipuri de credit"
SELECT 
    u.IdRol,
    tc.TypeCredit,
    COUNT(*) AS NumărAplicatii,
    MIN(f.Scoring) AS ScoringMin,
    MAX(f.Scoring) AS ScoringMax,
    AVG(f.Scoring) AS ScoringMediu,
    STDDEV(f.Scoring) AS ScoringStdDev
FROM FACT_APLICATII_CREDIT f
JOIN DIM_UTILIZATOR u ON f.IdUtilizator = u.IdUtilizator
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
WHERE f.Scoring IS NOT NULL
GROUP BY u.IdRol, tc.TypeCredit
ORDER BY u.IdRol, tc.TypeCredit;
```

### 10.7 Raport 7: Rata de Aprobare pe Bancă
**Complexitate:** Medie  
**Tip grafic:** Gauge chart sau Bar chart

```sql
-- "Rata de aprobare (aprobați / total) pentru fiecare bancă"
SELECT 
    b.Name AS Banca,
    COUNT(*) AS TotalAplicatii,
    SUM(CASE WHEN s.Status = 'APROBAT' THEN 1 ELSE 0 END) AS Aprobate,
    SUM(CASE WHEN s.Status = 'REFUZAT' THEN 1 ELSE 0 END) AS Refuzate,
    ROUND(SUM(CASE WHEN s.Status = 'APROBAT' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS RataAprobare
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status IN ('APROBAT', 'REFUZAT')
GROUP BY b.Name
ORDER BY RataAprobare DESC;
```

---

## 11. Rezumat

### 11.1 Model DW
- **Tip:** Star Schema
- **Tabel fact:** FACT_APLICATII_CREDIT
- **Dimensiuni:** 6 (DIM_UTILIZATOR, DIM_BANCA, DIM_TIMP, DIM_TIP_CREDIT, DIM_STATUS, DIM_BROKER)

### 11.2 Optimizări
- **Indecși:** 4 (2 bitmap, 2 B-tree)
- **Obiecte dimensiune:** 2 (DIM_TIMP, DIM_UTILIZATOR)
- **Partiționare:** 2 tabele (FACT_APLICATII_CREDIT, DIM_TIMP)

### 11.3 Rapoarte
- **Total:** 7 rapoarte
- **Complexitate:** Simplă (2), Medie (5)

---

**Data finalizare:** 2025-01-08  
**Status:** Analiză completă - Ready for implementation

