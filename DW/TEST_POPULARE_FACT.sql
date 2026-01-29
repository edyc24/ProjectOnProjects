-- =====================================================
-- TEST POPULARE FACT TABLE - DEBUG
-- =====================================================

-- 1. Verifică datele din view-uri
SELECT COUNT(*) as aplicatii_total FROM VW_ETL_EXTRACT_APLICATII;

-- 2. Testează JOIN-ul cu DIM_TIMP
SELECT COUNT(*) as aplicatii_cu_timp
FROM VW_ETL_EXTRACT_APLICATII e
JOIN DIM_TIMP t ON TRUNC(e.CreatedAt) = t.DataCompleta;

-- 3. Testează JOIN-ul cu DIM_TIP_CREDIT
SELECT COUNT(*) as aplicatii_cu_tip_credit
FROM VW_ETL_EXTRACT_APLICATII e
JOIN DIM_TIP_CREDIT tc ON e.TypeCredit = tc.TypeCredit 
                      AND e.TipOperatiune = tc.TipOperatiune;

-- 4. Testează JOIN-ul cu DIM_STATUS
SELECT COUNT(*) as aplicatii_cu_status
FROM VW_ETL_EXTRACT_APLICATII e
JOIN DIM_STATUS s ON e.Status = s.Status;

-- 5. Testează toate JOIN-urile împreună
SELECT COUNT(*) as aplicatii_cu_toate_join
FROM VW_ETL_EXTRACT_APLICATII e
JOIN DIM_TIMP t ON TRUNC(e.CreatedAt) = t.DataCompleta
JOIN DIM_TIP_CREDIT tc ON e.TypeCredit = tc.TypeCredit 
                      AND e.TipOperatiune = tc.TipOperatiune
JOIN DIM_STATUS s ON e.Status = s.Status;

-- 6. Testează cu toate condițiile EXISTS
SELECT COUNT(*) as aplicatii_final
FROM VW_ETL_EXTRACT_APLICATII e
JOIN DIM_TIMP t ON TRUNC(e.CreatedAt) = t.DataCompleta
JOIN DIM_TIP_CREDIT tc ON e.TypeCredit = tc.TypeCredit 
                      AND e.TipOperatiune = tc.TipOperatiune
JOIN DIM_STATUS s ON e.Status = s.Status
WHERE EXISTS (SELECT 1 FROM DIM_UTILIZATOR d WHERE d.IdUtilizator = e.UserId)
  AND EXISTS (SELECT 1 FROM DIM_BANCA d WHERE d.IdBanca = NVL(e.BankId, 1))
  AND (e.BrokerId IS NULL OR EXISTS (SELECT 1 FROM DIM_BROKER d WHERE d.IdBroker = e.BrokerId));

-- 7. Verifică valori care nu se potrivesc
-- Verifică TypeCredit și TipOperatiune din aplicații
SELECT DISTINCT TypeCredit, TipOperatiune, COUNT(*) as count
FROM VW_ETL_EXTRACT_APLICATII
GROUP BY TypeCredit, TipOperatiune
ORDER BY TypeCredit, TipOperatiune;

-- Verifică Status din aplicații
SELECT DISTINCT Status, COUNT(*) as count
FROM VW_ETL_EXTRACT_APLICATII
GROUP BY Status
ORDER BY Status;

-- Verifică datele din DIM_TIP_CREDIT
SELECT TypeCredit, TipOperatiune FROM DIM_TIP_CREDIT;

-- Verifică datele din DIM_STATUS
SELECT Status FROM DIM_STATUS;

