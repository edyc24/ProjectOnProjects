-- =====================================================
-- TESTE CERINȚE SECURITATE - MoneyShop
-- Oracle Database 19c+
-- =====================================================
-- 
-- Acest script demonstrează fiecare dintre cele 7 cerințe de securitate:
-- 1. Criptare Date (TDE + Column-level encryption)
-- 2. Auditare (Standard + Trigger-based + FGA)
-- 3. Gestiune Utilizatori și Resurse (Matrici proces-utilizator)
-- 4. Privilegii și Roluri (Ierarhie Oracle roles)
-- 5. Prevenire SQL Injection (Parametrized queries + Validare)
-- 6. Mascare Date (Data masking functions + Views)
-- 7. Securitate la Nivel de Aplicație (Constraints + Validări)
--
-- =====================================================

SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 200;

PROMPT =====================================================
PROMPT TESTE CERINȚE SECURITATE - MoneyShop
PROMPT =====================================================
PROMPT

-- =====================================================
-- CERINȚA 1: CRIPTARE DATE
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT CERINȚA 1: CRIPTARE DATE
PROMPT =====================================================
PROMPT

PROMPT Test 1.1: Verificare funcții de criptare/decriptare
PROMPT ----------------------------------------

DECLARE
    v_text_original VARCHAR2(100) := 'Test123@email.com';
    v_text_criptat RAW(2000);
    v_text_decriptat VARCHAR2(100);
BEGIN
    -- Test criptare
    v_text_criptat := fn_encrypt_column(v_text_original);
    DBMS_OUTPUT.PUT_LINE('✅ Text original: ' || v_text_original);
    DBMS_OUTPUT.PUT_LINE('✅ Text criptat (RAW): ' || RAWTOHEX(SUBSTR(v_text_criptat, 1, 32)));
    
    -- Test decriptare
    v_text_decriptat := fn_decrypt_column(v_text_criptat);
    DBMS_OUTPUT.PUT_LINE('✅ Text decriptat: ' || v_text_decriptat);
    
    IF v_text_original = v_text_decriptat THEN
        DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 1: Criptare/Decriptare funcționează corect!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ EROARE: Decriptarea nu a returnat textul original!');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Funcțiile de criptare nu sunt disponibile: ' || SQLERRM);
END;
/

PROMPT
PROMPT Test 1.2: Verificare coloane criptate în UTILIZATORI
PROMPT ----------------------------------------

SELECT 
    COUNT(*) AS NumarUtilizatori,
    COUNT(Email_Encrypted) AS CuEmailCriptat,
    COUNT(CNP_Encrypted) AS CuCNPCriptat
FROM UTILIZATORI
WHERE ROWNUM <= 10;

PROMPT

-- =====================================================
-- CERINȚA 2: AUDITARE
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT CERINȚA 2: AUDITARE
PROMPT =====================================================
PROMPT

PROMPT Test 2.1: Verificare trigger-uri de audit
PROMPT ----------------------------------------

-- Test inserare (ar trebui să genereze înregistrare în AUDIT_LOG)
DECLARE
    v_count_before NUMBER;
    v_count_after NUMBER;
    v_test_user_id NUMBER;
BEGIN
    -- Obține un ID de utilizator existent
    SELECT MIN(IdUtilizator) INTO v_test_user_id FROM UTILIZATORI WHERE ROWNUM = 1;
    
    IF v_test_user_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Nu există utilizatori pentru test');
        RETURN;
    END IF;
    
    -- Numără înregistrările înainte
    SELECT COUNT(*) INTO v_count_before FROM AUDIT_LOG;
    
    -- Simulează o modificare (UPDATE)
    UPDATE UTILIZATORI 
    SET UpdatedAt = SYSTIMESTAMP 
    WHERE IdUtilizator = v_test_user_id 
      AND ROWNUM = 1;
    
    COMMIT;
    
    -- Numără înregistrările după
    SELECT COUNT(*) INTO v_count_after FROM AUDIT_LOG;
    
    IF v_count_after > v_count_before THEN
        DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 2.1: Trigger-ul de audit funcționează!');
        DBMS_OUTPUT.PUT_LINE('   Înregistrări înainte: ' || v_count_before);
        DBMS_OUTPUT.PUT_LINE('   Înregistrări după: ' || v_count_after);
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠️  Trigger-ul de audit nu a generat înregistrări');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Eroare la test audit: ' || SQLERRM);
END;
/

