-- =====================================================
-- SETUP PDB - Mutare în PDB pentru Oracle Multitenant
-- =====================================================
-- 
-- Dacă ai Oracle 12c+ (multitenant), trebuie să te muți
-- într-un PDB înainte de a crea utilizatorul
--
-- =====================================================

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT SETUP PDB - Oracle Multitenant
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
    DBMS_OUTPUT.PUT_LINE('');
    
    IF v_is_cdb > 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Oracle Multitenant detectat (CDB)');
        DBMS_OUTPUT.PUT_LINE('');
        
        IF v_container = 'CDB$ROOT' THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Ești în CDB$ROOT');
            DBMS_OUTPUT.PUT_LINE('   Trebuie să te muți într-un PDB');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('PDB-uri disponibile:');
            
            FOR rec IN (
                SELECT name, open_mode 
                FROM v$pdbs 
                ORDER BY name
            ) LOOP
                DBMS_OUTPUT.PUT_LINE('   - ' || rec.name || ' (' || rec.open_mode || ')');
            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('SOLUȚIE:');
            DBMS_OUTPUT.PUT_LINE('   ALTER SESSION SET CONTAINER = XEPDB1;');
            DBMS_OUTPUT.PUT_LINE('   -- SAU alt PDB disponibil');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('   Apoi rulează:');
            DBMS_OUTPUT.PUT_LINE('   @00_CREARE_UTILIZATOR.sql');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ Ești deja într-un PDB: ' || v_container);
            DBMS_OUTPUT.PUT_LINE('   Poți continua cu crearea utilizatorului');
            DBMS_OUTPUT.PUT_LINE('   @00_CREARE_UTILIZATOR.sql');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ Oracle Non-CDB (versiune veche)');
        DBMS_OUTPUT.PUT_LINE('   Poți continua direct cu crearea utilizatorului');
        DBMS_OUTPUT.PUT_LINE('   @00_CREARE_UTILIZATOR.sql');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

