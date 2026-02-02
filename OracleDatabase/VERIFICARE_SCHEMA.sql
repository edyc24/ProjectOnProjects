-- =====================================================
-- VERIFICARE SCHEMA ȘI UTILIZATOR
-- =====================================================
-- 
-- Rulează acest script pentru a verifica schema curentă
-- și pentru a identifica problema cu triggerii
--
-- =====================================================

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT VERIFICARE SCHEMA ȘI UTILIZATOR
PROMPT =====================================================
PROMPT

-- Verificare utilizator curent
SELECT 
    'Utilizator curent: ' || USER AS Info
FROM DUAL;

SELECT 
    'Schema curentă: ' || SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS Info
FROM DUAL;

-- Verificare proprietar tabele
PROMPT
PROMPT Proprietar tabele:
SELECT 
    table_name AS Tabela,
    owner AS Proprietar
FROM all_tables
WHERE table_name IN ('UTILIZATORI', 'APLICATII', 'DOCUMENTE', 'AUDIT_LOG')
ORDER BY owner, table_name;

-- Verificare dacă tabelele sunt în schema SYS
PROMPT
PROMPT Verificare tabele în schema SYS:
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '❌ PROBLEMĂ: Tabelele sunt în schema SYS!'
        ELSE '✅ OK: Tabelele NU sunt în schema SYS'
    END AS Status
FROM all_tables
WHERE table_name IN ('UTILIZATORI', 'APLICATII', 'DOCUMENTE', 'AUDIT_LOG')
  AND owner = 'SYS';

-- Verificare privilegii
PROMPT
PROMPT Verificare privilegii CREATE TRIGGER:
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Ai privilegii CREATE TRIGGER'
        ELSE '❌ Nu ai privilegii CREATE TRIGGER'
    END AS Status
FROM user_sys_privs
WHERE privilege = 'CREATE TRIGGER'
UNION ALL
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Ai privilegii CREATE ANY TRIGGER'
        ELSE '❌ Nu ai privilegii CREATE ANY TRIGGER'
    END
FROM user_sys_privs
WHERE privilege = 'CREATE ANY TRIGGER';

-- Recomandări
PROMPT
PROMPT =====================================================
PROMPT RECOMANDĂRI:
PROMPT =====================================================
PROMPT

DECLARE
    v_user VARCHAR2(128);
    v_schema VARCHAR2(128);
    v_tables_in_sys NUMBER;
BEGIN
    v_user := USER;
    v_schema := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
    
    SELECT COUNT(*) INTO v_tables_in_sys
    FROM all_tables
    WHERE table_name IN ('UTILIZATORI', 'APLICATII', 'DOCUMENTE', 'AUDIT_LOG')
      AND owner = 'SYS';
    
    DBMS_OUTPUT.PUT_LINE('Utilizator curent: ' || v_user);
    DBMS_OUTPUT.PUT_LINE('Schema curentă: ' || v_schema);
    DBMS_OUTPUT.PUT_LINE('');
    
    IF v_user = 'SYS' OR v_schema = 'SYS' THEN
        DBMS_OUTPUT.PUT_LINE('❌ PROBLEMĂ: Ești conectat ca SYS sau schema este SYS!');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SOLUȚIE:');
        DBMS_OUTPUT.PUT_LINE('1. Deconectează-te din SYS');
        DBMS_OUTPUT.PUT_LINE('2. Creează un utilizator nou:');
        DBMS_OUTPUT.PUT_LINE('   CREATE USER moneyshop IDENTIFIED BY parola123;');
        DBMS_OUTPUT.PUT_LINE('   GRANT CONNECT, RESOURCE TO moneyshop;');
        DBMS_OUTPUT.PUT_LINE('3. Conectează-te cu utilizatorul nou');
        DBMS_OUTPUT.PUT_LINE('4. Rulează scripturile de creare tabele');
    ELSIF v_tables_in_sys > 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ PROBLEMĂ: Tabelele sunt în schema SYS!');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SOLUȚIE:');
        DBMS_OUTPUT.PUT_LINE('1. Mută tabelele în schema ta:');
        DBMS_OUTPUT.PUT_LINE('   ALTER TABLE SYS.UTILIZATORI MOVE;');
        DBMS_OUTPUT.PUT_LINE('   -- SAU recreează tabelele în schema ta');
        DBMS_OUTPUT.PUT_LINE('2. Rulează din nou scripturile');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ Configurația pare corectă!');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Dacă tot ai erori, verifică:');
        DBMS_OUTPUT.PUT_LINE('1. Dacă tabelele există în schema ta');
        DBMS_OUTPUT.PUT_LINE('2. Dacă ai privilegii CREATE TRIGGER');
    END IF;
END;
/

PROMPT
PROMPT =====================================================

