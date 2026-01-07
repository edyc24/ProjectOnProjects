CREATE TABLE [BacDocuments] (
    [IdDocument] int NOT NULL IDENTITY,
    [NumeDocument] nvarchar(255) NOT NULL,
    [TipMaterie] nvarchar(50) NOT NULL,
    [Continut] varbinary(max) NOT NULL,
    [DataAdaugare] datetime NULL DEFAULT ((getdate())),
    CONSTRAINT [PK__BacDocum__BEAAD0BAD56E4F0E] PRIMARY KEY ([IdDocument])
);
GO


CREATE TABLE [Banks] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(255) NOT NULL,
    [CommissionPercent] decimal(5,2) NOT NULL,
    [Active] bit NOT NULL,
    CONSTRAINT [PK_Banks] PRIMARY KEY ([Id])
);
GO


CREATE TABLE [Leads] (
    [Id] int NOT NULL IDENTITY,
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
GO


CREATE TABLE [LegalDocs] (
    [DocId] uniqueidentifier NOT NULL,
    [DocType] nvarchar(30) NOT NULL,
    [Version] nvarchar(20) NOT NULL,
    [PublishedAt] datetime2 NOT NULL,
    [ContentHash] varbinary(max) NOT NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_LegalDocs] PRIMARY KEY ([DocId])
);
GO


CREATE TABLE [Roluri] (
    [IdRol] int NOT NULL IDENTITY,
    [NumeRol] nvarchar(50) NOT NULL,
    CONSTRAINT [PK__Roluri__2A49584C65FE7A4A] PRIMARY KEY ([IdRol])
);
GO


CREATE TABLE [Utilizatori] (
    [IdUtilizator] int NOT NULL IDENTITY,
    [Nume] nvarchar(255) NOT NULL,
    [Prenume] nvarchar(255) NOT NULL,
    [Username] nvarchar(255) NULL,
    [Mail] nvarchar(255) NULL,
    [Parola] nvarchar(255) NULL,
    [NumarTelefon] nvarchar(20) NULL,
    [EmailVerified] bit NOT NULL,
    [PhoneVerified] bit NOT NULL,
    [Skills] nvarchar(max) NULL,
    [Description] nvarchar(max) NULL,
    [DataIncepere] datetime NULL,
    [DataNastere] datetime NULL,
    [IdRol] int NOT NULL,
    [IsDeleted] bit NULL DEFAULT (((0))),
    CONSTRAINT [PK__Utilizat__99101D6D31235E34] PRIMARY KEY ([IdUtilizator])
);
GO


CREATE TABLE [Applications] (
    [Id] int NOT NULL IDENTITY,
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
    CONSTRAINT [PK_Applications] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Applications_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE NO ACTION
);
GO


CREATE TABLE [BrokerDirectories] (
    [Id] int NOT NULL IDENTITY,
    [ExcelFileName] nvarchar(255) NOT NULL,
    [BlobPath] nvarchar(1000) NOT NULL,
    [FileSize] bigint NOT NULL,
    [UploadedAt] datetime2 NOT NULL,
    [UploadedByUserId] int NOT NULL,
    [Notes] nvarchar(500) NULL,
    CONSTRAINT [PK_BrokerDirectories] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_BrokerDirectories_Utilizatori_UploadedByUserId] FOREIGN KEY ([UploadedByUserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE NO ACTION
);
GO


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
    [UtilizatoriIdUtilizator] int NULL,
    CONSTRAINT [PK_KycSessions] PRIMARY KEY ([KycId]),
    CONSTRAINT [FK_KycSessions_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE,
    CONSTRAINT [FK_KycSessions_Utilizatori_UtilizatoriIdUtilizator] FOREIGN KEY ([UtilizatoriIdUtilizator]) REFERENCES [Utilizatori] ([IdUtilizator])
);
GO


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
    CONSTRAINT [PK_Mandates] PRIMARY KEY ([MandateId]),
    CONSTRAINT [FK_Mandates_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE
);
GO


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
    [UtilizatoriIdUtilizator] int NULL,
    CONSTRAINT [PK_OtpChallenges] PRIMARY KEY ([OtpId]),
    CONSTRAINT [FK_OtpChallenges_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE SET NULL,
    CONSTRAINT [FK_OtpChallenges_Utilizatori_UtilizatoriIdUtilizator] FOREIGN KEY ([UtilizatoriIdUtilizator]) REFERENCES [Utilizatori] ([IdUtilizator])
);
GO


CREATE TABLE [Proiecte] (
    [IdProject] int NOT NULL IDENTITY,
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
    [UtilizatoriIdUtilizator] int NULL,
    CONSTRAINT [PK__Proiecte__187B9AAFDE323DC0] PRIMARY KEY ([IdProject]),
    CONSTRAINT [FK_Proiecte_Utilizatori_UtilizatoriIdUtilizator] FOREIGN KEY ([UtilizatoriIdUtilizator]) REFERENCES [Utilizatori] ([IdUtilizator])
);
GO


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
    [UtilizatoriIdUtilizator] int NULL,
    CONSTRAINT [PK_Sessions] PRIMARY KEY ([SessionId]),
    CONSTRAINT [FK_Sessions_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Sessions_Utilizatori_UtilizatoriIdUtilizator] FOREIGN KEY ([UtilizatoriIdUtilizator]) REFERENCES [Utilizatori] ([IdUtilizator])
);
GO


