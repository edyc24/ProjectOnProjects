# Script PowerShell pentru eliminare comentarii din fișiere SQL
param(
    [string]$InputFile,
    [string]$OutputFile
)

$content = Get-Content $InputFile -Raw -Encoding UTF8

# Elimină comentarii multi-linie /* ... */
$content = $content -replace '/\*.*?\*/', '' -replace '(?s)/\*.*?\*/', ''

# Elimină comentarii single-line -- (dar păstrează -- în string-uri)
$lines = $content -split "`n"
$cleanedLines = @()

foreach ($line in $lines) {
    $inString = $false
    $quoteChar = $null
    $result = ""
    
    for ($i = 0; $i -lt $line.Length; $i++) {
        $char = $line[$i]
        $nextChar = if ($i + 1 -lt $line.Length) { $line[$i + 1] } else { $null }
        
        if (-not $inString) {
            if ($char -eq "'" -or $char -eq '"') {
                $inString = $true
                $quoteChar = $char
                $result += $char
            } elseif ($char -eq '-' -and $nextChar -eq '-') {
                # Găsit --, ignoră restul liniei
                break
            } else {
                $result += $char
            }
        } else {
            $result += $char
            if ($char -eq $quoteChar -and ($i -eq 0 -or $line[$i-1] -ne '\')) {
                $inString = $false
                $quoteChar = $null
            }
        }
    }
    
    $trimmed = $result.Trim()
    if ($trimmed) {
        $cleanedLines += $trimmed
    }
}

$cleanedContent = $cleanedLines -join "`n"

# Elimină linii goale multiple consecutive
$cleanedContent = $cleanedContent -replace "(`n\s*){3,}", "`n`n"

Set-Content -Path $OutputFile -Value $cleanedContent -Encoding UTF8 -NoNewline

Write-Host "Procesat: $InputFile -> $OutputFile"

