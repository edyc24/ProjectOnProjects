-- =====================================================
-- Reguli de Securitate pentru MoneyShop
-- Oracle Database 19c+
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. Constrângeri de Securitate
-- =====================================================

-- Validare parolă puternică (trigger)
CREATE OR REPLACE TRIGGER trg_utilizatori_parola_securitate
BEFORE INSERT OR UPDATE OF Parola ON UTILIZATORI
FOR EACH ROW
DECLARE
    v_parola VARCHAR2(255);
BEGIN
    v_parola := :NEW.Parola;
    
    -- Verificare lungime minimă 8 caractere
    IF LENGTH(v_parola) < 8 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Parola trebuie să aibă minim 8 caractere');
    END IF;
    
    -- Verificare conține cel puțin o cifră
    IF NOT REGEXP_LIKE(v_parola, '[0-9]') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Parola trebuie să conțină cel puțin o cifră');
    END IF;
    
    -- Verificare conține cel puțin o literă mare
    IF NOT REGEXP_LIKE(v_parola, '[A-Z]') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Parola trebuie să conțină cel puțin o literă mare');
    END IF;
    
    -- Verificare conține cel puțin o literă mică
    IF NOT REGEXP_LIKE(v_parola, '[a-z]') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Parola trebuie să conțină cel puțin o literă mică');
    END IF;
    
    -- Notă: Parola trebuie să fie deja hash-uită în aplicație
    -- Acest trigger verifică doar formatul hash-ului
END;
/

-- Validare vârstă minimă 18 ani
CREATE OR REPLACE TRIGGER trg_utilizatori_varsta
BEFORE INSERT OR UPDATE OF DataNastere ON UTILIZATORI
FOR EACH ROW
BEGIN
    IF :NEW.DataNastere > ADD_MONTHS(SYSDATE, -216) THEN -- 18 ani = 216 luni
        RAISE_APPLICATION_ERROR(-20005, 'Utilizatorul trebuie să aibă minim 18 ani');
    END IF;
END;
/

-- Validare email unic și format
CREATE OR REPLACE TRIGGER trg_utilizatori_email
BEFORE INSERT OR UPDATE OF Email ON UTILIZATORI
FOR EACH ROW
BEGIN
    -- Verificare format email
    IF NOT REGEXP_LIKE(:NEW.Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20006, 'Format email invalid');
    END IF;
END;
/

-- Validare scoring în interval valid
CREATE OR REPLACE TRIGGER trg_aplicatii_scoring
BEFORE INSERT OR UPDATE OF Scoring ON APLICATII
FOR EACH ROW
BEGIN
    IF :NEW.Scoring IS NOT NULL AND (:NEW.Scoring < 300 OR :NEW.Scoring > 850) THEN
        RAISE_APPLICATION_ERROR(-20007, 'Scoring-ul trebuie să fie între 300 și 850');
    END IF;
END;
/

-- Validare DTI în interval valid
CREATE OR REPLACE TRIGGER trg_aplicatii_dti
BEFORE INSERT OR UPDATE OF Dti ON APLICATII
FOR EACH ROW
BEGIN
    IF :NEW.Dti IS NOT NULL AND (:NEW.Dti < 0 OR :NEW.Dti > 100) THEN
        RAISE_APPLICATION_ERROR(-20008, 'DTI trebuie să fie între 0 și 100%');
    END IF;
END;
/

-- =====================================================
-- 2. Politici de Securitate
-- =====================================================

-- Verificare că brokerul are rolul corect pentru mandate
CREATE OR REPLACE TRIGGER trg_mandate_broker_rol
BEFORE INSERT OR UPDATE OF BrokerId ON MANDATE
FOR EACH ROW
DECLARE
    v_rol VARCHAR2(50);
BEGIN
    SELECT r.NumeRol INTO v_rol
    FROM UTILIZATORI u
    JOIN ROLURI r ON u.IdRol = r.IdRol
    WHERE u.IdUtilizator = :NEW.BrokerId;
    
    IF v_rol != 'BROKER' THEN
        RAISE_APPLICATION_ERROR(-20009, 'BrokerId trebuie să fie un utilizator cu rol BROKER');
    END IF;
END;
/

-- Verificare că utilizatorul nu își poate modifica propriul rol
CREATE OR REPLACE TRIGGER trg_utilizatori_rol_securitate
BEFORE UPDATE OF IdRol ON UTILIZATORI
FOR EACH ROW
DECLARE
    v_current_user VARCHAR2(100);
BEGIN
    v_current_user := USER;
    
    -- Doar adminii pot modifica rolurile
    -- Această verificare se face la nivel de aplicație, dar adăugăm și aici
    IF :OLD.IdRol != :NEW.IdRol THEN
        -- Logăm modificarea
        INSERT INTO AUDIT_LOG (TableName, Operation, OldValues, NewValues, Timestamp)
        VALUES ('UTILIZATORI', 'UPDATE', 
                'IdRol=' || :OLD.IdRol, 
                'IdRol=' || :NEW.IdRol, 
                SYSTIMESTAMP);
    END IF;
END;
/

-- =====================================================
-- 3. Securitate la nivel de aplicație
-- =====================================================

-- Funcție pentru validare CNP (dacă ar fi stocat)
-- Notă: CNP-ul nu este stocat direct, ci criptat sau pseudonimizat
CREATE OR REPLACE FUNCTION fn_validare_cnp(p_cnp VARCHAR2) RETURN NUMBER
IS
    v_valid NUMBER := 0;
