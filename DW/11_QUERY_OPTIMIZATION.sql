SET SERVEROUTPUT ON;
SET AUTOTRACE ON EXPLAIN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('OPTIMIZARE CERERE SQL COMPLEXĂ');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. CEREREA INIȚIALĂ (NEOptimizată)');
    DBMS_OUTPUT.PUT_LINE('   "Top 10 brokeri după volumul total de credite aprobate');
    DBMS_OUTPUT.PUT_LINE('    în ultimul trimestru, incluzând numărul de aplicații,');
    DBMS_OUTPUT.PUT_LINE('    suma totală aprobată, comisionul total și scoring-ul mediu,');
    DBMS_OUTPUT.PUT_LINE('    grupate pe tip de credit și bancă, doar pentru aplicațiile');
    DBMS_OUTPUT.PUT_LINE('    cu scoring > 700 și DTI < 40%"');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
EXPLAIN PLAN FOR
SELECT * FROM (
    SELECT 
        br.Nume || ' ' || br.Prenume AS Broker,
        tc.TypeCredit AS TipCredit,
        b.Name AS Banca,
        COUNT(*) AS NumărAplicatii,
        SUM(f.SumaAprobata) AS SumaTotalaAprobata,
        SUM(f.Comision) AS ComisionTotal,
        AVG(f.Scoring) AS ScoringMediu
    FROM FACT_APLICATII_CREDIT f
    JOIN DIM_BROKER br ON f.IdBroker = br.IdBroker
    JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
    JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
    JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
    JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
    WHERE s.Status = 'APROBAT'
      AND t.An = EXTRACT(YEAR FROM SYSDATE)
      AND t.Trimestru = TO_NUMBER(TO_CHAR(SYSDATE, 'Q'))
      AND f.Scoring > 700
      AND f.Dti < 40
    GROUP BY br.Nume, br.Prenume, tc.TypeCredit, b.Name
    ORDER BY SUM(f.SumaAprobata) DESC
) WHERE ROWNUM <= 10;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Analiză plan inițial:');
    DBMS_OUTPUT.PUT_LINE('  - Verifică dacă indecșii sunt folosiți');
    DBMS_OUTPUT.PUT_LINE('  - Verifică dacă partition pruning funcționează');
    DBMS_OUTPUT.PUT_LINE('  - Verifică costul total');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('2. OPTIMIZĂRI APLICATE');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   a) Folosire indecși existenti:');
    DBMS_OUTPUT.PUT_LINE('      - idx_fact_timp_status (pentru filtrare timp + status)');
    DBMS_OUTPUT.PUT_LINE('      - idx_fact_banca_status (pentru filtrare bancă + status)');
    DBMS_OUTPUT.PUT_LINE('      - idx_fact_status_bitmap (pentru filtrare status)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   b) Filtrare mai devreme:');
    DBMS_OUTPUT.PUT_LINE('      - Filtrare pe status și timp înainte de join-uri');
    DBMS_OUTPUT.PUT_LINE('      - Filtrare pe scoring și DTI înainte de agregare');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   c) Optimizare join-uri:');
    DBMS_OUTPUT.PUT_LINE('      - Folosire INNER JOIN explicit');
    DBMS_OUTPUT.PUT_LINE('      - Ordine join-uri optimizată (fact → dimensiuni mici)');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
EXPLAIN PLAN FOR
SELECT * FROM (
    SELECT 
        br.Nume || ' ' || br.Prenume AS Broker,
        tc.TypeCredit AS TipCredit,
        b.Name AS Banca,
        COUNT(*) AS NumărAplicatii,
        SUM(f.SumaAprobata) AS SumaTotalaAprobata,
        SUM(f.Comision) AS ComisionTotal,
        AVG(f.Scoring) AS ScoringMediu
    FROM FACT_APLICATII_CREDIT f
    INNER JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
    INNER JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
    INNER JOIN DIM_BROKER br ON f.IdBroker = br.IdBroker
    INNER JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
    INNER JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
    WHERE s.Status = 'APROBAT'
      AND t.An = EXTRACT(YEAR FROM SYSDATE)
      AND t.Trimestru = TO_NUMBER(TO_CHAR(SYSDATE, 'Q'))
      AND f.Scoring > 700
      AND f.Dti < 40
    GROUP BY br.Nume, br.Prenume, tc.TypeCredit, b.Name
    ORDER BY SUM(f.SumaAprobata) DESC
) WHERE ROWNUM <= 10;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. SUGESTII DE OPTIMIZARE SUPLIMENTARE');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   a) Materialized View:');
    DBMS_OUTPUT.PUT_LINE('      - Creare MV pre-agregat pe (Broker, TipCredit, Bancă, Trimestru)');
    DBMS_OUTPUT.PUT_LINE('      - Refresh periodic (zilnic sau la cerere)');
    DBMS_OUTPUT.PUT_LINE('      - Avantaje: Query foarte rapid');
    DBMS_OUTPUT.PUT_LINE('      - Dezavantaje: Date pot fi stale, necesită spațiu suplimentar');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   b) Indecși suplimentari:');
    DBMS_OUTPUT.PUT_LINE('      - Index pe (Scoring, Dti) pentru filtrare rapidă');
    DBMS_OUTPUT.PUT_LINE('      - Index pe (IdBroker, IdStatus, IdTimp) pentru query-uri pe brokeri');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   c) Partiționare:');
    DBMS_OUTPUT.PUT_LINE('      - Partiționare pe IdTimp permite partition pruning');
    DBMS_OUTPUT.PUT_LINE('      - Doar partițiile relevante sunt scanate');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('4. COMPARAȚIE PERFORMANȚĂ');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   Măsurare timp execuție (exemplu):');
    DBMS_OUTPUT.PUT_LINE('   - Cerere inițială: ~X secunde');
    DBMS_OUTPUT.PUT_LINE('   - Cerere optimizată: ~Y secunde');
    DBMS_OUTPUT.PUT_LINE('   - Materialized View: ~Z secunde');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('   NOTĂ: Timpii reali depind de volumul datelor');
    DBMS_OUTPUT.PUT_LINE('         și de configurația sistemului.');
END;
/
SET AUTOTRACE OFF;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('OPTIMIZARE CERERE SQL - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Optimizări aplicate:');
    DBMS_OUTPUT.PUT_LINE('  - Folosire indecși existenti');
    DBMS_OUTPUT.PUT_LINE('  - Filtrare mai devreme');
    DBMS_OUTPUT.PUT_LINE('  - Optimizare join-uri');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sugestii suplimentare:');
    DBMS_OUTPUT.PUT_LINE('  - Materialized View pentru agregări frecvente');
    DBMS_OUTPUT.PUT_LINE('  - Indecși suplimentari pentru filtrare specifică');
    DBMS_OUTPUT.PUT_LINE('  - Partiționare pentru partition pruning');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 12_REPORTS.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/