# ANALIZĂ PROIECT SBD - MoneyShop
## Verificare Cerințe vs. Implementare Există

**Data:** 2025-01-08  
**Proiect:** MoneyShop - Platformă de Brokeraj de Credite  
**Baza de date:** Oracle Database 19c+

---

## 📋 CERINȚE PROIECT SBD

### ✅ 1. Prezentarea concisă a bazei de date
**Status:** ✅ COMPLETAT  
**Locație:** `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`  
**Conținut:** Prezentare completă a modelului și scenariului de business

---

### ✅ 2. Diagrama Entitate-Relație (ERD)
**Status:** ✅ COMPLETAT  
**Locație:** `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`  
**Verificare:**
- ✅ Minim 6 entități independente: ROLURI, UTILIZATORI, BANCI, APLICATII, DOCUMENTE, CONSENTURI, MANDATE, LEADURI, AGREEMENTS, USER_FINANCIAL_DATA, USER_SESSIONS, AUDIT_LOG (12 entități)
- ✅ Cel puțin o relație many-to-many: APPLICATION_BANKS (APLICATII ↔ BANCI)
- ✅ Toate entitățile și relațiile definite în limba română

---

### ✅ 3. Diagrama conceptuală
**Status:** ✅ COMPLETAT  
**Locație:** `OracleDatabase/01_DIAGRAMA_CONCEPTUALA.md`  
**Conținut:** Diagramă completă cu toate entitățile și relațiile

---

### ✅ 4. Design logic (chei primare și străine)
**Status:** ✅ COMPLETAT  
**Locație:** `OracleDatabase/02_SCHEME_RELATIONALE.md`  
**Conținut:** 
- ✅ Toate cheile primare definite
- ✅ Toate cheile străine definite
- ✅ Relațiile dintre tabele documentate

---

### ⚠️ 5. Design fizic în FN3
**Status:** ⚠️ PARȚIAL - LIPSEȘTE DOCUMENTAȚIA  
**Locație:** Trebuie creat document separat  
**Ce lipsește:**
- ❌ Exemplu de atribut repetitiv (multivaloare) al unei entități
- ❌ Exemplu de tabel în FN1 dar nu în FN2 + aducere la FN2
- ❌ Exemplu de tabel în FN2 dar nu în FN3 + aducere la FN3
- ❌ Demonstrație că toate tabelele sunt în FN3

**Sugestie:** 
- Atribut repetitiv: `ListaBanciActive CLOB` (JSON array) din APLICATII poate fi considerat atribut multivaloare
- Tabel pentru exemplu FN1→FN2: poate fi creat un tabel temporar pentru demonstrație
- Tabel pentru exemplu FN2→FN3: poate fi creat un tabel temporar pentru demonstrație

---

### ✅ 6. Implementare tabele în Oracle
**Status:** ✅ COMPLETAT  
**Locație:** `OracleDatabase/03_CREATE_TABLES.sql`  
**Verificare:**
- ✅ Chei primare: Toate tabelele au chei primare
- ✅ Constrângeri de referință: Toate foreign keys definite
- ✅ Constrângeri de domeniu: CHECK constraints pentru validare
- ⚠️ Date de test: Trebuie verificat dacă există minim 5 înregistrări per entitate independentă și 10 per tabel asociativ

**Tabele create:**
1. ROLURI ✅
2. UTILIZATORI ✅
3. BANCI ✅
4. APLICATII ✅
5. APPLICATION_BANKS ✅ (many-to-many)
6. DOCUMENTE ✅
7. AGREEMENTS ✅
8. LEADURI ✅
9. CONSENTURI ✅
10. MANDATE ✅
11. USER_FINANCIAL_DATA ✅
12. USER_SESSIONS ✅
13. AUDIT_LOG ✅

---

### ❌ 7. 15 interogări SQL complexe
**Status:** ❌ LIPSEȘTE  
**Locație:** Trebuie creat fișier separat  
**Cerințe:**
- ❌ 15 interogări complexe cu enunțuri în limbaj natural
- ❌ GROUP BY, HAVING
- ❌ START WITH, CONNECT BY (hierarhii)
- ❌ ORDER BY
- ❌ Funcții șiruri: LOWER, UPPER, SUBSTR, INSTR
- ❌ Funcții date: TO_CHAR, TO_DATE, ADD_MONTHS, MONTHS_BETWEEN
- ❌ Funcții diverse: DECODE, NVL, NULLIF, CASE
- ❌ INNER, LEFT, RIGHT, FULL JOIN
- ❌ Operatori pe mulțimi (UNION, INTERSECT, MINUS)
- ❌ Funcții agregat: AVG, SUM, MIN, MAX, COUNT
- ❌ Subinterogări în SELECT, FROM, WHERE, HAVING
- ❌ Operatorul DIVISION

