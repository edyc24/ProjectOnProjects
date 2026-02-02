-- =====================================================
-- SCRIPT CONECTARE SYS - Oracle Database
-- =====================================================
-- 
-- Acest script demonstrează cum să te conectezi ca SYS
-- și cum să verifici conexiunea
--
-- =====================================================

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT VERIFICARE CONEXIUNE SYS
PROMPT =====================================================
PROMPT

-- Verificare utilizator curent
SELECT 
    'Utilizator curent: ' || USER AS Info
FROM DUAL;

-- Verificare privilegii SYS
SELECT 
    'Privilegii SYS: ' || COUNT(*) || ' privilegii sistem' AS Info
FROM USER_SYS_PRIVS;

-- Verificare container curent
SELECT 
    'Container curent: ' || SYS_CONTEXT('USERENV', 'CON_NAME') AS Info
FROM DUAL;

-- Verificare dacă ești în CDB sau PDB
DECLARE
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
BEGIN
    SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
    
    SELECT COUNT(*) INTO v_is_cdb
    FROM v$database
    WHERE cdb = 'YES';
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('INFORMAȚII CONEXIUNE');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Utilizator: SYS');
    DBMS_OUTPUT.PUT_LINE('Container: ' || v_container);
    
    IF v_is_cdb > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Tip: CDB (Container Database)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Tip: Non-CDB');
    END IF;
    
    IF v_container = 'CDB$ROOT' THEN
        DBMS_OUTPUT.PUT_LINE('Status: Ești în CDB$ROOT');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('PDB-uri disponibile:');
        
        FOR rec IN (
            SELECT name, open_mode 
            FROM v$pdbs 
            ORDER BY name
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  - ' || rec.name || ' (' || rec.open_mode || ')');
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Pentru a te muta într-un PDB:');
        DBMS_OUTPUT.PUT_LINE('  ALTER SESSION SET CONTAINER = ORCLPDB;');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Status: Ești într-un PDB');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Pentru a te muta în CDB$ROOT:');
        DBMS_OUTPUT.PUT_LINE('  ALTER SESSION SET CONTAINER = CDB$ROOT;');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

PROMPT
PROMPT =====================================================
PROMPT VERIFICARE PRIVILEGII
PROMPT =====================================================
PROMPT

SELECT 
    privilege AS Privilegiu,
    admin_option AS AdminOption
FROM USER_SYS_PRIVS
ORDER BY privilege;

PROMPT
PROMPT =====================================================
PROMPT VERIFICARE ROLURI
PROMPT =====================================================
PROMPT

SELECT 
    granted_role AS Rol,
    admin_option AS AdminOption
FROM USER_ROLE_PRIVS
ORDER BY granted_role;

PROMPT
PROMPT =====================================================
PROMPT COMENZI UTILE CA SYS
PROMPT =====================================================
PROMPT
PROMPT 1. Listează toate PDB-urile:
PROMPT    SELECT name, open_mode FROM v$pdbs;
PROMPT
PROMPT 2. Deschide un PDB:
PROMPT    ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
PROMPT
PROMPT 3. Mută-te într-un PDB:
PROMPT    ALTER SESSION SET CONTAINER = ORCLPDB;
PROMPT
PROMPT 4. Verifică utilizatori în PDB:
PROMPT    SELECT username FROM dba_users WHERE username = 'MONEYSHOP';
PROMPT
PROMPT 5. Verifică tabele în schema utilizator:
PROMPT    SELECT table_name FROM dba_tables WHERE owner = 'MONEYSHOP';
PROMPT
PROMPT =====================================================

