# GHID: Rezolvare Eroare ORA-04089 pentru Triggeri

## Problema

Eroarea `ORA-04089: cannot create triggers on objects owned by SYS` apare când încerci să creezi triggeri pe tabele care aparțin schemei SYS.

**Oracle nu permite crearea de triggeri pe obiecte deținute de SYS** din motive de securitate.

## Soluții

### Soluția 1: Conectare ca utilizatorul corect (RECOMANDAT)

1. **Identifică proprietarul tabelelor:**
```sql
SELECT owner, table_name 
FROM all_tables 
WHERE table_name IN ('APLICATII', 'UTILIZATORI', 'MESAJE')
ORDER BY owner, table_name;
```

2. **Conectează-te ca utilizatorul care deține tabelele:**
   - Dacă tabelele sunt în schema `MONEYSHOP`, conectează-te ca `MONEYSHOP`
   - Dacă tabelele sunt în altă schemă, conectează-te ca acel utilizator

3. **Rulează scriptul de triggeri:**
   - `14_TRIGGERI_LMD_MESAJE_FIX.sql` (versiunea corectată)

### Soluția 2: Setare schema curentă (dacă ai privilegii)

Dacă ești conectat ca un utilizator cu privilegii suficiente:

```sql
-- Verifică proprietarul tabelelor
SELECT DISTINCT owner FROM all_tables 
WHERE table_name IN ('APLICATII', 'UTILIZATORI');

-- Setează schema curentă (înlocuiește MONEYSHOP cu schema corectă)
ALTER SESSION SET CURRENT_SCHEMA = MONEYSHOP;

-- Verifică schema curentă
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') FROM DUAL;

-- Acum rulează scriptul de triggeri
```

### Soluția 3: Creare triggeri cu schema explicită (dacă ai privilegii)

Dacă ai privilegii CREATE ANY TRIGGER:

```sql
-- Înlocuiește MONEYSHOP cu schema corectă
CREATE OR REPLACE TRIGGER MONEYSHOP.trg_aplicatii_before_insert
BEFORE INSERT ON MONEYSHOP.APLICATII
...
```

**Notă:** Această soluție necesită privilegii speciale și nu este recomandată.

## Verificare Schema Curentă

```sql
-- Verifică schema curentă
SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS Schema_Curenta FROM DUAL;

-- Verifică utilizatorul curent
SELECT USER AS Utilizator_Curent FROM DUAL;

-- Verifică proprietarul tabelelor
SELECT owner, COUNT(*) AS Numar_Tabele
FROM all_tables
WHERE table_name IN ('APLICATII', 'UTILIZATORI', 'BANCI', 'MESAJE')
GROUP BY owner;
```

## Script Corectat

Am creat `14_TRIGGERI_LMD_MESAJE_FIX.sql` care:
- ✅ Verifică automat schema curentă
- ✅ Identifică proprietarul tabelelor
- ✅ Încearcă să seteze schema automat (dacă e posibil)
- ✅ Oferă instrucțiuni clare dacă nu poate seta schema

## Pași Recomandați

1. **Verifică schema tabelelor:**
```sql
SELECT owner, table_name 
FROM all_tables 
WHERE table_name = 'APLICATII';
```

2. **Conectează-te ca utilizatorul corect:**
   - În Oracle SQL Developer: File → New → Database Connection
   - Folosește utilizatorul care deține tabelele (nu SYS)

3. **Rulează scriptul corectat:**
   - `14_TRIGGERI_LMD_MESAJE_FIX.sql`

4. **Verifică triggerii creați:**
```sql
SELECT trigger_name, status, table_name
FROM user_triggers
WHERE trigger_name LIKE 'TRG_%'
ORDER BY trigger_name;
```

## Exemplu: Conectare ca MONEYSHOP

Dacă tabelele sunt în schema MONEYSHOP:

1. **Creează conexiune nouă în SQL Developer:**
   - Username: `MONEYSHOP`
   - Password: (parola ta)
   - Hostname: (hostname-ul tău)
   - Port: (port-ul tău, de obicei 1521)
   - SID/Service Name: (SID-ul tău)

2. **Conectează-te cu această conexiune**

3. **Rulează scriptul:**
   - `14_TRIGGERI_LMD_MESAJE_FIX.sql`

## Verificare Finală

După crearea triggerilor, verifică:

```sql
-- Verifică toți triggerii
SELECT trigger_name, trigger_type, table_name, status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_%'
ORDER BY trigger_name;

-- Ar trebui să vezi:
-- TRG_APLICATII_AFTER_DELETE
-- TRG_APLICATII_AFTER_INSERT
-- TRG_APLICATII_BEFORE_INSERT
-- TRG_APLICATII_BEFORE_UPDATE
-- TRG_UTILIZATORI_VARSTA_MESAJE
```

---

**Dacă problema persistă, verifică:**
1. Ai privilegii CREATE TRIGGER?
2. Tabelele există în schema corectă?
3. Ești conectat ca utilizatorul corect?

