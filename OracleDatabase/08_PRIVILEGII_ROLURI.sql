-- =====================================================
-- Privilegii și Roluri - MoneyShop
-- Oracle Database 19c+
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. Crearea Utilizatorilor de Baza de Date
-- =====================================================

-- Notă: Aceste comenzi trebuie executate de SYSDBA

/*
-- Creare utilizator pentru aplicație
CREATE USER moneyshop_app IDENTIFIED BY "SecurePassword123!";
CREATE USER moneyshop_readonly IDENTIFIED BY "ReadOnlyPassword123!";
CREATE USER moneyshop_admin IDENTIFIED BY "AdminPassword123!";

-- Grant privilegii de bază
GRANT CONNECT, RESOURCE TO moneyshop_app;
GRANT CONNECT TO moneyshop_readonly;
GRANT CONNECT, RESOURCE, DBA TO moneyshop_admin;
*/

-- =====================================================
-- 2. Crearea Rolurilor Oracle
-- =====================================================

-- Verificare container și creare roluri corespunzătoare
DECLARE
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
    v_role_prefix VARCHAR2(10) := '';
BEGIN
    -- Verificare dacă e CDB
    BEGIN
        SELECT COUNT(*) INTO v_is_cdb
        FROM v$database
        WHERE cdb = 'YES';
        
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
        
        IF v_is_cdb > 0 AND v_container = 'CDB$ROOT' THEN
            v_role_prefix := 'c##';
            DBMS_OUTPUT.PUT_LINE('⚠️  Ești în CDB$ROOT - rolurile vor avea prefix C##');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ Ești în PDB - rolurile vor fi normale');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_role_prefix := '';
    END;
    
    DBMS_OUTPUT.PUT_LINE('Container: ' || v_container);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Creare roluri (cu prefix dacă e necesar)
DECLARE
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
    v_prefix VARCHAR2(10) := '';
BEGIN
    BEGIN
        SELECT COUNT(*) INTO v_is_cdb
        FROM v$database
        WHERE cdb = 'YES';
        
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
        
        IF v_is_cdb > 0 AND v_container = 'CDB$ROOT' THEN
            v_prefix := 'c##';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_prefix := '';
    END;
    
    -- Rol pentru clienți
    BEGIN
        EXECUTE IMMEDIATE 'CREATE ROLE ' || v_prefix || 'moneyshop_client_role';
        DBMS_OUTPUT.PUT_LINE('✅ Rol ' || v_prefix || 'moneyshop_client_role creat');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1921 THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  Rol ' || v_prefix || 'moneyshop_client_role există deja');
            ELSE
                RAISE;
            END IF;
    END;
    
    -- Rol pentru brokeri
    BEGIN
        EXECUTE IMMEDIATE 'CREATE ROLE ' || v_prefix || 'moneyshop_broker_role';
        DBMS_OUTPUT.PUT_LINE('✅ Rol ' || v_prefix || 'moneyshop_broker_role creat');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1921 THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  Rol ' || v_prefix || 'moneyshop_broker_role există deja');
            ELSE
                RAISE;
            END IF;
    END;
    
    -- Rol pentru administratori
    BEGIN
        EXECUTE IMMEDIATE 'CREATE ROLE ' || v_prefix || 'moneyshop_admin_role';
        DBMS_OUTPUT.PUT_LINE('✅ Rol ' || v_prefix || 'moneyshop_admin_role creat');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1921 THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  Rol ' || v_prefix || 'moneyshop_admin_role există deja');
            ELSE
                RAISE;
            END IF;
    END;
    
    -- Rol pentru citire doar
    BEGIN
        EXECUTE IMMEDIATE 'CREATE ROLE ' || v_prefix || 'moneyshop_readonly_role';
        DBMS_OUTPUT.PUT_LINE('✅ Rol ' || v_prefix || 'moneyshop_readonly_role creat');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1921 THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  Rol ' || v_prefix || 'moneyshop_readonly_role există deja');
            ELSE
                RAISE;
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 3. Privilegii Obiect (pe tabele)
-- =====================================================

