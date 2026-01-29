# ✅ CHECKLIST EXECUTIE SCRIPTS - PROIECT SBD

Folosește acest checklist pentru a verifica că ai rulat toate scripturile corect.

---

## 📋 CHECKLIST

### ✅ PASUL 1: Creare Tabele
- [ ] Am rulat `03_CREATE_TABLES.sql`
- [ ] Nu am primit erori
- [ ] Tabelul MESAJE există
- [ ] Secvența seq_mesaje există
- [ ] Am văzut mesajul "Tabelele au fost create cu succes!"

**Verificare:**
```sql
SELECT COUNT(*) FROM user_tables WHERE table_name = 'MESAJE';
SELECT sequence_name FROM user_sequences WHERE sequence_name = 'SEQ_MESAJE';
```

---

### ✅ PASUL 2: Populare Date
- [ ] Am rulat `17_POPULARE_DATE_TEST.sql`
- [ ] Nu am primit erori
- [ ] Am văzut mesajele de confirmare pentru fiecare tabel

**Verificare:**
```sql
SELECT COUNT(*) FROM ROLURI;        -- Minim 3
SELECT COUNT(*) FROM UTILIZATORI;   -- Minim 5
SELECT COUNT(*) FROM BANCI;         -- Minim 5
SELECT COUNT(*) FROM APLICATII;     -- Minim 5
SELECT COUNT(*) FROM APPLICATION_BANKS; -- Minim 10
```

---

### ✅ PASUL 3: PL/SQL Colecții
- [ ] Am rulat `09_PLSQL_COLECTII.sql`
- [ ] Nu am primit erori
- [ ] Procedura SP_PROCESARE_COLECTII există

**Verificare:**
```sql
SELECT object_name FROM user_objects 
WHERE object_name = 'SP_PROCESARE_COLECTII';
```

---

### ✅ PASUL 4: PL/SQL Cursoare
- [ ] Am rulat `10_PLSQL_CURSOARE.sql`
- [ ] Nu am primit erori
- [ ] Procedura SP_PROCESARE_CURSOARE există

**Verificare:**
```sql
SELECT object_name FROM user_objects 
WHERE object_name = 'SP_PROCESARE_CURSOARE';
```

---

### ✅ PASUL 5: PL/SQL Funcție Excepții
- [ ] Am rulat `11_PLSQL_FUNCTIE_EXCEPTII.sql`
- [ ] Nu am primit erori
- [ ] Funcția FN_CALCUL_STATISTICI_UTILIZATOR există

**Verificare:**
```sql
SELECT object_name FROM user_objects 
WHERE object_name = 'FN_CALCUL_STATISTICI_UTILIZATOR';
```

---

### ✅ PASUL 6: Trigger LDD
- [ ] Am rulat `12_TRIGGER_LDD.sql`
- [ ] Nu am primit erori
- [ ] Am văzut mesajele de declanșare trigger în DBMS_OUTPUT
- [ ] Triggerul trg_audit_ddl există

**Verificare:**
```sql
SELECT trigger_name FROM user_triggers 
WHERE trigger_name = 'TRG_AUDIT_DDL';
```

---

### ✅ PASUL 7: Pachet
- [ ] Am rulat `13_PACHET_MONEYSHOP.sql`
- [ ] Nu am primit erori
- [ ] Pachetul PKG_MONEYSHOP există (PACKAGE și PACKAGE BODY)

**Verificare:**
```sql
SELECT object_name, object_type FROM user_objects 
WHERE object_name LIKE 'PKG_MONEYSHOP%';
-- Ar trebui să vezi: PKG_MONEYSHOP (PACKAGE) și PKG_MONEYSHOP (PACKAGE BODY)
```

---

### ✅ PASUL 8: Triggeri LMD
- [ ] Am rulat `14_TRIGGERI_LMD_MESAJE.sql`
- [ ] Nu am primit erori
- [ ] Toți triggerii LMD există

**Verificare:**
```sql
SELECT trigger_name, table_name FROM user_triggers 
WHERE trigger_name LIKE 'TRG_%'
ORDER BY trigger_name;
-- Ar trebui să vezi: trg_aplicatii_before_insert, trg_aplicatii_before_update, etc.
```

---

### ✅ PASUL 9: Exemple Normalizare (Opțional)
- [ ] Am rulat `16_NORMALIZARE_EXEMPLE.sql` (opțional)
- [ ] Nu am primit erori

---

### ✅ PASUL 10: Testare Interogări (Opțional)
- [ ] Am rulat `08_INTEROGARI_SQL.sql` (opțional)
- [ ] Am testat câteva interogări individual

