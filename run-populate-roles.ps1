# Script PowerShell pentru popularea rolurilor în Azure SQL Database
# Folosește connection string-ul din appsettings.json

$connectionString = "Server=tcp:moneyshop.database.windows.net,1433;Initial Catalog=moneyshop;Persist Security Info=False;User ID=alexmoore;Password=Moneyshop2026?;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# SQL Script pentru popularea rolurilor
$sqlScript = @"
USE [moneyshop];
GO

-- Verifică dacă există deja roluri
IF NOT EXISTS (SELECT 1 FROM Roluri)
BEGIN
    -- Inserează doar rolurile necesare
    INSERT INTO Roluri (NumeRol) VALUES ('Utilizator');
    INSERT INTO Roluri (NumeRol) VALUES ('Administrator');
    INSERT INTO Roluri (NumeRol) VALUES ('Broker');
    
    PRINT 'Rolurile au fost populate cu succes!';
END
ELSE
BEGIN
    -- Verifică și adaugă rolurile care lipsesc
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Utilizator')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Utilizator');
    END
    
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Administrator')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Administrator');
    END
    
    IF NOT EXISTS (SELECT 1 FROM Roluri WHERE NumeRol = 'Broker')
    BEGIN
        INSERT INTO Roluri (NumeRol) VALUES ('Broker');
    END
END
"@

try {
    # Încarcă assembly-ul System.Data.SqlClient
    Add-Type -AssemblyName System.Data
    
    # Creează conexiunea
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    Write-Host "Conectat la baza de date Azure SQL..." -ForegroundColor Green
    
    # Elimină GO statements și execută fiecare comandă separat
    $commands = $sqlScript -split "GO" | Where-Object { $_.Trim() -ne "" }
    
    foreach ($command in $commands) {
        $command = $command.Trim()
        if ($command -ne "") {
            $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($command, $connection)
            $sqlCommand.CommandTimeout = 30
            $result = $sqlCommand.ExecuteNonQuery()
            Write-Host "Comandă executată: $($command.Substring(0, [Math]::Min(50, $command.Length)))..." -ForegroundColor Yellow
        }
    }
    
    # Verifică rolurile
    $checkCommand = "SELECT IdRol, NumeRol FROM Roluri ORDER BY IdRol"
    $checkSql = New-Object System.Data.SqlClient.SqlCommand($checkCommand, $connection)
    $reader = $checkSql.ExecuteReader()
    
    Write-Host "`nRoluri existente în baza de date:" -ForegroundColor Cyan
    while ($reader.Read()) {
        Write-Host "  ID: $($reader[0]) - $($reader[1])" -ForegroundColor White
    }
    $reader.Close()
    
    $connection.Close()
    Write-Host "`nScript executat cu succes!" -ForegroundColor Green
}
catch {
    Write-Host "Eroare: $($_.Exception.Message)" -ForegroundColor Red
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
    exit 1
}

