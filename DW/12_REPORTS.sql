SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('RAPOARTE SQL - BUSINESS INTELLIGENCE');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('RAPORT 1: Evoluția Aplicațiilor în Timp');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Medie | Tip grafic: Line chart');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_EVOLUTIE_APLICATII AS
SELECT 
    t.An,
    t.Trimestru,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Scoring) AS ScoringMediu,
    AVG(f.Dti) AS DtiMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIMP t ON f.IdTimp = t.IdTimp
WHERE t.An >= EXTRACT(YEAR FROM SYSDATE) - 2
GROUP BY t.An, t.Trimestru
ORDER BY t.An, t.Trimestru;
SELECT * FROM VW_REPORT_EVOLUTIE_APLICATII;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RAPORT 2: Distribuție Aplicații pe Status');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Simplă | Tip grafic: Pie chart');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_DISTRIBUTIE_STATUS AS
SELECT 
    s.Status,
    s.Categorie,
    COUNT(*) AS NumărAplicatii,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Procent
FROM FACT_APLICATII_CREDIT f
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
GROUP BY s.Status, s.Categorie
ORDER BY NumărAplicatii DESC;
SELECT * FROM VW_REPORT_DISTRIBUTIE_STATUS;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RAPORT 3: Top Bănci după Volum Credit');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Simplă | Tip grafic: Bar chart');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_TOP_BANCI AS
SELECT 
    b.Name AS Banca,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Comision) AS ComisionMediu,
    AVG(f.Scoring) AS ScoringMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status = 'APROBAT'
GROUP BY b.Name
ORDER BY SumaTotalaAprobata DESC
FETCH FIRST 10 ROWS ONLY;
SELECT * FROM VW_REPORT_TOP_BANCI;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RAPORT 4: Comparație Tipuri Credit');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Medie | Tip grafic: Bar chart (grouped)');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_COMPARATIE_TIPURI_CREDIT AS
SELECT 
    tc.TypeCredit AS TipCredit,
    tc.TipOperatiune,
    COUNT(*) AS NumărAplicatii,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Scoring) AS ScoringMediu,
    AVG(f.Dti) AS DtiMediu,
    AVG(f.DurataProcesare) AS DurataMedieProcesare
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
GROUP BY tc.TypeCredit, tc.TipOperatiune
ORDER BY NumărAplicatii DESC;
SELECT * FROM VW_REPORT_COMPARATIE_TIPURI_CREDIT;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RAPORT 5: Performanța Brokerilor');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Medie | Tip grafic: Bar chart');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_PERFORMANTA_BROKERI AS
SELECT 
    br.Nume || ' ' || br.Prenume AS Broker,
    COUNT(*) AS NumărAplicatiiAprobate,
    SUM(f.SumaAprobata) AS SumaTotalaAprobata,
    AVG(f.Scoring) AS ScoringMediu,
    SUM(f.Comision) AS ComisionTotal,
    ROUND(SUM(f.Comision) * 100.0 / NULLIF(SUM(f.SumaAprobata), 0), 2) AS ProcentComision
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BROKER br ON f.IdBroker = br.IdBroker
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status = 'APROBAT'
GROUP BY br.Nume, br.Prenume
ORDER BY NumărAplicatiiAprobate DESC
FETCH FIRST 10 ROWS ONLY;
SELECT * FROM VW_REPORT_PERFORMANTA_BROKERI;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RAPORT 6: Analiza Scoring pe Categorii');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Medie | Tip grafic: Box plot sau Bar chart');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_SCORING_CATEGORII AS
SELECT 
    u.IdRol,
    tc.TypeCredit,
    COUNT(*) AS NumărAplicatii,
    MIN(f.Scoring) AS ScoringMin,
    MAX(f.Scoring) AS ScoringMax,
    AVG(f.Scoring) AS ScoringMediu,
    ROUND(STDDEV(f.Scoring), 2) AS ScoringStdDev,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.Scoring) AS ScoringMedian
