# ORDINE EXACTĂ DE EXECUTARE SCRIPTS - PROIECT SBD
## MoneyShop - Oracle Database

**IMPORTANT:** Rulează scripturile în această ordine exactă pentru o bază de date nouă!

---

## 📋 ORDINEA DE EXECUTARE

### **PASUL 1: Creare Tabele și Structură de Bază**
**Fișier:** `03_CREATE_TABLES.sql`

**Ce face:**
- Creează toate tabelele (ROLURI, UTILIZATORI, BANCI, APLICATII, etc.)
- Creează tabelul **MESAJE** și secvența **seq_mesaje**
- Creează indexuri
- Creează triggeri de bază (UpdatedAt, validare vârstă)
- Inserează rolurile inițiale (CLIENT, BROKER, ADMIN)

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 03_CREATE_TABLES.sql
-- 2. Rulează tot scriptul (F5 sau Run Script)
-- 3. Verifică că nu sunt erori
```

**Verificare:**
```sql
SELECT table_name FROM user_tables 
WHERE table_name IN ('ROLURI', 'UTILIZATORI', 'BANCI', 'APLICATII', 'MESAJE')
ORDER BY table_name;
-- Ar trebui să vezi toate cele 5 tabele
```

---

### **PASUL 2: Populare Date Test**
**Fișier:** `17_POPULARE_DATE_TEST.sql`

**Ce face:**
- Verifică datele existente
- Completează datele dacă nu sunt suficiente
- Asigură minim 5 înregistrări per entitate independentă
- Asigură minim 10 înregistrări per tabel asociativ

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 17_POPULARE_DATE_TEST.sql
-- 2. Rulează tot scriptul (F5)
-- 3. Verifică mesajele DBMS_OUTPUT pentru confirmare
```

**Verificare:**
```sql
SELECT 'ROLURI' AS Tabel, COUNT(*) AS Numar FROM ROLURI
UNION ALL
SELECT 'UTILIZATORI', COUNT(*) FROM UTILIZATORI
UNION ALL
SELECT 'BANCI', COUNT(*) FROM BANCI
UNION ALL
SELECT 'APLICATII', COUNT(*) FROM APLICATII
UNION ALL
SELECT 'APPLICATION_BANKS', COUNT(*) FROM APPLICATION_BANKS;
-- Toate ar trebui să aibă minim 5 (APPLICATION_BANKS minim 10)
```

---

### **PASUL 3: Creare Tipuri de Colecții (pentru PL/SQL)**
**Fișier:** `09_PLSQL_COLECTII.sql`

**Ce face:**
- Creează tipurile de colecții (VARRAY, NESTED TABLE)
- Creează procedura `SP_PROCESARE_COLECTII` care folosește toate cele 3 tipuri

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 09_PLSQL_COLECTII.sql
-- 2. Rulează tot scriptul (F5)
-- 3. Verifică că procedura este creată
```

**Verificare:**
```sql
SELECT object_name, object_type 
FROM user_objects 
WHERE object_name = 'SP_PROCESARE_COLECTII';
-- Ar trebui să vezi PROCEDURE
```

---

### **PASUL 4: Creare Subprogram cu Cursoare**
**Fișier:** `10_PLSQL_CURSOARE.sql`

**Ce face:**
- Creează procedura `SP_PROCESARE_CURSOARE` cu 2 tipuri de cursoare

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 10_PLSQL_CURSOARE.sql
-- 2. Rulează tot scriptul (F5)
```

**Verificare:**
```sql
SELECT object_name, object_type 
FROM user_objects 
WHERE object_name = 'SP_PROCESARE_CURSOARE';
```

---

### **PASUL 5: Creare Funcție cu Excepții**
**Fișier:** `11_PLSQL_FUNCTIE_EXCEPTII.sql`

**Ce face:**
- Creează funcția `FN_CALCUL_STATISTICI_UTILIZATOR` cu 3 tabele și tratare excepții

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 11_PLSQL_FUNCTIE_EXCEPTII.sql
-- 2. Rulează tot scriptul (F5)
```

**Verificare:**
```sql
SELECT object_name, object_type 
FROM user_objects 
WHERE object_name = 'FN_CALCUL_STATISTICI_UTILIZATOR';
```

---

### **PASUL 6: Creare Trigger LDD**
**Fișier:** `12_TRIGGER_LDD.sql`

**Ce face:**
- Creează triggerul `trg_audit_ddl` pentru evenimente DDL
- Testează triggerul prin creare/modificare/ștergere tabel

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 12_TRIGGER_LDD.sql
-- 2. Rulează tot scriptul (F5)
-- 3. Verifică mesajele DBMS_OUTPUT pentru confirmare declanșare trigger
```

**Verificare:**
```sql
SELECT trigger_name, trigger_type, status 
FROM user_triggers 
WHERE trigger_name = 'TRG_AUDIT_DDL';
```

---

### **PASUL 7: Creare Pachet PKG_MONEYSHOP**
**Fișier:** `13_PACHET_MONEYSHOP.sql`

