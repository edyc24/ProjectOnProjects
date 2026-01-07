-- ============================================================================
-- SCRIPT COMPLET DE CREARE ȘI CONFIGURARE BAZĂ DE DATE - MoneyShop
-- ============================================================================
-- Acest script creează TOATE tabelele, constrângerile, indexurile și populează
-- datele inițiale necesare pentru aplicația MoneyShop
-- 
-- INSTRUCȚIUNI:
-- 1. Conectează-te la Azure SQL Database prin Azure Portal Query Editor, Azure Data Studio sau SSMS
-- 2. Selectează baza de date: moneyshop (sau creează-o dacă nu există)
-- 3. Rulează acest script complet
-- 
-- NOTĂ: Scriptul este IDEMPOTENT - poate fi rulat de mai multe ori fără probleme
--       Verifică existența tabelelor înainte de a le crea
-- ============================================================================

-- IMPORTANT: Selectează baza de date corectă
USE [moneyshop];
GO

-- Verifică că suntem în baza de date corectă
DECLARE @CurrentDB NVARCHAR(128);
SELECT @CurrentDB = DB_NAME();
IF @CurrentDB != 'moneyshop'
BEGIN
    PRINT 'EROARE: Nu ești conectat la baza de date moneyshop!';
    PRINT 'Baza de date curentă: ' + @CurrentDB;
    PRINT 'Te rog selectează baza de date moneyshop înainte de a rula scriptul.';
    RETURN;
END

PRINT '========================================';
PRINT 'Începe crearea completă a bazei de date MoneyShop';
PRINT 'Baza de date selectată: ' + @CurrentDB;
PRINT '========================================';
PRINT '';

-- ============================================================================
-- SECȚIUNEA 1: CREARE TABEL MIGRAȚII EF
-- ============================================================================
PRINT '--- SECȚIUNEA 1: Creare Tabel Migrații Entity Framework ---';
PRINT '';

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = '__EFMigrationsHistory' AND type = 'U')
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
    PRINT '✓ Tabelul __EFMigrationsHistory a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul __EFMigrationsHistory există deja.';
END
GO

-- ============================================================================
-- SECȚIUNEA 2: CREARE TOATE TABELELE
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 2: Creare Toate Tabelele ---';
PRINT '';

-- Tabel Roluri (trebuie primul pentru foreign keys)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roluri' AND type = 'U')
BEGIN
    CREATE TABLE [Roluri] (
        [IdRol] int NOT NULL IDENTITY(1,1),
        [NumeRol] nvarchar(50) NOT NULL,
        CONSTRAINT [PK__Roluri__2A49584C65FE7A4A] PRIMARY KEY ([IdRol])
    );
    PRINT '✓ Tabelul Roluri a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Roluri există deja.';
END
GO

-- Tabel Utilizatori
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Utilizatori' AND type = 'U')
BEGIN
    CREATE TABLE [Utilizatori] (
        [IdUtilizator] int NOT NULL IDENTITY(1,1),
        [Nume] nvarchar(255) NOT NULL,
        [Prenume] nvarchar(255) NOT NULL,
        [Username] nvarchar(255) NULL,
        [Mail] nvarchar(255) NULL,
        [Parola] nvarchar(255) NULL,
        [NumarTelefon] nvarchar(20) NULL,
        [EmailVerified] bit NOT NULL DEFAULT 0,
        [PhoneVerified] bit NOT NULL DEFAULT 0,
        [Skills] nvarchar(max) NULL,
        [Description] nvarchar(max) NULL,
        [DataIncepere] datetime NULL,
        [DataNastere] datetime NULL,
        [IdRol] int NOT NULL,
        [IsDeleted] bit NULL DEFAULT 0,
        CONSTRAINT [PK__Utilizat__99101D6D31235E34] PRIMARY KEY ([IdUtilizator])
    );
    CREATE UNIQUE INDEX [UQ__Utilizat__536C85E4B4BA6916] ON [Utilizatori] ([Username]) WHERE [Username] IS NOT NULL;
    PRINT '✓ Tabelul Utilizatori a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Utilizatori există deja.';
END
GO

-- Tabel BacDocuments
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BacDocuments' AND type = 'U')
BEGIN
    CREATE TABLE [BacDocuments] (
        [IdDocument] int NOT NULL IDENTITY(1,1),
        [NumeDocument] nvarchar(255) NOT NULL,
        [TipMaterie] nvarchar(50) NOT NULL,
        [Continut] varbinary(max) NOT NULL,
        [DataAdaugare] datetime NULL DEFAULT (getdate()),
        CONSTRAINT [PK__BacDocum__BEAAD0BAD56E4F0E] PRIMARY KEY ([IdDocument])
    );
    PRINT '✓ Tabelul BacDocuments a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul BacDocuments există deja.';
END
GO