**Acțiune necesară:** Creare fișier `OracleDatabase/08_INTEROGARI_SQL.sql` cu 15 interogări complexe

---

### ❌ 8. Tabel de mesaje
**Status:** ❌ LIPSEȘTE  
**Locație:** Trebuie adăugat în `03_CREATE_TABLES.sql`  
**Structură necesară:**
```sql
CREATE TABLE MESAJE (
    cod_mesaj NUMBER PRIMARY KEY,
    mesaj VARCHAR2(255),
    tip_mesaj VARCHAR2(1) CHECK (tip_mesaj IN ('E', 'W', 'I')),
    creat_de VARCHAR2(40) NOT NULL,
    creat_la DATE NOT NULL
);
```

**Acțiune necesară:** 
- Adăugare tabel MESAJE în `03_CREATE_TABLES.sql`
- Creare secvență pentru cod_mesaj

---

### ⚠️ 9. PL/SQL - Subprograme și Triggeri
**Status:** ⚠️ PARȚIAL - LIPSEȘTE DOCUMENTAȚIA COMPLETĂ  
**Locație:** Fișiere multiple în `OracleDatabase/`  

**Verificare cerințe:**

#### 9.1 Subprogram stocat cu colecții (3 tipuri)
**Status:** ❌ LIPSEȘTE  
**Cerință:** Subprogram care să utilizeze toate cele 3 tipuri de colecții (VARRAY, NESTED TABLE, ASSOCIATIVE ARRAY)  
**Acțiune necesară:** Creare procedură/funcție care folosește toate cele 3 tipuri

#### 9.2 Subprogram cu cursoare (2 tipuri, unul parametrizat)
**Status:** ❌ LIPSEȘTE  
**Cerință:** Subprogram cu 2 tipuri de cursoare, unul parametrizat, dependent de celălalt  
**Acțiune necesară:** Creare procedură/funcție cu cursoare

#### 9.3 Funcție cu 3 tabele + tratare excepții
**Status:** ⚠️ PARȚIAL  
**Cerință:** Funcție care folosește 3 tabele, tratare minim 2 excepții proprii, apelare cu toate cazurile  
**Acțiune necesară:** Verificare și completare dacă lipsește

#### 9.4 Trigger LMD la nivel de comandă
**Status:** ✅ EXISTĂ (parțial)  
**Locație:** `03_CREATE_TABLES.sql` - triggeri pentru UpdatedAt  
**Acțiune necesară:** Verificare dacă sunt triggeri la nivel de comandă (nu doar la nivel de linie)

#### 9.5 Trigger LMD la nivel de linie
**Status:** ✅ EXISTĂ  
**Locație:** `03_CREATE_TABLES.sql` - `trg_utilizatori_varsta`, `trg_utilizatori_updated`, `trg_aplicatii_updated`  
**Verificare:** ✅ Triggeri la nivel de linie există

#### 9.6 Trigger LDD
**Status:** ❌ LIPSEȘTE  
**Cerință:** Trigger de tip LDD (Data Definition Language)  
**Acțiune necesară:** Creare trigger LDD (ex: AFTER CREATE ON SCHEMA)

#### 9.7 Pachet cu toate obiectele
**Status:** ❌ LIPSEȘTE  
**Cerință:** Pachet care să conțină toate obiectele definite la punctul 9  
**Acțiune necesară:** Creare pachet `PKG_MONEYSHOP` cu toate subprogramele și triggerii

---

### ❌ 10. Tratare excepții cu inserare în tabel mesaje
**Status:** ❌ LIPSEȘTE  
**Cerință:** În cazul excepțiilor, inserare mesaje în tabelul MESAJE folosind secvență  
**Acțiune necesară:** 
- Creare secvență pentru cod_mesaj
- Modificare subprograme pentru a insera mesaje în MESAJE la excepții

---

## 📊 REZUMAT STATUS

