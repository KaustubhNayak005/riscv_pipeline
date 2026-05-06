$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vivadoBat = "C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"
$tclScript = Join-Path $scriptDir "run_offline_bringup.tcl"

if (-not (Test-Path -LiteralPath $vivadoBat)) {
    throw "Vivado was not found at $vivadoBat"
}

& $vivadoBat -mode batch -source $tclScript
exit $LASTEXITCODE
