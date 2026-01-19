-- Script pentru verificarea existenței TUTUROR tabelelor necesare pentru aplicația MoneyShop
-- Rulează acest script în baza de date moneyshop pentru a verifica ce tabele lipsesc

USE [moneyshop];
GO

PRINT '========================================';
PRINT 'Verificare TOATE tabelele MoneyShop';
PRINT '========================================';
PRINT '';

DECLARE @TotalTables INT = 0;
DECLARE @ExistingTables INT = 0;
DECLARE @MissingTablesList NVARCHAR(MAX) = '';

-- ========================================
-- Tabele de bază (legacy/vechi)
-- ========================================
PRINT '--- Tabele de bază ---';

-- BacDocuments
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BacDocuments' AND type = 'U')
BEGIN
    PRINT '✓ BacDocuments';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ BacDocuments - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'BacDocuments' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Proiectes
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Proiectes' AND type = 'U')
BEGIN
    PRINT '✓ Proiectes';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Proiectes - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Proiectes' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Roluri
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Roluri' AND type = 'U')
BEGIN
    PRINT '✓ Roluri';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Roluri - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Roluri' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- SavedProjects
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SavedProjects' AND type = 'U')
BEGIN
    PRINT '✓ SavedProjects';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ SavedProjects - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'SavedProjects' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Utilizatori
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Utilizatori' AND type = 'U')
BEGIN
    PRINT '✓ Utilizatori';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Utilizatori - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Utilizatori' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Favorites
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Favorites' AND type = 'U')
BEGIN
    PRINT '✓ Favorites';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Favorites - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Favorites' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- MoneyShop Core Entities
-- ========================================
PRINT '--- MoneyShop Core Entities ---';

-- Applications
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Applications' AND type = 'U')
BEGIN
    PRINT '✓ Applications';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Applications - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Applications' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Documents
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Documents' AND type = 'U')
BEGIN
    PRINT '✓ Documents';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Documents - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Documents' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Banks
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Banks' AND type = 'U')
BEGIN
    PRINT '✓ Banks';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Banks - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Banks' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- ApplicationBanks
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ApplicationBanks' AND type = 'U')
BEGIN
    PRINT '✓ ApplicationBanks';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ ApplicationBanks - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'ApplicationBanks' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Agreements
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Agreements' AND type = 'U')
BEGIN
    PRINT '✓ Agreements';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Agreements - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Agreements' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Leads
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Leads' AND type = 'U')
BEGIN
    PRINT '✓ Leads';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Leads - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Leads' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- OTP & Session Entities
-- ========================================
PRINT '--- OTP & Session Entities ---';

-- OtpChallenges
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'OtpChallenges' AND type = 'U')
BEGIN
    PRINT '✓ OtpChallenges';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ OtpChallenges - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'OtpChallenges' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Sessions
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Sessions' AND type = 'U')
BEGIN
    PRINT '✓ Sessions';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Sessions - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Sessions' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- Consent & Mandate Entities
-- ========================================
PRINT '--- Consent & Mandate Entities ---';

-- LegalDocs
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LegalDocs' AND type = 'U')
BEGIN
    PRINT '✓ LegalDocs';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ LegalDocs - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'LegalDocs' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Consents
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Consents' AND type = 'U')
BEGIN
    PRINT '✓ Consents';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Consents - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Consents' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- Mandates
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Mandates' AND type = 'U')
BEGIN
    PRINT '✓ Mandates';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ Mandates - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'Mandates' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- Subject Map (CNP Pseudonymization)
-- ========================================
PRINT '--- Subject Map ---';

-- SubjectMaps
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SubjectMaps' AND type = 'U')
BEGIN
    PRINT '✓ SubjectMaps';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ SubjectMaps - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'SubjectMaps' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- KYC Entities
-- ========================================
PRINT '--- KYC Entities ---';

-- KycSessions
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'KycSessions' AND type = 'U')
BEGIN
    PRINT '✓ KycSessions';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ KycSessions - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'KycSessions' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- KycFiles
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'KycFiles' AND type = 'U')
BEGIN
    PRINT '✓ KycFiles';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ KycFiles - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'KycFiles' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- Broker Directory
-- ========================================
PRINT '--- Broker Directory ---';

-- BrokerDirectories
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BrokerDirectories' AND type = 'U')
BEGIN
    PRINT '✓ BrokerDirectories';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ BrokerDirectories - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'BrokerDirectories' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- User Financial Data