-- Privilegii pentru CLIENT
GRANT SELECT ON UTILIZATORI TO moneyshop_client_role;
GRANT SELECT, INSERT, UPDATE ON APLICATII TO moneyshop_client_role;
GRANT SELECT, INSERT ON DOCUMENTE TO moneyshop_client_role;
GRANT SELECT, INSERT ON CONSENTURI TO moneyshop_client_role;
GRANT SELECT, INSERT ON MANDATE TO moneyshop_client_role;
GRANT SELECT, INSERT, UPDATE ON USER_FINANCIAL_DATA TO moneyshop_client_role;

-- Restricție: CLIENT poate accesa doar propriile date
-- Aceasta se face prin view-uri și proceduri stocate

-- Privilegii pentru BROKER
GRANT SELECT ON UTILIZATORI TO moneyshop_broker_role;
GRANT SELECT, UPDATE ON APLICATII TO moneyshop_broker_role;
GRANT SELECT, INSERT, UPDATE ON DOCUMENTE TO moneyshop_broker_role;
GRANT SELECT ON CONSENTURI TO moneyshop_broker_role;
GRANT SELECT ON MANDATE TO moneyshop_broker_role;
GRANT SELECT ON APPLICATION_BANKS TO moneyshop_broker_role;
GRANT SELECT, INSERT, UPDATE ON APPLICATION_BANKS TO moneyshop_broker_role;
GRANT SELECT ON BANCI TO moneyshop_broker_role;

-- Privilegii pentru ADMIN
GRANT SELECT, INSERT, UPDATE, DELETE ON UTILIZATORI TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON APLICATII TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON DOCUMENTE TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON CONSENTURI TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON MANDATE TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON BANCI TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON APPLICATION_BANKS TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON USER_FINANCIAL_DATA TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON LEADURI TO moneyshop_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON AGREEMENTS TO moneyshop_admin_role;
GRANT SELECT ON AUDIT_LOG TO moneyshop_admin_role;

-- Privilegii pentru READONLY
GRANT SELECT ON vw_utilizatori_public TO moneyshop_readonly_role;
GRANT SELECT ON vw_aplicatii_public TO moneyshop_readonly_role;
GRANT SELECT ON BANCI TO moneyshop_readonly_role;

-- =====================================================
-- 4. Privilegii Sistem
-- =====================================================

-- Privilegii pentru aplicație (minimale)
-- GRANT CREATE SESSION TO moneyshop_app;
-- GRANT CREATE TABLE TO moneyshop_app; -- Doar dacă este necesar
-- GRANT CREATE PROCEDURE TO moneyshop_app; -- Doar dacă este necesar
-- GRANT CREATE VIEW TO moneyshop_app; -- Doar dacă este necesar

-- Privilegii pentru admin
-- GRANT CREATE ANY TABLE TO moneyshop_admin_role;
-- GRANT DROP ANY TABLE TO moneyshop_admin_role;
-- GRANT ALTER ANY TABLE TO moneyshop_admin_role;
-- GRANT CREATE ANY PROCEDURE TO moneyshop_admin_role;
-- GRANT DROP ANY PROCEDURE TO moneyshop_admin_role;
-- GRANT EXECUTE ANY PROCEDURE TO moneyshop_admin_role;

-- =====================================================
-- 5. Privilegii pe Proceduri Stocate
-- =====================================================

-- Grant pentru proceduri de autentificare
GRANT EXECUTE ON sp_autentificare_utilizator TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT EXECUTE ON sp_schimbare_parola TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;

-- Grant pentru proceduri de gestionare
GRANT EXECUTE ON sp_asignare_proces_utilizator TO moneyshop_admin_role;
GRANT EXECUTE ON sp_revocare_proces_utilizator TO moneyshop_admin_role;
GRANT EXECUTE ON sp_initializare_procese_rol TO moneyshop_admin_role;

