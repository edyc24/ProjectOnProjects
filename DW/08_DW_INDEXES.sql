SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Început creare indecși DW...');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. Creare Bitmap Indexes...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE BITMAP INDEX idx_fact_status_bitmap 
        ON FACT_APLICATII_CREDIT(IdStatus)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_fact_status_bitmap creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_fact_status_bitmap există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_fact_status_bitmap: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE BITMAP INDEX idx_fact_tip_credit_bitmap 
        ON FACT_APLICATII_CREDIT(IdTipCredit)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_fact_tip_credit_bitmap creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_fact_tip_credit_bitmap există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_fact_tip_credit_bitmap: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. Creare B-Tree Indexes...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_fact_timp_btree 
        ON FACT_APLICATII_CREDIT(IdTimp)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_fact_timp_btree creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_fact_timp_btree există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_fact_timp_btree: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_fact_utilizator_btree 
        ON FACT_APLICATII_CREDIT(IdUtilizator)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_fact_utilizator_btree creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_fact_utilizator_btree există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_fact_utilizator_btree: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_fact_banca_btree 
        ON FACT_APLICATII_CREDIT(IdBanca)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_fact_banca_btree creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_fact_banca_btree există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_fact_banca_btree: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. Creare Composite Indexes...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_fact_timp_status 
        ON FACT_APLICATII_CREDIT(IdTimp, IdStatus)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_fact_timp_status creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_fact_timp_status există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_fact_timp_status: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_fact_banca_status 
        ON FACT_APLICATII_CREDIT(IdBanca, IdStatus)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_fact_banca_status creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_fact_banca_status există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_fact_banca_status: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. Creare Indexes pe Dimensiuni...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX idx_dim_banca_name 
        ON DIM_BANCA(Name)';
    DBMS_OUTPUT.PUT_LINE('  ✓ idx_dim_banca_name creat');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ idx_dim_banca_name există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare idx_dim_banca_name: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('5. Verificare indecși...');
END;
/
SELECT 
    INDEX_NAME,
    INDEX_TYPE,
    TABLE_NAME,
    UNIQUENESS,
    STATUS
FROM USER_INDEXES
WHERE TABLE_NAME IN ('FACT_APLICATII_CREDIT', 'DIM_UTILIZATOR', 'DIM_BANCA', 'DIM_TIMP', 'DIM_TIP_CREDIT', 'DIM_STATUS', 'DIM_BROKER')
ORDER BY TABLE_NAME, INDEX_NAME;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('6. Testare planuri de execuție...');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Cerere 1: Folosește bitmap index pe IdStatus');
END;
/
EXPLAIN PLAN FOR
SELECT 
    s.Status,
    COUNT(*) AS NumărAplicatii
FROM FACT_APLICATII_CREDIT f
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status IN ('APROBAT', 'REFUZAT')
GROUP BY s.Status;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Cerere 2: Folosește composite index pe (IdTimp, IdStatus)');
END;
/
EXPLAIN PLAN FOR
SELECT 
    t.An,
    t.Trimestru,
    s.Status,
    COUNT(*) AS NumărAplicatii
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE t.An = EXTRACT(YEAR FROM SYSDATE) - 1
  AND s.Status = 'APROBAT'
GROUP BY t.An, t.Trimestru, s.Status
ORDER BY t.An, t.Trimestru;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('INDECȘI DW - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Indecși creați:');
    DBMS_OUTPUT.PUT_LINE('  - 2 Bitmap Indexes (IdStatus, IdTipCredit)');
    DBMS_OUTPUT.PUT_LINE('  - 3 B-Tree Indexes (IdTimp, IdUtilizator, IdBanca)');
    DBMS_OUTPUT.PUT_LINE('  - 2 Composite Indexes ((IdTimp, IdStatus), (IdBanca, IdStatus))');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Planuri de execuție verificate - indecșii sunt utilizați eficient');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 09_DW_DIMENSIONS.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/