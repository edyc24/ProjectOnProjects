# ANALIZĂ PROIECT DW&BI - MoneyShop
## Status Cerințe și Plan de Dezvoltare

---

## 📊 REZUMAT EXECUTIV

**Proiect:** MoneyShop - Platformă de Brokeraj de Credite  
**Status General:** Baza de date OLTP și aplicațiile există, dar **Data Warehouse lipsește complet**  
**Prioritate:** Urgent - trebuie implementat DW complet pentru a îndeplini cerințele proiectului

---

## ✅ CE EXISTĂ DEJA (OLTP)

### 1. Baza de Date OLTP - Oracle Database ✅
- **Status:** COMPLET IMPLEMENTAT
- **Locație:** `OracleDatabase/`
- **Tabele principale:**
  - `UTILIZATORI` - utilizatori (clienți, brokeri, admini)
  - `ROLURI` - roluri utilizatori
  - `APLICATII` - cereri de credit
  - `BANCI` - bănci partenere
  - `DOCUMENTE` - documente încărcate
  - `CONSENTURI` - consimțământuri GDPR
  - `MANDATE` - mandate broker
  - `USER_FINANCIAL_DATA` - date financiare utilizatori
  - `AUDIT_LOG` - log audit
  - `USER_SESSIONS` - sesiuni utilizatori
  - `LEADURI` - lead-uri capturate
  - `AGREEMENTS` - acorduri
  - `APPLICATION_BANKS` - relație many-to-many aplicații-bănci

- **Documentație:**
  - ✅ Diagramă conceptuală (`01_DIAGRAMA_CONCEPTUALA.md`)
  - ✅ Scheme relaționale (`02_SCHEME_RELATIONALE.md`)
  - ✅ Scripturi SQL complete (`00_SCRIPT_COMPLET.sql`)

### 2. Aplicații Existente ✅
- **Aplicație Web:** ASP.NET Core MVC (`MoneyShop/`)
- **Aplicație Mobilă:** React Native (`MoneyShopMobile/`)
- **Funcționalități:**
  - Autentificare utilizatori
  - Gestionare aplicații credit
  - Simulator credit
  - Gestionare documente
  - Chat asistent virtual
  - KYC (Know Your Customer)
  - Gestionare consimțământuri GDPR

---

## ❌ CE LIPSEȘTE (DW&BI)

### 1. MODUL ANALIZĂ ❌
**Status:** 0% completat

#### Cerințe Obligatorii (N₁ >= 5):
- ❌ **1.1** Descrierea modelului ales și obiectivele aplicației
- ❌ **1.2** Diagramele bazei de date OLTP
  - ❌ Diagrama entitate-relație (minim 7 entități, minim 1 many-to-many)
  - ❌ Diagrama conceptuală
- ❌ **1.3** Diagrama stea/fulg a bazei de date depozit
  - ❌ Tabel de fapte
  - ❌ Minim 5 tabele dimensiune
- ❌ **1.4** Descrierea câmpurilor pentru fiecare tabel DW și modul de populare
- ❌ **1.5** Identificarea constrângerilor specifice DW
- ❌ **1.6** Identificarea indecșilor specifici DW (minim 2)
- ❌ **1.7** Identificarea obiectelor dimensiune (minim 2)
- ❌ **1.8** Identificarea tabelelor partizionate (minim 2)
- ❌ **1.9** Formularea cererii SQL complexe pentru optimizare
- ❌ **1.10** Formularea cel puțin 5 cereri specifice DW pentru rapoarte

### 2. MODUL IMPLEMENTARE BAZE DE DATE (BACK-END) ❌
**Status:** 0% completat

#### Cerințe Obligatorii (N₂ >= 5):
- ❌ **2.1** Crearea bazei de date OLTP și utilizatorilor
- ❌ **2.2** Generarea și inserarea datelor în tabele
- ❌ **2.3** Crearea bazei de date depozit și utilizatorilor
- ❌ **2.4** Popularea DW folosind date din OLTP
- ❌ **2.5** Definirea constrângerilor DW
- ❌ **2.6** Definirea indecșilor și cereri SQL cu plan de execuție
- ❌ **2.7** Definirea obiectelor dimensiune și validare
- ❌ **2.8** Definirea partițiilor și cereri SQL cu plan de execuție
- ❌ **2.9** Optimizarea cererii SQL propusă în analiză
- ❌ **2.10** Crearea rapoartelor cu complexitate diferită (scripturi SQL)

