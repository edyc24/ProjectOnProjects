SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION fn_mask_email(p_email IN VARCHAR2) RETURN VARCHAR2
IS
v_masked VARCHAR2(255);
v_at_pos NUMBER;
v_dot_pos NUMBER;
BEGIN
IF p_email IS NULL THEN
RETURN NULL;
END IF;
v_at_pos := INSTR(p_email, '@');
v_dot_pos := INSTR(p_email, '.', v_at_pos);
IF v_at_pos > 0 THEN
v_masked := SUBSTR(p_email, 1, 1) || '***@' || SUBSTR(p_email, v_at_pos + 1);
ELSE
v_masked := SUBSTR(p_email, 1, 1) || '***';
END IF;
RETURN v_masked;
END;
/
CREATE OR REPLACE FUNCTION fn_mask_telefon(p_telefon IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
IF p_telefon IS NULL OR LENGTH(p_telefon) < 4 THEN
RETURN '***';
END IF;
RETURN SUBSTR(p_telefon, 1, 3) || '***' || SUBSTR(p_telefon, -2);
END;
/
CREATE OR REPLACE FUNCTION fn_mask_cnp(p_cnp IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
IF p_cnp IS NULL OR LENGTH(p_cnp) != 13 THEN
RETURN '***';
END IF;
RETURN SUBSTR(p_cnp, 1, 2) || '***' || SUBSTR(p_cnp, -2);
END;
/
CREATE OR REPLACE FUNCTION fn_mask_nume(p_nume IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
IF p_nume IS NULL OR LENGTH(p_nume) < 2 THEN
RETURN '***';
END IF;
RETURN SUBSTR(p_nume, 1, 1) || '***' || SUBSTR(p_nume, -1);
END;
/
CREATE OR REPLACE VIEW vw_utilizatori_masked AS
SELECT
IdUtilizator,
fn_mask_nume(Nume) AS Nume_Masked,
fn_mask_nume(Prenume) AS Prenume_Masked,
Username,
fn_mask_email(Email) AS Email_Masked,
fn_mask_telefon(NumarTelefon) AS Telefon_Masked,
EmailVerified,
PhoneVerified,
IdRol,
CreatedAt
FROM UTILIZATORI
WHERE IsDeleted = 0;
CREATE OR REPLACE VIEW vw_aplicatii_masked AS
SELECT
Id,
UserId,
Status,
TypeCredit,
TipOperatiune,
CASE
WHEN SalariuNet IS NOT NULL THEN ROUND(SalariuNet / 1000) * 1000
ELSE NULL
END AS SalariuNet_Masked,
Scoring,
Dti,
RecommendedLevel,
CreatedAt,
UpdatedAt
FROM APLICATII;
CREATE OR REPLACE PROCEDURE sp_generate_masked_test_data
IS
v_count NUMBER := 0;
BEGIN
DBMS_OUTPUT.PUT_LINE('Date mascate generate pentru ' || v_count || ' înregistrări');
END;
/
CREATE OR REPLACE VIEW vw_client_own_data AS
SELECT
IdUtilizator,
Nume,
Prenume,
Username,
Email,
NumarTelefon,
IdRol
FROM UTILIZATORI
WHERE IdUtilizator = SYS_CONTEXT('USERENV', 'SESSION_USERID');
CREATE OR REPLACE VIEW vw_broker_clients_masked AS
SELECT
u.IdUtilizator,
fn_mask_nume(u.Nume) AS Nume,
fn_mask_nume(u.Prenume) AS Prenume,
u.Username,
fn_mask_email(u.Email) AS Email,
fn_mask_telefon(u.NumarTelefon) AS Telefon,
u.IdRol
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE r.NumeRol = 'CLIENT'
AND u.IsDeleted = 0;
GRANT SELECT ON vw_utilizatori_masked TO moneyshop_readonly_role;
GRANT SELECT ON vw_aplicatii_masked TO moneyshop_readonly_role;
GRANT SELECT ON vw_broker_clients_masked TO moneyshop_broker_role;
SELECT
fn_mask_email('test@example.com') AS Email_Masked,
fn_mask_telefon('0712345678') AS Telefon_Masked,
fn_mask_cnp('1234567890123') AS CNP_Masked,
fn_mask_nume('Ionescu') AS Nume_Masked
FROM DUAL;
BEGIN
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Mascarea datelor configurată!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Funcții create:');
DBMS_OUTPUT.PUT_LINE('  - fn_mask_email');
DBMS_OUTPUT.PUT_LINE('  - fn_mask_telefon');
DBMS_OUTPUT.PUT_LINE('  - fn_mask_cnp');
DBMS_OUTPUT.PUT_LINE('  - fn_mask_nume');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('View-uri create:');
DBMS_OUTPUT.PUT_LINE('  - vw_utilizatori_masked');
DBMS_OUTPUT.PUT_LINE('  - vw_aplicatii_masked');
DBMS_OUTPUT.PUT_LINE('  - vw_broker_clients_masked');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/