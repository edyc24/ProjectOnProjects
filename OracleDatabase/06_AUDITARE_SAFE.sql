-- =====================================================
-- Auditarea Activităților - MoneyShop (VERSIUNE SIGURĂ)
-- Oracle Database 19c+
-- =====================================================
-- 
-- Această versiune verifică schema înainte de a crea triggerii
-- și gestionează erorile de privilegii
--
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. VERIFICARE SCHEMA ȘI UTILIZATOR
-- =====================================================

DECLARE
    v_user VARCHAR2(128);
    v_schema VARCHAR2(128);
    v_tables_in_sys NUMBER;
    v_audit_log_exists NUMBER;
BEGIN
    v_user := USER;
    v_schema := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
    
    -- Verificare dacă suntem în SYS
    IF v_user = 'SYS' OR v_schema = 'SYS' THEN
        DBMS_OUTPUT.PUT_LINE('❌ EROARE: Nu poți crea triggeri când ești conectat ca SYS!');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SOLUȚIE:');
        DBMS_OUTPUT.PUT_LINE('1. Deconectează-te din SYS');
        DBMS_OUTPUT.PUT_LINE('2. Creează un utilizator nou:');
        DBMS_OUTPUT.PUT_LINE('   CREATE USER moneyshop IDENTIFIED BY parola123;');
        DBMS_OUTPUT.PUT_LINE('   GRANT CONNECT, RESOURCE TO moneyshop;');
        DBMS_OUTPUT.PUT_LINE('3. Conectează-te cu utilizatorul nou');
        DBMS_OUTPUT.PUT_LINE('4. Rulează din nou acest script');
        RAISE_APPLICATION_ERROR(-20000, 'Nu poți crea triggeri în schema SYS!');
    END IF;
    
    -- Verificare dacă tabelele sunt în SYS
    SELECT COUNT(*) INTO v_tables_in_sys
    FROM all_tables
    WHERE table_name IN ('UTILIZATORI', 'APLICATII', 'DOCUMENTE')
      AND owner = 'SYS';
    
    IF v_tables_in_sys > 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ EROARE: Tabelele sunt în schema SYS!');
        DBMS_OUTPUT.PUT_LINE('   Trebuie să fie în schema ta: ' || v_user);
        RAISE_APPLICATION_ERROR(-20001, 'Tabelele sunt în schema SYS!');
    END IF;
    
    -- Verificare existență tabel AUDIT_LOG
    SELECT COUNT(*) INTO v_audit_log_exists
    FROM user_tables
    WHERE table_name = 'AUDIT_LOG';
    
    IF v_audit_log_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  ATENȚIE: Tabelul AUDIT_LOG nu există!');
        DBMS_OUTPUT.PUT_LINE('   Rulează mai întâi 03_CREATE_TABLES.sql');
        RAISE_APPLICATION_ERROR(-20002, 'Tabelul AUDIT_LOG nu există. Rulează 03_CREATE_TABLES.sql mai întâi.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✅ Verificare schema: OK');
    DBMS_OUTPUT.PUT_LINE('   Utilizator: ' || v_user);
    DBMS_OUTPUT.PUT_LINE('   Schema: ' || v_schema);
    DBMS_OUTPUT.PUT_LINE('   Tabelul AUDIT_LOG există');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 2. Trigger-i de Auditare
-- =====================================================

-- Funcție helper pentru serializare JSON simplă
CREATE OR REPLACE FUNCTION fn_serialize_values (
    p_old_values IN VARCHAR2,
    p_new_values IN VARCHAR2
) RETURN CLOB
IS
    v_result CLOB;
BEGIN
    v_result := '{';
    IF p_old_values IS NOT NULL THEN
        v_result := v_result || '"old":' || p_old_values || ',';
    END IF;
    IF p_new_values IS NOT NULL THEN
        v_result := v_result || '"new":' || p_new_values;
    END IF;
    v_result := v_result || '}';
    RETURN v_result;
END;
/