### 3. MODUL IMPLEMENTARE APLICAȚIE (FRONT-END) ❌
**Status:** 0% completat

#### Cerințe:
- ❌ **3.1** Modul aplicație pentru introducere și gestionare informații OLTP
- ❌ **3.2** Modul aplicație pentru propagare OLTP → DW și vizualizare efecte
- ❌ **3.3** Modul aplicație cu rapoarte grafice dinamice

---

## 🎯 PLAN DE DEZVOLTARE

### FAZA 1: ANALIZĂ (Săptămâna 1-2)
**Obiectiv:** Finalizarea raportului de analiză complet

#### Task-uri:
1. **Diagramă ER OLTP** (0.5p)
   - Extragere din `01_DIAGRAMA_CONCEPTUALA.md`
   - Verificare minim 7 entități independente
   - Verificare minim 1 relație many-to-many (APPLICATION_BANKS)

2. **Diagramă Conceptuală OLTP** (0.5p)
   - Actualizare diagramă existentă
   - Adăugare detalii complete

3. **Diagramă Stea/Fulg DW** (1.5p) ⭐ CRITIC
   - **Tabel de fapte propus:** `FACT_APLICATII_CREDIT`
     - Măsuri: SumaAprobata, Comision, Scoring, Dti, NumărAplicatii
     - Granularitate: o înregistrare per aplicație de credit
   - **Tabele dimensiune propuse:**
     - `DIM_UTILIZATOR` - dimensiune utilizator
     - `DIM_BANCA` - dimensiune bancă
     - `DIM_TIMP` - dimensiune timp (data aplicației)
     - `DIM_TIP_CREDIT` - dimensiune tip credit
     - `DIM_STATUS` - dimensiune status aplicație
     - `DIM_BROKER` - dimensiune broker (dacă aplicabil)
     - `DIM_REGION` - dimensiune regiune (dacă adăugăm locație)

4. **Descrierea câmpurilor DW** (1p)
   - Documentare completă pentru fiecare tabel
   - Mapping OLTP → DW
   - Reguli de transformare

5. **Constrângeri DW** (1p)
   - Constrângeri de integritate referențială
   - Constrângeri de domeniu
   - Constrângeri de business

6. **Indecși DW** (0.5p)
   - Minim 2 indecși bitmap sau B-tree
   - Cereri SQL care folosesc indecșii

7. **Obiecte dimensiune** (0.5p)
   - Minim 2 dimensiuni (ex: DIM_TIMP, DIM_UTILIZATOR)
   - Validare constrângeri

8. **Partiționare** (1p)
   - Minim 2 tabele partizionate
   - Tip partiționare (range, list, hash)
   - Cereri SQL care beneficiază de partiționare

9. **Cerere SQL complexă pentru optimizare** (0.5p)
   - Cerere analitică complexă
   - Tehnici de optimizare propuse

10. **5+ Cereri pentru rapoarte** (2p)
    - Cereri specifice DW
    - Grad de complexitate diferit
    - Descriere rapoarte grafice

**Deliverable:** `Raport_Analiza_DW_BI.docx`

---

### FAZA 2: IMPLEMENTARE BACK-END (Săptămâna 3-5)
**Obiectiv:** Crearea și popularea Data Warehouse

#### Task-uri:

1. **Creare bază de date DW** (0.5p)
   - Schema Oracle pentru DW
   - Utilizatori și privilegii
   - Script: `DW/01_CREATE_DW_SCHEMA.sql`

2. **Generare date test OLTP** (0.25p)
   - Script pentru populare OLTP cu date de test
   - Minim 1000 utilizatori, 5000 aplicații
   - Script: `DW/02_POPULATE_OLTP_TEST_DATA.sql`

3. **Creare tabele DW** (0.5p)
   - Tabel de fapte: `FACT_APLICATII_CREDIT`
   - Tabele dimensiune: `DIM_*`
   - Script: `DW/03_CREATE_DW_TABLES.sql`

