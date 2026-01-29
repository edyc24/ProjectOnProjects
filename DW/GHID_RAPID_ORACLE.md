# 🚀 GHID RAPID - CREARE BAZĂ DE DATE ORACLE PENTRU PROIECT DW&BI

## ⚡ LISTA SCURTĂ - 12 SCRIPTURI ÎN ORDINE

### **FAZA 1: OLTP (Baza de date sursă)**

#### 1️⃣ **Creare tabele OLTP**
**Script:** `OracleDatabase/03_CREATE_TABLES.sql`  
**Conectare:** Ca SYSDBA sau utilizator cu privilegii CREATE TABLE  
**Ce face:** Creează toate tabelele OLTP (UTILIZATORI, ROLURI, BANCI, APLICATII, etc.)

```sql
-- Rulează în SQL Developer sau SQL*Plus
@OracleDatabase/03_CREATE_TABLES.sql
```

#### 2️⃣ **Populare date test OLTP**
**Script:** `DW/02_POPULATE_OLTP_TEST_DATA.sql`  
**Conectare:** Același utilizator ca la pasul 1 (schema OLTP)  
**Ce face:** Generează 1000+ utilizatori, 5000+ aplicații, bănci, mandate

```sql
@DW/02_POPULATE_OLTP_TEST_DATA.sql
```

---

### **FAZA 2: DW (Data Warehouse)**

#### 3️⃣ **Creare schema DW**
**Script:** `DW/01_CREATE_DW_SCHEMA.sql`  
**Conectare:** Ca SYSDBA  
**Ce face:** Creează utilizatorul `moneyshop_dw_user` și tablespace-ul

```sql
@DW/01_CREATE_DW_SCHEMA.sql
```

#### 4️⃣ **Creare tabele DW**
**Script:** `DW/03_CREATE_DW_TABLES.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Creează tabelul de fapte (FACT_APLICATII_CREDIT) și 6 tabele dimensiune

```sql
-- Conectează-te ca: moneyshop_dw_user / MoneyShopDW2025!
@DW/03_CREATE_DW_TABLES.sql
```

#### 5️⃣ **ETL - Extract**
**Script:** `DW/04_ETL_EXTRACT.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Extrage date din OLTP

```sql
@DW/04_ETL_EXTRACT.sql
```

#### 6️⃣ **ETL - Transform**
**Script:** `DW/05_ETL_TRANSFORM.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Transformă datele pentru DW

```sql
@DW/05_ETL_TRANSFORM.sql
```

#### 7️⃣ **ETL - Load**
**Script:** `DW/06_ETL_LOAD.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Încarcă datele în tabelele DW

```sql
@DW/06_ETL_LOAD.sql
```

---

### **FAZA 3: OPTIMIZARE DW**

#### 8️⃣ **Constrângeri DW**
**Script:** `DW/07_DW_CONSTRAINTS.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Adaugă foreign keys și CHECK constraints

```sql
@DW/07_DW_CONSTRAINTS.sql
```

#### 9️⃣ **Indecși DW**
**Script:** `DW/08_DW_INDEXES.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Creează Bitmap și B-tree indexes

```sql
@DW/08_DW_INDEXES.sql
```

#### 🔟 **Dimensiuni Oracle**
**Script:** `DW/09_DW_DIMENSIONS.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Creează obiecte DIMENSION (dim_timp, dim_utilizator)

```sql
@DW/09_DW_DIMENSIONS.sql
```

#### 1️⃣1️⃣ **Partiții**
**Script:** `DW/10_DW_PARTITIONS.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Partiționează tabelele (RANGE și LIST)

```sql
@DW/10_DW_PARTITIONS.sql
```

---

### **FAZA 4: ANALIZĂ ȘI RAPOARTE**

#### 1️⃣2️⃣ **Optimizare Query**
**Script:** `DW/11_QUERY_OPTIMIZATION.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** Demonstrează optimizarea unei cereri SQL complexe

```sql
@DW/11_QUERY_OPTIMIZATION.sql
```

#### 1️⃣3️⃣ **Rapoarte SQL**
**Script:** `DW/12_REPORTS.sql`  
**Conectare:** Ca `moneyshop_dw_user`  
**Ce face:** 5+ rapoarte SQL cu complexitate diferită

```sql
@DW/12_REPORTS.sql
```

---

## 📋 REZUMAT - ORDINEA COMPLETĂ

```
1. OracleDatabase/03_CREATE_TABLES.sql          (SYSDBA)
2. DW/02_POPULATE_OLTP_TEST_DATA.sql           (Schema OLTP)
3. DW/01_CREATE_DW_SCHEMA.sql                  (SYSDBA)
4. DW/03_CREATE_DW_TABLES.sql                  (moneyshop_dw_user)
5. DW/04_ETL_EXTRACT.sql                       (moneyshop_dw_user)
6. DW/05_ETL_TRANSFORM.sql                     (moneyshop_dw_user)
7. DW/06_ETL_LOAD.sql                          (moneyshop_dw_user)
8. DW/07_DW_CONSTRAINTS.sql                    (moneyshop_dw_user)
9. DW/08_DW_INDEXES.sql                        (moneyshop_dw_user)
10. DW/09_DW_DIMENSIONS.sql                     (moneyshop_dw_user)
11. DW/10_DW_PARTITIONS.sql                    (moneyshop_dw_user)
12. DW/11_QUERY_OPTIMIZATION.sql               (moneyshop_dw_user)
13. DW/12_REPORTS.sql                          (moneyshop_dw_user)
```

---

## ⚙️ CONFIGURARE RAPIDĂ

### **Credențiale:**
- **Schema OLTP:** Utilizatorul tău curent (sau creează unul nou)
- **Schema DW:** 
  - Username: `moneyshop_dw_user`
  - Password: `MoneyShopDW2025!`

### **Verificare rapidă după fiecare pas:**
```sql
-- Verifică tabelele OLTP
SELECT COUNT(*) FROM UTILIZATORI;
SELECT COUNT(*) FROM APLICATII;

-- Verifică tabelele DW
SELECT COUNT(*) FROM FACT_APLICATII_CREDIT;
SELECT COUNT(*) FROM DIM_UTILIZATOR;
```

---

## ⚠️ NOTE IMPORTANTE

1. **Rulează scripturile în ordine** - fiecare depinde de precedentul
2. **Verifică erorile** - dacă apare o eroare, rezolvă-o înainte de a continua
3. **Commit-urile** - scripturile fac commit automat, dar poți face manual dacă e nevoie
4. **Timp estimat:** ~30-60 minute pentru toate scripturile

---

## ✅ CHECKLIST FINAL

- [ ] Tabele OLTP create și populate
- [ ] Schema DW creată
- [ ] Tabele DW create
- [ ] ETL rulat cu succes
- [ ] Constrângeri, indici, dimensiuni, partiții create
- [ ] Query optimizat și rapoarte generate

**Gata pentru prezentare!** 🎉

