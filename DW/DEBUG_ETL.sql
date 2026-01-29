-- =====================================================
-- DEBUG ETL - Verificare și testare manuală
-- =====================================================

-- 1. Verifică dacă view-urile ETL există
SELECT VIEW_NAME, STATUS 
FROM USER_VIEWS 
WHERE VIEW_NAME LIKE 'VW_ETL_EXTRACT%'
ORDER BY VIEW_NAME;

-- 2. Testează numărul de înregistrări în view-uri
SELECT 'VW_ETL_EXTRACT_APLICATII' as view_name, COUNT(*) as count FROM VW_ETL_EXTRACT_APLICATII
UNION ALL
SELECT 'VW_ETL_EXTRACT_UTILIZATORI', COUNT(*) FROM VW_ETL_EXTRACT_UTILIZATORI
UNION ALL
SELECT 'VW_ETL_EXTRACT_BANCI', COUNT(*) FROM VW_ETL_EXTRACT_BANCI
UNION ALL
SELECT 'VW_ETL_EXTRACT_BROKERI', COUNT(*) FROM VW_ETL_EXTRACT_BROKERI;

-- 3. Testează populare manuală DIM_UTILIZATOR
SELECT COUNT(*) as utilizatori_disponibili FROM VW_ETL_EXTRACT_UTILIZATORI;

-- 4. Testează inserare manuală (primul utilizator)
INSERT INTO DIM_UTILIZATOR (
    IdUtilizator, Nume, Prenume, EmailMasked, TelefonMasked, 
    IdRol, DataNastere, VechimeLuni, CreatedAt
)
SELECT 
    IdUtilizator, Nume, Prenume, 
    FN_MASK_EMAIL(Email) AS EmailMasked,
    FN_MASK_TELEFON(NumarTelefon) AS TelefonMasked,
    IdRol, DataNastere, VechimeLuni, CreatedAt
FROM VW_ETL_EXTRACT_UTILIZATORI
WHERE ROWNUM <= 1;

SELECT COUNT(*) as dim_utilizator_dupa_insert FROM DIM_UTILIZATOR;

-- 5. Testează populare manuală DIM_BANCA
INSERT INTO DIM_BANCA (IdBanca, Name, CommissionPercent, Active, CreatedAt)
SELECT BankId, Name, CommissionPercent, Active, CreatedAt
FROM VW_ETL_EXTRACT_BANCI;

SELECT COUNT(*) as dim_banca_dupa_insert FROM DIM_BANCA;

-- 6. Testează populare manuală DIM_BROKER
INSERT INTO DIM_BROKER (IdBroker, Nume, Prenume, EmailMasked, CreatedAt)
SELECT 
    BrokerId, Nume, Prenume, 
    FN_MASK_EMAIL(Email) AS EmailMasked,
    CreatedAt
FROM VW_ETL_EXTRACT_BROKERI;

SELECT COUNT(*) as dim_broker_dupa_insert FROM DIM_BROKER;

-- 7. Verifică erorile din proceduri
SELECT OBJECT_NAME, OBJECT_TYPE, STATUS 
FROM USER_OBJECTS 
WHERE OBJECT_NAME LIKE 'SP_ETL%'
ORDER BY OBJECT_NAME;

