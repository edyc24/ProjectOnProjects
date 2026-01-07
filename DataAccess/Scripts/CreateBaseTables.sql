-- Script pentru crearea tabelelor de bază necesare înainte de migrarea InitialCreate
-- Rulează acest script în SSMS înainte de a aplica migrarea Entity Framework

USE [MoneyShop];
GO

-- Creează tabelul Roluri
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roluri')
BEGIN
    CREATE TABLE [Roluri] (
        [IdRol] int IDENTITY(1,1) NOT NULL,
        [NumeRol] nvarchar(50) NOT NULL,
        CONSTRAINT [PK__Roluri__2A49584C65FE7A4A] PRIMARY KEY ([IdRol])
    );
    PRINT 'Tabelul Roluri a fost creat.';
END
ELSE
BEGIN
    PRINT 'Tabelul Roluri există deja.';
END
GO

-- Creează tabelul Utilizatori
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Utilizatori')
BEGIN
    CREATE TABLE [Utilizatori] (
        [IdUtilizator] int IDENTITY(1,1) NOT NULL,
        [Nume] nvarchar(255) NOT NULL,
        [Prenume] nvarchar(255) NOT NULL,
        [Username] nvarchar(255) NULL,
        [Mail] nvarchar(255) NULL,
        [Parola] nvarchar(255) NULL,
        [NumarTelefon] nvarchar(20) NULL,
        [Skills] nvarchar(max) NULL,
        [Description] nvarchar(max) NULL,
        [DataIncepere] datetime NULL,
        [DataNastere] datetime NULL,
        [IdRol] int NOT NULL,
        [IsDeleted] bit NULL DEFAULT 0,
        CONSTRAINT [PK__Utilizat__99101D6D31235E34] PRIMARY KEY ([IdUtilizator]),
        CONSTRAINT [UQ__Utilizat__536C85E4B4BA6916] UNIQUE ([Username])
    );
    PRINT 'Tabelul Utilizatori a fost creat.';
END
ELSE
BEGIN
    PRINT 'Tabelul Utilizatori există deja.';
END
GO

-- Creează tabelul Proiecte
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Proiecte')
BEGIN
    CREATE TABLE [Proiecte] (
        [IdProject] int IDENTITY(1,1) NOT NULL,
        [ProjectName] nvarchar(255) NULL,
        [StartDate] datetime NULL,
        [Deadline] datetime NULL,
        [IdUtilizator] int NULL,
        CONSTRAINT [PK__Proiecte__187B9AAFDE323DC0] PRIMARY KEY ([IdProject])
    );
    PRINT 'Tabelul Proiecte a fost creat.';
END
ELSE
BEGIN
    PRINT 'Tabelul Proiecte există deja.';
END
GO

-- Creează tabelul SavedProjects
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SavedProjects')
BEGIN
    CREATE TABLE [SavedProjects] (
        [IdSavedProject] int IDENTITY(1,1) NOT NULL,
        [IdProiect] int NOT NULL,
        [IdUtilizator] int NOT NULL,
        [DataSalvare] datetime NULL DEFAULT (getdate()),
        CONSTRAINT [PK__SavedPro__E5878A3ADC55E572] PRIMARY KEY ([IdSavedProject]),
        CONSTRAINT [FK__SavedProj__IdPro__46E78A0C] FOREIGN KEY ([IdProiect]) REFERENCES [Proiecte] ([IdProject]),
        CONSTRAINT [FK__SavedProj__IdUti__45F365D3] FOREIGN KEY ([IdUtilizator]) REFERENCES [Utilizatori] ([IdUtilizator])
    );
    PRINT 'Tabelul SavedProjects a fost creat.';
END
ELSE
BEGIN
    PRINT 'Tabelul SavedProjects există deja.';
END
GO

-- Creează tabelul Favorites
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Favorites')
BEGIN
    CREATE TABLE [Favorites] (
        [Id] int IDENTITY(1,1) NOT NULL,
        [UserId] int NOT NULL,
        [ProjectId] int NOT NULL,
        CONSTRAINT [PK_Favorites] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Favorites_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]),
        CONSTRAINT [FK_Favorites_Proiecte_ProjectId] FOREIGN KEY ([ProjectId]) REFERENCES [Proiecte] ([IdProject])
    );
    PRINT 'Tabelul Favorites a fost creat.';
END
ELSE
BEGIN
    PRINT 'Tabelul Favorites există deja.';
END
GO

-- Creează tabelul BacDocuments
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BacDocuments')
BEGIN
    CREATE TABLE [BacDocuments] (
        [IdDocument] int IDENTITY(1,1) NOT NULL,
        [NumeDocument] nvarchar(255) NOT NULL,
        [TipMaterie] nvarchar(50) NOT NULL,
        [Continut] varbinary(max) NOT NULL,
        [DataAdaugare] datetime NULL DEFAULT (getdate()),
        CONSTRAINT [PK__BacDocum__BEAAD0BAD56E4F0E] PRIMARY KEY ([IdDocument])
    );
    PRINT 'Tabelul BacDocuments a fost creat.';
END
ELSE
BEGIN
    PRINT 'Tabelul BacDocuments există deja.';
END
GO

PRINT 'Toate tabelele de bază au fost verificate/create. Acum poți aplica migrarea Entity Framework.';
GO

