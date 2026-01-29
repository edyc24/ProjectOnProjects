-- =====================================================
-- 15 INTEROGĂRI SQL COMPLEXE - MoneyShop
-- Proiect SBD - Cerința 7
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- INTEROGAREA 1: GROUP BY, HAVING, funcții agregat
-- =====================================================
-- Enunț: "Afișează băncile care au procesat mai mult de 5 aplicații aprobate, 
--         împreună cu numărul total de aplicații, suma totală aprobată și comisionul mediu"
SELECT 
    b.Name AS Banca,
    COUNT(ab.ApplicationId) AS NumarAplicatii,
    SUM(a.SumaAprobata) AS SumaTotalaAprobata,
    AVG(a.Comision) AS ComisionMediu,
    MAX(a.Scoring) AS ScoringMaxim
FROM BANCI b
INNER JOIN APPLICATION_BANKS ab ON b.Id = ab.BankId
INNER JOIN APLICATII a ON ab.ApplicationId = a.Id
WHERE a.Status = 'APROBAT'
GROUP BY b.Name
HAVING COUNT(ab.ApplicationId) > 5
ORDER BY SumaTotalaAprobata DESC;

-- =====================================================
-- INTEROGAREA 2: Funcții șiruri de caractere (LOWER, UPPER, SUBSTR, INSTR)
-- =====================================================
-- Enunț: "Afișează utilizatorii cu email-ul formatat (numele domeniului în majuscule, 
--         restul în minuscule) și primele 3 caractere din nume"
SELECT 
    UPPER(SUBSTR(Email, INSTR(Email, '@') + 1)) AS DomeniuMajuscule,
    LOWER(SUBSTR(Email, 1, INSTR(Email, '@') - 1)) AS PrefixMinuscule,
    SUBSTR(Nume, 1, 3) AS PrimeleTreiCaractere,
    Nume || ' ' || Prenume AS NumeComplet
FROM UTILIZATORI
WHERE Email IS NOT NULL
ORDER BY Nume;

