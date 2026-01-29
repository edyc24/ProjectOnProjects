SET SERVEROUTPUT ON;
CREATE ROLE moneyshop_client_role;
CREATE ROLE moneyshop_broker_role;
CREATE ROLE moneyshop_admin_role;
CREATE ROLE moneyshop_readonly_role;
GRANT SELECT ON UTILIZATORI TO moneyshop_client_role;
GRANT SELECT, INSERT, UPDATE ON APLICATII TO moneyshop_client_role;
GRANT SELECT, INSERT ON DOCUMENTE TO moneyshop_client_role;
GRANT SELECT, INSERT ON CONSENTURI TO moneyshop_client_role;
GRANT SELECT, INSERT ON MANDATE TO moneyshop_client_role;
GRANT SELECT, INSERT, UPDATE ON USER_FINANCIAL_DATA TO moneyshop_client_role;
GRANT SELECT ON UTILIZATORI TO moneyshop_broker_role;
GRANT SELECT, UPDATE ON APLICATII TO moneyshop_broker_role;
GRANT SELECT, INSERT, UPDATE ON DOCUMENTE TO moneyshop_broker_role;
GRANT SELECT ON CONSENTURI TO moneyshop_broker_role;
GRANT SELECT ON MANDATE TO moneyshop_broker_role;
GRANT SELECT ON APPLICATION_BANKS TO moneyshop_broker_role;
GRANT SELECT, INSERT, UPDATE ON APPLICATION_BANKS TO moneyshop_broker_role;
GRANT SELECT ON BANCI TO moneyshop_broker_role;
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
GRANT SELECT ON vw_utilizatori_public TO moneyshop_readonly_role;
GRANT SELECT ON vw_aplicatii_public TO moneyshop_readonly_role;
GRANT SELECT ON BANCI TO moneyshop_readonly_role;
GRANT EXECUTE ON sp_autentificare_utilizator TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT EXECUTE ON sp_schimbare_parola TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT EXECUTE ON sp_asignare_proces_utilizator TO moneyshop_admin_role;
GRANT EXECUTE ON sp_revocare_proces_utilizator TO moneyshop_admin_role;
GRANT EXECUTE ON sp_initializare_procese_rol TO moneyshop_admin_role;
GRANT EXECUTE ON sp_audit_report_user TO moneyshop_admin_role;
GRANT EXECUTE ON sp_cleanup_audit_log TO moneyshop_admin_role;
GRANT EXECUTE ON fn_utilizator_poate_proces TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT EXECUTE ON fn_utilizator_poate_entitate TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT SELECT ON vw_utilizatori_public TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT SELECT ON vw_aplicatii_public TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role;
GRANT SELECT ON vw_utilizatori_decrypted TO moneyshop_admin_role;
GRANT SELECT ON vw_procese_utilizator TO moneyshop_admin_role;
GRANT SELECT ON vw_audit_log_recent TO moneyshop_admin_role;
GRANT SELECT ON vw_audit_statistics TO moneyshop_admin_role;
GRANT SELECT ON vw_audit_top_users TO moneyshop_admin_role;
GRANT moneyshop_client_role TO moneyshop_broker_role;
GRANT moneyshop_broker_role TO moneyshop_admin_role;
GRANT SELECT ON UTILIZATORI TO moneyshop_admin_role WITH GRANT OPTION;
GRANT SELECT ON APLICATII TO moneyshop_admin_role WITH GRANT OPTION;
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
WHERE a.UserId = SYS_CONTEXT('USERENV', 'SESSION_USERID');
GRANT SELECT ON vw_client_own_applications TO moneyshop_client_role;
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
CREATE OR REPLACE PROCEDURE sp_client_create_application (
p_user_id IN NUMBER,
p_type_credit IN VARCHAR2,
p_tip_operatiune IN VARCHAR2,
p_salariu_net IN NUMBER,
p_application_id OUT NUMBER
)
AUTHID DEFINER
IS
v_rol VARCHAR2(50);
BEGIN
SELECT r.NumeRol INTO v_rol
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE u.IdUtilizator = p_user_id;
IF v_rol != 'CLIENT' THEN
RAISE_APPLICATION_ERROR(-20020, 'Doar clienții pot crea aplicații');
END IF;
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
CREATE OR REPLACE FUNCTION fn_client_app_policy (
p_schema IN VARCHAR2,
p_object IN VARCHAR2
) RETURN VARCHAR2
IS
v_user_id NUMBER;
v_rol VARCHAR2(50);
BEGIN
SELECT r.NumeRol INTO v_rol
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE u.Username = USER;
IF v_rol = 'CLIENT' THEN
RETURN 'UserId = ' || v_user_id;
ELSIF v_rol IN ('BROKER', 'ADMIN') THEN
RETURN '1=1';
ELSE
RETURN '1=0';
END IF;
END;
/
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