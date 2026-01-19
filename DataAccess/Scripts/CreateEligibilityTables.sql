-- Script pentru crearea tabelelor necesare pentru Eligibility (Eligibilitate Credit)
-- Rulează acest script în baza de date moneyshop

USE [moneyshop];
GO

PRINT '========================================';
PRINT 'Creare tabele Eligibility';
PRINT '========================================';
PRINT '';

-- ========================================
-- Tabel RatesRulesConfigs
-- ========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RatesRulesConfigs' AND type = 'U')
BEGIN
    CREATE TABLE RatesRulesConfigs (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Version NVARCHAR(50) NOT NULL,
        ConfigJson NVARCHAR(MAX) NOT NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NULL
    );
    
    CREATE INDEX IX_RatesRulesConfigs_IsActive ON RatesRulesConfigs(IsActive);
    CREATE INDEX IX_RatesRulesConfigs_Version ON RatesRulesConfigs(Version);
    
    PRINT '✓ Tabela RatesRulesConfigs a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'ℹ Tabela RatesRulesConfigs exista deja.';
END
GO

-- ========================================
-- Tabel AnafReports
-- ========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AnafReports' AND type = 'U')
BEGIN
    CREATE TABLE AnafReports (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        ReportId NVARCHAR(100) NOT NULL,
        BlobPath NVARCHAR(1000) NULL,
        FileContentBase64 NVARCHAR(MAX) NULL,
        FileName NVARCHAR(255) NULL,
        AvgNet6Months DECIMAL(18,2) NULL,
        AvgMeal6Months DECIMAL(18,2) NULL,
        PeriodMonths INT NULL,
        ParseWarnings NVARCHAR(2000) NULL,
        ParserVersion NVARCHAR(50) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ParsedAt DATETIME2 NULL
    );
    
    CREATE UNIQUE INDEX IX_AnafReports_ReportId ON AnafReports(ReportId);
    CREATE INDEX IX_AnafReports_UserId ON AnafReports(UserId);
    
    -- Foreign key către Utilizatori (dacă există)
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Utilizatori' AND type = 'U')
    BEGIN
        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_AnafReports_Utilizatori')
        BEGIN
            ALTER TABLE AnafReports
            ADD CONSTRAINT FK_AnafReports_Utilizatori
            FOREIGN KEY (UserId) REFERENCES Utilizatori(IdUtilizator)
            ON DELETE CASCADE;
            PRINT '  ✓ Foreign key către Utilizatori adăugată.';
        END
    END
    
    PRINT '✓ Tabela AnafReports a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'ℹ Tabela AnafReports exista deja.';
END
GO

-- ========================================
-- Tabel BcReports
-- ========================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BcReports' AND type = 'U')
BEGIN
    CREATE TABLE BcReports (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        ReportId NVARCHAR(100) NOT NULL,
        BlobPath NVARCHAR(1000) NULL,
        FileContentBase64 NVARCHAR(MAX) NULL,
        FileName NVARCHAR(255) NULL,
        FicoScore INT NULL,
        ExistingMonthlyObligations DECIMAL(18,2) NULL,
        Dpd30Count INT NULL,
        Dpd60Count INT NULL,
        Dpd90PlusCount INT NULL,
        NonbankClosedLast4Years INT NULL,
        NonbankActiveNow INT NULL,
        ParseWarnings NVARCHAR(2000) NULL,
        ParserVersion NVARCHAR(50) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ParsedAt DATETIME2 NULL
    );
    
    CREATE UNIQUE INDEX IX_BcReports_ReportId ON BcReports(ReportId);
    CREATE INDEX IX_BcReports_UserId ON BcReports(UserId);
    
    -- Foreign key către Utilizatori (dacă există)
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Utilizatori' AND type = 'U')
    BEGIN
        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_BcReports_Utilizatori')
        BEGIN
            ALTER TABLE BcReports
            ADD CONSTRAINT FK_BcReports_Utilizatori
            FOREIGN KEY (UserId) REFERENCES Utilizatori(IdUtilizator)
            ON DELETE CASCADE;
            PRINT '  ✓ Foreign key către Utilizatori adăugată.';
        END
    END
    
    PRINT '✓ Tabela BcReports a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'ℹ Tabela BcReports exista deja.';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'Script finalizat cu succes!';
PRINT '========================================';
PRINT '';
PRINT 'Tabele create:';
PRINT '  - RatesRulesConfigs (configurație rates & rules)';
PRINT '  - AnafReports (rapoarte ANAF)';
PRINT '  - BcReports (rapoarte Birou Credit)';
PRINT '';
GO