| Cerință | Status | Acțiune Necesară |
|---------|--------|------------------|
| 1. Prezentare concisă | ✅ | - |
| 2. Diagrama ERD | ✅ | - |
| 3. Diagrama conceptuală | ✅ | - |
| 4. Design logic | ✅ | - |
| 5. Design fizic FN3 | ⚠️ | Documentație normalizare |
| 6. Implementare tabele | ✅ | Verificare date test |
| 7. 15 interogări SQL | ❌ | **CREARE FIȘIER** |
| 8. Tabel mesaje | ❌ | **ADĂUGARE TABEL** |
| 9. PL/SQL complet | ⚠️ | **COMPLETARE** |
| 10. Tratare excepții | ❌ | **IMPLEMENTARE** |

---

## 🎯 ACȚIUNI NECESARE

### Prioritate 1 (Obligatorii):
1. **Creare tabel MESAJE** + secvență
2. **Creare 15 interogări SQL complexe** cu toate cerințele
3. **Creare subprograme PL/SQL** cu colecții, cursoare, funcții
4. **Creare trigger LDD**
5. **Creare pachet** cu toate obiectele
6. **Implementare tratare excepții** cu inserare în MESAJE

### Prioritate 2 (Documentație):
7. **Documentație normalizare FN1→FN2→FN3** cu exemple
8. **Verificare date test** (minim 5 per entitate, 10 per asociativ)

---

## 📝 FIȘIERE NECESARE PENTRU PREDARE

Conform cerințelor, trebuie 4 fișiere:

1. **`nr_grupa_nume_prenume_PREZENTARE.docx`**
   - ✅ Diagrame ERD, conceptuală, logică
   - ⚠️ Normalizare FN1→FN2→FN3 (trebuie adăugat)
   - ❌ Capturi de ecran cu execuția comenzilor
   - ✅ Cod SQL/PL-SQL ca text (nu imagine)

2. **`nr_grupa_nume_prenume_SCHEMA.txt`**
   - ✅ Creare tabele (03_CREATE_TABLES.sql)
   - ❌ Populare date (trebuie verificat/adaugat)
   - ❌ Tabel MESAJE (trebuie adăugat)

3. **`nr_grupa_nume_prenume_SQL.txt`**
   - ❌ 15 interogări SQL complexe (trebuie creat)

4. **`nr_grupa_nume_prenume_PLSQL.txt`**
   - ⚠️ Subprograme PL/SQL (parțial există)
   - ❌ Tabel MESAJE (trebuie adăugat)
   - ❌ Pachet complet (trebuie creat)
   - ❌ Tratare excepții (trebuie implementat)

---

## ✅ CE AVEM DEJA

1. ✅ Baza de date completă cu 13 tabele
2. ✅ Diagramă ERD și conceptuală
3. ✅ Design logic documentat
4. ✅ Triggeri LMD la nivel de linie
5. ✅ Constrângeri complete (PK, FK, CHECK)
6. ✅ Indexuri pentru performanță
7. ✅ Scripturi PL/SQL pentru securitate, criptare, auditare

---

## ❌ CE LIPSEȘTE

1. ❌ Tabel MESAJE
2. ❌ 15 interogări SQL complexe
3. ❌ Subprograme PL/SQL cu colecții (3 tipuri)
4. ❌ Subprograme PL/SQL cu cursoare (2 tipuri)
5. ❌ Funcție cu 3 tabele + excepții proprii
6. ❌ Trigger LDD
7. ❌ Pachet complet
8. ❌ Tratare excepții cu inserare în MESAJE
9. ❌ Documentație normalizare FN1→FN2→FN3
10. ❌ Date test suficiente (verificare necesară)

---

**Data analiză:** 2025-01-08  
**Status general:** ✅ COMPLET - Toate cerințele sunt implementate!

---

## ✅ ACTUALIZARE FINALĂ

**Data:** 2025-01-08  
**Status:** ✅ TOATE CERINȚELE COMPLETATE

Toate cerințele au fost implementate:
- ✅ Tabel MESAJE creat
- ✅ 15 interogări SQL complexe create
- ✅ Subprograme PL/SQL cu colecții, cursoare, funcții
- ✅ Trigger LDD creat
- ✅ Pachet PKG_MONEYSHOP creat
- ✅ Tratare excepții cu inserare în MESAJE implementată
- ✅ Documentație normalizare FN1→FN2→FN3 creată
- ✅ Scripturi pentru populare date test create

**Vezi:** `REZUMAT_PROIECT_SBD.md` pentru detalii complete.

