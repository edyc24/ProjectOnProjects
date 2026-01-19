-- Script pentru verificarea existenței tuturor tabelelor necesare pentru Chat Asistent Virtual
-- Rulează acest script în baza de date moneyshop pentru a verifica ce tabele lipsesc

USE [moneyshop];
GO

PRINT '========================================';
PRINT 'Verificare tabele Chat Asistent Virtual';
PRINT '========================================';
PRINT '';

-- Verificare ChatRateLimits
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatRateLimits' AND type = 'U')
BEGIN
    PRINT '✓ ChatRateLimits - EXISTA';
    
    -- Verificare coloane
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ChatRateLimits') AND name = 'RateLimitKey')
        PRINT '  ✓ Coloana RateLimitKey exista';
    ELSE
        PRINT '  ✗ Coloana RateLimitKey LIPSEȘTE';
END
ELSE
BEGIN
    PRINT '✗ ChatRateLimits - LIPSEȘTE';
END
PRINT '';

-- Verificare ChatUsages
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatUsages' AND type = 'U')
BEGIN
    PRINT '✓ ChatUsages - EXISTA';
    
    -- Verificare coloane
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ChatUsages') AND name = 'MonthKey')
        PRINT '  ✓ Coloana MonthKey exista';
    ELSE
        PRINT '  ✗ Coloana MonthKey LIPSEȘTE';
END
ELSE
BEGIN
    PRINT '✗ ChatUsages - LIPSEȘTE';
END
PRINT '';

-- Verificare FaqItems
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FaqItems' AND type = 'U')
BEGIN
    PRINT '✓ FaqItems - EXISTA';
    
    -- Verificare coloane
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('FaqItems') AND name = 'Question')
        PRINT '  ✓ Coloana Question exista';
    ELSE
        PRINT '  ✗ Coloana Question LIPSEȘTE';
    
    -- Verificare dacă are date
    DECLARE @FaqCount INT;
    SELECT @FaqCount = COUNT(*) FROM FaqItems;
    PRINT '  ℹ Număr FAQ-uri înregistrate: ' + CAST(@FaqCount AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT '✗ FaqItems - LIPSEȘTE';
END
PRINT '';

-- Verificare LeadCaptures
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadCaptures' AND type = 'U')
BEGIN
    PRINT '✓ LeadCaptures - EXISTA';
    
    -- Verificare coloane
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('LeadCaptures') AND name = 'NumePrenume')
        PRINT '  ✓ Coloana NumePrenume exista';
    ELSE
        PRINT '  ✗ Coloana NumePrenume LIPSEȘTE';
END
ELSE
BEGIN
    PRINT '✗ LeadCaptures - LIPSEȘTE';
END
PRINT '';

-- Verificare LeadSessions
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadSessions' AND type = 'U')
BEGIN
    PRINT '✓ LeadSessions - EXISTA';
    
    -- Verificare coloane
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('LeadSessions') AND name = 'SessionKey')
        PRINT '  ✓ Coloana SessionKey exista';
    ELSE
        PRINT '  ✗ Coloana SessionKey LIPSEȘTE';
END
ELSE
BEGIN
    PRINT '✗ LeadSessions - LIPSEȘTE';
END
PRINT '';

PRINT '========================================';
PRINT 'REZUMAT:';
PRINT '========================================';

DECLARE @TotalTables INT = 5;
DECLARE @ExistingCount INT = 0;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatRateLimits' AND type = 'U') SET @ExistingCount = @ExistingCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatUsages' AND type = 'U') SET @ExistingCount = @ExistingCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FaqItems' AND type = 'U') SET @ExistingCount = @ExistingCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadCaptures' AND type = 'U') SET @ExistingCount = @ExistingCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadSessions' AND type = 'U') SET @ExistingCount = @ExistingCount + 1;

PRINT 'Tabele existente: ' + CAST(@ExistingCount AS NVARCHAR(10)) + ' / ' + CAST(@TotalTables AS NVARCHAR(10));
PRINT '';

IF @ExistingCount = @TotalTables
BEGIN
    PRINT '✓ TOATE TABELELE SUNT CREATE!';
    PRINT '';
    PRINT 'Scripturi disponibile pentru populare:';
    PRINT '  - SeedFaqItems.sql (pentru FAQ-uri)';
END
ELSE
BEGIN
    PRINT '✗ LIPSESC ' + CAST(@TotalTables - @ExistingCount AS NVARCHAR(10)) + ' TABELE!';
    PRINT '';
    PRINT 'Scripturi necesare pentru creare:';
    PRINT '';
    
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatRateLimits' AND type = 'U')
        PRINT '  ✗ CreateChatTables.sql (contine ChatRateLimits si ChatUsages)';
    ELSE
        PRINT '  ✓ CreateChatTables.sql - DEJA RULAT';
    
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FaqItems' AND type = 'U')
        PRINT '  ✗ CreateFaqTable.sql';
    ELSE
        PRINT '  ✓ CreateFaqTable.sql - DEJA RULAT';
    
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadCaptures' AND type = 'U')
        PRINT '  ✗ CreateLeadTables.sql (contine LeadCaptures si LeadSessions)';
    ELSE
        PRINT '  ✓ CreateLeadTables.sql - DEJA RULAT';
END

PRINT '';
PRINT '========================================';
GO

