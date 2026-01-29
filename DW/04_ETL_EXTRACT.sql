SET SERVEROUTPUT ON;
DECLARE
    v_oltp_schema VARCHAR2(128);
BEGIN
    SELECT OWNER INTO v_oltp_schema
    FROM (
        SELECT OWNER, COUNT(*) as cnt
        FROM ALL_TABLES
        WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
        GROUP BY OWNER
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;
    DBMS_OUTPUT.PUT_LINE('✓ Schema OLTP detectată: ' || v_oltp_schema);
    DBMS_OUTPUT.PUT_LINE('');
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = moneyshop_dw_user';
END;
/
DECLARE
    v_oltp_schema VARCHAR2(128);
    v_sql VARCHAR2(4000);
BEGIN
    SELECT OWNER INTO v_oltp_schema
    FROM (
        SELECT OWNER, COUNT(*) as cnt
        FROM ALL_TABLES
        WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
        GROUP BY OWNER
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;
    BEGIN
        EXECUTE IMMEDIATE 'DROP VIEW VW_ETL_EXTRACT_APLICATII';
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;
    v_sql := 'CREATE OR REPLACE VIEW VW_ETL_EXTRACT_APLICATII AS
SELECT 
    a.Id AS ApplicationId,
    a.UserId,
    a.Status,
    a.TypeCredit,
    a.TipOperatiune,
    a.SalariuNet,
    a.Scoring,
    a.Dti,
    a.SumaAprobata,
    a.Comision,
    a.CreatedAt,
    a.UpdatedAt,
    ab.BankId,
    m.BrokerId,
    CASE 
        WHEN a.UpdatedAt IS NOT NULL AND a.CreatedAt IS NOT NULL THEN
            EXTRACT(DAY FROM (a.UpdatedAt - a.CreatedAt))
        ELSE 0
    END AS DurataProcesare
FROM ' || v_oltp_schema || '.APLICATII a
LEFT JOIN (
    SELECT ApplicationId, BankId,
           ROW_NUMBER() OVER (PARTITION BY ApplicationId ORDER BY CreatedAt) AS rn
    FROM ' || v_oltp_schema || '.APPLICATION_BANKS
) ab ON a.Id = ab.ApplicationId AND ab.rn = 1
LEFT JOIN (
    SELECT UserId, BrokerId,
           ROW_NUMBER() OVER (PARTITION BY UserId ORDER BY DataMandat DESC) AS rn
    FROM ' || v_oltp_schema || '.MANDATE
    WHERE Status = ''ACTIV''
) m ON a.UserId = m.UserId AND m.rn = 1';
    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('✓ View VW_ETL_EXTRACT_APLICATII creat');
END;
/
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM VW_ETL_EXTRACT_APLICATII;
    DBMS_OUTPUT.PUT_LINE('  Număr aplicații disponibile pentru extract: ' || v_count);
END;
/
DECLARE
    v_oltp_schema VARCHAR2(128);
    v_sql VARCHAR2(4000);
    v_count NUMBER;
BEGIN
    SELECT OWNER INTO v_oltp_schema
    FROM (
        SELECT OWNER, COUNT(*) as cnt
        FROM ALL_TABLES
        WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
        GROUP BY OWNER
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;
    v_sql := 'CREATE OR REPLACE VIEW VW_ETL_EXTRACT_UTILIZATORI AS
SELECT 
    u.IdUtilizator,
    u.Nume,
    u.Prenume,
    u.Email,
    u.NumarTelefon,
    u.IdRol,
    u.DataNastere,
    u.CreatedAt,
    FLOOR(MONTHS_BETWEEN(SYSDATE, u.CreatedAt)) AS VechimeLuni
FROM ' || v_oltp_schema || '.UTILIZATORI u
WHERE u.IsDeleted = 0 OR u.IsDeleted IS NULL';
    BEGIN
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('✓ View VW_ETL_EXTRACT_UTILIZATORI creat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ Eroare la creare view VW_ETL_EXTRACT_UTILIZATORI: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('  SQL: ' || SUBSTR(v_sql, 1, 200));
            RAISE;
    END;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM VW_ETL_EXTRACT_UTILIZATORI;
        DBMS_OUTPUT.PUT_LINE('  Număr utilizatori disponibili pentru extract: ' || v_count);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ View VW_ETL_EXTRACT_UTILIZATORI nu există sau nu este accesibil');
    END;
END;
/
DECLARE
    v_oltp_schema VARCHAR2(128);
    v_sql VARCHAR2(4000);
    v_count NUMBER;
BEGIN
    SELECT OWNER INTO v_oltp_schema
    FROM (
        SELECT OWNER, COUNT(*) as cnt
        FROM ALL_TABLES
        WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
        GROUP BY OWNER
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;
    v_sql := 'CREATE OR REPLACE VIEW VW_ETL_EXTRACT_BANCI AS
SELECT 
    b.Id AS BankId,
    b.Name,
    b.CommissionPercent,
    b.Active,
    b.CreatedAt
FROM ' || v_oltp_schema || '.BANCI b';
    BEGIN
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('✓ View VW_ETL_EXTRACT_BANCI creat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ Eroare la creare view VW_ETL_EXTRACT_BANCI: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('  SQL: ' || SUBSTR(v_sql, 1, 200));
            RAISE;
    END;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM VW_ETL_EXTRACT_BANCI;
        DBMS_OUTPUT.PUT_LINE('  Număr bănci disponibile pentru extract: ' || v_count);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ View VW_ETL_EXTRACT_BANCI nu există sau nu este accesibil');
    END;
END;
/
DECLARE
    v_oltp_schema VARCHAR2(128);
    v_sql VARCHAR2(4000);
    v_count NUMBER;
BEGIN
    SELECT OWNER INTO v_oltp_schema
    FROM (
        SELECT OWNER, COUNT(*) as cnt
        FROM ALL_TABLES
        WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
        GROUP BY OWNER
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;
    v_sql := 'CREATE OR REPLACE VIEW VW_ETL_EXTRACT_BROKERI AS
SELECT 
    u.IdUtilizator AS BrokerId,
    u.Nume,
    u.Prenume,
    u.Email,
    u.CreatedAt
FROM ' || v_oltp_schema || '.UTILIZATORI u
JOIN ' || v_oltp_schema || '.ROLURI r ON u.IdRol = r.IdRol
WHERE r.NumeRol = ''BROKER''
  AND (u.IsDeleted = 0 OR u.IsDeleted IS NULL)';
    BEGIN
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('✓ View VW_ETL_EXTRACT_BROKERI creat');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ Eroare la creare view VW_ETL_EXTRACT_BROKERI: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('  SQL: ' || SUBSTR(v_sql, 1, 200));
            RAISE;
    END;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM VW_ETL_EXTRACT_BROKERI;
        DBMS_OUTPUT.PUT_LINE('  Număr brokeri disponibili pentru extract: ' || v_count);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ View VW_ETL_EXTRACT_BROKERI nu există sau nu este accesibil');
    END;
END;
/
CREATE OR REPLACE FUNCTION FN_MASK_EMAIL(p_email IN VARCHAR2) RETURN VARCHAR2
IS
    v_at_pos NUMBER;
BEGIN
    IF p_email IS NULL THEN
        RETURN NULL;
    END IF;
    v_at_pos := INSTR(p_email, '@');
    IF v_at_pos > 0 THEN
        RETURN SUBSTR(p_email, 1, 1) || '***@' || SUBSTR(p_email, v_at_pos + 1);
    ELSE
        RETURN SUBSTR(p_email, 1, 1) || '***';
    END IF;
END;
/
CREATE OR REPLACE FUNCTION FN_MASK_TELEFON(p_telefon IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
    IF p_telefon IS NULL OR LENGTH(p_telefon) < 4 THEN
        RETURN '***';
    END IF;
    RETURN SUBSTR(p_telefon, 1, 3) || '***' || SUBSTR(p_telefon, -2);
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL EXTRACT - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Views create pentru extract:');
    DBMS_OUTPUT.PUT_LINE('  - VW_ETL_EXTRACT_APLICATII');
    DBMS_OUTPUT.PUT_LINE('  - VW_ETL_EXTRACT_UTILIZATORI');
    DBMS_OUTPUT.PUT_LINE('  - VW_ETL_EXTRACT_BANCI');
    DBMS_OUTPUT.PUT_LINE('  - VW_ETL_EXTRACT_BROKERI');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Funcții helper:');
    DBMS_OUTPUT.PUT_LINE('  - FN_MASK_EMAIL');
    DBMS_OUTPUT.PUT_LINE('  - FN_MASK_TELEFON');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 05_ETL_TRANSFORM.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/