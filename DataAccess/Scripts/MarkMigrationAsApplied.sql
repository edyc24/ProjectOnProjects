-- Mark the migration as applied in __EFMigrationsHistory
-- This is needed because the column was added manually via SQL script

-- Check if migration is already recorded
IF NOT EXISTS (SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = '20260103140908_AddFileContentBase64ToKycFiles')
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES ('20260103140908_AddFileContentBase64ToKycFiles', '7.0.13');
    PRINT 'Migration marked as applied successfully';
END
ELSE
BEGIN
    PRINT 'Migration already marked as applied';
END
GO

