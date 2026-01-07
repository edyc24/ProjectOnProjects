-- Add FileContentBase64 column to KycFiles table
-- Make BlobPath nullable (deprecated, kept for backward compatibility)
-- Run this script in SSMS (SQL Server Management Studio)

-- Step 1: Add FileContentBase64 column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'KycFiles') AND name = 'FileContentBase64')
BEGIN
    ALTER TABLE KycFiles ADD FileContentBase64 NVARCHAR(MAX) NULL;
    PRINT 'FileContentBase64 column added successfully';
END
ELSE
BEGIN
    PRINT 'FileContentBase64 column already exists';
END
GO

-- Step 2: Make BlobPath nullable (if it's not already nullable)
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'KycFiles') AND name = 'BlobPath' AND is_nullable = 0)
BEGIN
    ALTER TABLE KycFiles ALTER COLUMN BlobPath NVARCHAR(1000) NULL;
    PRINT 'BlobPath column made nullable successfully';
END
ELSE
BEGIN
    PRINT 'BlobPath column is already nullable or does not exist';
END
GO

PRINT 'Migration completed successfully!';
GO

-- Mark the migration as applied in __EFMigrationsHistory
-- This is needed because the column was added manually via SQL script
IF NOT EXISTS (SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = '20260103140908_AddFileContentBase64ToKycFiles')
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES ('20260103140908_AddFileContentBase64ToKycFiles', '7.0.13');
    PRINT 'Migration marked as applied in __EFMigrationsHistory';
END
ELSE
BEGIN
    PRINT 'Migration already marked as applied';
END
GO