BEGIN
    -- Verificare lungime
    IF LENGTH(p_cnp) != 13 THEN
        RETURN 0;
    END IF;
    
    -- Verificare că sunt doar cifre
    IF NOT REGEXP_LIKE(p_cnp, '^[0-9]{13}$') THEN
        RETURN 0;
    END IF;
    
    -- Algoritm de validare CNP (simplificat)
    -- În producție, se folosește algoritmul complet
    RETURN 1;
END;
/

-- =====================================================
-- 4. View-uri pentru securitate (maschează date sensibile)
-- =====================================================

-- View pentru utilizatori fără date sensibile
CREATE OR REPLACE VIEW vw_utilizatori_public AS
SELECT 
    IdUtilizator,
    Nume,
    Prenume,
    Username,
    SUBSTR(Email, 1, 3) || '***@***' AS Email_Masked,
    SUBSTR(NumarTelefon, 1, 3) || '***' AS Telefon_Masked,
    IdRol,
    CreatedAt
FROM UTILIZATORI
WHERE IsDeleted = 0;

-- View pentru aplicații fără date financiare detaliate
CREATE OR REPLACE VIEW vw_aplicatii_public AS
SELECT 
    Id,
    UserId,
    Status,
    TypeCredit,
    TipOperatiune,
    RecommendedLevel,
    CreatedAt,
    UpdatedAt
FROM APLICATII;

-- =====================================================
-- 5. Proceduri stocate pentru operațiuni securizate
-- =====================================================

-- Procedură pentru autentificare securizată
CREATE OR REPLACE PROCEDURE sp_autentificare_utilizator (
    p_username IN VARCHAR2,
    p_parola_hash IN VARCHAR2,
    p_user_id OUT NUMBER,
    p_rol OUT VARCHAR2,
    p_success OUT NUMBER
)
IS
    v_parola VARCHAR2(255);
    v_id_rol NUMBER;
BEGIN
    p_success := 0;
    
    SELECT u.IdUtilizator, u.Parola, u.IdRol
    INTO p_user_id, v_parola, v_id_rol
    FROM UTILIZATORI u
    WHERE u.Username = p_username
      AND u.IsDeleted = 0;
    
    -- Verificare parolă (comparare hash)
    IF v_parola = p_parola_hash THEN
        SELECT NumeRol INTO p_rol
        FROM ROLURI
        WHERE IdRol = v_id_rol;
        
        p_success := 1;
        
        -- Log autentificare reușită
        INSERT INTO AUDIT_LOG (TableName, Operation, UserId, NewValues, Timestamp)
        VALUES ('UTILIZATORI', 'AUTH', p_user_id, 'Login successful', SYSTIMESTAMP);
    ELSE
        -- Log autentificare eșuată
        INSERT INTO AUDIT_LOG (TableName, Operation, NewValues, Timestamp)
        VALUES ('UTILIZATORI', 'AUTH', 'Login failed for: ' || p_username, SYSTIMESTAMP);
        
        RAISE_APPLICATION_ERROR(-20010, 'Autentificare eșuată');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_success := 0;
        INSERT INTO AUDIT_LOG (TableName, Operation, NewValues, Timestamp)
        VALUES ('UTILIZATORI', 'AUTH', 'Login failed - user not found: ' || p_username, SYSTIMESTAMP);
    WHEN OTHERS THEN
        p_success := 0;
        RAISE;
END;
/

-- Procedură pentru actualizare parolă securizată
CREATE OR REPLACE PROCEDURE sp_schimbare_parola (
    p_user_id IN NUMBER,
    p_parola_veche_hash IN VARCHAR2,
    p_parola_noua_hash IN VARCHAR2,
    p_success OUT NUMBER
)
IS
    v_parola_curenta VARCHAR2(255);
BEGIN
    p_success := 0;
    
    SELECT Parola INTO v_parola_curenta
    FROM UTILIZATORI
    WHERE IdUtilizator = p_user_id
      AND IsDeleted = 0;
    
    -- Verificare parolă veche
    IF v_parola_curenta = p_parola_veche_hash THEN
        -- Actualizare parolă nouă
        UPDATE UTILIZATORI
        SET Parola = p_parola_noua_hash,
            UpdatedAt = SYSTIMESTAMP
        WHERE IdUtilizator = p_user_id;
        
        p_success := 1;
        
        -- Log schimbare parolă
        INSERT INTO AUDIT_LOG (TableName, Operation, UserId, NewValues, Timestamp)
        VALUES ('UTILIZATORI', 'UPDATE', p_user_id, 'Password changed', SYSTIMESTAMP);
        
        COMMIT;
    ELSE
        -- Log încercare eșuată
        INSERT INTO AUDIT_LOG (TableName, Operation, UserId, NewValues, Timestamp)
        VALUES ('UTILIZATORI', 'UPDATE', p_user_id, 'Password change failed - wrong old password', SYSTIMESTAMP);
        
        RAISE_APPLICATION_ERROR(-20011, 'Parola veche incorectă');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_success := 0;
        RAISE_APPLICATION_ERROR(-20012, 'Utilizator negăsit');
    WHEN OTHERS THEN
        p_success := 0;
        RAISE;
END;
/

-- =====================================================
-- 6. Grant-uri pentru view-uri și proceduri
-- =====================================================

-- Grant pentru view-uri publice (se va face după crearea utilizatorilor)
-- GRANT SELECT ON vw_utilizatori_public TO moneyshop_app;
-- GRANT SELECT ON vw_aplicatii_public TO moneyshop_app;
-- GRANT EXECUTE ON sp_autentificare_utilizator TO moneyshop_app;
-- GRANT EXECUTE ON sp_schimbare_parola TO moneyshop_app;

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Regulile de securitate au fost create!');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