FROM FACT_APLICATII_CREDIT f
JOIN DIM_UTILIZATOR u ON f.IdUtilizator = u.IdUtilizator
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
WHERE f.Scoring IS NOT NULL
GROUP BY u.IdRol, tc.TypeCredit
ORDER BY u.IdRol, tc.TypeCredit;
SELECT * FROM VW_REPORT_SCORING_CATEGORII;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RAPORT 7: Rata de Aprobare pe Bancă');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Medie | Tip grafic: Gauge chart sau Bar chart');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_RATA_APROBARE_BANCA AS
SELECT 
    b.Name AS Banca,
    COUNT(*) AS TotalAplicatii,
    SUM(CASE WHEN s.Status = 'APROBAT' THEN 1 ELSE 0 END) AS Aprobate,
    SUM(CASE WHEN s.Status = 'REFUZAT' THEN 1 ELSE 0 END) AS Refuzate,
    ROUND(SUM(CASE WHEN s.Status = 'APROBAT' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS RataAprobare,
    AVG(CASE WHEN s.Status = 'APROBAT' THEN f.Scoring END) AS ScoringMediuAprobate,
    AVG(CASE WHEN s.Status = 'REFUZAT' THEN f.Scoring END) AS ScoringMediuRefuzate
FROM FACT_APLICATII_CREDIT f
JOIN DIM_BANCA b ON f.IdBanca = b.IdBanca
JOIN DIM_STATUS s ON f.IdStatus = s.IdStatus
WHERE s.Status IN ('APROBAT', 'REFUZAT')
GROUP BY b.Name
ORDER BY RataAprobare DESC;
SELECT * FROM VW_REPORT_RATA_APROBARE_BANCA;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('RAPORT BONUS: Analiza DTI pe Tipuri Credit');
    DBMS_OUTPUT.PUT_LINE('Complexitate: Medie | Tip grafic: Heatmap');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE VIEW VW_REPORT_DTI_TIPURI_CREDIT AS
SELECT 
    tc.TypeCredit,
    CASE 
        WHEN f.Dti < 20 THEN 'Foarte Bun (<20%)'
        WHEN f.Dti < 40 THEN 'Bun (20-40%)'
        WHEN f.Dti < 60 THEN 'Mediu (40-60%)'
        WHEN f.Dti < 80 THEN 'Risc (60-80%)'
        ELSE 'Risc Mare (>80%)'
    END AS CategorieDTI,
    COUNT(*) AS NumărAplicatii,
    AVG(f.Dti) AS DtiMediu,
    AVG(f.Scoring) AS ScoringMediu
FROM FACT_APLICATII_CREDIT f
JOIN DIM_TIP_CREDIT tc ON f.IdTipCredit = tc.IdTipCredit
WHERE f.Dti IS NOT NULL
GROUP BY tc.TypeCredit,
    CASE 
        WHEN f.Dti < 20 THEN 'Foarte Bun (<20%)'
        WHEN f.Dti < 40 THEN 'Bun (20-40%)'
        WHEN f.Dti < 60 THEN 'Mediu (40-60%)'
        WHEN f.Dti < 80 THEN 'Risc (60-80%)'
        ELSE 'Risc Mare (>80%)'
    END
ORDER BY tc.TypeCredit, DtiMediu;
SELECT * FROM VW_REPORT_DTI_TIPURI_CREDIT;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('RAPOARTE SQL - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Rapoarte create (8 total):');
    DBMS_OUTPUT.PUT_LINE('  1. VW_REPORT_EVOLUTIE_APLICATII - Evoluția aplicațiilor în timp');
    DBMS_OUTPUT.PUT_LINE('  2. VW_REPORT_DISTRIBUTIE_STATUS - Distribuție aplicații pe status');
    DBMS_OUTPUT.PUT_LINE('  3. VW_REPORT_TOP_BANCI - Top bănci după volum credit');
    DBMS_OUTPUT.PUT_LINE('  4. VW_REPORT_COMPARATIE_TIPURI_CREDIT - Comparație tipuri credit');
    DBMS_OUTPUT.PUT_LINE('  5. VW_REPORT_PERFORMANTA_BROKERI - Performanța brokerilor');
    DBMS_OUTPUT.PUT_LINE('  6. VW_REPORT_SCORING_CATEGORII - Analiza scoring pe categorii');
    DBMS_OUTPUT.PUT_LINE('  7. VW_REPORT_RATA_APROBARE_BANCA - Rata de aprobare pe bancă');
    DBMS_OUTPUT.PUT_LINE('  8. VW_REPORT_DTI_TIPURI_CREDIT - Analiza DTI pe tipuri credit (BONUS)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Toate rapoartele sunt disponibile ca VIEW-uri');
    DBMS_OUTPUT.PUT_LINE('și pot fi folosite direct în aplicația front-end.');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('FAZA 2 (BACK-END DW) - COMPLETAT! ✅');
    DBMS_OUTPUT.PUT_LINE('');
END;
/