-- Tabel Banks
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Banks' AND type = 'U')
BEGIN
    CREATE TABLE [Banks] (
        [Id] int NOT NULL IDENTITY(1,1),
        [Name] nvarchar(255) NOT NULL,
        [CommissionPercent] decimal(5,2) NOT NULL,
        [Active] bit NOT NULL,
        CONSTRAINT [PK_Banks] PRIMARY KEY ([Id])
    );
    PRINT '✓ Tabelul Banks a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Banks există deja.';
END
GO

-- Tabel Leads
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Leads' AND type = 'U')
BEGIN
    CREATE TABLE [Leads] (
        [Id] int NOT NULL IDENTITY(1,1),
        [Name] nvarchar(255) NOT NULL,
        [Phone] nvarchar(20) NULL,
        [Email] nvarchar(255) NULL,
        [Judet] nvarchar(100) NULL,
        [TypeCredit] nvarchar(50) NULL,
        [GdprConsent] bit NOT NULL,
        [IpAddress] nvarchar(50) NULL,
        [CreatedAt] datetime NOT NULL,
        [Converted] bit NOT NULL,
        [ConvertedToUserId] int NULL,
        [ConvertedToApplicationId] int NULL,
        CONSTRAINT [PK_Leads] PRIMARY KEY ([Id])
    );
    PRINT '✓ Tabelul Leads a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Leads există deja.';
END
GO

-- Tabel LegalDocs
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LegalDocs' AND type = 'U')
BEGIN
    CREATE TABLE [LegalDocs] (
        [DocId] uniqueidentifier NOT NULL,
        [DocType] nvarchar(30) NOT NULL,
        [Version] nvarchar(20) NOT NULL,
        [PublishedAt] datetime2 NOT NULL,
        [ContentHash] varbinary(max) NOT NULL,
        [IsActive] bit NOT NULL,
        CONSTRAINT [PK_LegalDocs] PRIMARY KEY ([DocId])
    );
    CREATE UNIQUE INDEX [IX_LegalDocs_DocType_Version] ON [LegalDocs] ([DocType], [Version]);
    CREATE INDEX [IX_LegalDocs_DocType_IsActive] ON [LegalDocs] ([DocType], [IsActive]);
    PRINT '✓ Tabelul LegalDocs a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul LegalDocs există deja.';
END
GO

-- Tabel Applications
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Applications' AND type = 'U')
BEGIN
    CREATE TABLE [Applications] (
        [Id] int NOT NULL IDENTITY(1,1),
        [UserId] int NOT NULL,
        [Status] nvarchar(50) NOT NULL DEFAULT N'INREGISTRAT',
        [TypeCredit] nvarchar(50) NULL,
        [TipOperatiune] nvarchar(50) NULL,
        [SalariuNet] decimal(18,2) NULL,
        [BonuriMasa] bit NULL,
        [SumaBonuriMasa] decimal(18,2) NULL,
        [VechimeLuni] int NULL,
        [NrCrediteBanci] int NULL,
        [ListaBanciActive] nvarchar(max) NULL,
        [NrIfn] int NULL,
        [Poprire] bit NULL,
        [SoldTotal] decimal(18,2) NULL,
        [Intarzieri] bit NULL,
        [IntarzieriNumar] int NULL,
        [CardCredit] nvarchar(max) NULL,
        [Overdraft] nvarchar(max) NULL,
        [Codebitori] nvarchar(max) NULL,
        [Scoring] decimal(18,2) NULL,
        [Dti] decimal(18,2) NULL,
        [RecommendedLevel] nvarchar(50) NULL,
        [SumaAprobata] decimal(18,2) NULL,
        [Comision] decimal(18,2) NULL,
        [DataDisbursare] datetime NULL,
        [CreatedAt] datetime NOT NULL,
        [UpdatedAt] datetime NOT NULL,
        CONSTRAINT [PK_Applications] PRIMARY KEY ([Id])
    );
    CREATE INDEX [IX_Applications_UserId] ON [Applications] ([UserId]);
    PRINT '✓ Tabelul Applications a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Applications există deja.';
END
GO

-- Tabel BrokerDirectories
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BrokerDirectories' AND type = 'U')
BEGIN
    CREATE TABLE [BrokerDirectories] (
        [Id] int NOT NULL IDENTITY(1,1),
        [ExcelFileName] nvarchar(255) NOT NULL,
        [BlobPath] nvarchar(1000) NOT NULL,
        [FileSize] bigint NOT NULL,
        [UploadedAt] datetime2 NOT NULL,
        [UploadedByUserId] int NOT NULL,
        [Notes] nvarchar(500) NULL,
        CONSTRAINT [PK_BrokerDirectories] PRIMARY KEY ([Id])
    );
    CREATE INDEX [IX_BrokerDirectories_UploadedAt] ON [BrokerDirectories] ([UploadedAt]);
    CREATE INDEX [IX_BrokerDirectories_UploadedByUserId] ON [BrokerDirectories] ([UploadedByUserId]);
    PRINT '✓ Tabelul BrokerDirectories a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul BrokerDirectories există deja.';