-- ========================================
PRINT '--- User Financial Data ---';

-- UserFinancialData
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserFinancialData' AND type = 'U')
BEGIN
    PRINT '✓ UserFinancialData';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ UserFinancialData - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'UserFinancialData' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- Eligibility Entities
-- ========================================
PRINT '--- Eligibility Entities ---';

-- RatesRulesConfigs
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RatesRulesConfigs' AND type = 'U')
BEGIN
    PRINT '✓ RatesRulesConfigs';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ RatesRulesConfigs - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'RatesRulesConfigs' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- AnafReports
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AnafReports' AND type = 'U')
BEGIN
    PRINT '✓ AnafReports';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ AnafReports - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'AnafReports' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- BcReports
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BcReports' AND type = 'U')
BEGIN
    PRINT '✓ BcReports';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ BcReports - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'BcReports' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- Chat Entities
-- ========================================
PRINT '--- Chat Entities ---';

-- ChatRateLimits
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatRateLimits' AND type = 'U')
BEGIN
    PRINT '✓ ChatRateLimits';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ ChatRateLimits - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'ChatRateLimits' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- ChatUsages
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatUsages' AND type = 'U')
BEGIN
    PRINT '✓ ChatUsages';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ ChatUsages - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'ChatUsages' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- FaqItems
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FaqItems' AND type = 'U')
BEGIN
    PRINT '✓ FaqItems';
    SET @ExistingTables = @ExistingTables + 1;
    
    DECLARE @FaqCount INT;
    SELECT @FaqCount = COUNT(*) FROM FaqItems;
    PRINT '  ℹ Număr FAQ-uri: ' + CAST(@FaqCount AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT '✗ FaqItems - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'FaqItems' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';

-- ========================================
-- Lead Capture Entities
-- ========================================
PRINT '--- Lead Capture Entities ---';

-- LeadCaptures
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadCaptures' AND type = 'U')
BEGIN
    PRINT '✓ LeadCaptures';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ LeadCaptures - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'LeadCaptures' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

-- LeadSessions
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadSessions' AND type = 'U')
BEGIN
    PRINT '✓ LeadSessions';
    SET @ExistingTables = @ExistingTables + 1;
END
ELSE
BEGIN
    PRINT '✗ LeadSessions - LIPSEȘTE';
    SET @MissingTablesList = @MissingTablesList + 'LeadSessions' + CHAR(13) + CHAR(10);
END
SET @TotalTables = @TotalTables + 1;

PRINT '';
PRINT '========================================';
PRINT 'REZUMAT FINAL:';
PRINT '========================================';
PRINT '';

PRINT 'Tabele existente: ' + CAST(@ExistingTables AS NVARCHAR(10)) + ' / ' + CAST(@TotalTables AS NVARCHAR(10));
PRINT 'Tabele lipsă: ' + CAST(@TotalTables - @ExistingTables AS NVARCHAR(10));
PRINT '';

IF @ExistingTables = @TotalTables
BEGIN
    PRINT '✓✓✓ TOATE TABELELE SUNT CREATE! ✓✓✓';
    PRINT '';
    PRINT 'Aplicația este pregătită pentru utilizare.';
END
ELSE
BEGIN
    PRINT '✗✗✗ LIPSESC ' + CAST(@TotalTables - @ExistingTables AS NVARCHAR(10)) + ' TABELE! ✗✗✗';
    PRINT '';
    PRINT 'Tabele lipsă:';
    PRINT @MissingTablesList;
    PRINT '';
    PRINT '========================================';
    PRINT 'RECOMANDĂRI:';
    PRINT '========================================';
    PRINT '';
    PRINT '1. Rulează scriptul complet de setup:';
    PRINT '   - Complete_Database_Setup_Azure.sql (pentru tabelele de bază)';
    PRINT '';
    PRINT '2. Rulează scripturile pentru funcționalități noi:';
    
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatRateLimits' AND type = 'U')
        PRINT '   - CreateChatTables.sql';
    
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FaqItems' AND type = 'U')
        PRINT '   - CreateFaqTable.sql';
    
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadCaptures' AND type = 'U')
        PRINT '   - CreateLeadTables.sql';
    
    PRINT '';
    PRINT '3. SAU rulează migrații Entity Framework Core:';
    PRINT '   dotnet ef migrations add AddAllTables';
    PRINT '   dotnet ef database update';
END

PRINT '';
PRINT '========================================';
GO