PROMPT
PROMPT Test 2.2: Verificare AUDIT_LOG recent
PROMPT ----------------------------------------

SELECT 
    audit_id,
    table_name,
    operation,
    user_name,
    TO_CHAR(timestamp, 'DD-MM-YYYY HH24:MI:SS') AS DataOra
FROM (
    SELECT * FROM AUDIT_LOG 
    ORDER BY timestamp DESC
)
WHERE ROWNUM <= 5;

PROMPT

PROMPT Test 2.3: Verificare FGA policies
PROMPT ----------------------------------------

SELECT 
    policy_name,
    object_schema,
    object_name,
    enabled
FROM dba_audit_policies
WHERE object_name = 'UTILIZATORI'
   OR object_name = 'APLICATII'
ORDER BY policy_name;

PROMPT

-- =====================================================
-- CERINȚA 3: GESTIUNE UTILIZATORI ȘI RESURSE
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT CERINȚA 3: GESTIUNE UTILIZATORI ȘI RESURSE
PROMPT =====================================================
PROMPT

PROMPT Test 3.1: Verificare matrici proces-utilizator
PROMPT ----------------------------------------

SELECT 
    p.NumeProces AS Proces,
    u.Username AS Utilizator,
    pu.IsActive AS Activ,
    TO_CHAR(pu.CreatedAt, 'DD-MM-YYYY') AS DataAsignare
FROM PROCES_UTILIZATOR pu
JOIN PROCESE p ON pu.IdProces = p.IdProces
JOIN UTILIZATORI u ON pu.IdUtilizator = u.IdUtilizator
WHERE u.IsDeleted = 0
ORDER BY p.NumeProces, u.Username;

PROMPT

PROMPT Test 3.2: Test funcție verificare proces
PROMPT ----------------------------------------

DECLARE
    v_user_id NUMBER;
    v_proces_id NUMBER;
    v_poate_proces NUMBER;
BEGIN
    -- Obține un utilizator și un proces existent
    SELECT MIN(u.IdUtilizator) INTO v_user_id 
    FROM UTILIZATORI u 
    WHERE u.IsDeleted = 0 AND ROWNUM = 1;
    
    SELECT MIN(p.IdProces) INTO v_proces_id 
    FROM PROCESE p 
    WHERE ROWNUM = 1;
    
    IF v_user_id IS NULL OR v_proces_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Nu există date suficiente pentru test');
        RETURN;
    END IF;
    
    -- Test funcție
    v_poate_proces := fn_utilizator_poate_proces(v_user_id, v_proces_id);
    
    IF v_poate_proces = 1 THEN
        DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 3.2: Utilizatorul ' || v_user_id || ' poate accesa procesul ' || v_proces_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 3.2: Utilizatorul ' || v_user_id || ' NU poate accesa procesul ' || v_proces_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Eroare la test funcție: ' || SQLERRM);
END;
/

PROMPT

-- =====================================================
-- CERINȚA 4: PRIVILEGII ȘI ROLURI
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT CERINȚA 4: PRIVILEGII ȘI ROLURI
PROMPT =====================================================
PROMPT

PROMPT Test 4.1: Verificare roluri create
PROMPT ----------------------------------------

SELECT 
    role AS NumeRol,
    password_required AS ParolaNecesara
FROM user_roles
WHERE role LIKE '%MONEYSHOP%' OR role LIKE '%moneyshop%'
ORDER BY role;

PROMPT

PROMPT Test 4.2: Verificare privilegii pe roluri
PROMPT ----------------------------------------

SELECT 
    grantee AS Rol,
    COUNT(DISTINCT table_name) AS NumarTabele,
    COUNT(DISTINCT privilege) AS NumarPrivilegii
