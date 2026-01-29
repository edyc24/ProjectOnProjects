# 📋 MAPARE CERINȚE PROIECT DW&BI → FIȘIERE SQL ȘI DOCUMENTE

## 📚 DOCUMENTE PRINCIPALE

### 1. **RAPORT ANALIZĂ** (Modul Analiză - N₁)
**Fișier:** `DW/01_ANALIZA_COMPLETA_DW.md`  
**Conține:**
- ✅ Descrierea modelului ales și obiectivele aplicației (Cerința 1)
- ✅ Diagramele bazei de date OLTP (Cerința 2)
- ✅ Diagrama stea/fulg DW (Cerința 3)
- ✅ Descrierea câmpurilor și modul de populare (Cerința 4)
- ✅ Constrângeri specifice DW (Cerința 5)
- ✅ Indecși specifici DW (Cerința 6)
- ✅ Obiecte dimensiune (Cerința 7)
- ✅ Partiționare tabele (Cerința 8)
- ✅ Cerere SQL complexă pentru optimizare (Cerința 9)
- ✅ 5+ cereri specifice DW (Cerința 10)

**Diagramă Stea:** `DW/00_DIAGRAMA_STEA_DW.md`

---

### 2. **SCRIPTURI SQL IMPLEMENTARE** (Modul Back-End - N₂)

#### **2.1 Crearea bazei de date OLTP și utilizatori** (Cerința 1)
**Fișier:** `OracleDatabase/00_SCRIPT_COMPLET.sql`  
**Sau:** `OracleDatabase/03_CREATE_TABLES.sql`

#### **2.2 Generarea datelor și inserarea în OLTP** (Cerința 2)
**Fișier:** `DW/02_POPULATE_OLTP_TEST_DATA.sql`  
**Conține:** Scripturi pentru generare date test și inserare în tabele OLTP

#### **2.3 Crearea bazei de date DW și utilizatori** (Cerința 3)
**Fișier:** `DW/01_CREATE_DW_SCHEMA.sql`  
**Conține:**
- Creare schema `DW_MONEYSHOP`
- Creare utilizatori (DW_ADMIN, DW_ETL, DW_READER)
- Grant-uri și privilegii

#### **2.4 Popularea bazei de date DW** (Cerința 4)
**Fișiere ETL:**
- `DW/04_ETL_EXTRACT.sql` - Extract (extragere din OLTP)
- `DW/05_ETL_TRANSFORM.sql` - Transform (transformare date)
- `DW/06_ETL_LOAD.sql` - Load (încărcare în DW)

**Script complet ETL:** Rulează cele 3 fișiere în ordine

#### **2.5 Definirea constrângerilor** (Cerința 5)
**Fișier:** `DW/07_DW_CONSTRAINTS.sql`  
**Conține:**
- Foreign keys (6 constrângeri referențiale)
- CHECK constraints pentru măsuri
- NOT NULL constraints

#### **2.6 Definirea indecșilor** (Cerința 6)
**Fișier:** `DW/08_DW_INDEXES.sql`  
**Conține:**
- 2 Bitmap indexes (pe IdStatus, IdTipCredit)
- 2 B-tree indexes (pe IdTimp, composite IdTimp+IdStatus)
- Cereri SQL care folosesc fiecare index
- Planuri de execuție (EXPLAIN PLAN)

#### **2.7 Definirea obiectelor dimensiune** (Cerința 7)
**Fișier:** `DW/09_DW_DIMENSIONS.sql`  
**Conține:**
- `DIMENSION dim_timp_dimension` (ierarhie: an → trimestru → lună → zi)
- `DIMENSION dim_utilizator_dimension` (ierarhie: rol → utilizator)
- Validare constrângeri (DBMS_DIMENSION.VALIDATE_DIMENSION)

#### **2.8 Definirea partițiilor** (Cerința 8)
**Fișier:** `DW/10_DW_PARTITIONS.sql`  
**Conține:**
- Partiționare RANGE pe `FACT_APLICATII_CREDIT` (pe DataAplicatie)
- Partiționare LIST pe `DIM_UTILIZATOR` (pe Regiune)
- Cereri SQL care folosesc partițiile
- Planuri de execuție (EXPLAIN PLAN)

#### **2.9 Optimizarea cererii SQL** (Cerința 9)
**Fișier:** `DW/11_QUERY_OPTIMIZATION.sql`  
**Conține:**
- Cerere SQL complexă originală
- Plan de execuție bazat pe cost (EXPLAIN PLAN)
- Explicație etape parcurse
- Sugestii de optimizare
- Plan de execuție optimizat
- Comparație costuri

#### **2.10 Crearea rapoartelor** (Cerința 10)
**Fișier:** `DW/12_REPORTS.sql`  
**Conține:** 5+ rapoarte SQL cu complexitate diferită:
1. Raport simplu: Număr aplicații pe lună
2. Raport mediu: Venit mediu utilizatori pe regiune
3. Raport complex: Analiză trenduri credit pe trimestre
4. Raport complex: Top 10 bănci după volum aplicații
5. Raport complex: Analiză performanță brokeri

---

### 3. **SCRIPT COMPLET UNIFICAT**
**Fișier:** `DW/00_SCRIPT_COMPLET_DW.sql`  
**Notă:** Acest fișier este un wrapper/documentație. Rulează scripturile individuale în ordine.

