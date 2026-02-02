-- =====================================================
-- SELECT-URI SEMNIFICATIVE - MoneyShop
-- Demonstrează: parola hash-uită, date mascate, date originale
-- =====================================================

SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 200;

PROMPT =====================================================
PROMPT SELECT-URI SEMNIFICATIVE - MoneyShop
PROMPT =====================================================
PROMPT

-- =====================================================
-- 1. UTILIZATORI - Date Originale vs. Mascate
-- =====================================================

PROMPT =====================================================
PROMPT 1. UTILIZATORI - Comparație Date Originale vs. Mascate
PROMPT =====================================================
PROMPT

PROMPT 1.1. Date ORIGINALE (doar pentru admin - cu parola hash-uită):
PROMPT ----------------------------------------

SELECT 
    IdUtilizator AS ID,
    Username,
    Nume,
    Prenume,
    Email,
    NumarTelefon,
    -- Parola hash-uită (nu se afișează în clar)
    SUBSTR(Parola, 1, 20) || '...' AS Parola_Hash_Partial,
    LENGTH(Parola) AS Lungime_Hash,
    CASE 
        WHEN EmailVerified = 1 THEN '✅ Verificat'
        ELSE '❌ Neverificat'
    END AS Email_Status,
    CASE 
        WHEN PhoneVerified = 1 THEN '✅ Verificat'
        ELSE '❌ Neverificat'
    END AS Phone_Status,
    TO_CHAR(DataNastere, 'DD-MM-YYYY') AS Data_Nastere,
    TO_CHAR(CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Inregistrare
FROM UTILIZATORI
WHERE IsDeleted = 0
  AND ROWNUM <= 5
ORDER BY CreatedAt DESC;

PROMPT
PROMPT 1.2. Date MASCATE (pentru utilizatori normali):
PROMPT ----------------------------------------

SELECT 
    IdUtilizator AS ID,
    Nume_Masked AS Nume,
    Prenume_Masked AS Prenume,
    Username,
    Email_Masked AS Email,
    Telefon_Masked AS Telefon,
    CASE 
        WHEN EmailVerified = 1 THEN '✅ Verificat'
        ELSE '❌ Neverificat'
    END AS Email_Status,
    IdRol,
    TO_CHAR(CreatedAt, 'DD-MM-YYYY') AS Data_Inregistrare
FROM vw_utilizatori_masked
WHERE ROWNUM <= 5
ORDER BY CreatedAt DESC;

PROMPT
PROMPT 1.3. Comparație DIRECTĂ - Original vs. Mascat:
PROMPT ----------------------------------------

SELECT 
    u.IdUtilizator AS ID,
    u.Email AS Email_Original,
    vm.Email_Masked AS Email_Mascat,
    u.NumarTelefon AS Telefon_Original,
    vm.Telefon_Masked AS Telefon_Mascat,
    u.Nume || ' ' || u.Prenume AS Nume_Original,
    vm.Nume_Masked || ' ' || vm.Prenume_Masked AS Nume_Mascat
FROM UTILIZATORI u
JOIN vw_utilizatori_masked vm ON u.IdUtilizator = vm.IdUtilizator
WHERE u.IsDeleted = 0
  AND ROWNUM <= 5
ORDER BY u.CreatedAt DESC;

PROMPT

-- =====================================================
-- 2. APLICAȚII - Date Financiare Originale vs. Mascate
-- =====================================================

PROMPT =====================================================
PROMPT 2. APLICAȚII - Date Financiare Originale vs. Mascate
PROMPT =====================================================
PROMPT

PROMPT 2.1. Date ORIGINALE (cu salariu complet):
PROMPT ----------------------------------------

SELECT 
    a.Id AS ID_Aplicatie,
    a.UserId AS ID_Utilizator,
    u.Nume || ' ' || u.Prenume AS Nume_Client,
    a.Status,
    a.TypeCredit AS Tip_Credit,
    a.SalariuNet AS Salariu_Net_Original,
    a.Scoring,
    a.Dti,
    a.RecommendedLevel AS Nivel_Recomandat,
    a.SumaAprobata AS Suma_Aprobata,
    TO_CHAR(a.CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Creare
FROM APLICATII a
JOIN UTILIZATORI u ON a.UserId = u.IdUtilizator
WHERE u.IsDeleted = 0
  AND ROWNUM <= 5
ORDER BY a.CreatedAt DESC;

PROMPT
PROMPT 2.2. Date MASCATE (salariu rotunjit):
PROMPT ----------------------------------------

SELECT 
    Id AS ID_Aplicatie,
    UserId AS ID_Utilizator,
    Status,
    TypeCredit AS Tip_Credit,
    SalariuNet_Masked AS Salariu_Net_Mascat,
    Scoring,
    Dti,
    RecommendedLevel AS Nivel_Recomandat,
    TO_CHAR(CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Creare
FROM vw_aplicatii_masked
WHERE ROWNUM <= 5
ORDER BY CreatedAt DESC;

PROMPT
PROMPT 2.3. Comparație Salariu - Original vs. Mascat:
PROMPT ----------------------------------------

SELECT 
    a.Id AS ID_Aplicatie,
    a.SalariuNet AS Salariu_Original,
    am.SalariuNet_Masked AS Salariu_Mascat,
    a.SalariuNet - am.SalariuNet_Masked AS Diferenta,
    ROUND((a.SalariuNet - am.SalariuNet_Masked) / a.SalariuNet * 100, 2) AS Procent_Mascat
FROM APLICATII a
JOIN vw_aplicatii_masked am ON a.Id = am.Id
WHERE a.SalariuNet IS NOT NULL
  AND ROWNUM <= 5
ORDER BY a.CreatedAt DESC;

PROMPT

-- =====================================================
-- 3. PAROLE HASH-UITE - Analiză Securitate
-- =====================================================

PROMPT =====================================================
PROMPT 3. PAROLE HASH-UITE - Analiză Securitate
PROMPT =====================================================
PROMPT

PROMPT 3.1. Analiză Parole Hash-uite (fără afișare completă):
PROMPT ----------------------------------------

SELECT 
    IdUtilizator AS ID,
    Username,
    Nume || ' ' || Prenume AS Nume_Complet,
    -- Primele 10 caractere din hash pentru verificare
    SUBSTR(Parola, 1, 10) || '...' AS Hash_Partial,
    LENGTH(Parola) AS Lungime_Hash,
    CASE 
        WHEN LENGTH(Parola) >= 64 THEN '✅ Hash SHA-256 (64+ caractere)'
        WHEN LENGTH(Parola) >= 40 THEN '⚠️  Hash SHA-1 (40 caractere)'
        ELSE '❌ Hash prea scurt - nesigur!'
    END AS Tip_Hash,
    TO_CHAR(CreatedAt, 'DD-MM-YYYY') AS Data_Creare
FROM UTILIZATORI
WHERE IsDeleted = 0
ORDER BY CreatedAt DESC;

PROMPT
PROMPT 3.2. Statistici Parole:
PROMPT ----------------------------------------

SELECT 
    COUNT(*) AS Total_Utilizatori,
    COUNT(DISTINCT LENGTH(Parola)) AS Tipuri_Hash_Diferite,
    MIN(LENGTH(Parola)) AS Lungime_Minima,
    MAX(LENGTH(Parola)) AS Lungime_Maxima,
    ROUND(AVG(LENGTH(Parola)), 2) AS Lungime_Medie,
    COUNT(CASE WHEN LENGTH(Parola) >= 64 THEN 1 END) AS Hash_SHA256,
    COUNT(CASE WHEN LENGTH(Parola) < 64 AND LENGTH(Parola) >= 40 THEN 1 END) AS Hash_SHA1,
    COUNT(CASE WHEN LENGTH(Parola) < 40 THEN 1 END) AS Hash_Nesigur
FROM UTILIZATORI
WHERE IsDeleted = 0;

PROMPT

-- =====================================================
-- 4. FUNCȚII DE MASCARE - Testare Directă
-- =====================================================

PROMPT =====================================================
PROMPT 4. FUNCȚII DE MASCARE - Testare Directă
PROMPT =====================================================
PROMPT

PROMPT 4.1. Test Funcții Mascare pe Date Reale:
PROMPT ----------------------------------------

SELECT 
    Email AS Email_Original,
    fn_mask_email(Email) AS Email_Mascat,
    NumarTelefon AS Telefon_Original,
    fn_mask_telefon(NumarTelefon) AS Telefon_Mascat,
    Nume AS Nume_Original,
    fn_mask_nume(Nume) AS Nume_Mascat
FROM UTILIZATORI
WHERE IsDeleted = 0
  AND ROWNUM <= 5
ORDER BY CreatedAt DESC;

PROMPT
PROMPT 4.2. Test Funcție Mascare CNP (dacă există coloana CNP):
PROMPT ----------------------------------------

-- Notă: Dacă nu există coloana CNP, acest SELECT va da eroare
-- Poți decomenta dacă ai coloana CNP în UTILIZATORI
/*
SELECT 
    CNP AS CNP_Original,
    fn_mask_cnp(CNP) AS CNP_Mascat
FROM UTILIZATORI
WHERE CNP IS NOT NULL
  AND ROWNUM <= 5;
*/

PROMPT (Comentat - coloana CNP poate să nu existe)
PROMPT

-- =====================================================
-- 5. AUDIT LOG - Istoric Activități
-- =====================================================

PROMPT =====================================================
PROMPT 5. AUDIT LOG - Istoric Activități
PROMPT =====================================================
PROMPT

PROMPT 5.1. Ultimele 10 Activități:
PROMPT ----------------------------------------

SELECT 
    Id AS ID_Audit,
    TableName AS Tabela,
    Operation AS Operatie,
    UserId AS ID_Utilizator,
    IpAddress AS IP,
    TO_CHAR(Timestamp, 'DD-MM-YYYY HH24:MI:SS') AS Data_Ora,
    EXTRACT(DAY FROM (SYSTIMESTAMP - Timestamp)) AS Zile_In_Urm,
    EXTRACT(HOUR FROM (SYSTIMESTAMP - Timestamp)) AS Ore_In_Urm
FROM (
    SELECT * FROM AUDIT_LOG
    ORDER BY Timestamp DESC
)
WHERE ROWNUM <= 10;

PROMPT
PROMPT 5.2. Statistici Audit pe Tabele:
PROMPT ----------------------------------------

SELECT 
    TableName AS Tabela,
    Operation AS Operatie,
    COUNT(*) AS Numar_Operatii,
    COUNT(DISTINCT UserId) AS Utilizatori_Unici,
    MIN(Timestamp) AS Prima_Operatie,
    MAX(Timestamp) AS Ultima_Operatie
FROM AUDIT_LOG
GROUP BY TableName, Operation
ORDER BY TableName, Operation;

PROMPT
PROMPT 5.3. Activități pe Utilizator (Top 5):
PROMPT ----------------------------------------

SELECT 
    UserId AS ID_Utilizator,
    COUNT(*) AS Numar_Activitati,
    COUNT(DISTINCT TableName) AS Tabele_Modificate,
    COUNT(DISTINCT Operation) AS Tipuri_Operatii,
    MIN(Timestamp) AS Prima_Activitatie,
    MAX(Timestamp) AS Ultima_Activitatie
FROM AUDIT_LOG
WHERE UserId IS NOT NULL
GROUP BY UserId
ORDER BY Numar_Activitati DESC
FETCH FIRST 5 ROWS ONLY;

PROMPT

-- =====================================================
-- 6. UTILIZATORI CU ROLURI - Date Complete
-- =====================================================

PROMPT =====================================================
PROMPT 6. UTILIZATORI CU ROLURI - Date Complete
PROMPT =====================================================
PROMPT

PROMPT 6.1. Utilizatori cu Roluri (date originale):
PROMPT ----------------------------------------

SELECT 
    u.IdUtilizator AS ID,
    u.Username,
    u.Nume || ' ' || u.Prenume AS Nume_Complet,
    u.Email,
    SUBSTR(u.Parola, 1, 15) || '...' AS Parola_Hash_Partial,
    r.NumeRol AS Rol,
    r.Descriere AS Descriere_Rol,
    CASE 
        WHEN u.EmailVerified = 1 AND u.PhoneVerified = 1 THEN '✅ Complet Verificat'
        WHEN u.EmailVerified = 1 THEN '⚠️  Doar Email'
        WHEN u.PhoneVerified = 1 THEN '⚠️  Doar Telefon'
        ELSE '❌ Neverificat'
    END AS Status_Verificare,
    TO_CHAR(u.CreatedAt, 'DD-MM-YYYY') AS Data_Inregistrare
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE u.IsDeleted = 0
ORDER BY u.CreatedAt DESC;

PROMPT
PROMPT 6.2. Utilizatori cu Roluri (date mascate):
PROMPT ----------------------------------------

SELECT 
    vm.IdUtilizator AS ID,
    vm.Username,
    vm.Nume_Masked || ' ' || vm.Prenume_Masked AS Nume_Complet_Mascat,
    vm.Email_Masked AS Email,
    r.NumeRol AS Rol,
    r.Descriere AS Descriere_Rol,
    CASE 
        WHEN vm.EmailVerified = 1 AND vm.PhoneVerified = 1 THEN '✅ Complet Verificat'
        WHEN vm.EmailVerified = 1 THEN '⚠️  Doar Email'
        WHEN vm.PhoneVerified = 1 THEN '⚠️  Doar Telefon'
        ELSE '❌ Neverificat'
    END AS Status_Verificare
FROM vw_utilizatori_masked vm
JOIN UTILIZATORI u ON vm.IdUtilizator = u.IdUtilizator
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE u.IsDeleted = 0
ORDER BY u.CreatedAt DESC;

PROMPT

-- =====================================================
-- 7. APLICAȚII CU DETALII COMPLETE
-- =====================================================

PROMPT =====================================================
PROMPT 7. APLICAȚII CU DETALII COMPLETE
PROMPT =====================================================
PROMPT

PROMPT 7.1. Aplicații cu Client și Date Financiare:
PROMPT ----------------------------------------

SELECT 
    a.Id AS ID_Aplicatie,
    u.Nume || ' ' || u.Prenume AS Nume_Client,
    fn_mask_email(u.Email) AS Email_Client_Mascat,
    a.Status,
    a.TypeCredit AS Tip_Credit,
    a.SalariuNet AS Salariu_Net,
    a.Scoring,
    a.Dti,
    a.RecommendedLevel AS Nivel_Recomandat,
    a.SumaAprobata AS Suma_Aprobata,
    TO_CHAR(a.CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Creare,
    TO_CHAR(a.UpdatedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Actualizare
FROM APLICATII a
JOIN UTILIZATORI u ON a.UserId = u.IdUtilizator
WHERE u.IsDeleted = 0
ORDER BY a.CreatedAt DESC;

PROMPT
PROMPT 7.2. Statistici Aplicații pe Status:
PROMPT ----------------------------------------

SELECT 
    Status,
    COUNT(*) AS Numar_Aplicatii,
    ROUND(AVG(Scoring), 2) AS Scoring_Mediu,
    ROUND(AVG(Dti), 2) AS DTI_Mediu,
    ROUND(AVG(SalariuNet), 2) AS Salariu_Net_Mediu,
    SUM(SUMAAprobata) AS Suma_Totala_Aprobata
FROM APLICATII
GROUP BY Status
ORDER BY Numar_Aplicatii DESC;

PROMPT

-- =====================================================
-- 8. REZUMAT SECURITATE - Parole și Mascare
-- =====================================================

PROMPT =====================================================
PROMPT 8. REZUMAT SECURITATE - Parole și Mascare
PROMPT =====================================================
PROMPT

PROMPT 8.1. Verificare Securitate Parole:
PROMPT ----------------------------------------

SELECT 
    'Total Utilizatori' AS Metrica,
    COUNT(*) AS Valoare
FROM UTILIZATORI
WHERE IsDeleted = 0
UNION ALL
SELECT 
    'Parole Hash SHA-256 (64+ caractere)',
    COUNT(*)
FROM UTILIZATORI
WHERE IsDeleted = 0 AND LENGTH(Parola) >= 64
UNION ALL
SELECT 
    'Parole Hash SHA-1 (40 caractere)',
    COUNT(*)
FROM UTILIZATORI
WHERE IsDeleted = 0 AND LENGTH(Parola) >= 40 AND LENGTH(Parola) < 64
UNION ALL
SELECT 
    'Parole Nesigure (< 40 caractere)',
    COUNT(*)
FROM UTILIZATORI
WHERE IsDeleted = 0 AND LENGTH(Parola) < 40
UNION ALL
SELECT 
    'Utilizatori cu Email Verificat',
    COUNT(*)
FROM UTILIZATORI
WHERE IsDeleted = 0 AND EmailVerified = 1
UNION ALL
SELECT 
    'Utilizatori cu Telefon Verificat',
    COUNT(*)
FROM UTILIZATORI
WHERE IsDeleted = 0 AND PhoneVerified = 1;

PROMPT
PROMPT 8.2. Verificare Funcții Mascare:
PROMPT ----------------------------------------

SELECT 
    'Funcții Mascare Disponibile' AS Tip,
    COUNT(*) AS Numar
FROM user_objects
WHERE object_type = 'FUNCTION'
  AND object_name LIKE 'FN_MASK%'
UNION ALL
SELECT 
    'View-uri Mascate Disponibile',
    COUNT(*)
FROM user_views
WHERE view_name LIKE '%MASKED%';

PROMPT
PROMPT 8.3. Exemplu Date Mascate vs. Originale (Side-by-Side):
PROMPT ----------------------------------------

SELECT 
    'ORIGINAL' AS Tip,
    u.Email AS Email,
    u.NumarTelefon AS Telefon,
    u.Nume || ' ' || u.Prenume AS Nume_Complet
FROM UTILIZATORI u
WHERE u.IsDeleted = 0 AND ROWNUM = 1
UNION ALL
SELECT 
    'MASCAT',
    vm.Email_Masked,
    vm.Telefon_Masked,
    vm.Nume_Masked || ' ' || vm.Prenume_Masked
FROM vw_utilizatori_masked vm
WHERE ROWNUM = 1;

PROMPT

-- =====================================================
-- 9. CONSENTURI ȘI MANDATE - Date Sensibile
-- =====================================================

PROMPT =====================================================
PROMPT 9. CONSENTURI ȘI MANDATE - Date Sensibile
PROMPT =====================================================
PROMPT

PROMPT 9.1. Consenturi cu Utilizatori (date mascate):
PROMPT ----------------------------------------

SELECT 
    c.Id AS ID_Consent,
    vm.Nume_Masked || ' ' || vm.Prenume_Masked AS Nume_Client_Mascat,
    vm.Email_Masked AS Email_Client,
    c.ConsentType AS Tip_Consent,
    c.Status,
    c.Scope,
    TO_CHAR(c.GrantedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Acordare,
    TO_CHAR(c.RevokedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Revocare
FROM CONSENTURI c
JOIN vw_utilizatori_masked vm ON c.UserId = vm.IdUtilizator
ORDER BY c.GrantedAt DESC;

PROMPT
PROMPT 9.2. Mandate cu Brokeri și Clienți (date mascate):
PROMPT ----------------------------------------

SELECT 
    m.Id AS ID_Mandat,
    vm_client.Nume_Masked || ' ' || vm_client.Prenume_Masked AS Nume_Client_Mascat,
    vm_broker.Nume_Masked || ' ' || vm_broker.Prenume_Masked AS Nume_Broker_Mascat,
    m.Status,
    TO_CHAR(m.StartDate, 'DD-MM-YYYY') AS Data_Inceput,
    TO_CHAR(m.EndDate, 'DD-MM-YYYY') AS Data_Sfarsit,
    TO_CHAR(m.CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS Data_Creare
FROM MANDATE m
JOIN vw_utilizatori_masked vm_client ON m.UserId = vm_client.IdUtilizator
JOIN UTILIZATORI u_broker ON m.BrokerId = u_broker.IdUtilizator
JOIN vw_utilizatori_masked vm_broker ON u_broker.IdUtilizator = vm_broker.IdUtilizator
ORDER BY m.CreatedAt DESC;

PROMPT

-- =====================================================
-- 10. REZUMAT FINAL - Dashboard Securitate
-- =====================================================

PROMPT =====================================================
PROMPT 10. REZUMAT FINAL - Dashboard Securitate
PROMPT =====================================================
PROMPT

SELECT 
    '📊 STATISTICI GENERALE' AS Categorie,
    '' AS Detalii,
    '' AS Valoare
FROM DUAL
UNION ALL
SELECT 
    'Total Utilizatori',
    'Activi',
    TO_CHAR(COUNT(*))
FROM UTILIZATORI
WHERE IsDeleted = 0
UNION ALL
SELECT 
    'Total Aplicații',
    'Toate statusurile',
    TO_CHAR(COUNT(*))
FROM APLICATII
UNION ALL
SELECT 
    'Total Activități Audit',
    'Ultimele 30 zile',
    TO_CHAR(COUNT(*))
FROM AUDIT_LOG
WHERE Timestamp >= SYSTIMESTAMP - INTERVAL '30' DAY
UNION ALL
SELECT 
    '',
    '',
    ''
FROM DUAL
UNION ALL
SELECT 
    '🔒 SECURITATE',
    '',
    ''
FROM DUAL
UNION ALL
SELECT 
    'Parole Hash SHA-256',
    'Securitate maximă',
    TO_CHAR(COUNT(*))
FROM UTILIZATORI
WHERE IsDeleted = 0 AND LENGTH(Parola) >= 64
UNION ALL
SELECT 
    'View-uri Mascate',
    'Disponibile',
    TO_CHAR(COUNT(*))
FROM user_views
WHERE view_name LIKE '%MASKED%'
UNION ALL
SELECT 
    'Funcții Mascare',
    'Disponibile',
    TO_CHAR(COUNT(*))
FROM user_objects
WHERE object_type = 'FUNCTION' AND object_name LIKE 'FN_MASK%';

PROMPT
PROMPT =====================================================
PROMPT ✅ SELECT-URI FINALIZATE!
PROMPT =====================================================
PROMPT

