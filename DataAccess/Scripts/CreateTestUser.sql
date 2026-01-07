-- Script pentru crearea unui utilizator de test
-- Parola: Test123! (hash-uită cu SHA256)
-- Rulează acest script în SSMS

USE [MoneyShop];
GO

-- Verifică dacă există deja un utilizator de test
IF NOT EXISTS (SELECT 1 FROM Utilizatori WHERE Mail = 'test@moneyshop.ro')
BEGIN
    -- Hash pentru parola "Test123!" folosind SHA256 + Base64
    -- Calculat: SHA256("Test123!") = Base64 encoded
    DECLARE @PasswordHash NVARCHAR(255);
    SET @PasswordHash = 'VN5/YG8lI8uo76wXP6tC+39Z1Wzv+XTI/bc0LPLP40U='; -- SHA256 hash of "Test123!"
    
    -- Verifică dacă există rolul "User" (IdRol = 1 sau altul)
    DECLARE @DefaultRoleId INT;
    SELECT @DefaultRoleId = ISNULL((SELECT TOP 1 IdRol FROM Roluri ORDER BY IdRol), 1);
    
    -- Dacă nu există roluri, creează unul
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE IdRol = @DefaultRoleId)
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('User');
        SET @DefaultRoleId = SCOPE_IDENTITY();
    END
    
    -- Creează utilizatorul de test
    INSERT INTO Utilizatori (
        Nume,
        Prenume,
        Username,
        Mail,
        Parola,
        IdRol,
        IsDeleted
    ) VALUES (
        'Test',
        'User',
        'testuser',
        'test@moneyshop.ro',
        @PasswordHash,
        @DefaultRoleId,
        0
    );
    
    PRINT 'Utilizator de test creat cu succes!';
    PRINT 'Email: test@moneyshop.ro';
    PRINT 'Parola: Test123!';
    PRINT 'ID: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Utilizatorul de test există deja.';
END
GO

-- Verifică utilizatorul creat
SELECT 
    IdUtilizator,
    Nume,
    Prenume,
    Mail,
    Username,
    IdRol,
    IsDeleted
FROM Utilizatori
WHERE Mail = 'test@moneyshop.ro';
GO