END
GO

-- Tabel KycSessions
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'KycSessions' AND type = 'U')
BEGIN
    CREATE TABLE [KycSessions] (
        [KycId] uniqueidentifier NOT NULL,
        [UserId] int NOT NULL,
        [KycType] nvarchar(30) NOT NULL,
        [Status] nvarchar(20) NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [VerifiedAt] datetime2 NULL,
        [ExpiresAt] datetime2 NULL,
        [ProviderTransactionId] nvarchar(200) NULL,
        [RejectionReason] nvarchar(500) NULL,
        [Cnp] nvarchar(500) NULL,
        [Address] nvarchar(500) NULL,
        [City] nvarchar(100) NULL,
        [County] nvarchar(100) NULL,
        [PostalCode] nvarchar(10) NULL,
        CONSTRAINT [PK_KycSessions] PRIMARY KEY ([KycId])
    );
    CREATE INDEX [IX_KycSessions_ExpiresAt] ON [KycSessions] ([ExpiresAt]);
    CREATE INDEX [IX_KycSessions_UserId_CreatedAt] ON [KycSessions] ([UserId], [CreatedAt]);
    PRINT '✓ Tabelul KycSessions a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul KycSessions există deja.';
END
GO

-- Tabel Mandates
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Mandates' AND type = 'U')
BEGIN
    CREATE TABLE [Mandates] (
        [MandateId] uniqueidentifier NOT NULL,
        [UserId] int NOT NULL,
        [MandateType] nvarchar(30) NOT NULL,
        [Scope] nvarchar(100) NOT NULL DEFAULT N'credit_eligibility_only',
        [Status] nvarchar(20) NOT NULL,
        [GrantedAt] datetime2 NOT NULL,
        [ExpiresAt] datetime2 NOT NULL,
        [RevokedAt] datetime2 NULL,
        [RevokedReason] nvarchar(200) NULL,
        [ConsentEventId] nvarchar(64) NULL,
        CONSTRAINT [PK_Mandates] PRIMARY KEY ([MandateId])
    );
    CREATE INDEX [IX_Mandates_ExpiresAt] ON [Mandates] ([ExpiresAt]);
    CREATE INDEX [IX_Mandates_UserId_Status_GrantedAt] ON [Mandates] ([UserId], [Status], [GrantedAt]);
    PRINT '✓ Tabelul Mandates a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Mandates există deja.';
END
GO

-- Tabel OtpChallenges
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OtpChallenges' AND type = 'U')
BEGIN
    CREATE TABLE [OtpChallenges] (
        [OtpId] uniqueidentifier NOT NULL,
        [UserId] int NULL,
        [Phone] nvarchar(30) NOT NULL,
        [Email] nvarchar(320) NULL,
        [Purpose] nvarchar(30) NOT NULL,
        [OtpHash] varbinary(max) NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [ExpiresAt] datetime2 NOT NULL,
        [Attempts] int NOT NULL,
        [UsedAt] datetime2 NULL,
        [Ip] nvarchar(64) NULL,
        [DeviceHash] varbinary(max) NULL,
        CONSTRAINT [PK_OtpChallenges] PRIMARY KEY ([OtpId])
    );
    CREATE INDEX [IX_OtpChallenges_ExpiresAt] ON [OtpChallenges] ([ExpiresAt]);
    CREATE INDEX [IX_OtpChallenges_Phone_Purpose_CreatedAt] ON [OtpChallenges] ([Phone], [Purpose], [CreatedAt]);
    CREATE INDEX [IX_OtpChallenges_UserId] ON [OtpChallenges] ([UserId]);
    PRINT '✓ Tabelul OtpChallenges a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul OtpChallenges există deja.';
END
GO

-- Tabel Proiecte
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Proiecte' AND type = 'U')
BEGIN
    CREATE TABLE [Proiecte] (
        [IdProject] int NOT NULL IDENTITY(1,1),
        [ProjectName] nvarchar(255) NOT NULL,
        [StartDate] datetime NOT NULL,
        [Deadline] datetime NOT NULL,
        [ProjectDetails] nvarchar(max) NULL,
        [ProjectFile] varbinary(max) NOT NULL,
        [FileFormat] nvarchar(max) NULL,
        [ContestCreator] nvarchar(max) NULL,
        [Organization] nvarchar(max) NULL,
        [WebsiteLink] nvarchar(max) NULL,
        [ContestRules] nvarchar(max) NULL,
        [UserId] int NOT NULL,
        [IsActive] bit NOT NULL,
        [TimeStamp] datetime2 NOT NULL,
        CONSTRAINT [PK__Proiecte__187B9AAFDE323DC0] PRIMARY KEY ([IdProject])
    );
    PRINT '✓ Tabelul Proiecte a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Proiecte există deja.';
