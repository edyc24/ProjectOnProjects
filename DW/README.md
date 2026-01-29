# Data Warehouse - MoneyShop
## Structură și Organizare

---

## 📁 Structura Foldere

```
DW/
├── README.md                          # Acest fișier
├── 01_CREATE_DW_SCHEMA.sql            # Creare schema DW și utilizatori
├── 02_POPULATE_OLTP_TEST_DATA.sql     # Generare date test pentru OLTP
├── 03_CREATE_DW_TABLES.sql            # Creare tabele DW (fact + dimensiuni)
├── 04_ETL_EXTRACT.sql                 # ETL - Extract (extragere din OLTP)
├── 05_ETL_TRANSFORM.sql               # ETL - Transform (transformare date)
├── 06_ETL_LOAD.sql                    # ETL - Load (încărcare în DW)
├── 07_DW_CONSTRAINTS.sql              # Constrângeri DW
├── 08_DW_INDEXES.sql                  # Indecși DW
├── 09_DW_DIMENSIONS.sql               # Obiecte dimensiune Oracle
├── 10_DW_PARTITIONS.sql               # Partiționare tabele
├── 11_QUERY_OPTIMIZATION.sql          # Optimizare cerere SQL
└── 12_REPORTS.sql                     # Rapoarte SQL
```

---

## 📊 Modelul DW - Diagramă Stea

### Tabel de Fapte
- **FACT_APLICATII_CREDIT** - fapte despre aplicațiile de credit

### Tabele Dimensiune
- **DIM_UTILIZATOR** - dimensiune utilizator
- **DIM_BANCA** - dimensiune bancă
- **DIM_TIMP** - dimensiune timp (data aplicației)
- **DIM_TIP_CREDIT** - dimensiune tip credit
- **DIM_STATUS** - dimensiune status aplicație
- **DIM_BROKER** - dimensiune broker (opțional)

---

## 🔄 Proces ETL

1. **Extract** - Extragere date din OLTP
2. **Transform** - Transformare și curățare date
3. **Load** - Încărcare în DW

---

## 📝 Note Importante

- Toate scripturile sunt independente de aplicația existentă
- Schema DW este separată de schema OLTP
- ETL poate rula manual sau prin trigger
- Nu afectează aplicația existentă

