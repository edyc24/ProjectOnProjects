-- Add FileContentBase64 column to KycFiles table
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