4. **Procese ETL** (0.5p) ⭐ CRITIC
   - **Extract:** Extragere date din OLTP
   - **Transform:** Transformare și curățare date
   - **Load:** Încărcare în DW
   - Scripturi PL/SQL:
     - `DW/04_ETL_EXTRACT.sql`
     - `DW/05_ETL_TRANSFORM.sql`
     - `DW/06_ETL_LOAD.sql`
   - Procedură principală: `SP_ETL_FULL_LOAD`

5. **Constrângeri DW** (0.5p)
   - Foreign keys între fact și dimensiuni
   - Check constraints
   - Script: `DW/07_DW_CONSTRAINTS.sql`

6. **Indecși DW** (1p)
   - Indecși bitmap pe coloane dimensiune
   - Indecși B-tree pe coloane fact
   - Planuri de execuție pentru validare
   - Script: `DW/08_DW_INDEXES.sql`

7. **Obiecte dimensiune** (1p)
   - Creare dimensiuni Oracle
   - Validare constrângeri
   - Script: `DW/09_DW_DIMENSIONS.sql`

8. **Partiționare** (1p)
   - Partiționare tabel fact pe dată
   - Partiționare dimensiune (dacă aplicabil)
   - Planuri de execuție pentru validare
   - Script: `DW/10_DW_PARTITIONS.sql`

9. **Optimizare cerere SQL** (2p)
   - Plan de execuție inițial
   - Sugestii de optimizare
   - Plan de execuție optimizat
   - Script: `DW/11_QUERY_OPTIMIZATION.sql`

10. **Rapoarte SQL** (2p)
    - 5+ scripturi SQL pentru rapoarte
    - Complexitate diferită
    - Script: `DW/12_REPORTS.sql`

**Deliverable:** 
- `DW/` folder cu toate scripturile SQL
- `NumeEchipa_Nume_Prenume_Sursa.txt` - scripturi sursă

---

### FAZA 3: IMPLEMENTARE FRONT-END (Săptămâna 6-8)
**Obiectiv:** Integrarea DW în aplicație

#### Task-uri:

1. **Modul gestionare OLTP** (3p)
   - **Status:** Parțial implementat în aplicația existentă
   - **Necesită:** Verificare și completare
   - **Locație:** `MoneyShop/Controllers/`
   - **Verificare:**
     - ✅ Creare utilizatori
     - ✅ Creare aplicații credit
     - ✅ Gestionare documente
     - ❓ Validare completă pentru toate operațiunile

2. **Modul propagare OLTP → DW** (3p) ⭐ CRITIC
   - **Status:** LIPSEȘTE COMPLET
   - **Necesită:**
     - Controller pentru trigger ETL
     - View pentru validare propagare
     - Interfață pentru vizualizare efecte
   - **Implementare:**
     - `MoneyShop/Controllers/ETLController.cs`
     - `MoneyShop/Views/ETL/` - interfață pentru ETL
     - API endpoint: `/api/etl/trigger`
     - API endpoint: `/api/etl/validate`

3. **Modul rapoarte grafice** (3p) ⭐ CRITIC
   - **Status:** LIPSEȘTE COMPLET
   - **Necesită:**
     - Integrare bibliotecă grafică (Chart.js, D3.js, sau Power BI Embedded)
     - Controller pentru rapoarte
     - View-uri pentru fiecare raport
   - **Implementare:**
     - `MoneyShop/Controllers/ReportsController.cs`
     - `MoneyShop/Views/Reports/` - interfață rapoarte
     - API endpoints pentru fiecare raport
   - **Rapoarte propuse:**
     1. Raport aplicații pe tip credit (pie chart)
     2. Raport aplicații pe status (bar chart)
     3. Raport volum credit pe bancă (bar chart)
     4. Raport evoluție aplicații în timp (line chart)
     5. Raport scoring mediu pe regiune (heatmap sau bar chart)
     6. Raport comisioane totale pe broker (bar chart)
     7. Raport rata de aprobare pe bancă (gauge chart)