-- Grant pentru proceduri de audit
GRANT EXECUTE ON sp_audit_report_user TO moneyshop_admin_role;
GRANT EXECUTE ON sp_cleanup_audit_log TO moneyshop_admin_role;

-- Grant pentru funcții
GRANT EXECUTE ON fn_utilizator_poate_proces TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT EXECUTE ON fn_utilizator_poate_entitate TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;

-- =====================================================
-- 6. Privilegii pe View-uri
-- =====================================================

GRANT SELECT ON vw_utilizatori_public TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT SELECT ON vw_aplicatii_public TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT SELECT ON vw_utilizatori_decrypted TO moneyshop_admin_role;
GRANT SELECT ON vw_procese_utilizator TO moneyshop_admin_role;
GRANT SELECT ON vw_audit_log_recent TO moneyshop_admin_role;
GRANT SELECT ON vw_audit_statistics TO moneyshop_admin_role;
GRANT SELECT ON vw_audit_top_users TO moneyshop_admin_role;

-- =====================================================
-- 7. Ierarhii de Privilegii
-- =====================================================

-- Ierarhie: ADMIN > BROKER > CLIENT
-- ADMIN moștenește toate privilegiile BROKER și CLIENT
GRANT moneyshop_client_role TO moneyshop_broker_role;
GRANT moneyshop_broker_role TO moneyshop_admin_role;

-- READONLY este separat
-- GRANT moneyshop_readonly_role TO moneyshop_client_role; -- Opțional

-- =====================================================
-- 8. Privilegii asupra Obiectelor Dependente
-- =====================================================

-- Grant cu opțiunea GRANT (permite delegarea)
GRANT SELECT ON UTILIZATORI TO moneyshop_admin_role WITH GRANT OPTION;
GRANT SELECT ON APLICATII TO moneyshop_admin_role WITH GRANT OPTION;

-- Grant pentru indexuri (implicit prin privilegii pe tabel)
-- Grant pentru secvențe (implicit prin IDENTITY columns)

-- =====================================================
-- 9. View-uri cu Privilegii Restricționate
-- =====================================================

-- View pentru CLIENT: doar propriile aplicații
CREATE OR REPLACE VIEW vw_client_own_applications AS
SELECT 
    a.Id,
    a.UserId,
    a.Status,
    a.TypeCredit,
    a.TipOperatiune,
    a.Scoring,
    a.Dti,
    a.RecommendedLevel,
    a.SumaAprobata,
    a.CreatedAt,
    a.UpdatedAt
FROM APLICATII a
WHERE a.UserId = SYS_CONTEXT('USERENV', 'SESSION_USERID'); -- Se va adapta în funcție de implementare

GRANT SELECT ON vw_client_own_applications TO moneyshop_client_role;

-- View pentru BROKER: toate aplicațiile active
CREATE OR REPLACE VIEW vw_broker_all_applications AS
SELECT 
    a.Id,
    a.UserId,
    u.Nume || ' ' || u.Prenume AS NumeClient,
    a.Status,
    a.TypeCredit,
    a.TipOperatiune,
    a.Scoring,
    a.Dti,
    a.RecommendedLevel,
    a.SumaAprobata,
    a.CreatedAt,
    a.UpdatedAt
FROM APLICATII a
JOIN UTILIZATORI u ON a.UserId = u.IdUtilizator
WHERE a.Status IN ('INREGISTRAT', 'IN_PROCESARE')
  AND u.IsDeleted = 0;

GRANT SELECT ON vw_broker_all_applications TO moneyshop_broker_role;

-- =====================================================
-- 10. Proceduri Stocate cu Privilegii Definite
-- =====================================================

-- Procedură pentru CLIENT: creare aplicație (cu verificare)
CREATE OR REPLACE PROCEDURE sp_client_create_application (
    p_user_id IN NUMBER,
    p_type_credit IN VARCHAR2,
    p_tip_operatiune IN VARCHAR2,
    p_salariu_net IN NUMBER,
    p_application_id OUT NUMBER
)
AUTHID DEFINER -- Rulează cu privilegiile creatorului
IS
    v_rol VARCHAR2(50);