---

## 📊 STRUCTURA COMPLETĂ FIȘIERE

```
DW/
├── 📄 01_ANALIZA_COMPLETA_DW.md          # RAPORT ANALIZĂ (N₁)
├── 📄 00_DIAGRAMA_STEA_DW.md             # Diagramă Stea
│
├── 🔧 01_CREATE_DW_SCHEMA.sql            # Creare schema DW (Cerința 3)
├── 🔧 02_POPULATE_OLTP_TEST_DATA.sql    # Date test OLTP (Cerința 2)
├── 🔧 03_CREATE_DW_TABLES.sql            # Creare tabele DW
│
├── 🔄 04_ETL_EXTRACT.sql                 # ETL Extract (Cerința 4)
├── 🔄 05_ETL_TRANSFORM.sql               # ETL Transform (Cerința 4)
├── 🔄 06_ETL_LOAD.sql                    # ETL Load (Cerința 4)
│
├── 🔒 07_DW_CONSTRAINTS.sql              # Constrângeri (Cerința 5)
├── 📊 08_DW_INDEXES.sql                  # Indecși (Cerința 6)
├── 📐 09_DW_DIMENSIONS.sql               # Dimensiuni (Cerința 7)
├── 📦 10_DW_PARTITIONS.sql               # Partiții (Cerința 8)
├── ⚡ 11_QUERY_OPTIMIZATION.sql          # Optimizare (Cerința 9)
├── 📈 12_REPORTS.sql                     # Rapoarte (Cerința 10)
│
├── 📋 README.md                          # Documentație generală
├── ✅ VERIFICARE_CERINTE.md             # Verificare completă cerințe
└── ✅ VERIFICARE_COMPLETA.md             # Status dezvoltare
```

---

## 🎯 ORDINEA DE EXECUTARE A SCRIPTURILOR

### **Pasul 1: Setup Schema DW** (ca SYSDBA)
```sql
@DW/01_CREATE_DW_SCHEMA.sql
```

### **Pasul 2: Populare OLTP** (în schema OLTP)
```sql
@DW/02_POPULATE_OLTP_TEST_DATA.sql
```

### **Pasul 3: Creare Tabele DW** (în schema DW)
```sql
@DW/03_CREATE_DW_TABLES.sql
```

### **Pasul 4: ETL Process** (în schema DW)
```sql
@DW/04_ETL_EXTRACT.sql
@DW/05_ETL_TRANSFORM.sql
@DW/06_ETL_LOAD.sql
```

### **Pasul 5: Constrângeri** (în schema DW)
```sql
@DW/07_DW_CONSTRAINTS.sql
```

### **Pasul 6: Indecși** (în schema DW)
```sql
@DW/08_DW_INDEXES.sql
```

### **Pasul 7: Dimensiuni** (în schema DW)
```sql
@DW/09_DW_DIMENSIONS.sql
```

### **Pasul 8: Partiții** (în schema DW)
```sql
@DW/10_DW_PARTITIONS.sql
```

### **Pasul 9: Optimizare Query** (în schema DW)
```sql
@DW/11_QUERY_OPTIMIZATION.sql
```

### **Pasul 10: Rapoarte** (în schema DW)
```sql
@DW/12_REPORTS.sql
```

---

## 📝 PENTRU PREZENTARE FINALĂ

### **Fișier 1: Raport Analiză**
**Nume:** `NumeEchipa_Nume_Prenume_Analiza.docx`  
**Conținut:** Copiază din `DW/01_ANALIZA_COMPLETA_DW.md` + `DW/00_DIAGRAMA_STEA_DW.md`

### **Fișier 2: Scripturi SQL**
**Nume:** `NumeEchipa_Nume_Prenume_Sursa.txt`  
**Conținut:** Concatenează toate fișierele `.sql` în ordine:
```
01_CREATE_DW_SCHEMA.sql
02_POPULATE_OLTP_TEST_DATA.sql
03_CREATE_DW_TABLES.sql
04_ETL_EXTRACT.sql
05_ETL_TRANSFORM.sql
06_ETL_LOAD.sql
07_DW_CONSTRAINTS.sql
08_DW_INDEXES.sql
09_DW_DIMENSIONS.sql
10_DW_PARTITIONS.sql
11_QUERY_OPTIMIZATION.sql
12_REPORTS.sql
```

### **Fișier 3: Documentație Aplicație**
**Nume:** `NumeEchipa_Nume_Prenume_Aplicatie.docx`  
**Conținut:** 
- Descriere modul OLTP (cerința 1 front-end)
- Descriere modul ETL/Propagare (cerința 2 front-end)
- Descriere rapoarte grafice (cerința 3 front-end)
- Print-screen-uri din aplicație

### **Fișier 4: Proiect Complet**
**Nume:** `NumeEchipa_Nume_Prenume_Project.docx`  
**Conținut:** 
- Integrează toate cele de mai sus
- Include print-screen-uri din SQL Developer pentru fiecare script rulat
- Include planuri de execuție (EXPLAIN PLAN)

---

## ✅ VERIFICARE FINALĂ

**Documente de verificat:**
- ✅ `DW/VERIFICARE_CERINTE.md` - Verificare completă cerințe
- ✅ `DW/VERIFICARE_COMPLETA.md` - Status dezvoltare

**Toate cerințele sunt îndeplinite!** 🎉

