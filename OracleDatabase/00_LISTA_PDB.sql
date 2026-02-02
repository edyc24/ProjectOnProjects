-- =====================================================
-- LISTARE PDB-URI DISPONIBILE
-- =====================================================
-- 
-- Rulează acest script ca SYSDBA pentru a vedea
-- ce PDB-uri sunt disponibile în sistemul tău
--
-- =====================================================

SET SERVEROUTPUT ON;
SET PAGESIZE 1000;

PROMPT =====================================================
PROMPT LISTARE PDB-URI DISPONIBILE
PROMPT =====================================================
PROMPT

-- Verificare dacă e CDB
DECLARE
    v_is_cdb NUMBER;
    v_container VARCHAR2(128);
BEGIN
    SELECT COUNT(*) INTO v_is_cdb
    FROM v$database
    WHERE cdb = 'YES';
    
    BEGIN
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
    EXCEPTION
        WHEN OTHERS THEN
            v_container := 'N/A';
    END;
    
    DBMS_OUTPUT.PUT_LINE('Container curent: ' || v_container);
    DBMS_OUTPUT.PUT_LINE('Oracle Multitenant: ' || CASE WHEN v_is_cdb > 0 THEN 'DA (CDB)' ELSE 'NU (Non-CDB)' END);
    DBMS_OUTPUT.PUT_LINE('');
    
    IF v_is_cdb = 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Oracle Non-CDB detectat');
        DBMS_OUTPUT.PUT_LINE('   Nu ai nevoie de PDB - poți crea utilizatorul direct');
        DBMS_OUTPUT.PUT_LINE('   Rulează: @00_CREARE_UTILIZATOR.sql');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ Oracle Multitenant (CDB) detectat');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('PDB-uri disponibile:');
        DBMS_OUTPUT.PUT_LINE('');
    END IF;
END;
/

-- Listare PDB-uri
SELECT 
    name AS Nume_PDB,
    open_mode AS Status,
    CASE 
        WHEN open_mode = 'READ WRITE' THEN '✅ Disponibil'
        WHEN open_mode = 'MOUNTED' THEN '⚠️  Montat (trebuie deschis)'
        ELSE '❌ ' || open_mode
    END AS Disponibilitate
FROM v$pdbs
ORDER BY name;

PROMPT
PROMPT =====================================================
PROMPT INSTRUCȚIUNI:
PROMPT =====================================================
PROMPT

DECLARE
    v_pdb_count NUMBER;
    v_open_pdb_count NUMBER;
    v_pdb_name VARCHAR2(128);
BEGIN
    SELECT COUNT(*) INTO v_pdb_count FROM v$pdbs;
    SELECT COUNT(*) INTO v_open_pdb_count FROM v$pdbs WHERE open_mode = 'READ WRITE';
    
    IF v_pdb_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Nu există PDB-uri în sistem');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SOLUȚIE:');
        DBMS_OUTPUT.PUT_LINE('   Poți crea un PDB nou SAU');
        DBMS_OUTPUT.PUT_LINE('   Poți folosi utilizatorul c##moneyshop în CDB$ROOT');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('   Pentru a crea PDB nou:');
        DBMS_OUTPUT.PUT_LINE('   CREATE PLUGGABLE DATABASE moneyshop_pdb');
        DBMS_OUTPUT.PUT_LINE('   ADMIN USER moneyshop_admin IDENTIFIED BY parola123;');
        DBMS_OUTPUT.PUT_LINE('   ALTER PLUGGABLE DATABASE moneyshop_pdb OPEN;');
    ELSIF v_open_pdb_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Există PDB-uri, dar niciunul nu este deschis');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SOLUȚIE: Deschide un PDB:');
        
        FOR rec IN (
            SELECT name FROM v$pdbs WHERE ROWNUM = 1
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('   ALTER PLUGGABLE DATABASE ' || rec.name || ' OPEN;');
            DBMS_OUTPUT.PUT_LINE('   ALTER SESSION SET CONTAINER = ' || rec.name || ';');
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ PDB-uri disponibile găsite!');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SOLUȚIE: Mută-te într-unul dintre PDB-urile de mai sus:');
        DBMS_OUTPUT.PUT_LINE('');
        
        FOR rec IN (
            SELECT name FROM v$pdbs WHERE open_mode = 'READ WRITE' AND ROWNUM = 1
        ) LOOP
            v_pdb_name := rec.name;
            DBMS_OUTPUT.PUT_LINE('   ALTER SESSION SET CONTAINER = ' || v_pdb_name || ';');
            DBMS_OUTPUT.PUT_LINE('   @00_CREARE_UTILIZATOR.sql');
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SAU continuă cu utilizatorul c##moneyshop în CDB$ROOT');
        DBMS_OUTPUT.PUT_LINE('(deși nu este recomandat pentru proiecte)');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

