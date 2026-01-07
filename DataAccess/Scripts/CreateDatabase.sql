-- Script pentru crearea bazei de date MoneyShop pe SQL Server local
-- Rulează acest script în SSMS conectat la serverul local (P1-EDUARDCR sau localhost)

-- Găsește calea default a SQL Server pentru fișierele de date
DECLARE @DefaultDataPath NVARCHAR(260);
DECLARE @DefaultLogPath NVARCHAR(260);

EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'DefaultData',
    @DefaultDataPath OUTPUT;

EXEC master.dbo.xp_instance_regread 
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'DefaultLog',
    @DefaultLogPath OUTPUT;

-- Dacă nu găsește în registry, folosește calea standard
IF @DefaultDataPath IS NULL
BEGIN
    SELECT @DefaultDataPath = SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1)
    FROM master.sys.master_files
    WHERE database_id = 1 AND file_id = 1;
END

IF @DefaultLogPath IS NULL
BEGIN
    SELECT @DefaultLogPath = SUBSTRING(physical_name, 1, CHARINDEX(N'mastlog.ldf', LOWER(physical_name)) - 1)
    FROM master.sys.master_files
    WHERE database_id = 1 AND file_id = 2;
END

-- Verifică dacă baza de date există deja
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MoneyShop')
BEGIN
    -- Creează baza de date cu calea găsită
    DECLARE @Sql NVARCHAR(MAX);
    SET @Sql = N'
    CREATE DATABASE [MoneyShop]
    ON 
    ( NAME = ''MoneyShop'',
      FILENAME = ''' + @DefaultDataPath + N'MoneyShop.mdf'',
      SIZE = 100MB,
      MAXSIZE = 10GB,
      FILEGROWTH = 10MB )
    LOG ON 
    ( NAME = ''MoneyShop_Log'',
      FILENAME = ''' + @DefaultLogPath + N'MoneyShop_Log.ldf'',
      SIZE = 10MB,
      MAXSIZE = 1GB,
      FILEGROWTH = 10% );';
    
    EXEC sp_executesql @Sql;
    
    PRINT 'Baza de date MoneyShop a fost creată cu succes!';
    PRINT 'Calea fișierelor: ' + @DefaultDataPath;
END
ELSE
BEGIN
    PRINT 'Baza de date MoneyShop există deja.';
END
GO

-- Folosește baza de date MoneyShop
USE [MoneyShop];
GO

-- Verifică dacă baza de date este gata pentru migrații
PRINT 'Baza de date MoneyShop este gata pentru migrații Entity Framework.';
PRINT 'Următorul pas: Rulează "dotnet ef database update" în terminal.';
GO

