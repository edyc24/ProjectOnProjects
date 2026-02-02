-- =====================================================
-- CREARE UTILIZATOR ȘI CONFIGURARE SCHEMA
-- MoneyShop - Oracle Database
-- =====================================================
-- 
-- IMPORTANT: Acest script trebuie rulat ca SYSDBA
-- 
-- Ce face:
-- 1. Creează utilizatorul MONEYSHOP
-- 2. Acordă privilegii necesare
-- 3. Configurează tablespace-ul
-- 
-- =====================================================

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT CREARE UTILIZATOR MONEYSHOP
PROMPT =====================================================
PROMPT

-- Verificare dacă suntem conectați ca SYSDBA și container
DECLARE
    v_user VARCHAR2(128);
    v_is_dba NUMBER;
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
BEGIN
    v_user := USER;
    
    -- Verificare dacă e CDB
    SELECT COUNT(*) INTO v_is_cdb
    FROM v$database
    WHERE cdb = 'YES';
    
    -- Verificare container curent
    BEGIN
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
    EXCEPTION
        WHEN OTHERS THEN
            v_container := 'N/A';
    END;
    
    SELECT COUNT(*) INTO v_is_dba
    FROM user_role_privs
    WHERE granted_role = 'DBA';
    
    IF v_user != 'SYS' AND v_is_dba = 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ EROARE: Trebuie să fii conectat ca SYSDBA!');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Conectează-te astfel:');
        DBMS_OUTPUT.PUT_LINE('  CONNECT sys AS SYSDBA;');
        DBMS_OUTPUT.PUT_LINE('  -- SAU');
        DBMS_OUTPUT.PUT_LINE('  CONNECT / AS SYSDBA;');
        RAISE_APPLICATION_ERROR(-20000, 'Trebuie să fii conectat ca SYSDBA!');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✅ Ești conectat ca SYSDBA');
    DBMS_OUTPUT.PUT_LINE('   Container: ' || v_container);
    
    -- Dacă e CDB și suntem în CDB$ROOT, trebuie să ne mutăm în PDB
    IF v_is_cdb > 0 THEN
        BEGIN
            SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
            IF v_container = 'CDB$ROOT' THEN
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('⚠️  Ești în CDB$ROOT. Trebuie să te muți într-un PDB.');
                DBMS_OUTPUT.PUT_LINE('   Caut PDB-uri disponibile...');
                
                -- Listare PDB-uri
                FOR rec IN (
                    SELECT name, open_mode 
                    FROM v$pdbs 
                    WHERE open_mode = 'READ WRITE'
                    ORDER BY name
                ) LOOP
                    DBMS_OUTPUT.PUT_LINE('   PDB disponibil: ' || rec.name);
                END LOOP;
                
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('SOLUȚIE: Mută-te într-un PDB:');
                DBMS_OUTPUT.PUT_LINE('   ALTER SESSION SET CONTAINER = XEPDB1;');
                DBMS_OUTPUT.PUT_LINE('   -- SAU alt PDB disponibil');
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('Apoi rulează din nou acest script.');
                RAISE_APPLICATION_ERROR(-20001, 'Trebuie să fii într-un PDB, nu în CDB$ROOT!');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Ștergere utilizator dacă există (opțional - pentru reconfigurare)
DECLARE
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
    v_username_to_drop VARCHAR2(128);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Verificare dacă utilizatorul MONEYSHOP există...');
    
    -- Determinare nume utilizator în funcție de container
    BEGIN
        SELECT COUNT(*) INTO v_is_cdb
        FROM v$database
        WHERE cdb = 'YES';
        
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
        
        IF v_is_cdb > 0 AND v_container = 'CDB$ROOT' THEN
            v_username_to_drop := 'c##moneyshop';
        ELSE
            v_username_to_drop := 'moneyshop';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_username_to_drop := 'moneyshop';
    END;
    
    -- Încearcă să șteargă utilizatorul
    BEGIN
        EXECUTE IMMEDIATE 'DROP USER ' || v_username_to_drop || ' CASCADE';
        DBMS_OUTPUT.PUT_LINE('⚠️  Utilizatorul ' || v_username_to_drop || ' a existat și a fost șters');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1918 THEN
                DBMS_OUTPUT.PUT_LINE('✅ Utilizatorul ' || v_username_to_drop || ' nu există (OK)');
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠️  Eroare la ștergere: ' || SUBSTR(SQLERRM, 1, 100));
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Creare utilizator
DECLARE
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creare utilizator MONEYSHOP...');
    
    -- Verificare dacă e CDB
    BEGIN
        SELECT COUNT(*) INTO v_is_cdb
        FROM v$database
        WHERE cdb = 'YES';
        
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
    EXCEPTION
        WHEN OTHERS THEN
            v_is_cdb := 0;
            v_container := 'N/A';
    END;
    
    -- Dacă suntem în CDB$ROOT, folosim prefixul C##
    IF v_is_cdb > 0 AND v_container = 'CDB$ROOT' THEN
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER c##moneyshop IDENTIFIED BY moneyshop123';
            DBMS_OUTPUT.PUT_LINE('✅ Utilizator C##MONEYSHOP creat (CDB)');
            DBMS_OUTPUT.PUT_LINE('   Nume complet: C##MONEYSHOP');
            DBMS_OUTPUT.PUT_LINE('   Parolă: moneyshop123');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('⚠️  NOTĂ: În CDB, utilizatorul este C##MONEYSHOP');
            DBMS_OUTPUT.PUT_LINE('   Pentru a te conecta: CONNECT c##moneyshop/moneyshop123;');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('❌ EROARE la creare utilizator: ' || SQLERRM);
                RAISE;
        END;
    ELSE
        -- În PDB sau non-CDB, creăm utilizator normal
        BEGIN
            EXECUTE IMMEDIATE 'CREATE USER moneyshop IDENTIFIED BY moneyshop123';
            DBMS_OUTPUT.PUT_LINE('✅ Utilizator MONEYSHOP creat (PDB/Local)');
            DBMS_OUTPUT.PUT_LINE('   Parolă: moneyshop123');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('❌ EROARE la creare utilizator: ' || SQLERRM);
                RAISE;
        END;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Acordare privilegii de bază