CREATE TABLE [SubjectMaps] (
    [SubjectId] nvarchar(19) NOT NULL,
    [UserId] int NOT NULL,
    [CnpHash] varbinary(900) NOT NULL,
    [CnpLast4] nvarchar(4) NULL,
    [CreatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_SubjectMaps] PRIMARY KEY ([SubjectId]),
    CONSTRAINT [FK_SubjectMaps_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE
);
GO


CREATE TABLE [UserFinancialData] (
    [Id] int NOT NULL IDENTITY,
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
    CONSTRAINT [PK_UserFinancialData] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_UserFinancialData_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE
);
GO


CREATE TABLE [Agreements] (
    [Id] int NOT NULL IDENTITY,
    [ApplicationId] int NOT NULL,
    [AgreementType] nvarchar(100) NOT NULL,
    [PdfBlobPath] nvarchar(500) NOT NULL,
    [Version] nvarchar(20) NOT NULL DEFAULT N'1.0',
    [SignedAt] datetime NULL,
    [SignatureImagePath] nvarchar(500) NULL,
    [CreatedAt] datetime NOT NULL,
    CONSTRAINT [PK_Agreements] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Agreements_Applications_ApplicationId] FOREIGN KEY ([ApplicationId]) REFERENCES [Applications] ([Id]) ON DELETE CASCADE
);
GO


CREATE TABLE [ApplicationBanks] (
    [Id] int NOT NULL IDENTITY,
    [ApplicationId] int NOT NULL,
    [BankId] int NOT NULL,
    [CommissionPercent] decimal(5,2) NOT NULL,
    CONSTRAINT [PK_ApplicationBanks] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_ApplicationBanks_Applications_ApplicationId] FOREIGN KEY ([ApplicationId]) REFERENCES [Applications] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_ApplicationBanks_Banks_BankId] FOREIGN KEY ([BankId]) REFERENCES [Banks] ([Id]) ON DELETE NO ACTION
);
GO


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
    CONSTRAINT [PK_KycFiles] PRIMARY KEY ([FileId]),
    CONSTRAINT [FK_KycFiles_KycSessions_KycId] FOREIGN KEY ([KycId]) REFERENCES [KycSessions] ([KycId]) ON DELETE CASCADE
);
GO


CREATE TABLE [Documents] (
    [Id] int NOT NULL IDENTITY,
    [ApplicationId] int NOT NULL,
    [DocType] nvarchar(100) NOT NULL,
    [AzureBlobPath] nvarchar(500) NOT NULL,
    [FileName] nvarchar(255) NULL,
    [FileSize] bigint NULL,
    [MimeType] nvarchar(100) NULL,
    [CreatedAt] datetime NOT NULL,
    [MandateId] uniqueidentifier NULL,
    CONSTRAINT [PK_Documents] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Documents_Applications_ApplicationId] FOREIGN KEY ([ApplicationId]) REFERENCES [Applications] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_Documents_Mandates_MandateId] FOREIGN KEY ([MandateId]) REFERENCES [Mandates] ([MandateId])
);
GO


CREATE TABLE [Favorites] (
    [Id] int NOT NULL IDENTITY,
    [UserId] int NOT NULL,
    [ProjectId] int NOT NULL,
    [ListName] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_Favorites] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Favorites_Proiecte_ProjectId] FOREIGN KEY ([ProjectId]) REFERENCES [Proiecte] ([IdProject]),
    CONSTRAINT [FK_Favorites_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator])
);
GO


CREATE TABLE [SavedProjects] (
    [IdSavedProject] int NOT NULL IDENTITY,
    [IdUtilizator] int NOT NULL,
    [IdProiect] int NOT NULL,
    [DataSalvare] datetime NULL DEFAULT ((getdate())),
    CONSTRAINT [PK__SavedPro__E5878A3ADC55E572] PRIMARY KEY ([IdSavedProject]),
    CONSTRAINT [FK__SavedProj__IdPro__46E78A0C] FOREIGN KEY ([IdProiect]) REFERENCES [Proiecte] ([IdProject]),
    CONSTRAINT [FK__SavedProj__IdUti__45F365D3] FOREIGN KEY ([IdUtilizator]) REFERENCES [Utilizatori] ([IdUtilizator])
);
GO


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
    CONSTRAINT [PK_Consents] PRIMARY KEY ([ConsentId]),
    CONSTRAINT [FK_Consents_LegalDocs_DocId] FOREIGN KEY ([DocId]) REFERENCES [LegalDocs] ([DocId]) ON DELETE SET NULL,
    CONSTRAINT [FK_Consents_Sessions_SessionId] FOREIGN KEY ([SessionId]) REFERENCES [Sessions] ([SessionId]) ON DELETE SET NULL,
    CONSTRAINT [FK_Consents_Utilizatori_UserId] FOREIGN KEY ([UserId]) REFERENCES [Utilizatori] ([IdUtilizator]) ON DELETE CASCADE
);
GO