END
GO

-- Tabel Sessions
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Sessions' AND type = 'U')
BEGIN
    CREATE TABLE [Sessions] (
        [SessionId] uniqueidentifier NOT NULL,
        [UserId] int NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [ExpiresAt] datetime2 NOT NULL,
        [RevokedAt] datetime2 NULL,
        [Ip] nvarchar(64) NULL,
        [UserAgent] nvarchar(1000) NULL,
        [DeviceHash] varbinary(max) NULL,
        [SourceChannel] nvarchar(20) NOT NULL,
        CONSTRAINT [PK_Sessions] PRIMARY KEY ([SessionId])
    );
    CREATE INDEX [IX_Sessions_ExpiresAt] ON [Sessions] ([ExpiresAt]);
    CREATE INDEX [IX_Sessions_UserId_CreatedAt] ON [Sessions] ([UserId], [CreatedAt]);
    PRINT '✓ Tabelul Sessions a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Sessions există deja.';
END
GO

-- Tabel SubjectMaps
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SubjectMaps' AND type = 'U')
BEGIN
    CREATE TABLE [SubjectMaps] (
        [SubjectId] nvarchar(19) NOT NULL,
        [UserId] int NOT NULL,
        [CnpHash] varbinary(900) NOT NULL,
        [CnpLast4] nvarchar(4) NULL,
        [CreatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_SubjectMaps] PRIMARY KEY ([SubjectId])
    );
    CREATE UNIQUE INDEX [IX_SubjectMaps_CnpHash] ON [SubjectMaps] ([CnpHash]);
    CREATE UNIQUE INDEX [IX_SubjectMaps_UserId] ON [SubjectMaps] ([UserId]);
    PRINT '✓ Tabelul SubjectMaps a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul SubjectMaps există deja.';
END
GO

-- Tabel UserFinancialData
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserFinancialData' AND type = 'U')
BEGIN
    CREATE TABLE [UserFinancialData] (
        [Id] int NOT NULL IDENTITY(1,1),
        [UserId] int NOT NULL,
        [SalariuNet] decimal(18,2) NULL,
        [BonuriMasa] bit NULL,
        [SumaBonuriMasa] decimal(18,2) NULL,
        [VenitTotal] decimal(18,2) NULL,
        [SoldTotal] decimal(18,2) NULL,
        [RataTotalaLunara] decimal(18,2) NULL,
        [NrCrediteBanci] int NULL,
        [NrIfn] int NULL,
        [Poprire] bit NULL,
        [Intarzieri] bit NULL,
        [IntarzieriNumar] int NULL,
        [Dti] decimal(5,4) NULL,
        [ScoringLevel] nvarchar(50) NULL,
        [RecommendedLevel] nvarchar(50) NULL,
        [LastUpdated] datetime2 NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_UserFinancialData] PRIMARY KEY ([Id])
    );
    CREATE INDEX [IX_UserFinancialData_LastUpdated] ON [UserFinancialData] ([LastUpdated]);
    CREATE INDEX [IX_UserFinancialData_UserId] ON [UserFinancialData] ([UserId]);
    PRINT '✓ Tabelul UserFinancialData a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul UserFinancialData există deja.';
END
GO

-- Tabel Agreements
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Agreements' AND type = 'U')
BEGIN
    CREATE TABLE [Agreements] (
        [Id] int NOT NULL IDENTITY(1,1),
        [ApplicationId] int NOT NULL,
        [AgreementType] nvarchar(100) NOT NULL,
        [PdfBlobPath] nvarchar(500) NOT NULL,
        [Version] nvarchar(20) NOT NULL DEFAULT N'1.0',
        [SignedAt] datetime NULL,
        [SignatureImagePath] nvarchar(500) NULL,
        [CreatedAt] datetime NOT NULL,
        CONSTRAINT [PK_Agreements] PRIMARY KEY ([Id])
    );
    CREATE INDEX [IX_Agreements_ApplicationId] ON [Agreements] ([ApplicationId]);
    PRINT '✓ Tabelul Agreements a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Agreements există deja.';
END
GO

-- Tabel ApplicationBanks
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ApplicationBanks' AND type = 'U')
BEGIN
    CREATE TABLE [ApplicationBanks] (
        [Id] int NOT NULL IDENTITY(1,1),
        [ApplicationId] int NOT NULL,
        [BankId] int NOT NULL,
        [CommissionPercent] decimal(5,2) NOT NULL,
        CONSTRAINT [PK_ApplicationBanks] PRIMARY KEY ([Id])
    );
    CREATE INDEX [IX_ApplicationBanks_ApplicationId] ON [ApplicationBanks] ([ApplicationId]);
    CREATE INDEX [IX_ApplicationBanks_BankId] ON [ApplicationBanks] ([BankId]);
    PRINT '✓ Tabelul ApplicationBanks a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul ApplicationBanks există deja.';