BEGIN
    -- Verificare rol
    SELECT r.NumeRol INTO v_rol
    FROM UTILIZATORI u
    JOIN ROLURI r ON u.IdRol = r.IdRol
    WHERE u.IdUtilizator = p_user_id;
    
    IF v_rol != 'CLIENT' THEN
        RAISE_APPLICATION_ERROR(-20020, 'Doar clienții pot crea aplicații');
    END IF;
    
    -- Creare aplicație
    INSERT INTO APLICATII (
        UserId, TypeCredit, TipOperatiune, SalariuNet, Status
    ) VALUES (
        p_user_id, p_type_credit, p_tip_operatiune, p_salariu_net, 'INREGISTRAT'
    ) RETURNING Id INTO p_application_id;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Aplicație creată cu ID: ' || p_application_id);
END;
/

GRANT EXECUTE ON sp_client_create_application TO moneyshop_client_role;

-- =====================================================
-- 11. Revocare Privilegii
-- =====================================================

-- Exemplu de revocare (comentat)
-- REVOKE SELECT ON UTILIZATORI FROM moneyshop_client_role;
-- REVOKE moneyshop_client_role FROM moneyshop_broker_role;

-- =====================================================
-- 12. Verificare Privilegii
-- =====================================================

-- View pentru verificare privilegii utilizator
CREATE OR REPLACE VIEW vw_user_privileges AS
SELECT 
    grantee AS UserOrRole,
    table_name AS ObjectName,
    privilege AS Privilege,
    grantable AS Grantable
FROM user_tab_privs
UNION ALL
SELECT 
    grantee AS UserOrRole,
    'PROCEDURE' AS ObjectName,
    privilege AS Privilege,
    grantable AS Grantable
FROM user_proc_privs
ORDER BY UserOrRole, ObjectName, Privilege;

-- =====================================================
-- 13. Politici de Securitate (Row-Level Security)
-- =====================================================

-- Politică pentru CLIENT: doar propriile aplicații
CREATE OR REPLACE FUNCTION fn_client_app_policy (
    p_schema IN VARCHAR2,
    p_object IN VARCHAR2
) RETURN VARCHAR2
IS
    v_user_id NUMBER;
    v_rol VARCHAR2(50);
BEGIN
    -- Obținere user ID din context (se va adapta în funcție de implementare)
    -- v_user_id := SYS_CONTEXT('MONEYSHOP_CTX', 'USER_ID');
    
    -- Obținere rol
    SELECT r.NumeRol INTO v_rol
    FROM UTILIZATORI u
    JOIN ROLURI r ON u.IdRol = r.IdRol
    WHERE u.Username = USER; -- Adaptare necesară
    
    IF v_rol = 'CLIENT' THEN
        RETURN 'UserId = ' || v_user_id;
    ELSIF v_rol IN ('BROKER', 'ADMIN') THEN
        RETURN '1=1'; -- Acces complet
    ELSE
        RETURN '1=0'; -- Fără acces
    END IF;
END;
/

-- Aplicare politică (comentat - necesită configurare suplimentară)
-- BEGIN
--     DBMS_RLS.ADD_POLICY(
--         object_schema   => USER,
--         object_name     => 'APLICATII',
--         policy_name     => 'POLICY_CLIENT_OWN_APPS',
--         function_schema => USER,
--         policy_function => 'fn_client_app_policy',
--         statement_types => 'SELECT, UPDATE, DELETE'
--     );
-- END;
-- /

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Privilegii și roluri configurate!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Roluri create:');
    DBMS_OUTPUT.PUT_LINE('  - moneyshop_client_role');
    DBMS_OUTPUT.PUT_LINE('  - moneyshop_broker_role');
    DBMS_OUTPUT.PUT_LINE('  - moneyshop_admin_role');
    DBMS_OUTPUT.PUT_LINE('  - moneyshop_readonly_role');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Ierarhie: ADMIN > BROKER > CLIENT');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

