# Adds Vivado 2023.2 to PATH for the current PowerShell session.
# Run from the repository root with:
#   . .\scripts\setup_vivado_path.ps1

$candidateBins = @(
    "C:\Programs\Xilinx2023.2\Vivado\2023.2\bin",
    "C:\Xilinx\Vivado\2023.2\bin"
)

$vivadoBin = $null
foreach ($candidate in $candidateBins) {
    if (Test-Path (Join-Path $candidate "vivado.bat")) {
        $vivadoBin = $candidate
        break
    }
}

if (-not $vivadoBin) {
    $vivadoCommand = Get-Command vivado -ErrorAction SilentlyContinue
    if ($vivadoCommand) {
        $vivadoBin = Split-Path -Parent $vivadoCommand.Source
    }
}

if (-not $vivadoBin) {
    throw "Vivado 2023.2 was not found. Expected one of: $($candidateBins -join ', '), or vivado already on PATH."
}

if (($env:Path -split ';') -notcontains $vivadoBin) {
    $env:Path += ";$vivadoBin"
}

Write-Host "INFO: Vivado PATH for this PowerShell session includes: $vivadoBin"
vivado -version
