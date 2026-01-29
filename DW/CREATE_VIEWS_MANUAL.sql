-- =====================================================
-- CREARE MANUALĂ VIEW-URI ETL EXTRACT
-- =====================================================
-- Rulează acest script ca moneyshop_dw_user în ORCLPDB
-- =====================================================

-- Asigură-te că ești în schema corectă
ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = moneyshop_dw_user;

-- 1. View pentru extract utilizatori
CREATE OR REPLACE VIEW VW_ETL_EXTRACT_UTILIZATORI AS
SELECT 
    u.IdUtilizator,
    u.Nume,
    u.Prenume,
    u.Email,
    u.NumarTelefon,
    u.IdRol,
    u.DataNastere,
    u.CreatedAt,
    FLOOR(MONTHS_BETWEEN(SYSDATE, u.CreatedAt)) AS VechimeLuni
FROM SYS.UTILIZATORI u
WHERE u.IsDeleted = 0 OR u.IsDeleted IS NULL;

SELECT COUNT(*) as utilizatori FROM VW_ETL_EXTRACT_UTILIZATORI;
-- Ar trebui să vezi: ~1000 utilizatori

-- 2. View pentru extract bănci
CREATE OR REPLACE VIEW VW_ETL_EXTRACT_BANCI AS
SELECT 
    b.Id AS BankId,
    b.Name,
    b.CommissionPercent,
    b.Active,
    b.CreatedAt
FROM SYS.BANCI b;

SELECT COUNT(*) as banci FROM VW_ETL_EXTRACT_BANCI;
-- Ar trebui să vezi: 6 bănci

-- 3. View pentru extract brokeri
CREATE OR REPLACE VIEW VW_ETL_EXTRACT_BROKERI AS
SELECT 
    u.IdUtilizator AS BrokerId,
    u.Nume,
    u.Prenume,
    u.Email,
    u.CreatedAt
FROM SYS.UTILIZATORI u
JOIN SYS.ROLURI r ON u.IdRol = r.IdRol
WHERE r.NumeRol = 'BROKER'
  AND (u.IsDeleted = 0 OR u.IsDeleted IS NULL);

SELECT COUNT(*) as brokeri FROM VW_ETL_EXTRACT_BROKERI;
-- Ar trebui să vezi: ~50 brokeri

-- Verificare finală
SELECT VIEW_NAME, STATUS 
FROM USER_VIEWS 
WHERE VIEW_NAME LIKE 'VW_ETL_EXTRACT%'
ORDER BY VIEW_NAME;

DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('✓ Toate view-urile ETL Extract create!');
DBMS_OUTPUT.PUT_LINE('Următorul pas: @DW/05_ETL_TRANSFORM.sql');
/

