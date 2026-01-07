-- ============================================================================
-- SCRIPT COMPLET DE CONFIGURARE AZURE SQL DATABASE - MoneyShop
-- ============================================================================
-- Acest script configurează toate datele inițiale necesare pentru aplicația MoneyShop
-- 
-- INSTRUCȚIUNI:
-- 1. Conectează-te la Azure SQL Database prin Azure Portal Query Editor, Azure Data Studio sau SSMS
-- 2. Selectează baza de date: moneyshop
-- 3. Rulează acest script complet
-- 
-- NOTĂ: Scriptul este IDEMPOTENT - poate fi rulat de mai multe ori fără probleme
-- ============================================================================

PRINT '========================================';
PRINT 'Începe configurarea bazei de date MoneyShop';
PRINT '========================================';
PRINT '';

-- ============================================================================
-- SECȚIUNEA 1: POPULARE ROLURI
-- ============================================================================
PRINT '--- SECȚIUNEA 1: Populare Roluri ---';
PRINT '';

-- Verifică dacă există deja roluri
IF NOT EXISTS (SELECT 1 FROM Roluri)
BEGIN
    PRINT 'Tabelul Roluri este gol. Se populează rolurile...';
    
    -- Inserează rolurile necesare
    INSERT INTO Roluri (NumeRol) VALUES ('Utilizator');
    INSERT INTO Roluri (NumeRol) VALUES ('Administrator');
    INSERT INTO Roluri (NumeRol) VALUES ('Broker');
    
    PRINT '✓ Rolurile au fost populate cu succes!';
    PRINT '  - IdRol 1 = Utilizator';
    PRINT '  - IdRol 2 = Administrator';
    PRINT '  - IdRol 3 = Broker';
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
        PRINT '✓ Rolul "Utilizator" a fost adăugat.';
    END
    
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Administrator')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Administrator');
        PRINT '✓ Rolul "Administrator" a fost adăugat.';
    END
    
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Broker')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Broker');
        PRINT '✓ Rolul "Broker" a fost adăugat.';
    END
    
    IF EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Utilizator') 
       AND EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Administrator')
       AND EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Broker')
    BEGIN
        PRINT '✓ Toate rolurile necesare sunt prezente.';
    END
END
GO

-- ============================================================================
-- SECȚIUNEA 2: VERIFICARE ȘI CREARE CONSTRÂNGERI FOREIGN KEY
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 2: Verificare Constrângeri Foreign Key ---';
PRINT '';

-- Verifică dacă există constrângerea de foreign key pentru Utilizatori -> Roluri
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
    
    PRINT '✓ Constrângerea de foreign key a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea de foreign key FK_Utilizatori_Roluri_IdRol există deja.';
END
GO

-- ============================================================================
-- SECȚIUNEA 3: VERIFICARE MIGRAȚII APLICATE
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 3: Verificare Migrații Entity Framework ---';
PRINT '';

IF EXISTS (SELECT * FROM sys.tables WHERE name = '__EFMigrationsHistory')
BEGIN
    PRINT 'Migrații Entity Framework aplicate:';
    SELECT 
        MigrationId,
        ProductVersion,
        '✓' AS Status
    FROM [__EFMigrationsHistory]
    ORDER BY MigrationId;
    
    DECLARE @MigrationCount INT;
    SELECT @MigrationCount = COUNT(*) FROM [__EFMigrationsHistory];
    PRINT '';
    PRINT 'Total migrații aplicate: ' + CAST(@MigrationCount AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT '⚠ ATENȚIE: Tabelul __EFMigrationsHistory nu există.';
    PRINT '  Migrațiile Entity Framework nu au fost aplicate încă.';
    PRINT '  Rulează: dotnet ef database update --project DataAccess --startup-project MoneyShop';
END
GO

-- ============================================================================
-- SECȚIUNEA 4: VERIFICARE STRUCTURĂ BAZĂ DE DATE
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 4: Verificare Structură Bază de Date ---';
PRINT '';

-- Verifică tabelele principale
DECLARE @TableCount INT = 0;
DECLARE @Tables NVARCHAR(MAX) = '';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Roluri')
BEGIN
    SET @TableCount = @TableCount + 1;
    SET @Tables = @Tables + '✓ Roluri' + CHAR(13) + CHAR(10);
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Utilizatori')
BEGIN
    SET @TableCount = @TableCount + 1;
    SET @Tables = @Tables + '✓ Utilizatori' + CHAR(13) + CHAR(10);
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'KycSessions')
BEGIN
    SET @TableCount = @TableCount + 1;
    SET @Tables = @Tables + '✓ KycSessions' + CHAR(13) + CHAR(10);
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'KycFiles')
BEGIN
    SET @TableCount = @TableCount + 1;
    SET @Tables = @Tables + '✓ KycFiles' + CHAR(13) + CHAR(10);
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'OtpChallenges')
BEGIN
    SET @TableCount = @TableCount + 1;
    SET @Tables = @Tables + '✓ OtpChallenges' + CHAR(13) + CHAR(10);
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BrokerDirectories')
BEGIN
    SET @TableCount = @TableCount + 1;
    SET @Tables = @Tables + '✓ BrokerDirectories' + CHAR(13) + CHAR(10);
