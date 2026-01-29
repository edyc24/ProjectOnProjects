-- =====================================================
-- FIX POPULARE FACT TABLE
-- =====================================================

-- 1. Verifică ce valori nu se potrivesc în DIM_TIP_CREDIT
SELECT 
    'Aplicatii' as sursa,
    TypeCredit, 
    TipOperatiune, 
    COUNT(*) as count
FROM VW_ETL_EXTRACT_APLICATII
GROUP BY TypeCredit, TipOperatiune
UNION ALL
SELECT 
    'DIM_TIP_CREDIT' as sursa,
    TypeCredit,
    TipOperatiune,
    COUNT(*) as count
FROM DIM_TIP_CREDIT
ORDER BY TypeCredit, TipOperatiune;

-- 2. Verifică ce valori nu se potrivesc în DIM_STATUS
SELECT 
    'Aplicatii' as sursa,
    Status,
    COUNT(*) as count
FROM VW_ETL_EXTRACT_APLICATII
GROUP BY Status
UNION ALL
SELECT 
    'DIM_STATUS' as sursa,
    Status,
    COUNT(*) as count
FROM DIM_STATUS
ORDER BY Status;

-- 3. Testează populare manuală FACT (fără toate condițiile)
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
WHERE EXISTS (SELECT 1 FROM DIM_UTILIZATOR d WHERE d.IdUtilizator = e.UserId)
  AND EXISTS (SELECT 1 FROM DIM_BANCA d WHERE d.IdBanca = NVL(e.BankId, 1))
  AND (e.BrokerId IS NULL OR EXISTS (SELECT 1 FROM DIM_BROKER d WHERE d.IdBroker = e.BrokerId));

COMMIT;

SELECT COUNT(*) as fact_dupa_insert FROM FACT_APLICATII_CREDIT;

