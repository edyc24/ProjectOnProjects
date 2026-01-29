-- =====================================================
-- VERIFICARE DATE ÎN DW
-- =====================================================

-- Verifică numărul de înregistrări în fiecare tabel DW
SELECT 'DIM_UTILIZATOR' as tabel, COUNT(*) as numar FROM DIM_UTILIZATOR
UNION ALL
SELECT 'DIM_BANCA', COUNT(*) FROM DIM_BANCA
UNION ALL
SELECT 'DIM_BROKER', COUNT(*) FROM DIM_BROKER
UNION ALL
SELECT 'DIM_TIP_CREDIT', COUNT(*) FROM DIM_TIP_CREDIT
UNION ALL
SELECT 'DIM_STATUS', COUNT(*) FROM DIM_STATUS
UNION ALL
SELECT 'DIM_TIMP', COUNT(*) FROM DIM_TIMP
UNION ALL
SELECT 'FACT_APLICATII_CREDIT', COUNT(*) FROM FACT_APLICATII_CREDIT;

-- Dacă toate sunt 0, trebuie să rulezi ETL-ul!