DECLARE
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
    v_username VARCHAR2(128);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Acordare privilegii...');
    
    -- Determinare nume utilizator (C## sau normal)
    BEGIN
        SELECT COUNT(*) INTO v_is_cdb
        FROM v$database
        WHERE cdb = 'YES';
        
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
        
        IF v_is_cdb > 0 AND v_container = 'CDB$ROOT' THEN
            v_username := 'c##moneyshop';
        ELSE
            v_username := 'moneyshop';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_username := 'moneyshop';
    END;
    
    DBMS_OUTPUT.PUT_LINE('   Utilizator: ' || v_username);
    
    -- Acordare roluri
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ CONNECT acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  CONNECT: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'GRANT RESOURCE TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ RESOURCE acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  RESOURCE: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    -- Acordare privilegii sistem
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ CREATE TRIGGER acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  CREATE TRIGGER: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ CREATE VIEW acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  CREATE VIEW: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ CREATE PROCEDURE acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  CREATE PROCEDURE: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CREATE FUNCTION TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ CREATE FUNCTION acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  CREATE FUNCTION: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ CREATE SEQUENCE acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  CREATE SEQUENCE: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CREATE TYPE TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('   ✅ CREATE TYPE acordat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  CREATE TYPE: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    -- UNLIMITED TABLESPACE nu mai este valid în Oracle 12c+
    -- Folosim ALTER USER ... QUOTA UNLIMITED ON tablespace
    BEGIN
        DECLARE
            v_default_tablespace VARCHAR2(128);
        BEGIN
            -- Obține tablespace-ul implicit
            SELECT property_value INTO v_default_tablespace
            FROM database_properties
            WHERE property_name = 'DEFAULT_PERMANENT_TABLESPACE';
            
            -- Acordă quota nelimitată
            EXECUTE IMMEDIATE 'ALTER USER ' || v_username || ' QUOTA UNLIMITED ON ' || v_default_tablespace;
            DBMS_OUTPUT.PUT_LINE('   ✅ QUOTA UNLIMITED acordată pe ' || v_default_tablespace);
        EXCEPTION
            WHEN OTHERS THEN
                -- Dacă nu găsește tablespace-ul, încearcă cu USERS (cel mai comun)
                BEGIN
                    EXECUTE IMMEDIATE 'ALTER USER ' || v_username || ' QUOTA UNLIMITED ON USERS';
                    DBMS_OUTPUT.PUT_LINE('   ✅ QUOTA UNLIMITED acordată pe USERS');
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('   ⚠️  QUOTA: ' || SUBSTR(SQLERRM, 1, 80));
                        DBMS_OUTPUT.PUT_LINE('      (Poți acorda manual: ALTER USER ' || v_username || ' QUOTA UNLIMITED ON tablespace_name)');
                END;
        END;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('   ⚠️  EROARE la acordare QUOTA: ' || SUBSTR(SQLERRM, 1, 80));
    END;
    
    -- Privilegii pentru DBMS_CRYPTO (pentru criptare)
    BEGIN
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('✅ Privilegii DBMS_CRYPTO acordate');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Nu s-au putut acorda privilegii DBMS_CRYPTO: ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    -- Privilegii pentru DBMS_FGA (pentru auditare - opțional)
    BEGIN
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.DBMS_FGA TO ' || v_username;
        DBMS_OUTPUT.PUT_LINE('✅ Privilegii DBMS_FGA acordate');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Nu s-au putut acorda privilegii DBMS_FGA (opțional): ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    DBMS_OUTPUT.PUT_LINE('✅ Toate privilegiile au fost acordate');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Verificare finală
DECLARE
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
    v_username VARCHAR2(128);
BEGIN
    -- Determinare nume utilizator
    BEGIN
        SELECT COUNT(*) INTO v_is_cdb
        FROM v$database
        WHERE cdb = 'YES';
        
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
        
        IF v_is_cdb > 0 AND v_container = 'CDB$ROOT' THEN
            v_username := 'c##moneyshop';
        ELSE
            v_username := 'moneyshop';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_username := 'moneyshop';
    END;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('✅ UTILIZATOR CREAT CU SUCCES!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorii pași:');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('1. Conectează-te cu utilizatorul nou:');
    DBMS_OUTPUT.PUT_LINE('   CONNECT ' || v_username || '/moneyshop123;');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. Rulează scripturile în ordine:');
    DBMS_OUTPUT.PUT_LINE('   @03_CREATE_TABLES.sql');
    DBMS_OUTPUT.PUT_LINE('   @17_POPULARE_DATE_TEST.sql');
    DBMS_OUTPUT.PUT_LINE('   @04_SECURITATE.sql');
    DBMS_OUTPUT.PUT_LINE('   @05_CRIPTARE.sql');
    DBMS_OUTPUT.PUT_LINE('   @06_AUDITARE_SAFE.sql');
    DBMS_OUTPUT.PUT_LINE('   -- etc.');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