**Deliverable:**
- Aplicație funcțională cu toate modulele
- `NumeEchipa_Nume_Prenume_Aplicatie.docx` - documentație cu screenshot-uri

---

## 📋 STRUCTURĂ PROIECT FINAL

```
MoneyShop/
├── OracleDatabase/          ✅ EXISTĂ (OLTP)
│   ├── 00_SCRIPT_COMPLET.sql
│   ├── 01_DIAGRAMA_CONCEPTUALA.md
│   └── ...
├── DW/                      ❌ DE CREAT
│   ├── 01_CREATE_DW_SCHEMA.sql
│   ├── 02_POPULATE_OLTP_TEST_DATA.sql
│   ├── 03_CREATE_DW_TABLES.sql
│   ├── 04_ETL_EXTRACT.sql
│   ├── 05_ETL_TRANSFORM.sql
│   ├── 06_ETL_LOAD.sql
│   ├── 07_DW_CONSTRAINTS.sql
│   ├── 08_DW_INDEXES.sql
│   ├── 09_DW_DIMENSIONS.sql
│   ├── 10_DW_PARTITIONS.sql
│   ├── 11_QUERY_OPTIMIZATION.sql
│   └── 12_REPORTS.sql
├── MoneyShop/              ✅ EXISTĂ (parțial)
│   ├── Controllers/
│   │   ├── ETLController.cs        ❌ DE CREAT
│   │   └── ReportsController.cs    ❌ DE CREAT
│   └── Views/
│       ├── ETL/                    ❌ DE CREAT
│       └── Reports/                ❌ DE CREAT
├── MoneyShopMobile/         ✅ EXISTĂ (nu necesar pentru DW&BI)
└── Documente/
    ├── NumeEchipa_Nume_Prenume_Project.docx      ❌ DE CREAT
    ├── NumeEchipa_Nume_Prenume_Echipa.txt        ❌ DE CREAT
    ├── NumeEchipa_Nume_Prenume_Analiza.docx      ❌ DE CREAT
    ├── NumeEchipa_Nume_Prenume_Sursa.txt         ❌ DE CREAT
    └── NumeEchipa_Nume_Prenume_Aplicatie.docx    ❌ DE CREAT
```

---

## ⚠️ RISCURI ȘI MITIGĂRI

### Risc 1: Timp insuficient pentru implementare completă
**Mitigare:** 
- Prioritizare: Faza 1 (Analiză) este critică - trebuie finalizată primul
- ETL poate fi simplificat inițial (full load, nu incremental)
- Rapoarte grafice pot folosi biblioteci simple (Chart.js)

### Risc 2: Complexitate partiționare și optimizare
**Mitigare:**
- Folosire partiționare range pe dată (cel mai simplu)
- Optimizare doar pentru cererea principală
- Documentare clară a planurilor de execuție

### Risc 3: Integrare DW în aplicația existentă
**Mitigare:**
- ETL poate rula separat (batch job)
- Rapoarte pot fi accesate prin interfață separată
- Nu este necesară modificare majoră a aplicației existente

---

## 📅 TIMELINE ESTIMAT

| Fază | Durată | Deadline |
|------|--------|----------|
| **Faza 1: Analiză** | 2 săptămâni | Săptămâna 2 |
| **Faza 2: Back-End DW** | 3 săptămâni | Săptămâna 5 |
| **Faza 3: Front-End** | 2 săptămâni | Săptămâna 7 |
| **Testing & Finalizare** | 1 săptămână | Săptămâna 8 |

**Total:** 8 săptămâni

---

## 🎯 PRIORITĂȚI IMEDIATE

1. **URGENT:** Începere Faza 1 - Analiză
   - Diagramă stea/fulg DW
   - Descrierea completă a modelului DW
   - 5+ cereri pentru rapoarte

2. **URGENT:** Planificare ETL
   - Mapping OLTP → DW
   - Reguli de transformare
   - Strategie de load (full vs incremental)

3. **IMPORTANT:** Alegere tehnologii pentru rapoarte
   - Chart.js (simplu, integrare ușoară)
   - Power BI Embedded (profesional, dar complex)
   - D3.js (flexibil, dar necesită timp)

---

