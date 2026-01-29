-- =====================================================
-- Auditarea Activităților - MoneyShop
-- Oracle Database 19c+
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. Auditare Standard Oracle
-- =====================================================

-- Activare auditare standard (necesită privilegii DBA)
-- Aceste comenzi trebuie executate de SYSDBA:

/*
-- Auditare pentru operațiuni pe tabele critice
AUDIT SELECT, INSERT, UPDATE, DELETE ON MONEYSHOP.UTILIZATORI;
AUDIT SELECT, INSERT, UPDATE, DELETE ON MONEYSHOP.APLICATII;
AUDIT SELECT, INSERT, UPDATE, DELETE ON MONEYSHOP.DOCUMENTE;
AUDIT SELECT, INSERT, UPDATE, DELETE ON MONEYSHOP.CONSENTURI;
AUDIT SELECT, INSERT, UPDATE, DELETE ON MONEYSHOP.MANDATE;

-- Auditare pentru operațiuni DDL
AUDIT CREATE TABLE, DROP TABLE, ALTER TABLE;
AUDIT CREATE USER, DROP USER, ALTER USER;
AUDIT GRANT, REVOKE;

-- Auditare pentru autentificări
AUDIT SESSION;

-- Auditare pentru proceduri stocate
AUDIT EXECUTE ON PROCEDURE MONEYSHOP.SP_AUTENTIFICARE_UTILIZATOR;
AUDIT EXECUTE ON PROCEDURE MONEYSHOP.SP_SCHIMBARE_PAROLA;
*/

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
                       '","IdRol":' || :OLD.IdRol || '}';
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
        :NEW.UserId,
        v_old_values,
        v_new_values,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYSTIMESTAMP
    );
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
    SELECT UserId INTO v_user_id
    FROM APLICATII
    WHERE Id = :NEW.ApplicationId;
    
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
        
        SELECT UserId INTO v_user_id
        FROM APLICATII
        WHERE Id = :OLD.ApplicationId;
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
        :NEW.UserId,
        v_old_values,
        v_new_values,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYSTIMESTAMP
    );
END;
/

-- =====================================================
-- 3. Fine-Grained Audit Policies (FGA)
-- =====================================================

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
END;
/

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
END;
/

-- Politică FGA pentru acces la documente
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'DOCUMENTE',
        policy_name     => 'FGA_DOCUMENTE_ACCES',
        audit_condition => '1=1',
        audit_column    => 'Path',
        handler_schema  => NULL,
        handler_module  => NULL,
        enable          => TRUE,
        statement_types => 'SELECT'
    );
END;
/

-- =====================================================
-- 4. View-uri pentru raportare audit
-- =====================================================

-- View pentru audit log recent
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

-- View pentru statistici audit
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

-- View pentru utilizatori cu cele mai multe operațiuni
CREATE OR REPLACE VIEW vw_audit_top_users AS
SELECT 
    UserId,
    COUNT(*) AS OperationCount,
    COUNT(DISTINCT TableName) AS TablesAccessed,
    MIN(Timestamp) AS FirstActivity,
    MAX(Timestamp) AS LastActivity
FROM AUDIT_LOG
WHERE Timestamp >= SYSTIMESTAMP - INTERVAL '30' DAY
  AND UserId IS NOT NULL
GROUP BY UserId
ORDER BY OperationCount DESC;

-- =====================================================
-- 5. Proceduri pentru raportare audit
-- =====================================================

-- Procedură pentru raport audit utilizator
CREATE OR REPLACE PROCEDURE sp_audit_report_user (
    p_user_id IN NUMBER,
    p_days_back IN NUMBER DEFAULT 30
)
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM AUDIT_LOG
    WHERE UserId = p_user_id
      AND Timestamp >= SYSTIMESTAMP - INTERVAL '1' DAY * p_days_back;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Raport Audit pentru Utilizator: ' || p_user_id);
    DBMS_OUTPUT.PUT_LINE('Perioada: Ultimele ' || p_days_back || ' zile');
    DBMS_OUTPUT.PUT_LINE('Total operațiuni: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    FOR rec IN (
        SELECT TableName, Operation, COUNT(*) AS Count
        FROM AUDIT_LOG
        WHERE UserId = p_user_id
          AND Timestamp >= SYSTIMESTAMP - INTERVAL '1' DAY * p_days_back
        GROUP BY TableName, Operation
        ORDER BY TableName, Operation
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.TableName || ' - ' || rec.Operation || ': ' || rec.Count);
    END LOOP;
END;
/

-- Procedură pentru curățare audit log vechi
CREATE OR REPLACE PROCEDURE sp_cleanup_audit_log (
    p_days_to_keep IN NUMBER DEFAULT 365
)
IS
    v_deleted NUMBER;
BEGIN
    DELETE FROM AUDIT_LOG
    WHERE Timestamp < SYSTIMESTAMP - INTERVAL '1' DAY * p_days_to_keep;
    
    v_deleted := SQL%ROWCOUNT;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Au fost șterse ' || v_deleted || ' înregistrări de audit mai vechi de ' || p_days_to_keep || ' zile');
END;
/

-- =====================================================
-- 6. Verificare auditare
-- =====================================================

-- Test trigger auditare
-- INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol)
-- VALUES ('Test', 'User', 'testuser', 'test@test.com', 'hash123', DATE '1990-01-01', 1);
-- 
-- SELECT * FROM AUDIT_LOG WHERE TableName = 'UTILIZATORI' ORDER BY Timestamp DESC;

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Sistemul de auditare a fost configurat!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Componente activate:');
    DBMS_OUTPUT.PUT_LINE('  - Trigger-i de auditare pentru tabele critice');
    DBMS_OUTPUT.PUT_LINE('  - Fine-Grained Audit Policies (FGA)');
    DBMS_OUTPUT.PUT_LINE('  - View-uri pentru raportare');
    DBMS_OUTPUT.PUT_LINE('  - Proceduri pentru raportare și curățare');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('NOTĂ: Pentru auditare standard Oracle,');
    DBMS_OUTPUT.PUT_LINE('este necesară configurarea de către DBA.');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