END
GO

-- Tabel KycFiles
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'KycFiles' AND type = 'U')
BEGIN
    CREATE TABLE [KycFiles] (
        [FileId] uniqueidentifier NOT NULL,
        [KycId] uniqueidentifier NOT NULL,
        [FileType] nvarchar(30) NOT NULL,
        [BlobPath] nvarchar(1000) NULL,
        [FileName] nvarchar(255) NOT NULL,
        [MimeType] nvarchar(100) NOT NULL,
        [FileSize] bigint NOT NULL,
        [Sha256Hash] varbinary(max) NULL,
        [FileContentBase64] nvarchar(max) NULL,
        [CreatedAt] datetime2 NOT NULL,
        [ExpiresAt] datetime2 NOT NULL,
        [DeletedAt] datetime2 NULL,
        CONSTRAINT [PK_KycFiles] PRIMARY KEY ([FileId])
    );
    CREATE INDEX [IX_KycFiles_ExpiresAt] ON [KycFiles] ([ExpiresAt]);
    CREATE INDEX [IX_KycFiles_KycId] ON [KycFiles] ([KycId]);
    PRINT '✓ Tabelul KycFiles a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul KycFiles există deja.';
    -- Verifică dacă coloana FileContentBase64 există
    IF NOT EXISTS (SELECT * FROM sys.columns c 
                   INNER JOIN sys.tables t ON c.object_id = t.object_id 
                   WHERE t.name = 'KycFiles' AND c.name = 'FileContentBase64')
    BEGIN
        ALTER TABLE [KycFiles] ADD [FileContentBase64] nvarchar(max) NULL;
        PRINT '✓ Coloana FileContentBase64 a fost adăugată la KycFiles.';
    END
    -- Verifică dacă BlobPath este nullable
    IF EXISTS (SELECT * FROM sys.columns c 
               INNER JOIN sys.tables t ON c.object_id = t.object_id 
               WHERE t.name = 'KycFiles' AND c.name = 'BlobPath' AND c.is_nullable = 0)
    BEGIN
        ALTER TABLE [KycFiles] ALTER COLUMN [BlobPath] nvarchar(1000) NULL;
        PRINT '✓ Coloana BlobPath a fost făcută nullable în KycFiles.';
    END
END
GO

-- Tabel Documents
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Documents' AND type = 'U')
BEGIN
    CREATE TABLE [Documents] (
        [Id] int NOT NULL IDENTITY(1,1),
        [ApplicationId] int NOT NULL,
        [DocType] nvarchar(100) NOT NULL,
        [AzureBlobPath] nvarchar(500) NOT NULL,
        [FileName] nvarchar(255) NULL,
        [FileSize] bigint NULL,
        [MimeType] nvarchar(100) NULL,
        [CreatedAt] datetime NOT NULL,
        [MandateId] uniqueidentifier NULL,
        CONSTRAINT [PK_Documents] PRIMARY KEY ([Id])
    );
    CREATE INDEX [IX_Documents_ApplicationId] ON [Documents] ([ApplicationId]);
    CREATE INDEX [IX_Documents_MandateId] ON [Documents] ([MandateId]);
    PRINT '✓ Tabelul Documents a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Documents există deja.';
END
GO

-- Tabel Favorites
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Favorites' AND type = 'U')
BEGIN
    CREATE TABLE [Favorites] (
        [Id] int NOT NULL IDENTITY(1,1),
        [UserId] int NOT NULL,
        [ProjectId] int NOT NULL,
        [ListName] nvarchar(max) NOT NULL,
        CONSTRAINT [PK_Favorites] PRIMARY KEY ([Id])
    );
    CREATE INDEX [IX_Favorites_ProjectId] ON [Favorites] ([ProjectId]);
    CREATE INDEX [IX_Favorites_UserId] ON [Favorites] ([UserId]);
    PRINT '✓ Tabelul Favorites a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Favorites există deja.';
END
GO

-- Tabel SavedProjects
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SavedProjects' AND type = 'U')
BEGIN
    CREATE TABLE [SavedProjects] (
        [IdSavedProject] int NOT NULL IDENTITY(1,1),
        [IdUtilizator] int NOT NULL,
        [IdProiect] int NOT NULL,
        [DataSalvare] datetime NULL DEFAULT (getdate()),
        CONSTRAINT [PK__SavedPro__E5878A3ADC55E572] PRIMARY KEY ([IdSavedProject])
    );
    CREATE INDEX [IX_SavedProjects_IdProiect] ON [SavedProjects] ([IdProiect]);
    CREATE INDEX [IX_SavedProjects_IdUtilizator] ON [SavedProjects] ([IdUtilizator]);
    PRINT '✓ Tabelul SavedProjects a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul SavedProjects există deja.';