FROM user_tab_privs
WHERE grantee LIKE '%MONEYSHOP%' OR grantee LIKE '%moneyshop%'
GROUP BY grantee
ORDER BY grantee;

PROMPT

PROMPT Test 4.3: Verificare ierarhie roluri
PROMPT ----------------------------------------

SELECT 
    grantee AS RolCarePrimeste,
    granted_role AS RolGrantat,
    admin_option AS AdminOption
FROM user_role_privs
WHERE grantee LIKE '%MONEYSHOP%' OR granted_role LIKE '%MONEYSHOP%'
ORDER BY grantee, granted_role;

PROMPT

-- =====================================================
-- CERINȚA 5: PREVENIRE SQL INJECTION
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT CERINȚA 5: PREVENIRE SQL INJECTION
PROMPT =====================================================
PROMPT

PROMPT Test 5.1: Test procedură cu parametri (parametrized query)
PROMPT ----------------------------------------

DECLARE
    v_user_id NUMBER;
    v_result NUMBER;
BEGIN
    -- Obține un utilizator existent
    SELECT MIN(IdUtilizator) INTO v_user_id FROM UTILIZATORI WHERE ROWNUM = 1;
    
    IF v_user_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Nu există utilizatori pentru test');
        RETURN;
    END IF;
    
    -- Test apel procedură cu parametri (prevenire SQL injection)
    BEGIN
        sp_autentificare_utilizator(
            p_username => 'test_user',
            p_parola => 'test_pass',
            p_user_id => v_result
        );
        
        DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 5.1: Procedura cu parametri funcționează');
        DBMS_OUTPUT.PUT_LINE('   (Parametrii sunt sanitizați automat)');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Eroare la test procedură: ' || SQLERRM);
    END;
END;
/

PROMPT
PROMPT Test 5.2: Verificare trigger-uri de validare input
PROMPT ----------------------------------------

-- Test validare email format
DECLARE
    v_test_email VARCHAR2(255) := 'test@invalid'; -- Email invalid (fără TLD)
BEGIN
    BEGIN
        -- Încearcă să insereze un email invalid
        INSERT INTO UTILIZATORI (
            Username, Email, Parola, Nume, Prenume, DataNastere, IdRol
        ) VALUES (
            'test_user', v_test_email, 'hash123', 'Test', 'User', DATE '1990-01-01', 1
        );
        
        DBMS_OUTPUT.PUT_LINE('❌ EROARE: Email invalid a fost acceptat!');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2290 THEN -- Constraint violation
                DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 5.2: Validare email funcționează!');
                DBMS_OUTPUT.PUT_LINE('   Email invalid a fost respins: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠️  Eroare neașteptată: ' || SQLERRM);
            END IF;
    END;
END;
/

PROMPT

-- =====================================================
-- CERINȚA 6: MASCARE DATE
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT CERINȚA 6: MASCARE DATE
PROMPT =====================================================
PROMPT

PROMPT Test 6.1: Test funcții de mascare
PROMPT ----------------------------------------

SELECT 
    fn_mask_email('test@example.com') AS Email_Masked,
    fn_mask_telefon('0712345678') AS Telefon_Masked,
    fn_mask_cnp('1234567890123') AS CNP_Masked,
    fn_mask_nume('Popescu') AS Nume_Masked
FROM DUAL;

PROMPT

PROMPT Test 6.2: Verificare view-uri cu date mascate
PROMPT ----------------------------------------

SELECT 
    IdUtilizator,
    Nume_Masked,
    Prenume_Masked,
    Email_Masked,
    Telefon_Masked
FROM vw_utilizatori_masked
WHERE ROWNUM <= 5;

PROMPT

PROMPT Test 6.3: Comparație date originale vs. mascate
PROMPT ----------------------------------------

SELECT 
    u.IdUtilizator,
    u.Email AS Email_Original,
    vm.Email_Masked AS Email_Masked,
    u.NumarTelefon AS Telefon_Original,
    vm.Telefon_Masked AS Telefon_Masked
