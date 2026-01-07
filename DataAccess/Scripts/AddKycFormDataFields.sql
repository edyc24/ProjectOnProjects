-- Script pentru adăugarea coloanelor KYC Form Data în tabelul KycSessions
USE [MoneyShop];
GO

-- Verifică dacă coloanele există deja
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'KycSessions' AND COLUMN_NAME = 'Cnp')
BEGIN
    ALTER TABLE [KycSessions]
    ADD [Cnp] NVARCHAR(500) NULL;
    PRINT 'Coloana Cnp a fost adăugată.';
END
ELSE
BEGIN
    PRINT 'Coloana Cnp există deja.';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'KycSessions' AND COLUMN_NAME = 'Address')
BEGIN
    ALTER TABLE [KycSessions]
    ADD [Address] NVARCHAR(500) NULL;
    PRINT 'Coloana Address a fost adăugată.';
END
ELSE
BEGIN
    PRINT 'Coloana Address există deja.';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'KycSessions' AND COLUMN_NAME = 'City')
BEGIN
    ALTER TABLE [KycSessions]
    ADD [City] NVARCHAR(100) NULL;
    PRINT 'Coloana City a fost adăugată.';
END
ELSE
BEGIN
    PRINT 'Coloana City există deja.';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'KycSessions' AND COLUMN_NAME = 'County')
BEGIN
    ALTER TABLE [KycSessions]
    ADD [County] NVARCHAR(100) NULL;
    PRINT 'Coloana County a fost adăugată.';
END
ELSE
BEGIN
    PRINT 'Coloana County există deja.';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'KycSessions' AND COLUMN_NAME = 'PostalCode')
BEGIN
    ALTER TABLE [KycSessions]
    ADD [PostalCode] NVARCHAR(10) NULL;
    PRINT 'Coloana PostalCode a fost adăugată.';
END
ELSE
BEGIN
    PRINT 'Coloana PostalCode există deja.';
END
GO

PRINT 'Migrarea AddKycFormDataFields a fost aplicată cu succes!';
GO

