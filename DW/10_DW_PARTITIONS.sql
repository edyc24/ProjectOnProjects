SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Început partiționare tabele DW...');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('NOTĂ: Partiționarea se face cel mai bine la crearea tabelelor.');
    DBMS_OUTPUT.PUT_LINE('Acest script arată cum se poate face partiționarea prin ALTER TABLE');
    DBMS_OUTPUT.PUT_LINE('sau prin recrearea tabelelor (dacă nu au date importante).');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. Partiționare FACT_APLICATII_CREDIT...');
    DBMS_OUTPUT.PUT_LINE('   NOTĂ: Pentru a partiționa un tabel existent, trebuie:');
    DBMS_OUTPUT.PUT_LINE('   1. Crearea unui tabel nou partizionat');
    DBMS_OUTPUT.PUT_LINE('   2. Copierea datelor');
    DBMS_OUTPUT.PUT_LINE('   3. Renumirea tabelelor');
    DBMS_OUTPUT.PUT_LINE('   Pentru simplitate, arătăm structura partiționată.');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM FACT_APLICATII_CREDIT;
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('   Tabelul este gol - putem recrea cu partiționare');
        DBMS_OUTPUT.PUT_LINE('   Structură recomandată:');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('   CREATE TABLE FACT_APLICATII_CREDIT_PARTITIONED (');
        DBMS_OUTPUT.PUT_LINE('       -- coloane...');
        DBMS_OUTPUT.PUT_LINE('   ) PARTITION BY RANGE (IdTimp) (');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2020 VALUES LESS THAN (20210101),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2021 VALUES LESS THAN (20220101),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2022 VALUES LESS THAN (20230101),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2023 VALUES LESS THAN (20240101),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2024 VALUES LESS THAN (20250101),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2025 VALUES LESS THAN (20260101),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p_future VALUES LESS THAN (MAXVALUE)');
        DBMS_OUTPUT.PUT_LINE('   );');
    ELSE
        DBMS_OUTPUT.PUT_LINE('   Tabelul are ' || v_count || ' înregistrări');
        DBMS_OUTPUT.PUT_LINE('   Pentru partiționare, folosește DBMS_REDEFINITION sau recreare tabel');
    END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. Partiționare DIM_TIMP...');
END;
/
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM DIM_TIMP;
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('   Tabelul are ' || v_count || ' înregistrări');
        DBMS_OUTPUT.PUT_LINE('   Structură recomandată pentru partiționare LIST pe An:');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('   CREATE TABLE DIM_TIMP_PARTITIONED (');
        DBMS_OUTPUT.PUT_LINE('       -- coloane...');
        DBMS_OUTPUT.PUT_LINE('   ) PARTITION BY LIST (An) (');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2020 VALUES (2020),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2021 VALUES (2021),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2022 VALUES (2022),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2023 VALUES (2023),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2024 VALUES (2024),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p2025 VALUES (2025),');
        DBMS_OUTPUT.PUT_LINE('       PARTITION p_future VALUES (2026, 2027, 2028, 2029, 2030)');
        DBMS_OUTPUT.PUT_LINE('   );');
    END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. Verificare partiționare existente...');
END;
/
SELECT 
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_POSITION,
    HIGH_VALUE
FROM USER_TAB_PARTITIONS
WHERE TABLE_NAME = 'FACT_APLICATII_CREDIT'
ORDER BY PARTITION_POSITION;
SELECT 
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_POSITION,
    HIGH_VALUE
FROM USER_TAB_PARTITIONS
WHERE TABLE_NAME = 'DIM_TIMP'
ORDER BY PARTITION_POSITION;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. Testare partition pruning...');
    DBMS_OUTPUT.PUT_LINE('   (Funcționează doar dacă tabelele sunt partizionate)');
END;
/
EXPLAIN PLAN FOR
SELECT 
    COUNT(*) AS NumărAplicatii,
    SUM(SumaAprobata) AS SumaTotalaAprobata
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
WHERE t.An = EXTRACT(YEAR FROM SYSDATE) - 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('NOTĂ: Dacă vezi "PARTITION RANGE ALL" în plan,');
    DBMS_OUTPUT.PUT_LINE('      înseamnă că toate partițiile sunt scanate.');
    DBMS_OUTPUT.PUT_LINE('      Dacă vezi "PARTITION RANGE SINGLE" sau "PARTITION RANGE ITERATOR",');
    DBMS_OUTPUT.PUT_LINE('      înseamnă că partition pruning funcționează.');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('PARTIȚIONARE DW - DOCUMENTAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Structuri partiționare recomandate:');
    DBMS_OUTPUT.PUT_LINE('  - FACT_APLICATII_CREDIT: RANGE pe IdTimp (pe an)');
    DBMS_OUTPUT.PUT_LINE('  - DIM_TIMP: LIST pe An');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('NOTĂ: Pentru a aplica partiționarea pe tabele existente,');
    DBMS_OUTPUT.PUT_LINE('      folosește DBMS_REDEFINITION sau recreare tabel.');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 11_QUERY_OPTIMIZATION.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/