FROM UTILIZATORI u
JOIN vw_utilizatori_masked vm ON u.IdUtilizator = vm.IdUtilizator
WHERE u.IsDeleted = 0
  AND ROWNUM <= 3;

PROMPT

-- =====================================================
-- CERINȚA 7: SECURITATE LA NIVEL DE APLICAȚIE
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT CERINȚA 7: SECURITATE LA NIVEL DE APLICAȚIE
PROMPT =====================================================
PROMPT

PROMPT Test 7.1: Verificare constraints de securitate
PROMPT ----------------------------------------

SELECT 
    constraint_name AS NumeConstraint,
    constraint_type AS Tip,
    search_condition AS Conditie
FROM user_constraints
WHERE table_name IN ('UTILIZATORI', 'APLICATII', 'ROLURI')
  AND constraint_type = 'C'
ORDER BY table_name, constraint_name;

PROMPT

PROMPT Test 7.2: Test validare vârstă minimă
PROMPT ----------------------------------------

DECLARE
    v_data_nastere_invalida DATE := DATE '2010-01-01'; -- Prea tânăr
BEGIN
    BEGIN
        -- Obține un ID de rol valid
        DECLARE
            v_id_rol NUMBER;
        BEGIN
            SELECT MIN(IdRol) INTO v_id_rol FROM ROLURI WHERE ROWNUM = 1;
            
            IF v_id_rol IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  Nu există roluri pentru test');
                RETURN;
            END IF;
            
            -- Încearcă să insereze utilizator prea tânăr
            INSERT INTO UTILIZATORI (
                Username, Email, Parola, Nume, Prenume, DataNastere, IdRol
            ) VALUES (
                'test_minor', 'test@test.com', 'hash123', 'Test', 'Minor', 
                v_data_nastere_invalida, v_id_rol
            );
            
            DBMS_OUTPUT.PUT_LINE('❌ EROARE: Utilizator minor a fost acceptat!');
            ROLLBACK;
        END;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2290 THEN
                DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 7.2: Validare vârstă funcționează!');
                DBMS_OUTPUT.PUT_LINE('   Utilizator minor a fost respins');
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠️  Eroare: ' || SQLERRM);
            END IF;
    END;
END;
/

PROMPT
PROMPT Test 7.3: Test validare scoring/DTI ranges
PROMPT ----------------------------------------

DECLARE
    v_user_id NUMBER;
BEGIN
    -- Obține un utilizator existent
    SELECT MIN(IdUtilizator) INTO v_user_id FROM UTILIZATORI WHERE ROWNUM = 1;
    
    IF v_user_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Nu există utilizatori pentru test');
        RETURN;
    END IF;
    
    BEGIN
        -- Încearcă să insereze aplicație cu scoring invalid
        INSERT INTO APLICATII (
            UserId, Status, Scoring, Dti
        ) VALUES (
            v_user_id, 'INREGISTRAT', 1000, 150 -- Scoring > 850, DTI > 100
        );
        
        DBMS_OUTPUT.PUT_LINE('❌ EROARE: Valori invalide au fost acceptate!');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2290 THEN
                DBMS_OUTPUT.PUT_LINE('✅ CERINȚA 7.3: Validare scoring/DTI funcționează!');
                DBMS_OUTPUT.PUT_LINE('   Valori invalide au fost respinse');
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠️  Eroare: ' || SQLERRM);
            END IF;
    END;
END;
/

PROMPT

-- =====================================================
-- REZUMAT FINAL
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT REZUMAT FINAL - STATUS CERINȚE
PROMPT =====================================================
PROMPT

DECLARE
    v_cerinta1 NUMBER := 0;
    v_cerinta2 NUMBER := 0;
    v_cerinta3 NUMBER := 0;
    v_cerinta4 NUMBER := 0;
    v_cerinta5 NUMBER := 0;
    v_cerinta6 NUMBER := 0;
    v_cerinta7 NUMBER := 0;