**Ce face:**
- Creează pachetul `PKG_MONEYSHOP` cu toate subprogramele
- Include funcția `FN_INSERARE_MESAJ` pentru tratare excepții

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 13_PACHET_MONEYSHOP.sql
-- 2. Rulează tot scriptul (F5)
```

**Verificare:**
```sql
SELECT object_name, object_type 
FROM user_objects 
WHERE object_name LIKE 'PKG_MONEYSHOP%';
-- Ar trebui să vezi PACKAGE și PACKAGE BODY
```

---

### **PASUL 8: Creare Triggeri LMD cu Mesaje**
**Fișier:** `14_TRIGGERI_LMD_MESAJE.sql`

**Ce face:**
- Creează triggeri LMD la nivel de comandă și linie
- Toți triggerii inserează mesaje în MESAJE

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 14_TRIGGERI_LMD_MESAJE.sql
-- 2. Rulează tot scriptul (F5)
```

**Verificare:**
```sql
SELECT trigger_name, trigger_type, table_name 
FROM user_triggers 
WHERE trigger_name LIKE 'TRG_%'
ORDER BY trigger_name;
```

---

### **PASUL 9: Exemple Normalizare (Opțional - pentru demonstrație)**
**Fișier:** `16_NORMALIZARE_EXEMPLE.sql`

**Ce face:**
- Creează tabele temporare pentru demonstrație normalizare FN1→FN2→FN3

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 16_NORMALIZARE_EXEMPLE.sql
-- 2. Rulează tot scriptul (F5)
```

**Notă:** Aceste tabele sunt doar pentru demonstrație. Le poți șterge după.

---

### **PASUL 10: Testare Interogări SQL (Opțional - pentru verificare)**
**Fișier:** `08_INTEROGARI_SQL.sql`

**Ce face:**
- Conține 15 interogări SQL complexe
- Poți rula fiecare interogare individual pentru testare

**Cum rulezi:**
```sql
-- În Oracle SQL Developer:
-- 1. Deschide fișierul 08_INTEROGARI_SQL.sql
-- 2. Rulează fiecare interogare individual (selectează și F9)
-- SAU rulează tot scriptul (F5)
```

**Notă:** Aceste interogări sunt pentru demonstrație. Nu modifică datele.

---

## ✅ VERIFICARE FINALĂ

După ce ai rulat toate scripturile, verifică:

```sql
-- 1. Verificare tabele
SELECT COUNT(*) AS NumarTabele 
FROM user_tables 
WHERE table_name IN ('ROLURI', 'UTILIZATORI', 'BANCI', 'APLICATII', 
                     'APPLICATION_BANKS', 'DOCUMENTE', 'CONSENTURI', 
                     'MANDATE', 'MESAJE');

-- 2. Verificare proceduri/funcții
SELECT object_name, object_type 
FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
ORDER BY object_type, object_name;

-- 3. Verificare triggeri
SELECT trigger_name, trigger_type, table_name, status 
FROM user_triggers 
ORDER BY trigger_name;

-- 4. Verificare secvență
SELECT sequence_name, last_number 
FROM user_sequences 
WHERE sequence_name = 'SEQ_MESAJE';

-- 5. Verificare date
SELECT 'ROLURI' AS Tabel, COUNT(*) AS Numar FROM ROLURI
UNION ALL SELECT 'UTILIZATORI', COUNT(*) FROM UTILIZATORI
UNION ALL SELECT 'BANCI', COUNT(*) FROM BANCI
UNION ALL SELECT 'APLICATII', COUNT(*) FROM APLICATII
UNION ALL SELECT 'APPLICATION_BANKS', COUNT(*) FROM APPLICATION_BANKS
UNION ALL SELECT 'MESAJE', COUNT(*) FROM MESAJE;
```

---

## 📝 ORDINE REZUMATĂ (COPY-PASTE)

```
1. 03_CREATE_TABLES.sql
2. 17_POPULARE_DATE_TEST.sql
3. 09_PLSQL_COLECTII.sql
4. 10_PLSQL_CURSOARE.sql
5. 11_PLSQL_FUNCTIE_EXCEPTII.sql
6. 12_TRIGGER_LDD.sql
7. 13_PACHET_MONEYSHOP.sql
8. 14_TRIGGERI_LMD_MESAJE.sql
9. 16_NORMALIZARE_EXEMPLE.sql (opțional)
10. 08_INTEROGARI_SQL.sql (opțional - pentru testare)
```

---

## ⚠️ ATENȚIE

1. **Nu rula scripturile în altă ordine** - există dependențe între ele
2. **Verifică erorile** - dacă apare o eroare, oprește-te și rezolvă-o
3. **Commit automat** - majoritatea scripturilor au COMMIT inclus
4. **DBMS_OUTPUT** - Activează DBMS_OUTPUT în SQL Developer pentru a vedea mesajele

---

**Data:** 2025-01-08  
**Status:** ✅ Gata pentru execuție

