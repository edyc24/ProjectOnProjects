SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE SP_ETL_FULL_LOAD
IS
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration NUMBER;
    v_count_fact NUMBER;
    v_count_dim_utilizator NUMBER;
    v_count_dim_banca NUMBER;
    v_count_dim_broker NUMBER;
    v_count_dim_tip_credit NUMBER;
    v_count_dim_status NUMBER;
    v_count_dim_timp NUMBER;
BEGIN
    v_start_time := SYSTIMESTAMP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL FULL LOAD - START');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Timp start: ' || TO_CHAR(v_start_time, 'YYYY-MM-DD HH24:MI:SS.FF'));
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('PAS 1: Transformare dimensiuni...');
    SP_ETL_TRANSFORM_DIMENSIONS;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('PAS 2: Transformare și load fact table...');
    SP_ETL_TRANSFORM_FACT;
    SELECT COUNT(*) INTO v_count_fact FROM FACT_APLICATII_CREDIT;
    v_end_time := SYSTIMESTAMP;
    v_duration := EXTRACT(SECOND FROM (v_end_time - v_start_time)) + 
                  EXTRACT(MINUTE FROM (v_end_time - v_start_time)) * 60 +
                  EXTRACT(HOUR FROM (v_end_time - v_start_time)) * 3600;
    SELECT COUNT(*) INTO v_count_dim_utilizator FROM DIM_UTILIZATOR;
    SELECT COUNT(*) INTO v_count_dim_banca FROM DIM_BANCA;
    SELECT COUNT(*) INTO v_count_dim_broker FROM DIM_BROKER;
    SELECT COUNT(*) INTO v_count_dim_tip_credit FROM DIM_TIP_CREDIT;
    SELECT COUNT(*) INTO v_count_dim_status FROM DIM_STATUS;
    SELECT COUNT(*) INTO v_count_dim_timp FROM DIM_TIMP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL FULL LOAD - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Timp final: ' || TO_CHAR(v_end_time, 'YYYY-MM-DD HH24:MI:SS.FF'));
    DBMS_OUTPUT.PUT_LINE('Durată: ' || ROUND(v_duration, 2) || ' secunde');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Rezultate:');
    DBMS_OUTPUT.PUT_LINE('  - DIM_UTILIZATOR: ' || v_count_dim_utilizator || ' înregistrări');
    DBMS_OUTPUT.PUT_LINE('  - DIM_BANCA: ' || v_count_dim_banca || ' înregistrări');
    DBMS_OUTPUT.PUT_LINE('  - DIM_BROKER: ' || v_count_dim_broker || ' înregistrări');
    DBMS_OUTPUT.PUT_LINE('  - DIM_TIP_CREDIT: ' || v_count_dim_tip_credit || ' înregistrări');
    DBMS_OUTPUT.PUT_LINE('  - DIM_STATUS: ' || v_count_dim_status || ' înregistrări');
    DBMS_OUTPUT.PUT_LINE('  - DIM_TIMP: ' || v_count_dim_timp || ' înregistrări');
    DBMS_OUTPUT.PUT_LINE('  - FACT_APLICATII_CREDIT: ' || v_count_fact || ' înregistrări');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE PROCEDURE SP_ETL_INCREMENTAL_LOAD
IS
    v_last_load_date TIMESTAMP;
    v_count_new NUMBER;
BEGIN
    v_last_load_date := SYSTIMESTAMP - INTERVAL '1' DAY;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL INCREMENTAL LOAD - START');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Căutare date noi după: ' || TO_CHAR(v_last_load_date, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Actualizare dimensiuni...');
    SP_ETL_TRANSFORM_DIMENSIONS;
    DBMS_OUTPUT.PUT_LINE('Inserare aplicații noi...');
    INSERT INTO FACT_APLICATII_CREDIT (
        IdUtilizator, IdBanca, IdTimp, IdTipCredit, IdStatus, IdBroker,
        SumaAprobata, Comision, Scoring, Dti, NumărAplicatii, DurataProcesare,
        SalariuNet, SoldTotal
    )
    SELECT 
        e.UserId AS IdUtilizator,
        NVL(e.BankId, 1) AS IdBanca,
        t.IdTimp,
        tc.IdTipCredit,
        s.IdStatus,
        e.BrokerId AS IdBroker,
        NVL(e.SumaAprobata, 0) AS SumaAprobata,
        NVL(e.Comision, 0) AS Comision,
        e.Scoring,
        e.Dti,
        1 AS NumărAplicatii,
        NVL(e.DurataProcesare, 0) AS DurataProcesare,
        e.SalariuNet,
        NULL AS SoldTotal
    FROM VW_ETL_EXTRACT_APLICATII e
    JOIN DIM_TIMP t ON TRUNC(e.CreatedAt) = t.DataCompleta
    JOIN DIM_TIP_CREDIT tc ON e.TypeCredit = tc.TypeCredit 
                          AND e.TipOperatiune = tc.TipOperatiune
    JOIN DIM_STATUS s ON e.Status = s.Status
    WHERE e.CreatedAt >= v_last_load_date
      AND NOT EXISTS (
          SELECT 1 FROM FACT_APLICATII_CREDIT f
          WHERE f.IdUtilizator = e.UserId
            AND f.IdTimp = t.IdTimp
            AND f.IdTipCredit = tc.IdTipCredit
            AND f.IdStatus = s.IdStatus
      )
      AND EXISTS (SELECT 1 FROM DIM_UTILIZATOR d WHERE d.IdUtilizator = e.UserId)
      AND EXISTS (SELECT 1 FROM DIM_BANCA d WHERE d.IdBanca = NVL(e.BankId, 1))
      AND (e.BrokerId IS NULL OR EXISTS (SELECT 1 FROM DIM_BROKER d WHERE d.IdBroker = e.BrokerId));
    v_count_new := SQL%ROWCOUNT;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL INCREMENTAL LOAD - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Aplicații noi inserate: ' || v_count_new);
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Proceduri ETL Load create:');
    DBMS_OUTPUT.PUT_LINE('  - SP_ETL_FULL_LOAD (full load)');
    DBMS_OUTPUT.PUT_LINE('  - SP_ETL_INCREMENTAL_LOAD (incremental load)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Pentru a rula ETL, execută:');
    DBMS_OUTPUT.PUT_LINE('  EXEC SP_ETL_FULL_LOAD;');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 07_DW_CONSTRAINTS.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/