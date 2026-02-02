-- =====================================================
-- Privilegii și Roluri - MoneyShop (VERSIUNE SIGURĂ)
-- Oracle Database 19c+
-- =====================================================
-- 
-- Această versiune gestionează automat CDB vs PDB
-- și folosește prefixul C## când este necesar
--
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. Determinare Container și Prefix
-- =====================================================

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
            DBMS_OUTPUT.PUT_LINE('⚠️  Ești în CDB$ROOT - rolurile vor avea prefix C##');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ Ești în PDB - rolurile vor fi normale');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_prefix := '';
    END;
    
    DBMS_OUTPUT.PUT_LINE('Container: ' || v_container);
    DBMS_OUTPUT.PUT_LINE('Prefix roluri: ' || NVL(v_prefix, '(fără prefix)'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Salvează prefixul într-o variabilă globală (prin tabel temporar)
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE temp_role_prefix';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE temp_role_prefix (prefix VARCHAR2(10)) ON COMMIT PRESERVE ROWS';
    EXECUTE IMMEDIATE 'INSERT INTO temp_role_prefix VALUES (''' || v_prefix || ''')';
    
    DBMS_OUTPUT.PUT_LINE('Prefix salvat pentru utilizare în script');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Funcție helper pentru a obține prefixul
CREATE OR REPLACE FUNCTION fn_get_role_prefix RETURN VARCHAR2
IS
    v_prefix VARCHAR2(10);
BEGIN
    SELECT prefix INTO v_prefix FROM temp_role_prefix WHERE ROWNUM = 1;
    RETURN NVL(v_prefix, '');
EXCEPTION
    WHEN OTHERS THEN
        RETURN '';
END;
/

-- =====================================================
-- 2. Crearea Rolurilor Oracle
-- =====================================================

DECLARE
    v_prefix VARCHAR2(10);
BEGIN
    v_prefix := fn_get_role_prefix();
    
    -- Rol pentru clienți
    BEGIN
        EXECUTE IMMEDIATE 'CREATE ROLE ' || v_prefix || 'moneyshop_client_role';
        DBMS_OUTPUT.PUT_LINE('✅ Rol ' || v_prefix || 'moneyshop_client_role creat');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1921 THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  Rol ' || v_prefix || 'moneyshop_client_role există deja');
            ELSE
                DBMS_OUTPUT.PUT_LINE('❌ Eroare: ' || SQLERRM);
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
                DBMS_OUTPUT.PUT_LINE('❌ Eroare: ' || SQLERRM);
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
                DBMS_OUTPUT.PUT_LINE('❌ Eroare: ' || SQLERRM);
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
                DBMS_OUTPUT.PUT_LINE('❌ Eroare: ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 3. Privilegii Obiect (pe tabele) - cu prefix dinamic
-- =====================================================

DECLARE
    v_prefix VARCHAR2(10);
    v_client_role VARCHAR2(50);
    v_broker_role VARCHAR2(50);
    v_admin_role VARCHAR2(50);
    v_readonly_role VARCHAR2(50);
BEGIN
    v_prefix := fn_get_role_prefix();
    v_client_role := v_prefix || 'moneyshop_client_role';
    v_broker_role := v_prefix || 'moneyshop_broker_role';
    v_admin_role := v_prefix || 'moneyshop_admin_role';
    v_readonly_role := v_prefix || 'moneyshop_readonly_role';
    
    DBMS_OUTPUT.PUT_LINE('Acordare privilegii obiect...');
    DBMS_OUTPUT.PUT_LINE('  Client role: ' || v_client_role);
    DBMS_OUTPUT.PUT_LINE('  Broker role: ' || v_broker_role);
    DBMS_OUTPUT.PUT_LINE('  Admin role: ' || v_admin_role);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Privilegii pentru CLIENT
    BEGIN
        EXECUTE IMMEDIATE 'GRANT SELECT ON UTILIZATORI TO ' || v_client_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON APLICATII TO ' || v_client_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT ON DOCUMENTE TO ' || v_client_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT ON CONSENTURI TO ' || v_client_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT ON MANDATE TO ' || v_client_role;
        DBMS_OUTPUT.PUT_LINE('✅ Privilegii CLIENT acordate');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Eroare privilegii CLIENT: ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    -- Privilegii pentru BROKER
    BEGIN
        EXECUTE IMMEDIATE 'GRANT SELECT ON UTILIZATORI TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, UPDATE ON APLICATII TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON DOCUMENTE TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT SELECT ON CONSENTURI TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT SELECT ON MANDATE TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT SELECT ON APPLICATION_BANKS TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON APPLICATION_BANKS TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT SELECT ON BANCI TO ' || v_broker_role;
        DBMS_OUTPUT.PUT_LINE('✅ Privilegii BROKER acordate');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Eroare privilegii BROKER: ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    -- Privilegii pentru ADMIN
    BEGIN
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON UTILIZATORI TO ' || v_admin_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON APLICATII TO ' || v_admin_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON DOCUMENTE TO ' || v_admin_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON CONSENTURI TO ' || v_admin_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON MANDATE TO ' || v_admin_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON BANCI TO ' || v_admin_role;
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON APPLICATION_BANKS TO ' || v_admin_role;
        EXECUTE IMMEDIATE 'GRANT SELECT ON AUDIT_LOG TO ' || v_admin_role;
        DBMS_OUTPUT.PUT_LINE('✅ Privilegii ADMIN acordate');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Eroare privilegii ADMIN: ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    -- Privilegii pentru READONLY
    BEGIN
        -- Verifică dacă view-urile există
        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_count
            FROM user_views
            WHERE view_name = 'VW_UTILIZATORI_PUBLIC';
            
            IF v_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_utilizatori_public TO ' || v_readonly_role;
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_aplicatii_public TO ' || v_readonly_role;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        EXECUTE IMMEDIATE 'GRANT SELECT ON BANCI TO ' || v_readonly_role;
        DBMS_OUTPUT.PUT_LINE('✅ Privilegii READONLY acordate');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Eroare privilegii READONLY: ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 4. Privilegii pe Proceduri/Funcții - cu prefix dinamic
-- =====================================================

DECLARE
    v_prefix VARCHAR2(10);
    v_client_role VARCHAR2(50);
    v_broker_role VARCHAR2(50);
    v_admin_role VARCHAR2(50);
BEGIN
    v_prefix := fn_get_role_prefix();
    v_client_role := v_prefix || 'moneyshop_client_role';
    v_broker_role := v_prefix || 'moneyshop_broker_role';
    v_admin_role := v_prefix || 'moneyshop_admin_role';
    
    DBMS_OUTPUT.PUT_LINE('Acordare privilegii pe proceduri/funcții...');
    
    -- Verifică dacă procedurile există înainte de a acorda privilegii
    DECLARE
        v_proc_count NUMBER;
    BEGIN
        -- sp_autentificare_utilizator
        BEGIN
            SELECT COUNT(*) INTO v_proc_count
            FROM user_objects
            WHERE object_name = 'SP_AUTENTIFICARE_UTILIZATOR' AND object_type = 'PROCEDURE';
            
            IF v_proc_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT EXECUTE ON sp_autentificare_utilizator TO ' || v_client_role || ', ' || v_broker_role || ', ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii sp_autentificare_utilizator acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  sp_autentificare_utilizator: ' || SUBSTR(SQLERRM, 1, 80));
        END;
        
        -- sp_schimbare_parola
        BEGIN
            SELECT COUNT(*) INTO v_proc_count
            FROM user_objects
            WHERE object_name = 'SP_SCHIMBARE_PAROLA' AND object_type = 'PROCEDURE';
            
            IF v_proc_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT EXECUTE ON sp_schimbare_parola TO ' || v_client_role || ', ' || v_broker_role || ', ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii sp_schimbare_parola acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  sp_schimbare_parola: ' || SUBSTR(SQLERRM, 1, 80));
        END;
        
        -- fn_utilizator_poate_proces
        BEGIN
            SELECT COUNT(*) INTO v_proc_count
            FROM user_objects
            WHERE object_name = 'FN_UTILIZATOR_POATE_PROCES' AND object_type = 'FUNCTION';
            
            IF v_proc_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT EXECUTE ON fn_utilizator_poate_proces TO ' || v_client_role || ', ' || v_broker_role || ', ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii fn_utilizator_poate_proces acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  fn_utilizator_poate_proces: ' || SUBSTR(SQLERRM, 1, 80));
        END;
        
        -- Proceduri admin
        BEGIN
            SELECT COUNT(*) INTO v_proc_count
            FROM user_objects
            WHERE object_name = 'SP_AUDIT_REPORT_USER' AND object_type = 'PROCEDURE';
            
            IF v_proc_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT EXECUTE ON sp_audit_report_user TO ' || v_admin_role;
                EXECUTE IMMEDIATE 'GRANT EXECUTE ON sp_cleanup_audit_log TO ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii proceduri audit acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('⚠️  Proceduri audit: ' || SUBSTR(SQLERRM, 1, 80));
        END;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 5. Privilegii pe View-uri - cu prefix dinamic
-- =====================================================

DECLARE
    v_prefix VARCHAR2(10);
    v_client_role VARCHAR2(50);
    v_broker_role VARCHAR2(50);
    v_admin_role VARCHAR2(50);
BEGIN
    v_prefix := fn_get_role_prefix();
    v_client_role := v_prefix || 'moneyshop_client_role';
    v_broker_role := v_prefix || 'moneyshop_broker_role';
    v_admin_role := v_prefix || 'moneyshop_admin_role';
    
    DBMS_OUTPUT.PUT_LINE('Acordare privilegii pe view-uri...');
    
    -- Verifică și acordă privilegii pentru view-uri existente
    DECLARE
        v_view_count NUMBER;
    BEGIN
        -- vw_utilizatori_public
        BEGIN
            SELECT COUNT(*) INTO v_view_count
            FROM user_views
            WHERE view_name = 'VW_UTILIZATORI_PUBLIC';
            
            IF v_view_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_utilizatori_public TO ' || v_client_role || ', ' || v_broker_role || ', ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii vw_utilizatori_public acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        -- vw_aplicatii_public
        BEGIN
            SELECT COUNT(*) INTO v_view_count
            FROM user_views
            WHERE view_name = 'VW_APLICATII_PUBLIC';
            
            IF v_view_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_aplicatii_public TO ' || v_client_role || ', ' || v_broker_role || ', ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii vw_aplicatii_public acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        -- vw_utilizatori_decrypted
        BEGIN
            SELECT COUNT(*) INTO v_view_count
            FROM user_views
            WHERE view_name = 'VW_UTILIZATORI_DECRYPTED';
            
            IF v_view_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_utilizatori_decrypted TO ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii vw_utilizatori_decrypted acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        -- vw_audit_log_recent
        BEGIN
            SELECT COUNT(*) INTO v_view_count
            FROM user_views
            WHERE view_name = 'VW_AUDIT_LOG_RECENT';
            
            IF v_view_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_audit_log_recent TO ' || v_admin_role;
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_audit_statistics TO ' || v_admin_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii view-uri audit acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        -- vw_client_own_applications
        BEGIN
            SELECT COUNT(*) INTO v_view_count
            FROM user_views
            WHERE view_name = 'VW_CLIENT_OWN_APPLICATIONS';
            
            IF v_view_count > 0 THEN
                EXECUTE IMMEDIATE 'GRANT SELECT ON vw_client_own_applications TO ' || v_client_role;
                DBMS_OUTPUT.PUT_LINE('✅ Privilegii vw_client_own_applications acordate');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 6. Ierarhii de Privilegii - cu prefix dinamic
-- =====================================================

DECLARE
    v_prefix VARCHAR2(10);
    v_client_role VARCHAR2(50);
    v_broker_role VARCHAR2(50);
    v_admin_role VARCHAR2(50);
BEGIN
    v_prefix := fn_get_role_prefix();
    v_client_role := v_prefix || 'moneyshop_client_role';
    v_broker_role := v_prefix || 'moneyshop_broker_role';
    v_admin_role := v_prefix || 'moneyshop_admin_role';
    
    DBMS_OUTPUT.PUT_LINE('Configurare ierarhie privilegii...');
    
    -- Ierarhie: ADMIN > BROKER > CLIENT
    BEGIN
        EXECUTE IMMEDIATE 'GRANT ' || v_client_role || ' TO ' || v_broker_role;
        EXECUTE IMMEDIATE 'GRANT ' || v_broker_role || ' TO ' || v_admin_role;
        DBMS_OUTPUT.PUT_LINE('✅ Ierarhie configurată: ADMIN > BROKER > CLIENT');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Eroare ierarhie: ' || SUBSTR(SQLERRM, 1, 100));
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 7. Privilegii asupra Obiectelor Dependente
-- =====================================================

-- NOTĂ: GRANT OPTION nu poate fi folosit cu roluri, doar cu utilizatori
-- Dacă vrei să acorzi privilegii cu GRANT OPTION, acordă-le direct utilizatorilor, nu rolurilor

DECLARE
    v_prefix VARCHAR2(10);
    v_admin_role VARCHAR2(50);
BEGIN
    v_prefix := fn_get_role_prefix();
    v_admin_role := v_prefix || 'moneyshop_admin_role';
    
    DBMS_OUTPUT.PUT_LINE('Privilegii asupra obiectelor dependente...');
    DBMS_OUTPUT.PUT_LINE('⚠️  GRANT OPTION nu este suportat pentru roluri');
    DBMS_OUTPUT.PUT_LINE('   (Privilegiile sunt deja acordate în secțiunea anterioară)');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- 8. Verificare Finală
-- =====================================================

DECLARE
    v_prefix VARCHAR2(10) := '';
    v_role_count NUMBER;
    v_container VARCHAR2(128);
    v_is_cdb NUMBER;
BEGIN
    -- Determinare prefix din nou (fără să depindă de tabelul temporar)
    BEGIN
        SELECT COUNT(*) INTO v_is_cdb
        FROM v$database
        WHERE cdb = 'YES';
        
        SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;
        
        IF v_is_cdb > 0 AND v_container = 'CDB$ROOT' THEN
            v_prefix := 'C##';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_prefix := '';
    END;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('✅ PRIVILEGII ȘI ROLURI CONFIGURATE!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Verificare roluri create
    BEGIN
        SELECT COUNT(*) INTO v_role_count
        FROM user_roles
        WHERE role LIKE v_prefix || 'MONEYSHOP%';
        
        DBMS_OUTPUT.PUT_LINE('Roluri create: ' || v_role_count);
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Lista roluri:');
        
        FOR rec IN (
            SELECT role
            FROM user_roles
            WHERE role LIKE v_prefix || 'MONEYSHOP%'
            ORDER BY role
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ✅ ' || rec.role);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Eroare la verificare roluri: ' || SUBSTR(SQLERRM, 1, 100));
            -- Listare manuală
            DBMS_OUTPUT.PUT_LINE('  ✅ ' || v_prefix || 'moneyshop_client_role');
            DBMS_OUTPUT.PUT_LINE('  ✅ ' || v_prefix || 'moneyshop_broker_role');
            DBMS_OUTPUT.PUT_LINE('  ✅ ' || v_prefix || 'moneyshop_admin_role');
            DBMS_OUTPUT.PUT_LINE('  ✅ ' || v_prefix || 'moneyshop_readonly_role');
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Ierarhie: ADMIN > BROKER > CLIENT');
    DBMS_OUTPUT.PUT_LINE('Container: ' || v_container);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Curățare tabel temporar (dacă există)
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE temp_role_prefix';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    
    -- Ștergere funcție helper (opțional)
    BEGIN
        EXECUTE IMMEDIATE 'DROP FUNCTION fn_get_role_prefix';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
END;
/