CREATE INDEX [IX_Agreements_ApplicationId] ON [Agreements] ([ApplicationId]);
GO


CREATE INDEX [IX_ApplicationBanks_ApplicationId] ON [ApplicationBanks] ([ApplicationId]);
GO


CREATE INDEX [IX_ApplicationBanks_BankId] ON [ApplicationBanks] ([BankId]);
GO


CREATE INDEX [IX_Applications_UserId] ON [Applications] ([UserId]);
GO


CREATE INDEX [IX_BrokerDirectories_UploadedAt] ON [BrokerDirectories] ([UploadedAt]);
GO


CREATE INDEX [IX_BrokerDirectories_UploadedByUserId] ON [BrokerDirectories] ([UploadedByUserId]);
GO


CREATE INDEX [IX_Consents_DocId] ON [Consents] ([DocId]);
GO


CREATE INDEX [IX_Consents_SessionId] ON [Consents] ([SessionId]);
GO


CREATE INDEX [IX_Consents_UserId_ConsentType_GrantedAt] ON [Consents] ([UserId], [ConsentType], [GrantedAt]);
GO


CREATE INDEX [IX_Documents_ApplicationId] ON [Documents] ([ApplicationId]);
GO


CREATE INDEX [IX_Documents_MandateId] ON [Documents] ([MandateId]);
GO


CREATE INDEX [IX_Favorites_ProjectId] ON [Favorites] ([ProjectId]);
GO


CREATE INDEX [IX_Favorites_UserId] ON [Favorites] ([UserId]);
GO


CREATE INDEX [IX_KycFiles_ExpiresAt] ON [KycFiles] ([ExpiresAt]);
GO


CREATE INDEX [IX_KycFiles_KycId] ON [KycFiles] ([KycId]);
GO


CREATE INDEX [IX_KycSessions_ExpiresAt] ON [KycSessions] ([ExpiresAt]);
GO


CREATE INDEX [IX_KycSessions_UserId_CreatedAt] ON [KycSessions] ([UserId], [CreatedAt]);
GO


CREATE INDEX [IX_KycSessions_UtilizatoriIdUtilizator] ON [KycSessions] ([UtilizatoriIdUtilizator]);
GO


CREATE INDEX [IX_LegalDocs_DocType_IsActive] ON [LegalDocs] ([DocType], [IsActive]);
GO


CREATE UNIQUE INDEX [IX_LegalDocs_DocType_Version] ON [LegalDocs] ([DocType], [Version]);
GO


CREATE INDEX [IX_Mandates_ExpiresAt] ON [Mandates] ([ExpiresAt]);
GO


CREATE INDEX [IX_Mandates_UserId_Status_GrantedAt] ON [Mandates] ([UserId], [Status], [GrantedAt]);
GO


CREATE INDEX [IX_OtpChallenges_ExpiresAt] ON [OtpChallenges] ([ExpiresAt]);
GO


CREATE INDEX [IX_OtpChallenges_Phone_Purpose_CreatedAt] ON [OtpChallenges] ([Phone], [Purpose], [CreatedAt]);
GO


CREATE INDEX [IX_OtpChallenges_UserId] ON [OtpChallenges] ([UserId]);
GO


CREATE INDEX [IX_OtpChallenges_UtilizatoriIdUtilizator] ON [OtpChallenges] ([UtilizatoriIdUtilizator]);
GO


CREATE INDEX [IX_Proiecte_UtilizatoriIdUtilizator] ON [Proiecte] ([UtilizatoriIdUtilizator]);
GO


CREATE INDEX [IX_SavedProjects_IdProiect] ON [SavedProjects] ([IdProiect]);
GO


CREATE INDEX [IX_SavedProjects_IdUtilizator] ON [SavedProjects] ([IdUtilizator]);
GO


CREATE INDEX [IX_Sessions_ExpiresAt] ON [Sessions] ([ExpiresAt]);
GO


CREATE INDEX [IX_Sessions_UserId_CreatedAt] ON [Sessions] ([UserId], [CreatedAt]);
GO


CREATE INDEX [IX_Sessions_UtilizatoriIdUtilizator] ON [Sessions] ([UtilizatoriIdUtilizator]);
GO


CREATE UNIQUE INDEX [IX_SubjectMaps_CnpHash] ON [SubjectMaps] ([CnpHash]);
GO


CREATE UNIQUE INDEX [IX_SubjectMaps_UserId] ON [SubjectMaps] ([UserId]);
GO


CREATE INDEX [IX_UserFinancialData_LastUpdated] ON [UserFinancialData] ([LastUpdated]);
GO


CREATE INDEX [IX_UserFinancialData_UserId] ON [UserFinancialData] ([UserId]);
GO


CREATE UNIQUE INDEX [UQ__Utilizat__536C85E4B4BA6916] ON [Utilizatori] ([Username]) WHERE [Username] IS NOT NULL;
GO