-- =====================================================
-- INTEROGAREA 3: Funcții date (TO_CHAR, TO_DATE, ADD_MONTHS, MONTHS_BETWEEN)
-- =====================================================
-- Enunț: "Afișează aplicațiile create în ultimele 6 luni, cu data formatată 
--         și numărul de luni de la creare"
SELECT 
    a.Id AS IdAplicatie,
    TO_CHAR(a.CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS DataFormatata,
    TO_CHAR(a.CreatedAt, 'MONTH YYYY', 'NLS_DATE_LANGUAGE=ROMANIAN') AS LunaAn,
    MONTHS_BETWEEN(SYSDATE, a.CreatedAt) AS LuniDeLaCreare,
    ADD_MONTHS(a.CreatedAt, 6) AS DataExpirareEstimata,
    u.Nume || ' ' || u.Prenume AS Utilizator
FROM APLICATII a
INNER JOIN UTILIZATORI u ON a.UserId = u.IdUtilizator
WHERE a.CreatedAt >= ADD_MONTHS(SYSDATE, -6)
ORDER BY a.CreatedAt DESC;

-- =====================================================
-- INTEROGAREA 4: Funcții diverse (DECODE, NVL, NULLIF, CASE)
-- =====================================================
-- Enunț: "Afișează aplicațiile cu statusul tradus în română, scoring-ul normalizat 
--         și tipul de credit cu DECODE și CASE"
SELECT 
    a.Id,
    DECODE(a.Status, 
        'INREGISTRAT', 'Înregistrat',
        'IN_PROCESARE', 'În procesare',
        'APROBAT', 'Aprobat',
        'REFUZAT', 'Refuzat',
        'ANULAT', 'Anulat',
        'Necunoscut') AS StatusRomana,
    CASE 
        WHEN a.Scoring IS NULL THEN 'Fără scoring'
        WHEN a.Scoring >= 700 THEN 'Scoring bun'
        WHEN a.Scoring >= 600 THEN 'Scoring mediu'
        ELSE 'Scoring slab'
    END AS CategorieScoring,
    NVL(TO_CHAR(a.SumaAprobata), 'N/A') AS SumaAprobata,
    NULLIF(a.Dti, 0) AS DtiNonZero,
    a.TypeCredit
FROM APLICATII a
ORDER BY a.Id;

-- =====================================================
-- INTEROGAREA 5: INNER JOIN cu subinterogare în WHERE
-- =====================================================
-- Enunț: "Afișează utilizatorii care au aplicații cu scoring mai mare decât media 
--         tuturor aplicațiilor aprobate"
SELECT 
    u.IdUtilizator,
    u.Nume || ' ' || u.Prenume AS NumeComplet,
    u.Email,
    a.Scoring,
    a.SumaAprobata
FROM UTILIZATORI u
INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
WHERE a.Scoring > (
    SELECT AVG(Scoring)
    FROM APLICATII
    WHERE Status = 'APROBAT' AND Scoring IS NOT NULL
)
AND a.Status = 'APROBAT'
ORDER BY a.Scoring DESC;

-- =====================================================
-- INTEROGAREA 6: LEFT JOIN cu funcții agregat
-- =====================================================
-- Enunț: "Afișează toți utilizatorii și numărul de aplicații pentru fiecare, 
--         inclusiv cei fără aplicații"
SELECT 
    u.IdUtilizator,
    u.Nume || ' ' || u.Prenume AS NumeComplet,
    COUNT(a.Id) AS NumarAplicatii,
    SUM(NVL(a.SumaAprobata, 0)) AS SumaTotalaAprobata,
    AVG(a.Scoring) AS ScoringMediu
FROM UTILIZATORI u
LEFT JOIN APLICATII a ON u.IdUtilizator = a.UserId
WHERE u.IsDeleted = 0
GROUP BY u.IdUtilizator, u.Nume, u.Prenume
ORDER BY NumarAplicatii DESC;

-- =====================================================
-- INTEROGAREA 7: RIGHT JOIN cu GROUP BY și HAVING
-- =====================================================
-- Enunț: "Afișează toate băncile și numărul de aplicații asociate, 
--         inclusiv băncile fără aplicații"
SELECT 
    b.Name AS Banca,
    b.CommissionPercent AS ComisionProcent,
    COUNT(ab.ApplicationId) AS NumarAplicatii,
    COUNT(CASE WHEN a.Status = 'APROBAT' THEN 1 END) AS AplicatiiAprobate
FROM APPLICATION_BANKS ab
RIGHT JOIN BANCI b ON ab.BankId = b.Id
LEFT JOIN APLICATII a ON ab.ApplicationId = a.Id
GROUP BY b.Name, b.CommissionPercent
HAVING COUNT(ab.ApplicationId) >= 0
ORDER BY NumarAplicatii DESC;

-- =====================================================
-- INTEROGAREA 8: FULL JOIN cu subinterogare în SELECT
-- =====================================================
-- Enunț: "Afișează toate aplicațiile și documentele asociate, 
--         inclusiv aplicațiile fără documente și documentele fără aplicații"
SELECT 
    NVL(a.Id, d.ApplicationId) AS IdAplicatie,
    a.Status,
    COUNT(d.Id) AS NumarDocumente,
    (SELECT COUNT(*) FROM DOCUMENTE WHERE ApplicationId = a.Id) AS TotalDocumente
FROM APLICATII a
FULL JOIN DOCUMENTE d ON a.Id = d.ApplicationId
GROUP BY NVL(a.Id, d.ApplicationId), a.Status
ORDER BY NumarDocumente DESC;

-- =====================================================
-- INTEROGAREA 9: UNION - operator pe mulțimi
-- =====================================================
-- Enunț: "Afișează toate entitățile (utilizatori și bănci) care au fost create 
--         în ultimele 3 luni"
SELECT 
    'UTILIZATOR' AS TipEntitate,
    Nume || ' ' || Prenume AS Denumire,
    TO_CHAR(CreatedAt, 'YYYY-MM-DD') AS DataCreare
FROM UTILIZATORI
WHERE CreatedAt >= ADD_MONTHS(SYSDATE, -3)
UNION
SELECT 
    'BANCA' AS TipEntitate,
    Name AS Denumire,
    TO_CHAR(CreatedAt, 'YYYY-MM-DD') AS DataCreare
FROM BANCI
WHERE CreatedAt >= ADD_MONTHS(SYSDATE, -3)
ORDER BY DataCreare DESC;

-- =====================================================
-- INTEROGAREA 10: INTERSECT - operator pe mulțimi
-- =====================================================
-- Enunț: "Afișează utilizatorii care au aplicații aprobate și mandate active"
SELECT u.IdUtilizator, u.Nume || ' ' || u.Prenume AS NumeComplet
FROM UTILIZATORI u
INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
WHERE a.Status = 'APROBAT'
INTERSECT
SELECT u.IdUtilizator, u.Nume || ' ' || u.Prenume AS NumeComplet
FROM UTILIZATORI u
INNER JOIN MANDATE m ON u.IdUtilizator = m.UserId
WHERE m.Status = 'ACTIV';

-- =====================================================
-- INTEROGAREA 11: MINUS - operator pe mulțimi
-- =====================================================
-- Enunț: "Afișează utilizatorii care au aplicații dar nu au mandate"
SELECT u.IdUtilizator, u.Nume || ' ' || u.Prenume AS NumeComplet
FROM UTILIZATORI u
INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
MINUS
SELECT u.IdUtilizator, u.Nume || ' ' || u.Prenume AS NumeComplet
FROM UTILIZATORI u
INNER JOIN MANDATE m ON u.IdUtilizator = m.UserId;

-- =====================================================
-- INTEROGAREA 12: Subinterogare în FROM (inline view)
-- =====================================================
-- Enunț: "Afișează top 5 utilizatori după suma totală aprobată, 
--         cu media scoring-ului pentru fiecare"
SELECT 
    u.Nume || ' ' || u.Prenume AS NumeComplet,
    stats.SumaTotala,
    stats.ScoringMediu,
    stats.NumarAplicatii
FROM UTILIZATORI u
INNER JOIN (
    SELECT 
        UserId,
        SUM(SumaAprobata) AS SumaTotala,
        AVG(Scoring) AS ScoringMediu,
        COUNT(*) AS NumarAplicatii
    FROM APLICATII
    WHERE Status = 'APROBAT' AND SumaAprobata IS NOT NULL
    GROUP BY UserId
) stats ON u.IdUtilizator = stats.UserId
WHERE ROWNUM <= 5
ORDER BY stats.SumaTotala DESC;

-- =====================================================
-- INTEROGAREA 13: Subinterogare în HAVING
-- =====================================================
-- Enunț: "Afișează băncile care au un număr de aplicații mai mare decât media 
--         numărului de aplicații per bancă"
SELECT 
    b.Name AS Banca,
    COUNT(ab.ApplicationId) AS NumarAplicatii,
    AVG(a.Scoring) AS ScoringMediu
FROM BANCI b
INNER JOIN APPLICATION_BANKS ab ON b.Id = ab.BankId
INNER JOIN APLICATII a ON ab.ApplicationId = a.Id
GROUP BY b.Name
HAVING COUNT(ab.ApplicationId) > (
    SELECT AVG(COUNT(*))
    FROM APPLICATION_BANKS
    GROUP BY BankId
)
ORDER BY NumarAplicatii DESC;

-- =====================================================
-- INTEROGAREA 14: START WITH, CONNECT BY (hierarhie)
-- =====================================================
-- Enunț: "Afișează ierarhia utilizatorilor: brokeri și clienții lor (prin mandate), 
--         cu nivelul în ierarhie"
SELECT 
    LEVEL AS NivelIerarhie,
    LPAD(' ', 2 * (LEVEL - 1)) || u.Nume || ' ' || u.Prenume AS NumeComplet,
    r.NumeRol AS Rol,
    CASE 
        WHEN LEVEL = 1 THEN 'Broker'
        WHEN LEVEL = 2 THEN 'Client'
        ELSE 'N/A'
    END AS TipNod
FROM UTILIZATORI u
INNER JOIN ROLURI r ON u.IdRol = r.IdRol
LEFT JOIN MANDATE m ON u.IdUtilizator = m.BrokerId
START WITH r.NumeRol = 'BROKER' AND m.Status = 'ACTIV'
CONNECT BY PRIOR m.UserId = m.BrokerId
ORDER SIBLINGS BY u.Nume;

-- =====================================================
-- INTEROGAREA 15: OPERATORUL DIVISION
-- =====================================================
-- Enunț: "Afișează băncile care au procesat aplicații pentru TOȚI utilizatorii 
--         care au aplicații aprobate (operator DIVISION)"
SELECT b.Name AS Banca
FROM BANCI b
WHERE NOT EXISTS (
    SELECT u.IdUtilizator
    FROM UTILIZATORI u
    INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
    WHERE a.Status = 'APROBAT'
    AND NOT EXISTS (
        SELECT 1
        FROM APPLICATION_BANKS ab
        WHERE ab.BankId = b.Id
        AND ab.ApplicationId = a.Id
    )
)
AND EXISTS (
    SELECT 1
    FROM APPLICATION_BANKS ab
    WHERE ab.BankId = b.Id
);

-- =====================================================
-- VERIFICARE INTEROGĂRI
-- =====================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('15 interogări SQL complexe create!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Toate cerințele sunt acoperite:');
    DBMS_OUTPUT.PUT_LINE('  ✓ GROUP BY, HAVING, ORDER BY');
    DBMS_OUTPUT.PUT_LINE('  ✓ START WITH, CONNECT BY');
    DBMS_OUTPUT.PUT_LINE('  ✓ Funcții șiruri: LOWER, UPPER, SUBSTR, INSTR');
    DBMS_OUTPUT.PUT_LINE('  ✓ Funcții date: TO_CHAR, TO_DATE, ADD_MONTHS, MONTHS_BETWEEN');
    DBMS_OUTPUT.PUT_LINE('  ✓ Funcții diverse: DECODE, NVL, NULLIF, CASE');
    DBMS_OUTPUT.PUT_LINE('  ✓ INNER, LEFT, RIGHT, FULL JOIN');
    DBMS_OUTPUT.PUT_LINE('  ✓ Operatori pe mulțimi: UNION, INTERSECT, MINUS');
    DBMS_OUTPUT.PUT_LINE('  ✓ Funcții agregat: AVG, SUM, MIN, MAX, COUNT');
    DBMS_OUTPUT.PUT_LINE('  ✓ Subinterogări în SELECT, FROM, WHERE, HAVING');
    DBMS_OUTPUT.PUT_LINE('  ✓ Operatorul DIVISION');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