---

## 🧪 TESTARE FUNCȚIONALITĂȚI

### Test 1: Testare Procedură cu Colecții
```sql
DECLARE
    v_rezultat VARCHAR2(500);
BEGIN
    PKG_MONEYSHOP.SP_PROCESARE_COLECTII(1, v_rezultat);
    DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
END;
/
```

### Test 2: Testare Procedură cu Cursoare
```sql
DECLARE
    v_rezultat VARCHAR2(500);
    v_id_rol NUMBER;
BEGIN
    SELECT IdRol INTO v_id_rol FROM ROLURI WHERE NumeRol = 'CLIENT';
    PKG_MONEYSHOP.SP_PROCESARE_CURSOARE(v_id_rol, v_rezultat);
    DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
END;
/
```

### Test 3: Testare Funcție cu Excepții
```sql
-- Test cu utilizator valid
SELECT PKG_MONEYSHOP.FN_CALCUL_STATISTICI_UTILIZATOR(1) FROM DUAL;

-- Test cu utilizator inexistent (va genera excepție)
SELECT PKG_MONEYSHOP.FN_CALCUL_STATISTICI_UTILIZATOR(99999) FROM DUAL;
```

### Test 4: Testare Trigger LDD
```sql
-- Va declanșa triggerul
CREATE TABLE TEST_TRIGGER_DDL (id NUMBER);
DROP TABLE TEST_TRIGGER_DDL;
```

### Test 5: Testare Triggeri LMD
```sql
-- Va declanșa triggerul și va insera mesaj în MESAJE
INSERT INTO APLICATII (UserId, Status, TypeCredit, SalariuNet, DataNastere)
VALUES (1, 'INREGISTRAT', 'NEVOI_PERSONALE', 5000, DATE '1990-01-01');

-- Verifică mesajele
SELECT * FROM MESAJE ORDER BY creat_la DESC;
```

### Test 6: Testare Pachet - Creare Aplicație
```sql
DECLARE
    v_id_aplicatie NUMBER;
BEGIN
    PKG_MONEYSHOP.SP_CREARE_APLICATIE(
        1, -- UserId
        'NEVOI_PERSONALE',
        'NOU',
        5000,
        v_id_aplicatie
    );
    DBMS_OUTPUT.PUT_LINE('Aplicație creată: ' || v_id_aplicatie);
END;
/
```

---

## ✅ VERIFICARE FINALĂ COMPLETĂ

```sql
-- 1. Toate tabelele există
SELECT 'Tabele' AS Tip, COUNT(*) AS Numar
FROM user_tables
WHERE table_name IN ('ROLURI', 'UTILIZATORI', 'BANCI', 'APLICATII', 
                     'APPLICATION_BANKS', 'DOCUMENTE', 'CONSENTURI', 
                     'MANDATE', 'MESAJE', 'AUDIT_LOG');

-- 2. Toate obiectele PL/SQL există
SELECT 'PL/SQL Objects' AS Tip, COUNT(*) AS Numar
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
AND object_name IN ('SP_PROCESARE_COLECTII', 'SP_PROCESARE_CURSOARE',
                    'FN_CALCUL_STATISTICI_UTILIZATOR', 'PKG_MONEYSHOP');

-- 3. Toți triggerii există
SELECT 'Triggeri' AS Tip, COUNT(*) AS Numar
FROM user_triggers
WHERE trigger_name IN ('TRG_AUDIT_DDL', 'TRG_APLICATII_BEFORE_INSERT',
                       'TRG_APLICATII_BEFORE_UPDATE', 'TRG_APLICATII_AFTER_INSERT',
                       'TRG_APLICATII_AFTER_DELETE', 'TRG_UTILIZATORI_VARSTA_MESAJE');

-- 4. Secvența există
SELECT 'Secvente' AS Tip, COUNT(*) AS Numar
FROM user_sequences
WHERE sequence_name = 'SEQ_MESAJE';

-- 5. Date suficiente
SELECT 'Date' AS Tip, 
       CASE 
           WHEN (SELECT COUNT(*) FROM ROLURI) >= 3 AND
                (SELECT COUNT(*) FROM UTILIZATORI) >= 5 AND
                (SELECT COUNT(*) FROM BANCI) >= 5 AND
                (SELECT COUNT(*) FROM APLICATII) >= 5 AND
                (SELECT COUNT(*) FROM APPLICATION_BANKS) >= 10
           THEN 1 ELSE 0
       END AS OK
FROM DUAL;
```

---

**Dacă toate verificările returnează rezultate pozitive, proiectul este complet! ✅**

