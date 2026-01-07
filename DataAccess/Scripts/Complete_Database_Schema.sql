IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS(SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = N'20260103104930_UpdateKycAndRecentChanges')
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260103104930_UpdateKycAndRecentChanges', N'7.0.13');
END;
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

IF NOT EXISTS(SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = N'20260103140908_AddFileContentBase64ToKycFiles')
BEGIN
    DECLARE @var0 sysname;
    SELECT @var0 = [d].[name]
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[KycFiles]') AND [c].[name] = N'BlobPath');
    IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [KycFiles] DROP CONSTRAINT [' + @var0 + '];');
    ALTER TABLE [KycFiles] ALTER COLUMN [BlobPath] nvarchar(1000) NULL;
END;
GO

IF NOT EXISTS(SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = N'20260103140908_AddFileContentBase64ToKycFiles')
BEGIN
    ALTER TABLE [KycFiles] ADD [FileContentBase64] nvarchar(max) NULL;
END;
GO

IF NOT EXISTS(SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = N'20260103140908_AddFileContentBase64ToKycFiles')
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260103140908_AddFileContentBase64ToKycFiles', N'7.0.13');
END;
GO

COMMIT;
GO