END

PRINT 'Tabele principale verificate:';
PRINT @Tables;
PRINT 'Total tabele verificate: ' + CAST(@TableCount AS NVARCHAR(10));
GO

-- ============================================================================
-- SECȚIUNEA 5: RAPORT FINAL
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 5: Raport Final ---';
PRINT '';

-- Numără rolurile
DECLARE @RoleCount INT;
SELECT @RoleCount = COUNT(*) FROM Roluri;
PRINT 'Roluri în baza de date: ' + CAST(@RoleCount AS NVARCHAR(10));

-- Numără utilizatorii
DECLARE @UserCount INT;
SELECT @UserCount = COUNT(*) FROM Utilizatori;
PRINT 'Utilizatori în baza de date: ' + CAST(@UserCount AS NVARCHAR(10));

-- Afișează rolurile finale
PRINT '';
PRINT 'Roluri disponibile:';
SELECT IdRol, NumeRol FROM Roluri ORDER BY IdRol;

PRINT '';
PRINT '========================================';
PRINT 'Configurarea bazei de date este completă!';
PRINT '========================================';
GO

-- ============================================================================
-- SECȚIUNEA 6: CREARE UTILIZATOR DE TEST (OPȚIONAL - COMENTAT)
-- ============================================================================
-- Decomentează această secțiune DOAR dacă vrei să creezi un utilizator de test
-- ⚠️ NU rula în production!
-- ============================================================================

/*
PRINT '';
PRINT '--- SECȚIUNEA 6: Creare Utilizator de Test (OPȚIONAL) ---';
PRINT '';

-- Verifică dacă există deja un utilizator de test
IF NOT EXISTS (SELECT 1 FROM Utilizatori WHERE Mail = 'test@moneyshop.ro')
BEGIN
    -- Hash pentru parola "Test123!" folosind SHA256 + Base64
    DECLARE @PasswordHash NVARCHAR(255);
    SET @PasswordHash = 'VN5/YG8lI8uo76wXP6tC+39Z1Wzv+XTI/bc0LPLP40U='; -- SHA256 hash of "Test123!"
    
    -- Obține IdRol pentru "Utilizator" (IdRol = 1)
    DECLARE @DefaultRoleId INT;
    SELECT @DefaultRoleId = IdRol FROM Roluri WHERE NumeRol = 'Utilizator';
    
    IF @DefaultRoleId IS NULL
    BEGIN
        -- Dacă nu există rolul "Utilizator", folosește primul rol disponibil
        SELECT @DefaultRoleId = MIN(IdRol) FROM Roluri;
    END
    
    -- Creează utilizatorul de test
    INSERT INTO Utilizatori (
        Nume,
        Prenume,
        Username,
        Mail,
        Parola,
        IdRol,
        IsDeleted,
        EmailVerified,
        PhoneVerified
    ) VALUES (
        'Test',
        'User',
        'testuser',
        'test@moneyshop.ro',
        @PasswordHash,
        @DefaultRoleId,
        0,
        0,
        0
    );
    
    PRINT '✓ Utilizator de test creat cu succes!';
    PRINT '  Email: test@moneyshop.ro';
    PRINT '  Parola: Test123!';
    PRINT '  ID: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Utilizatorul de test există deja.';
END
GO
*/

-- ============================================================================
-- FINAL
-- ============================================================================
PRINT '';
PRINT 'Script completat cu succes!';
PRINT '';
PRINT 'Baza de date este gata pentru utilizare.';
PRINT '';

