-- Script SIMPLIFICAT pentru crearea bazei de date MoneyShop
-- Această versiune folosește setările default ale SQL Server
-- Rulează acest script în SSMS conectat la serverul local

-- Verifică dacă baza de date există deja
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MoneyShop')
BEGIN
    -- Creează baza de date cu setările default (cea mai simplă metodă)
    CREATE DATABASE [MoneyShop];
    
    PRINT 'Baza de date MoneyShop a fost creată cu succes!';
    PRINT 'Folosește setările default ale SQL Server pentru fișiere.';
END
ELSE
BEGIN
    PRINT 'Baza de date MoneyShop există deja.';
END
GO

-- Folosește baza de date MoneyShop
USE [MoneyShop];
GO

-- Verifică dacă baza de date este gata pentru migrații
PRINT 'Baza de date MoneyShop este gata pentru migrații Entity Framework.';
PRINT 'Următorul pas: Rulează "dotnet ef database update" în terminal.';
GO

