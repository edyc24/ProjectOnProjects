-- Script pentru crearea tabelelor necesare pentru Chat Asistent Virtual
-- Rulează acest script în baza de date moneyshop
-- NOTA: Rulează și CreateFaqTable.sql pentru FAQ Cache

USE [moneyshop];
GO

-- Tabel pentru rate limiting
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatRateLimits' AND type = 'U')
BEGIN
    CREATE TABLE ChatRateLimits (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        RateLimitKey NVARCHAR(255) NOT NULL UNIQUE,
        Count INT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ExpiresAt DATETIME2 NULL
    );
    
    CREATE INDEX IX_ChatRateLimits_RateLimitKey ON ChatRateLimits(RateLimitKey);
    CREATE INDEX IX_ChatRateLimits_ExpiresAt ON ChatRateLimits(ExpiresAt);
    
    PRINT 'Tabela ChatRateLimits a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'Tabela ChatRateLimits exista deja.';
END
GO

-- Tabel pentru cost control / usage tracking
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChatUsages' AND type = 'U')
BEGIN
    CREATE TABLE ChatUsages (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        MonthKey NVARCHAR(10) NOT NULL UNIQUE, -- YYYY-MM
        UsdSpent DECIMAL(10,4) NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        MetaLast NVARCHAR(1000) NULL
    );
    
    CREATE INDEX IX_ChatUsages_MonthKey ON ChatUsages(MonthKey);
    
    PRINT 'Tabela ChatUsages a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'Tabela ChatUsages exista deja.';
END
GO

-- Cleanup: Șterge rate limits expirate (opțional, poate fi rulat periodic)
-- DELETE FROM ChatRateLimits WHERE ExpiresAt < GETUTCDATE();

PRINT 'Script finalizat cu succes!';
GO

