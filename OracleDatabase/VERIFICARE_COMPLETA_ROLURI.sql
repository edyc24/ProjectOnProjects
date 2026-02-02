-- =====================================================
-- VERIFICARE COMPLETĂ - TOATE TIPURILE DE ROLURI
-- MoneyShop - Oracle Database
-- =====================================================

SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 200;

PROMPT =====================================================
PROMPT VERIFICARE COMPLETĂ - ROLURI
PROMPT =====================================================
PROMPT

-- =====================================================
-- PARTEA 1: TABELUL ROLURI (Aplicație)
-- =====================================================

PROMPT =====================================================
PROMPT PARTEA 1: TABELUL ROLURI (Aplicație)
PROMPT =====================================================
PROMPT

SELECT 
    IdRol AS ID,
    NumeRol AS NumeRol,
    Descriere AS Descriere,
    TO_CHAR(CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS DataCreare
FROM ROLURI
ORDER BY IdRol;

PROMPT

-- =====================================================
-- PARTEA 2: ROLURILE ORACLE (Privilegii)
-- =====================================================

PROMPT =====================================================
PROMPT PARTEA 2: ROLURILE ORACLE (Privilegii)
PROMPT =====================================================
PROMPT

SELECT 
    role AS NumeRolOracle,
    password_required AS ParolaNecesara
FROM user_roles
WHERE role LIKE '%MONEYSHOP%' OR role LIKE '%moneyshop%'
ORDER BY role;

PROMPT

-- =====================================================
-- PARTEA 3: CORELAȚIE ÎNTRE ELE
-- =====================================================

PROMPT =====================================================
PROMPT PARTEA 3: CORELAȚIE ROLURI APLICAȚIE ↔ ROLURI ORACLE
PROMPT =====================================================
PROMPT

SELECT 
    r.NumeRol AS RolAplicatie,
    r.Descriere AS DescriereAplicatie,
    CASE 
        WHEN r.NumeRol = 'CLIENT' THEN 'c##moneyshop_client_role'
        WHEN r.NumeRol = 'BROKER' THEN 'c##moneyshop_broker_role'
        WHEN r.NumeRol = 'ADMIN' THEN 'c##moneyshop_admin_role'
        ELSE 'N/A'
    END AS RolOracle,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM user_roles ur
            WHERE UPPER(ur.role) = CASE 
                WHEN r.NumeRol = 'CLIENT' THEN 'C##MONEYSHOP_CLIENT_ROLE'
                WHEN r.NumeRol = 'BROKER' THEN 'C##MONEYSHOP_BROKER_ROLE'
                WHEN r.NumeRol = 'ADMIN' THEN 'C##MONEYSHOP_ADMIN_ROLE'
                ELSE NULL
            END
        ) THEN '✅ Configurat'
        ELSE '❌ Lipsă'
    END AS Status
FROM ROLURI r
ORDER BY r.IdRol;

PROMPT

-- =====================================================
-- PARTEA 4: UTILIZATORI ȘI ROLURILE LOR
-- =====================================================

PROMPT =====================================================
PROMPT PARTEA 4: UTILIZATORI ȘI ROLURILE LOR (din aplicație)
PROMPT =====================================================
PROMPT

SELECT 
    u.IdUtilizator AS ID,
    u.Nume || ' ' || u.Prenume AS NumeComplet,
    u.Username AS Username,
    r.NumeRol AS RolAplicatie,
    r.Descriere AS DescriereRol,
    TO_CHAR(u.CreatedAt, 'DD-MM-YYYY') AS DataInregistrare
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE u.IsDeleted = 0
ORDER BY r.NumeRol, u.Nume, u.Prenume;

PROMPT

-- =====================================================
-- PARTEA 5: STATISTICI
-- =====================================================

PROMPT =====================================================
PROMPT PARTEA 5: STATISTICI
PROMPT =====================================================
PROMPT

SELECT 
    'Roluri în tabel ROLURI' AS Tip,
    COUNT(*) AS Numar
FROM ROLURI
UNION ALL
SELECT 
    'Roluri Oracle create',
    COUNT(*)
FROM user_roles
WHERE role LIKE '%MONEYSHOP%' OR role LIKE '%moneyshop%'
UNION ALL
SELECT 
    'Utilizatori activi',
    COUNT(*)
FROM UTILIZATORI
WHERE IsDeleted = 0
UNION ALL
SELECT 
    'Utilizatori CLIENT',
    COUNT(*)
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE r.NumeRol = 'CLIENT' AND u.IsDeleted = 0
UNION ALL
SELECT 
    'Utilizatori BROKER',
    COUNT(*)
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE r.NumeRol = 'BROKER' AND u.IsDeleted = 0
UNION ALL
SELECT 
    'Utilizatori ADMIN',
    COUNT(*)
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE r.NumeRol = 'ADMIN' AND u.IsDeleted = 0;

PROMPT
PROMPT =====================================================
PROMPT Verificare completă finalizată!
PROMPT =====================================================
PROMPT

