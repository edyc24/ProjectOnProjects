-- Script pentru popularea tabelului Roluri cu rolurile necesare
-- Versiune pentru Azure SQL Database (baza de date: moneyshop)
-- Rulează acest script în Azure Portal Query Editor, Azure Data Studio sau SSMS

-- Nu este necesar USE [moneyshop] în Azure Query Editor, dar poate fi folosit în SSMS
-- USE [moneyshop];
-- GO

-- Verifică dacă există deja roluri
IF NOT EXISTS (SELECT 1 FROM Roluri)
BEGIN
    -- Inserează doar rolurile necesare
    INSERT INTO Roluri (NumeRol) VALUES ('Utilizator');
    INSERT INTO Roluri (NumeRol) VALUES ('Administrator');
    INSERT INTO Roluri (NumeRol) VALUES ('Broker');
    
    PRINT 'Rolurile au fost populate cu succes!';
    PRINT 'IdRol 1 = Utilizator';
    PRINT 'IdRol 2 = Administrator';
    PRINT 'IdRol 3 = Broker';
END
ELSE
BEGIN
    PRINT 'Tabelul Roluri conține deja date.';
    PRINT 'Roluri existente:';
    SELECT IdRol, NumeRol FROM Roluri ORDER BY IdRol;
    
    -- Verifică și adaugă rolurile care lipsesc
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Utilizator')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Utilizator');
        PRINT 'Rolul "Utilizator" a fost adăugat.';
    END
    
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Administrator')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Administrator');
        PRINT 'Rolul "Administrator" a fost adăugat.';
    END
    
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Broker')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Broker');
        PRINT 'Rolul "Broker" a fost adăugat.';
    END
END
GO

-- Verifică dacă există constrângerea de foreign key
IF NOT EXISTS (
    SELECT 1 
    FROM sys.foreign_keys 
    WHERE name = 'FK_Utilizatori_Roluri_IdRol'
)
BEGIN
    PRINT 'Creează constrângerea de foreign key FK_Utilizatori_Roluri_IdRol...';
    ALTER TABLE [Utilizatori]
    ADD CONSTRAINT [FK_Utilizatori_Roluri_IdRol] 
    FOREIGN KEY ([IdRol]) REFERENCES [Roluri] ([IdRol]) 
    ON DELETE CASCADE;
    
    PRINT 'Constrângerea de foreign key a fost creată.';
END
ELSE
BEGIN
    PRINT 'Constrângerea de foreign key există deja.';
END
GO

-- Verificare finală
SELECT IdRol, NumeRol FROM Roluri ORDER BY IdRol;
GO