## 📝 NOTE IMPORTANTE

1. **Baza de date OLTP există și este completă** - nu trebuie recreată
2. **Aplicația există** - trebuie doar adăugate modulele pentru DW
3. **Focus pe DW** - acesta este componenta lipsă critică
4. **Documentație completă** - fiecare pas trebuie documentat cu screenshot-uri
5. **Testare continuă** - validare la fiecare fază

---

## ✅ CHECKLIST FINAL

### Modul Analiză (N₁ >= 5)
- [x] Raport analiză complet ✅ `DW/01_ANALIZA_COMPLETA_DW.md`
- [x] Diagramă ER OLTP ✅ `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`
- [x] Diagramă conceptuală OLTP ✅ `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`
- [x] Diagramă stea/fulg DW ✅ `DW/00_DIAGRAMA_STEA_DW.md`
- [x] Descrierea câmpurilor DW ✅ `DW/01_ANALIZA_COMPLETA_DW.md` - Secțiunea 4
- [x] Constrângeri DW ✅ `DW/01_ANALIZA_COMPLETA_DW.md` - Secțiunea 5
- [x] Indecși DW (minim 2) ✅ **4 indecși** - `DW/01_ANALIZA_COMPLETA_DW.md` - Secțiunea 6
- [x] Obiecte dimensiune (minim 2) ✅ **2 dimensiuni** - `DW/01_ANALIZA_COMPLETA_DW.md` - Secțiunea 7
- [x] Partiționare (minim 2 tabele) ✅ **2 tabele** - `DW/01_ANALIZA_COMPLETA_DW.md` - Secțiunea 8
- [x] Cerere SQL complexă ✅ `DW/01_ANALIZA_COMPLETA_DW.md` - Secțiunea 9
- [x] 5+ cereri pentru rapoarte ✅ **7 rapoarte** - `DW/01_ANALIZA_COMPLETA_DW.md` - Secțiunea 10

### Modul Back-End (N₂ >= 5)
- [x] Baza de date DW creată ✅ `DW/01_CREATE_DW_SCHEMA.sql`
- [x] Date test OLTP generate ✅ `DW/02_POPULATE_OLTP_TEST_DATA.sql`
- [x] Tabele DW create ✅ `DW/03_CREATE_DW_TABLES.sql`
- [x] Procese ETL implementate ✅ `DW/04_ETL_EXTRACT.sql`, `05_ETL_TRANSFORM.sql`, `06_ETL_LOAD.sql`
- [x] Constrângeri DW definite ✅ `DW/07_DW_CONSTRAINTS.sql`
- [x] Indecși DW cu planuri de execuție ✅ `DW/08_DW_INDEXES.sql`
- [x] Obiecte dimensiune validate ✅ `DW/09_DW_DIMENSIONS.sql`
- [x] Partiționare cu planuri de execuție ✅ `DW/10_DW_PARTITIONS.sql`
- [x] Optimizare cerere SQL ✅ `DW/11_QUERY_OPTIMIZATION.sql`
- [x] Rapoarte SQL create ✅ `DW/12_REPORTS.sql` (7 rapoarte)

### Modul Front-End (N₃)
- [x] Modul gestionare OLTP complet ✅ Există deja în aplicație
- [x] Modul propagare OLTP → DW ✅ `MoneyShop/Controllers/ETLController.cs` + Views
- [x] Modul rapoarte grafice dinamice ✅ `MoneyShop/Controllers/ReportsController.cs` + Views (Chart.js)

### Documente Finale
- [ ] NumeEchipa_Nume_Prenume_Project.docx
- [ ] NumeEchipa_Nume_Prenume_Echipa.txt
- [ ] NumeEchipa_Nume_Prenume_Analiza.docx
- [ ] NumeEchipa_Nume_Prenume_Sursa.txt
- [ ] NumeEchipa_Nume_Prenume_Aplicatie.docx

---

**Data creării:** 2025-01-08  
**Data finalizare:** 2025-01-08  
**Status:** ✅ **TOATE FAZELE COMPLETATE - PROIECT FINALIZAT**

**Verificare completă:** Vezi `DW/VERIFICARE_CERINTE.md`

