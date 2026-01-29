-- =====================================================
-- Mascarea Datelor - MoneyShop
-- Oracle Database 19c+
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. Data Masking Functions
-- =====================================================

-- Funcție pentru mascare email
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
        -- Mascare: primul caracter + *** + @ + domeniu
        v_masked := SUBSTR(p_email, 1, 1) || '***@' || SUBSTR(p_email, v_at_pos + 1);
    ELSE
        v_masked := SUBSTR(p_email, 1, 1) || '***';
    END IF;
    
    RETURN v_masked;
END;
/

-- Funcție pentru mascare telefon
CREATE OR REPLACE FUNCTION fn_mask_telefon(p_telefon IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    IF p_telefon IS NULL OR LENGTH(p_telefon) < 4 THEN
        RETURN '***';
    END IF;
    
    -- Mascare: primele 3 cifre + *** + ultimele 2 cifre
    RETURN SUBSTR(p_telefon, 1, 3) || '***' || SUBSTR(p_telefon, -2);
END;
/

-- Funcție pentru mascare CNP
CREATE OR REPLACE FUNCTION fn_mask_cnp(p_cnp IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    IF p_cnp IS NULL OR LENGTH(p_cnp) != 13 THEN
        RETURN '***';
    END IF;
    
    -- Mascare: primele 2 cifre + *** + ultimele 2 cifre
    RETURN SUBSTR(p_cnp, 1, 2) || '***' || SUBSTR(p_cnp, -2);
END;
/

-- Funcție pentru mascare nume complet
CREATE OR REPLACE FUNCTION fn_mask_nume(p_nume IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    IF p_nume IS NULL OR LENGTH(p_nume) < 2 THEN
        RETURN '***';
    END IF;
    
    -- Mascare: primul caracter + *** + ultimul caracter
    RETURN SUBSTR(p_nume, 1, 1) || '***' || SUBSTR(p_nume, -1);
END;
/

-- =====================================================
-- 2. View-uri cu Date Mascate
-- =====================================================

-- View pentru utilizatori cu date mascate
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

-- View pentru aplicații cu date financiare mascate
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

-- =====================================================
-- 3. Dynamic Data Masking (Oracle 12c+)
-- =====================================================

-- Notă: Oracle nu are Dynamic Data Masking nativ ca SQL Server
-- Implementăm prin view-uri și funcții

-- =====================================================
-- 4. Proceduri pentru Mascare în Masă
-- =====================================================

-- Procedură pentru generare date de test mascate
CREATE OR REPLACE PROCEDURE sp_generate_masked_test_data
IS
    v_count NUMBER := 0;
BEGIN
    -- Actualizare email-uri mascate (dacă există coloană separată)
    -- UPDATE UTILIZATORI SET Email_Masked = fn_mask_email(Email) WHERE Email_Masked IS NULL;
    
    -- Actualizare telefoane mascate
    -- UPDATE UTILIZATORI SET Telefon_Masked = fn_mask_telefon(NumarTelefon) WHERE Telefon_Masked IS NULL;
    
    DBMS_OUTPUT.PUT_LINE('Date mascate generate pentru ' || v_count || ' înregistrări');
END;
/

-- =====================================================
-- 5. Politici de Mascare Bazate pe Rol
-- =====================================================

-- View pentru CLIENT: doar propriile date (nemascate)
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
WHERE IdUtilizator = SYS_CONTEXT('USERENV', 'SESSION_USERID'); -- Adaptare necesară

-- View pentru BROKER: date mascate pentru clienți
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

-- =====================================================
-- 6. Grant-uri pentru View-uri Mascate
-- =====================================================

GRANT SELECT ON vw_utilizatori_masked TO moneyshop_readonly_role;
GRANT SELECT ON vw_aplicatii_masked TO moneyshop_readonly_role;
GRANT SELECT ON vw_broker_clients_masked TO moneyshop_broker_role;

-- =====================================================
-- 7. Testare Mascare
-- =====================================================

-- Test funcții de mascare
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

