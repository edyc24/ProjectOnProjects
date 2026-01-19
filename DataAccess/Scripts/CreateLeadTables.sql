-- Script pentru crearea tabelelor necesare pentru Lead Capture
-- Rulează acest script în baza de date moneyshop

USE [moneyshop];
GO

-- Tabel pentru Lead Capture
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadCaptures' AND type = 'U')
BEGIN
    CREATE TABLE LeadCaptures (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NULL,
        NumePrenume NVARCHAR(120) NOT NULL,
        Telefon NVARCHAR(20) NOT NULL,
        Email NVARCHAR(200) NOT NULL,
        Oras NVARCHAR(80) NOT NULL,
        CrediteActive BIT NOT NULL DEFAULT 0,
        SoldTotalAprox DECIMAL(18,2) NULL,
        TipCreditor NVARCHAR(20) NULL,
        Intarzieri BIT NOT NULL DEFAULT 0,
        IntarzieriNumarAprox INT NULL,
        IntarzieriZileMax INT NULL,
        VenitNetLunar DECIMAL(18,2) NOT NULL,
        BonuriMasaAprox DECIMAL(18,2) NULL,
        PoprireSauExecutorUltimii5Ani BIT NOT NULL DEFAULT 0,
        SituatiePoprireInchisa BIT NULL,
        Source NVARCHAR(50) NOT NULL DEFAULT 'api',
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    
    CREATE INDEX IX_LeadCaptures_UserId ON LeadCaptures(UserId);
    CREATE INDEX IX_LeadCaptures_CreatedAt ON LeadCaptures(CreatedAt);
    
    PRINT 'Tabela LeadCaptures a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'Tabela LeadCaptures exista deja.';
END
GO

-- Tabel pentru Lead Sessions (state machine)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadSessions' AND type = 'U')
BEGIN
    CREATE TABLE LeadSessions (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        SessionKey NVARCHAR(255) NOT NULL UNIQUE,
        UserId INT NULL,
        ConversationId NVARCHAR(100) NULL,
        Step INT NOT NULL DEFAULT 1,
        SessionDataJson NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ExpiresAt DATETIME2 NULL
    );
    
    CREATE INDEX IX_LeadSessions_SessionKey ON LeadSessions(SessionKey);
    CREATE INDEX IX_LeadSessions_UserId ON LeadSessions(UserId);
    CREATE INDEX IX_LeadSessions_ExpiresAt ON LeadSessions(ExpiresAt);
    
    PRINT 'Tabela LeadSessions a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'Tabela LeadSessions exista deja.';
END
GO

-- Cleanup: Șterge sesiuni expirate (opțional, poate fi rulat periodic)
-- DELETE FROM LeadSessions WHERE ExpiresAt < GETUTCDATE();

PRINT 'Script finalizat cu succes!';
GO

