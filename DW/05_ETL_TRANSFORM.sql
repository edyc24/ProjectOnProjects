SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE SP_ETL_TRANSFORM_DIMENSIONS
IS
    v_counter NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Început transformare dimensiuni...');
    DBMS_OUTPUT.PUT_LINE('  Transformare DIM_UTILIZATOR...');
    MERGE INTO DIM_UTILIZATOR d
    USING (
        SELECT 
            u.IdUtilizator,
            u.Nume,
            u.Prenume,
            FN_MASK_EMAIL(u.Email) AS EmailMasked,
            FN_MASK_TELEFON(u.NumarTelefon) AS TelefonMasked,
            u.IdRol,
            u.DataNastere,
            u.VechimeLuni,
            u.CreatedAt
        FROM VW_ETL_EXTRACT_UTILIZATORI u
    ) s
    ON (d.IdUtilizator = s.IdUtilizator)
    WHEN MATCHED THEN
        UPDATE SET
            d.Nume = s.Nume,
            d.Prenume = s.Prenume,
            d.EmailMasked = s.EmailMasked,
            d.TelefonMasked = s.TelefonMasked,
            d.IdRol = s.IdRol,
            d.DataNastere = s.DataNastere,
            d.VechimeLuni = s.VechimeLuni,
            d.CreatedAt = s.CreatedAt
    WHEN NOT MATCHED THEN
        INSERT (IdUtilizator, Nume, Prenume, EmailMasked, TelefonMasked, IdRol, DataNastere, VechimeLuni, CreatedAt)
        VALUES (s.IdUtilizator, s.Nume, s.Prenume, s.EmailMasked, s.TelefonMasked, s.IdRol, s.DataNastere, s.VechimeLuni, s.CreatedAt);
    v_counter := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('    ✓ DIM_UTILIZATOR: ' || v_counter || ' înregistrări procesate');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('  Transformare DIM_BANCA...');
    MERGE INTO DIM_BANCA d
    USING VW_ETL_EXTRACT_BANCI s
    ON (d.IdBanca = s.BankId)
    WHEN MATCHED THEN
        UPDATE SET
            d.Name = s.Name,
            d.CommissionPercent = s.CommissionPercent,
            d.Active = s.Active,
            d.CreatedAt = s.CreatedAt
    WHEN NOT MATCHED THEN
        INSERT (IdBanca, Name, CommissionPercent, Active, CreatedAt)
        VALUES (s.BankId, s.Name, s.CommissionPercent, s.Active, s.CreatedAt);
    v_counter := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('    ✓ DIM_BANCA: ' || v_counter || ' înregistrări procesate');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('  Transformare DIM_BROKER...');
    MERGE INTO DIM_BROKER d
    USING (
        SELECT 
            b.BrokerId,
            b.Nume,
            b.Prenume,
            FN_MASK_EMAIL(b.Email) AS EmailMasked,
            b.CreatedAt
        FROM VW_ETL_EXTRACT_BROKERI b
    ) s
    ON (d.IdBroker = s.BrokerId)
    WHEN MATCHED THEN
        UPDATE SET
            d.Nume = s.Nume,
            d.Prenume = s.Prenume,
            d.EmailMasked = s.EmailMasked,
            d.CreatedAt = s.CreatedAt
    WHEN NOT MATCHED THEN
        INSERT (IdBroker, Nume, Prenume, EmailMasked, CreatedAt)
        VALUES (s.BrokerId, s.Nume, s.Prenume, s.EmailMasked, s.CreatedAt);
    v_counter := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('    ✓ DIM_BROKER: ' || v_counter || ' înregistrări procesate');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Transformare dimensiuni completată');
END;
/
CREATE OR REPLACE PROCEDURE SP_ETL_TRANSFORM_FACT
IS
    v_counter NUMBER := 0;
    v_processed NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Început transformare fact table...');
    DELETE FROM FACT_APLICATII_CREDIT;
    DBMS_OUTPUT.PUT_LINE('  Date vechi șterse');
    INSERT INTO FACT_APLICATII_CREDIT (
        IdUtilizator,
        IdBanca,
        IdTimp,
        IdTipCredit,
        IdStatus,
        IdBroker,
        SumaAprobata,
        Comision,
        Scoring,
        Dti,
        NumărAplicatii,
        DurataProcesare,
        SalariuNet,
        SoldTotal
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
    WHERE EXISTS (SELECT 1 FROM DIM_UTILIZATOR d WHERE d.IdUtilizator = e.UserId)
      AND EXISTS (SELECT 1 FROM DIM_BANCA d WHERE d.IdBanca = NVL(e.BankId, 1))
      AND (e.BrokerId IS NULL OR EXISTS (SELECT 1 FROM DIM_BROKER d WHERE d.IdBroker = e.BrokerId));
    v_counter := SQL%ROWCOUNT;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('  ✓ FACT_APLICATII_CREDIT: ' || v_counter || ' înregistrări inserate');
    DBMS_OUTPUT.PUT_LINE('✓ Transformare fact table completată');
END;
/
CREATE OR REPLACE PROCEDURE SP_ETL_TRANSFORM_FULL
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL TRANSFORM - START');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    SP_ETL_TRANSFORM_DIMENSIONS;
    DBMS_OUTPUT.PUT_LINE('');
    SP_ETL_TRANSFORM_FACT;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ETL TRANSFORM - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Proceduri ETL Transform create:');
    DBMS_OUTPUT.PUT_LINE('  - SP_ETL_TRANSFORM_DIMENSIONS');
    DBMS_OUTPUT.PUT_LINE('  - SP_ETL_TRANSFORM_FACT');
    DBMS_OUTPUT.PUT_LINE('  - SP_ETL_TRANSFORM_FULL');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 06_ETL_LOAD.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/