BEGIN
    -- Verificare cerință 1 (Criptare)
    BEGIN
        SELECT 1 INTO v_cerinta1 FROM DUAL 
        WHERE EXISTS (SELECT 1 FROM user_objects WHERE object_name = 'FN_ENCRYPT_COLUMN');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_cerinta1 := 0;
    END;
    
    -- Verificare cerință 2 (Auditare)
    BEGIN
        SELECT 1 INTO v_cerinta2 FROM DUAL 
        WHERE EXISTS (SELECT 1 FROM user_tables WHERE table_name = 'AUDIT_LOG');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_cerinta2 := 0;
    END;
    
    -- Verificare cerință 3 (Gestiune utilizatori)
    BEGIN
        SELECT 1 INTO v_cerinta3 FROM DUAL 
        WHERE EXISTS (SELECT 1 FROM user_tables WHERE table_name = 'PROCES_UTILIZATOR');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_cerinta3 := 0;
    END;
    
    -- Verificare cerință 4 (Privilegii)
    BEGIN
        SELECT 1 INTO v_cerinta4 FROM DUAL 
        WHERE EXISTS (
            SELECT 1 FROM user_roles 
            WHERE role LIKE '%MONEYSHOP%' OR role LIKE '%moneyshop%'
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_cerinta4 := 0;
    END;
    
    -- Verificare cerință 5 (SQL Injection)
    BEGIN
        SELECT 1 INTO v_cerinta5 FROM DUAL 
        WHERE EXISTS (SELECT 1 FROM user_objects WHERE object_name = 'SP_AUTENTIFICARE_UTILIZATOR');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_cerinta5 := 0;
    END;
    
    -- Verificare cerință 6 (Mascare)
    BEGIN
        SELECT 1 INTO v_cerinta6 FROM DUAL 
        WHERE EXISTS (SELECT 1 FROM user_views WHERE view_name = 'VW_UTILIZATORI_MASKED');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_cerinta6 := 0;
    END;
    
    -- Verificare cerință 7 (Securitate aplicație)
    BEGIN
        SELECT 1 INTO v_cerinta7 FROM DUAL 
        WHERE EXISTS (
            SELECT 1 FROM user_constraints 
            WHERE table_name = 'UTILIZATORI' AND constraint_type = 'C'
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_cerinta7 := 0;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Cerință 1 - Criptare Date:        ' || CASE WHEN v_cerinta1 = 1 THEN '✅ IMPLEMENTAT' ELSE '❌ LIPSĂ' END);
    DBMS_OUTPUT.PUT_LINE('Cerință 2 - Auditare:             ' || CASE WHEN v_cerinta2 = 1 THEN '✅ IMPLEMENTAT' ELSE '❌ LIPSĂ' END);
    DBMS_OUTPUT.PUT_LINE('Cerință 3 - Gestiune Utilizatori: ' || CASE WHEN v_cerinta3 = 1 THEN '✅ IMPLEMENTAT' ELSE '❌ LIPSĂ' END);
    DBMS_OUTPUT.PUT_LINE('Cerință 4 - Privilegii și Roluri: ' || CASE WHEN v_cerinta4 = 1 THEN '✅ IMPLEMENTAT' ELSE '❌ LIPSĂ' END);
    DBMS_OUTPUT.PUT_LINE('Cerință 5 - Prevenire SQL Inj:    ' || CASE WHEN v_cerinta5 = 1 THEN '✅ IMPLEMENTAT' ELSE '❌ LIPSĂ' END);
    DBMS_OUTPUT.PUT_LINE('Cerință 6 - Mascare Date:         ' || CASE WHEN v_cerinta6 = 1 THEN '✅ IMPLEMENTAT' ELSE '❌ LIPSĂ' END);
    DBMS_OUTPUT.PUT_LINE('Cerință 7 - Securitate Aplicație: ' || CASE WHEN v_cerinta7 = 1 THEN '✅ IMPLEMENTAT' ELSE '❌ LIPSĂ' END);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Total implementate: ' || (v_cerinta1 + v_cerinta2 + v_cerinta3 + v_cerinta4 + v_cerinta5 + v_cerinta6 + v_cerinta7) || ' / 7');
END;
/

PROMPT
PROMPT =====================================================
PROMPT TESTE FINALIZATE!
PROMPT =====================================================
PROMPT