END
GO

-- Tabel Consents
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Consents' AND type = 'U')
BEGIN
    CREATE TABLE [Consents] (
        [ConsentId] uniqueidentifier NOT NULL,
        [UserId] int NOT NULL,
        [ConsentType] nvarchar(60) NOT NULL,
        [Status] nvarchar(20) NOT NULL DEFAULT N'granted',
        [GrantedAt] datetime2 NOT NULL,
        [RevokedAt] datetime2 NULL,
        [DocId] uniqueidentifier NULL,
        [ConsentTextSnapshot] nvarchar(max) NOT NULL,
        [SessionId] uniqueidentifier NULL,
        [Ip] nvarchar(64) NULL,
        [UserAgent] nvarchar(1000) NULL,
        [DeviceHash] varbinary(max) NULL,
        [SourceChannel] nvarchar(20) NOT NULL,
        CONSTRAINT [PK_Consents] PRIMARY KEY ([ConsentId])
    );
    CREATE INDEX [IX_Consents_DocId] ON [Consents] ([DocId]);
    CREATE INDEX [IX_Consents_SessionId] ON [Consents] ([SessionId]);
    CREATE INDEX [IX_Consents_UserId_ConsentType_GrantedAt] ON [Consents] ([UserId], [ConsentType], [GrantedAt]);
    PRINT '✓ Tabelul Consents a fost creat.';
END
ELSE
BEGIN
    PRINT '✓ Tabelul Consents există deja.';
END
GO

-- ============================================================================
-- SECȚIUNEA 3: CREARE CONSTRÂNGERI FOREIGN KEY
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 3: Creare Constrângeri Foreign Key ---';
PRINT '';

