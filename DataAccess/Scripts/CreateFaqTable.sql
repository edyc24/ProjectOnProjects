-- Script pentru crearea tabelei FaqItems (FAQ Cache)
-- Rulează acest script în baza de date moneyshop

USE [moneyshop];
GO

-- Tabel pentru FAQ Cache
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FaqItems' AND type = 'U')
BEGIN
    CREATE TABLE FaqItems (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Question NVARCHAR(500) NOT NULL,
        Answer NVARCHAR(MAX) NOT NULL,
        AliasesJson NVARCHAR(MAX) NULL,
        TagsJson NVARCHAR(MAX) NULL,
        Priority INT NOT NULL DEFAULT 0,
        Enabled BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
    
    CREATE INDEX IX_FaqItems_Enabled ON FaqItems(Enabled);
    CREATE INDEX IX_FaqItems_Question ON FaqItems(Question);
    
    PRINT 'Tabela FaqItems a fost creata cu succes.';
END
ELSE
BEGIN
    PRINT 'Tabela FaqItems exista deja.';
END
GO

PRINT 'Script finalizat cu succes!';
GO