-- Trigger auditare pentru UTILIZATORI
CREATE OR REPLACE TRIGGER trg_audit_utilizatori
AFTER INSERT OR UPDATE OR DELETE ON UTILIZATORI
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_user_id NUMBER;
BEGIN
    -- Determinare operație
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_values := '{"IdUtilizator":' || :NEW.IdUtilizator || 
                       ',"Email":"' || :NEW.Email || 
                       '","IdRol":' || :NEW.IdRol || '}';
        v_user_id := :NEW.IdUtilizator;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := '{"IdUtilizator":' || :OLD.IdUtilizator || 
                       ',"Email":"' || :OLD.Email || 
                       ',"IdRol":' || :OLD.IdRol || '}';
        v_new_values := '{"IdUtilizator":' || :NEW.IdUtilizator || 
                       ',"Email":"' || :NEW.Email || 
                       ',"IdRol":' || :NEW.IdRol || '}';
        v_user_id := :NEW.IdUtilizator;
    ELSE
        v_operation := 'DELETE';
        v_old_values := '{"IdUtilizator":' || :OLD.IdUtilizator || 
                       ',"Email":"' || :OLD.Email || 
                       ',"IdRol":' || :OLD.IdRol || '}';
        v_user_id := :OLD.IdUtilizator;
    END IF;
    
    -- Inserare în audit log
    INSERT INTO AUDIT_LOG (
        TableName,
        Operation,
        UserId,
        OldValues,
        NewValues,
        IpAddress,
        Timestamp
    ) VALUES (
        'UTILIZATORI',
        v_operation,
        v_user_id,
        v_old_values,
        v_new_values,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN
        -- Nu ridicăm excepții în trigger pentru a nu bloca operațiile
        NULL;
END;
/

-- Trigger auditare pentru APLICATII
CREATE OR REPLACE TRIGGER trg_audit_aplicatii
AFTER INSERT OR UPDATE OR DELETE ON APLICATII
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_values := '{"Id":' || :NEW.Id || 
                       ',"UserId":' || :NEW.UserId || 
                       ',"Status":"' || :NEW.Status || 
                       ',"Scoring":' || NVL(:NEW.Scoring, 0) || '}';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := '{"Id":' || :OLD.Id || 
                       ',"Status":"' || :OLD.Status || 
                       ',"Scoring":' || NVL(:OLD.Scoring, 0) || '}';
        v_new_values := '{"Id":' || :NEW.Id || 
                       ',"Status":"' || :NEW.Status || 
                       ',"Scoring":' || NVL(:NEW.Scoring, 0) || '}';
    ELSE
        v_operation := 'DELETE';
        v_old_values := '{"Id":' || :OLD.Id || '}';
    END IF;
    
    INSERT INTO AUDIT_LOG (
        TableName,
        Operation,
        UserId,
        OldValues,
        NewValues,
        IpAddress,
        Timestamp
    ) VALUES (
        'APLICATII',
        v_operation,
        NVL(:NEW.UserId, :OLD.UserId),
        v_old_values,
        v_new_values,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger auditare pentru DOCUMENTE
CREATE OR REPLACE TRIGGER trg_audit_documente
AFTER INSERT OR UPDATE OR DELETE ON DOCUMENTE
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_user_id NUMBER;
BEGIN
    -- Obținere UserId din ApplicationId
    BEGIN
        IF INSERTING OR UPDATING THEN
            SELECT UserId INTO v_user_id
            FROM APLICATII
            WHERE Id = :NEW.ApplicationId;
        ELSE
            SELECT UserId INTO v_user_id
            FROM APLICATII
            WHERE Id = :OLD.ApplicationId;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_user_id := NULL;
    END;
    
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_values := '{"Id":' || :NEW.Id || 
                       ',"ApplicationId":' || :NEW.ApplicationId || 
                       ',"TipDocument":"' || :NEW.TipDocument || '}';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := '{"Id":' || :OLD.Id || '}';
        v_new_values := '{"Id":' || :NEW.Id || '}';
    ELSE
        v_operation := 'DELETE';
        v_old_values := '{"Id":' || :OLD.Id || '}';
    END IF;
    
    INSERT INTO AUDIT_LOG (
        TableName,
        Operation,
        UserId,
        OldValues,
        NewValues,
        IpAddress,
        Timestamp
    ) VALUES (
        'DOCUMENTE',
        v_operation,
        v_user_id,
        v_old_values,
        v_new_values,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Trigger auditare pentru CONSENTURI
CREATE OR REPLACE TRIGGER trg_audit_consenturi
AFTER INSERT OR UPDATE OR DELETE ON CONSENTURI
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_values := '{"Id":' || :NEW.Id || 
                       ',"UserId":' || :NEW.UserId || 
                       ',"TipConsent":"' || :NEW.TipConsent || 
                       ',"Status":"' || :NEW.Status || '}';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := '{"Status":"' || :OLD.Status || '}';
        v_new_values := '{"Status":"' || :NEW.Status || '}';
    ELSE
        v_operation := 'DELETE';
        v_old_values := '{"Id":' || :OLD.Id || '}';
    END IF;
    
    INSERT INTO AUDIT_LOG (
        TableName,
        Operation,
        UserId,
        OldValues,
        NewValues,
        IpAddress,
        Timestamp
    ) VALUES (
        'CONSENTURI',
        v_operation,
        NVL(:NEW.UserId, :OLD.UserId),
        v_old_values,
        v_new_values,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYSTIMESTAMP
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- =====================================================
-- 3. Fine-Grained Audit Policies (FGA) - OPȚIONAL
-- =====================================================

BEGIN
    -- Verificare privilegii pentru FGA
    DECLARE
        v_has_privilege NUMBER := 0;
    BEGIN
        -- Testare dacă avem acces la DBMS_FGA
        BEGIN
            DBMS_FGA.ADD_POLICY(
                object_schema   => USER,
                object_name     => 'APLICATII',
                policy_name     => 'FGA_TEST_TEMP',
                audit_condition => '1=0',
                audit_column    => NULL,
                enable          => FALSE
            );
            DBMS_FGA.DROP_POLICY(USER, 'APLICATII', 'FGA_TEST_TEMP');
            v_has_privilege := 1;
        EXCEPTION
            WHEN OTHERS THEN
                v_has_privilege := 0;
        END;
        
        IF v_has_privilege = 0 THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Nu ai privilegii pentru Fine-Grained Audit (FGA)');
            DBMS_OUTPUT.PUT_LINE('   Politicile FGA vor fi omise. Triggerii de auditare funcționează normal.');
        ELSE
            -- Politică FGA pentru acces la date financiare sensibile
            BEGIN
                DBMS_FGA.ADD_POLICY(
                    object_schema   => USER,
                    object_name     => 'APLICATII',
                    policy_name     => 'FGA_APLICATII_FINANCIARE',
                    audit_condition => 'Scoring IS NOT NULL OR SumaAprobata IS NOT NULL',
                    audit_column    => 'Scoring,SumaAprobata,SalariuNet',
                    handler_schema  => NULL,
                    handler_module  => NULL,
                    enable          => TRUE,
                    statement_types => 'SELECT,UPDATE'
                );
                DBMS_OUTPUT.PUT_LINE('✅ Politică FGA pentru APLICATII creată');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('⚠️  Nu s-a putut crea politica FGA pentru APLICATII: ' || SUBSTR(SQLERRM, 1, 100));
            END;
            
            -- Politică FGA pentru acces la date utilizatori sensibile
            BEGIN
                DBMS_FGA.ADD_POLICY(
                    object_schema   => USER,
                    object_name     => 'UTILIZATORI',
                    policy_name     => 'FGA_UTILIZATORI_SENSIBILE',
                    audit_condition => 'Email IS NOT NULL OR NumarTelefon IS NOT NULL',
                    audit_column    => 'Email,NumarTelefon,DataNastere',
                    handler_schema  => NULL,
                    handler_module  => NULL,
                    enable          => TRUE,
                    statement_types => 'SELECT,UPDATE'
                );
                DBMS_OUTPUT.PUT_LINE('✅ Politică FGA pentru UTILIZATORI creată');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('⚠️  Nu s-a putut crea politica FGA pentru UTILIZATORI: ' || SUBSTR(SQLERRM, 1, 100));
            END;
        END IF;
    END;
END;
/

-- =====================================================
-- 4. View-uri pentru raportare audit
-- =====================================================

CREATE OR REPLACE VIEW vw_audit_log_recent AS
SELECT 
    Id,
    TableName,
    Operation,
    UserId,
    IpAddress,
    Timestamp,
    EXTRACT(DAY FROM (SYSTIMESTAMP - Timestamp)) AS DaysAgo,
    EXTRACT(HOUR FROM (SYSTIMESTAMP - Timestamp)) AS HoursAgo
FROM AUDIT_LOG
WHERE Timestamp >= SYSTIMESTAMP - INTERVAL '30' DAY
ORDER BY Timestamp DESC;

CREATE OR REPLACE VIEW vw_audit_statistics AS
SELECT 
    TableName,
    Operation,
    COUNT(*) AS Count,
    MIN(Timestamp) AS FirstOccurrence,
    MAX(Timestamp) AS LastOccurrence
FROM AUDIT_LOG
WHERE Timestamp >= SYSTIMESTAMP - INTERVAL '7' DAY
GROUP BY TableName, Operation
ORDER BY TableName, Operation;

-- =====================================================
-- 5. Verificare finală
-- =====================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('✅ Sistemul de auditare a fost configurat!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Triggeri creați:');
    DBMS_OUTPUT.PUT_LINE('  ✅ trg_audit_utilizatori');
    DBMS_OUTPUT.PUT_LINE('  ✅ trg_audit_aplicatii');
    DBMS_OUTPUT.PUT_LINE('  ✅ trg_audit_documente');
    DBMS_OUTPUT.PUT_LINE('  ✅ trg_audit_consenturi');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Verificare triggeri:');
    
    FOR rec IN (
        SELECT trigger_name, table_name, status 
        FROM user_triggers 
        WHERE trigger_name LIKE 'TRG_AUDIT%'
        ORDER BY trigger_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ✅ ' || rec.trigger_name || ' pe ' || rec.table_name || ' - ' || rec.status);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