-- FK Utilizatori -> Roluri
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Utilizatori_Roluri_IdRol')
BEGIN
    ALTER TABLE [Utilizatori]
    ADD CONSTRAINT [FK_Utilizatori_Roluri_IdRol] 
    FOREIGN KEY ([IdRol]) REFERENCES [Roluri] ([IdRol]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_Utilizatori_Roluri_IdRol a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Utilizatori_Roluri_IdRol există deja.';
END
GO

-- FK Applications -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Applications_Utilizatori_UserId')
BEGIN
    ALTER TABLE [Applications]
    ADD CONSTRAINT [FK_Applications_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE NO ACTION;
    PRINT '✓ Constrângerea FK_Applications_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Applications_Utilizatori_UserId există deja.';
END
GO

-- FK BrokerDirectories -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_BrokerDirectories_Utilizatori_UploadedByUserId')
BEGIN
    ALTER TABLE [BrokerDirectories]
    ADD CONSTRAINT [FK_BrokerDirectories_Utilizatori_UploadedByUserId] 
    FOREIGN KEY ([UploadedByUserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE NO ACTION;
    PRINT '✓ Constrângerea FK_BrokerDirectories_Utilizatori_UploadedByUserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_BrokerDirectories_Utilizatori_UploadedByUserId există deja.';
END
GO

-- FK KycSessions -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_KycSessions_Utilizatori_UserId')
BEGIN
    ALTER TABLE [KycSessions]
    ADD CONSTRAINT [FK_KycSessions_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_KycSessions_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_KycSessions_Utilizatori_UserId există deja.';
END
GO

-- FK Mandates -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Mandates_Utilizatori_UserId')
BEGIN
    ALTER TABLE [Mandates]
    ADD CONSTRAINT [FK_Mandates_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_Mandates_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Mandates_Utilizatori_UserId există deja.';
END
GO

-- FK OtpChallenges -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_OtpChallenges_Utilizatori_UserId')
BEGIN
    ALTER TABLE [OtpChallenges]
    ADD CONSTRAINT [FK_OtpChallenges_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE SET NULL;
    PRINT '✓ Constrângerea FK_OtpChallenges_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_OtpChallenges_Utilizatori_UserId există deja.';
END
GO

-- FK Sessions -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Sessions_Utilizatori_UserId')
BEGIN
    ALTER TABLE [Sessions]
    ADD CONSTRAINT [FK_Sessions_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE NO ACTION;
    PRINT '✓ Constrângerea FK_Sessions_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Sessions_Utilizatori_UserId există deja.';
END
GO

-- FK SubjectMaps -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_SubjectMaps_Utilizatori_UserId')
BEGIN
    ALTER TABLE [SubjectMaps]
    ADD CONSTRAINT [FK_SubjectMaps_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_SubjectMaps_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_SubjectMaps_Utilizatori_UserId există deja.';
END
GO

-- FK UserFinancialData -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserFinancialData_Utilizatori_UserId')
BEGIN
    ALTER TABLE [UserFinancialData]
    ADD CONSTRAINT [FK_UserFinancialData_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_UserFinancialData_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_UserFinancialData_Utilizatori_UserId există deja.';
END
GO

-- FK Agreements -> Applications
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Agreements_Applications_ApplicationId')
BEGIN
    ALTER TABLE [Agreements]
    ADD CONSTRAINT [FK_Agreements_Applications_ApplicationId] 
    FOREIGN KEY ([ApplicationId]) REFERENCES [Applications] ([Id]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_Agreements_Applications_ApplicationId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Agreements_Applications_ApplicationId există deja.';
END
GO

-- FK ApplicationBanks -> Applications
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ApplicationBanks_Applications_ApplicationId')
BEGIN
    ALTER TABLE [ApplicationBanks]
    ADD CONSTRAINT [FK_ApplicationBanks_Applications_ApplicationId] 
    FOREIGN KEY ([ApplicationId]) REFERENCES [Applications] ([Id]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_ApplicationBanks_Applications_ApplicationId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_ApplicationBanks_Applications_ApplicationId există deja.';
END
GO

-- FK ApplicationBanks -> Banks
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ApplicationBanks_Banks_BankId')
BEGIN
    ALTER TABLE [ApplicationBanks]
    ADD CONSTRAINT [FK_ApplicationBanks_Banks_BankId] 
    FOREIGN KEY ([BankId]) REFERENCES [Banks] ([Id]) ON DELETE NO ACTION;
    PRINT '✓ Constrângerea FK_ApplicationBanks_Banks_BankId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_ApplicationBanks_Banks_BankId există deja.';
END
GO

-- FK KycFiles -> KycSessions
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_KycFiles_KycSessions_KycId')
BEGIN
    ALTER TABLE [KycFiles]
    ADD CONSTRAINT [FK_KycFiles_KycSessions_KycId] 
    FOREIGN KEY ([KycId]) REFERENCES [KycSessions] ([KycId]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_KycFiles_KycSessions_KycId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_KycFiles_KycSessions_KycId există deja.';
END
GO

-- FK Documents -> Applications
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Documents_Applications_ApplicationId')
BEGIN
    ALTER TABLE [Documents]
    ADD CONSTRAINT [FK_Documents_Applications_ApplicationId] 
    FOREIGN KEY ([ApplicationId]) REFERENCES [Applications] ([Id]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_Documents_Applications_ApplicationId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Documents_Applications_ApplicationId există deja.';
END
GO

-- FK Documents -> Mandates
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Documents_Mandates_MandateId')
BEGIN
    ALTER TABLE [Documents]
    ADD CONSTRAINT [FK_Documents_Mandates_MandateId] 
    FOREIGN KEY ([MandateId]) REFERENCES [Mandates] ([MandateId]);
    PRINT '✓ Constrângerea FK_Documents_Mandates_MandateId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Documents_Mandates_MandateId există deja.';
END
GO

-- FK Favorites -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Favorites_Utilizatori_UserId')
BEGIN
    ALTER TABLE [Favorites]
    ADD CONSTRAINT [FK_Favorites_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]);
    PRINT '✓ Constrângerea FK_Favorites_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Favorites_Utilizatori_UserId există deja.';
END
GO

-- FK Favorites -> Proiecte
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Favorites_Proiecte_ProjectId')
BEGIN
    ALTER TABLE [Favorites]
    ADD CONSTRAINT [FK_Favorites_Proiecte_ProjectId] 
    FOREIGN KEY ([ProjectId]) REFERENCES [Proiecte] ([IdProject]);
    PRINT '✓ Constrângerea FK_Favorites_Proiecte_ProjectId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Favorites_Proiecte_ProjectId există deja.';
END
GO

-- FK SavedProjects -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__SavedProj__IdUti__45F365D3')
BEGIN
    ALTER TABLE [SavedProjects]
    ADD CONSTRAINT [FK__SavedProj__IdUti__45F365D3] 
    FOREIGN KEY ([IdUtilizator]) REFERENCES [Utilizatori] ([IdUtilizator]);
    PRINT '✓ Constrângerea FK__SavedProj__IdUti__45F365D3 a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK__SavedProj__IdUti__45F365D3 există deja.';
END
GO

-- FK SavedProjects -> Proiecte
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK__SavedProj__IdPro__46E78A0C')
BEGIN
    ALTER TABLE [SavedProjects]
    ADD CONSTRAINT [FK__SavedProj__IdPro__46E78A0C] 
    FOREIGN KEY ([IdProiect]) REFERENCES [Proiecte] ([IdProject]);
    PRINT '✓ Constrângerea FK__SavedProj__IdPro__46E78A0C a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK__SavedProj__IdPro__46E78A0C există deja.';
END
GO

-- FK Consents -> Utilizatori
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Consents_Utilizatori_UserId')
BEGIN
    ALTER TABLE [Consents]
    ADD CONSTRAINT [FK_Consents_Utilizatori_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE;
    PRINT '✓ Constrângerea FK_Consents_Utilizatori_UserId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Consents_Utilizatori_UserId există deja.';
END
GO

-- FK Consents -> LegalDocs
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Consents_LegalDocs_DocId')
BEGIN
    ALTER TABLE [Consents]
    ADD CONSTRAINT [FK_Consents_LegalDocs_DocId] 
    FOREIGN KEY ([DocId]) REFERENCES [LegalDocs] ([DocId]) ON DELETE SET NULL;
    PRINT '✓ Constrângerea FK_Consents_LegalDocs_DocId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Consents_LegalDocs_DocId există deja.';
END
GO

-- FK Consents -> Sessions
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Consents_Sessions_SessionId')
BEGIN
    ALTER TABLE [Consents]
    ADD CONSTRAINT [FK_Consents_Sessions_SessionId] 
    FOREIGN KEY ([SessionId]) REFERENCES [Sessions] ([SessionId]) ON DELETE SET NULL;
    PRINT '✓ Constrângerea FK_Consents_Sessions_SessionId a fost creată.';
END
ELSE
BEGIN
    PRINT '✓ Constrângerea FK_Consents_Sessions_SessionId există deja.';
END
GO

-- ============================================================================
-- SECȚIUNEA 4: POPULARE DATE INIȚIALE
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 4: Populare Date Inițiale ---';
PRINT '';

-- Populare Roluri
IF NOT EXISTS (SELECT 1 FROM Roluri)
BEGIN
    PRINT 'Se populează tabelul Roluri...';
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
-- SECȚIUNEA 5: MARCARE MIGRAȚII APLICATE
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 5: Marcare Migrații Entity Framework ---';
PRINT '';

-- Marchează migrațiile ca aplicate
IF NOT EXISTS (SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = N'20260103104930_UpdateKycAndRecentChanges')
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260103104930_UpdateKycAndRecentChanges', N'7.0.13');
    PRINT '✓ Migrația 20260103104930_UpdateKycAndRecentChanges a fost marcată ca aplicată.';
END
ELSE
BEGIN
    PRINT '✓ Migrația 20260103104930_UpdateKycAndRecentChanges este deja marcată.';
END
GO

IF NOT EXISTS (SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = N'20260103140908_AddFileContentBase64ToKycFiles')
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260103140908_AddFileContentBase64ToKycFiles', N'7.0.13');
    PRINT '✓ Migrația 20260103140908_AddFileContentBase64ToKycFiles a fost marcată ca aplicată.';
END
ELSE
BEGIN
    PRINT '✓ Migrația 20260103140908_AddFileContentBase64ToKycFiles este deja marcată.';
END
GO

-- ============================================================================
-- SECȚIUNEA 6: RAPORT FINAL
-- ============================================================================
PRINT '';
PRINT '--- SECȚIUNEA 6: Raport Final ---';
PRINT '';

-- Numără tabelele create
DECLARE @TableCount INT;
SELECT @TableCount = COUNT(*) 
FROM sys.tables 
WHERE name IN (
    'Roluri', 'Utilizatori', 'Applications', 'Banks', 'Leads', 'LegalDocs',
    'BrokerDirectories', 'KycSessions', 'KycFiles', 'Mandates', 'OtpChallenges',
    'Proiecte', 'Sessions', 'SubjectMaps', 'UserFinancialData', 'Agreements',
    'ApplicationBanks', 'Documents', 'Favorites', 'SavedProjects', 'Consents',
    'BacDocuments', '__EFMigrationsHistory'
);
PRINT 'Total tabele verificate: ' + CAST(@TableCount AS NVARCHAR(10));

-- Numără rolurile
DECLARE @RoleCount INT;
SELECT @RoleCount = COUNT(*) FROM Roluri;
PRINT 'Roluri în baza de date: ' + CAST(@RoleCount AS NVARCHAR(10));

-- Numără utilizatorii
DECLARE @UserCount INT;
SELECT @UserCount = COUNT(*) FROM Utilizatori;
PRINT 'Utilizatori în baza de date: ' + CAST(@UserCount AS NVARCHAR(10));

-- Numără migrațiile
DECLARE @MigrationCount INT;
SELECT @MigrationCount = COUNT(*) FROM [__EFMigrationsHistory];
PRINT 'Migrații marcate: ' + CAST(@MigrationCount AS NVARCHAR(10));

PRINT '';
PRINT 'Roluri disponibile:';
SELECT IdRol, NumeRol FROM Roluri ORDER BY IdRol;

PRINT '';
PRINT '========================================';
PRINT 'Crearea și configurarea bazei de date este completă!';
PRINT '========================================';
PRINT '';
PRINT 'Baza de date este gata pentru utilizare.';
PRINT '';

