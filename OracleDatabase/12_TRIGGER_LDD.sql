-- =====================================================
-- TRIGGER LDD (DATA DEFINITION LANGUAGE)
-- Proiect SBD - Cerința 9.6
-- =====================================================

SET SERVEROUTPUT ON;

-- Trigger LDD care se declanșează la crearea, modificarea sau ștergerea obiectelor
-- în schema curentă
CREATE OR REPLACE TRIGGER trg_audit_ddl
AFTER CREATE OR ALTER OR DROP ON SCHEMA
DECLARE
    v_event_type VARCHAR2(30);
    v_object_type VARCHAR2(30);
    v_object_name VARCHAR2(128);
    v_object_owner VARCHAR2(128);
    v_sql_text ORA_NAME_LIST_T;
    v_sql_text_full VARCHAR2(4000) := '';
    v_i NUMBER;
BEGIN
    -- Determinare tip eveniment
    IF ORA_SYSEVENT = 'CREATE' THEN
        v_event_type := 'CREATE';
    ELSIF ORA_SYSEVENT = 'ALTER' THEN
        v_event_type := 'ALTER';
    ELSIF ORA_SYSEVENT = 'DROP' THEN
        v_event_type := 'DROP';
    ELSE
        v_event_type := ORA_SYSEVENT;
    END IF;
    
    -- Obținere informații despre obiect
    v_object_type := ORA_DICT_OBJ_TYPE;
    v_object_name := ORA_DICT_OBJ_NAME;
    v_object_owner := ORA_DICT_OBJ_OWNER;
    
    -- Obținere text SQL complet
    v_sql_text := ORA_SQL_TXT;
    IF v_sql_text.COUNT > 0 THEN
        FOR v_i IN 1..v_sql_text.COUNT LOOP
            v_sql_text_full := v_sql_text_full || v_sql_text(v_i);
        END LOOP;
    END IF;
    
    -- Inserare în tabelul de audit (sau afișare)
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TRIGGER LDD DECLANSAT');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Eveniment: ' || v_event_type);
    DBMS_OUTPUT.PUT_LINE('Tip obiect: ' || v_object_type);
    DBMS_OUTPUT.PUT_LINE('Nume obiect: ' || v_object_name);
    DBMS_OUTPUT.PUT_LINE('Proprietar: ' || v_object_owner);
    DBMS_OUTPUT.PUT_LINE('Utilizator: ' || USER);
    DBMS_OUTPUT.PUT_LINE('Data/Ora: ' || TO_CHAR(SYSDATE, 'DD-MM-YYYY HH24:MI:SS'));
    IF LENGTH(v_sql_text_full) > 0 THEN
        DBMS_OUTPUT.PUT_LINE('SQL: ' || SUBSTR(v_sql_text_full, 1, 200));
    END IF;
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Inserare în tabelul MESAJE (dacă există)
    BEGIN
        INSERT INTO MESAJE (
            cod_mesaj,
            mesaj,
            tip_mesaj,
            creat_de,
            creat_la
        ) VALUES (
            seq_mesaje.NEXTVAL,
            'DDL Event: ' || v_event_type || ' ' || v_object_type || ' ' || v_object_name,
            'I',
            USER,
            SYSDATE
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Dacă tabelul MESAJE nu există încă, ignorăm eroarea
            NULL;
    END;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Nu ridicăm excepții în trigger LDD pentru a nu bloca operațiile DDL
        DBMS_OUTPUT.PUT_LINE('EROARE în trigger LDD: ' || SQLERRM);
END;
/

-- Testare trigger LDD
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('TESTARE TRIGGER LDD');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Se va crea un tabel de test pentru a declanșa triggerul...');
END;
/

-- Creare tabel de test (va declanșa triggerul)
CREATE TABLE TEST_TRIGGER_LDD (
    id NUMBER PRIMARY KEY,
    nume VARCHAR2(100)
);

-- Modificare tabel (va declanșa triggerul)
ALTER TABLE TEST_TRIGGER_LDD ADD descriere VARCHAR2(200);

-- Ștergere tabel (va declanșa triggerul)
DROP TABLE TEST_TRIGGER_LDD;

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Testare trigger LDD completată!');
    DBMS_OUTPUT.PUT_LINE('Verifică mesajele de mai sus pentru confirmare.');
END;
/

