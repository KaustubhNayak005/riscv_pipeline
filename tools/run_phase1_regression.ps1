<#
.SYNOPSIS
  Phase 1 Expected-Output Regression Test.
  Rebuilds each C program from source and diffs against committed expected
  .mem file. Passes only when every program's output is bit-for-bit identical
  to the expected baseline.

.DESCRIPTION
  For each program under tests/expected/, this script:
    1. Creates an isolated scratch build directory
    2. Rebuilds the .mem file using riscv-none-elf-gcc + objcopy + bin_to_mem.py
       (mirroring the recipe in sw/Makefile, with per-program source paths for
        the three benchmarks living under benchmarks/ rather than demos/)
    3. Diffs the fresh .mem against tests/expected/<name>.mem via SHA256
    4. Reports PASS/FAIL per program

  Exits 0 if all programs pass, 1 if any fail.

  Invocation:
    .\tools\run_phase1_regression.ps1

.PARAMETER ScratchDir
  Scratch directory for builds. Defaults to tests/_scratch_regr/.
  Created automatically if it does not exist.

.NOTES
  Records the toolchain version at initialization for drift detection.
  A version mismatch produces a warning but is not a hard failure.
#>

param(
    [string]$ScratchDir = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
if (-not $ScratchDir) { $ScratchDir = "$ProjectRoot/tests/_scratch_regr" }

# Recorded toolchain version at time of script creation
$RecordedGcc = "riscv-none-elf-gcc (xPack GNU RISC-V Embedded GCC x86_64) 15.2.0"
$RecordedObjcopy = "GNU objcopy (xPack GNU RISC-V Embedded GCC x86_64) 2.45"

$Programs = @(
    @{ Name="benchmark";        Source="demos/benchmark.c" }
    @{ Name="branch_sort";      Source="benchmarks/branch_sort.c" }
    @{ Name="fibonacci_rec";    Source="demos/fibonacci_rec.c" }
    @{ Name="hello_world";      Source="demos/hello_world.c" }
    @{ Name="matmul";           Source="demos/matmul.c" }
    @{ Name="primes";           Source="demos/primes.c" }
    @{ Name="scalar_checksum";  Source="benchmarks/scalar_checksum.c" }
    @{ Name="simd_checksum";    Source="benchmarks/simd_checksum.c" }
    @{ Name="string_match";     Source="demos/string_match.c" }
)

$ExpectedDir = "$ProjectRoot/tests/expected"
$SwDir       = "$ProjectRoot/sw"
$CC          = "riscv-none-elf-gcc"
$OBJCOPY     = "riscv-none-elf-objcopy"
$PYTHON      = "python.exe"
$CFLAGS_STR  = "-march=rv32im -mabi=ilp32 -O1 -ffreestanding -nostdlib -fno-builtin"
$LinkerScript = "linker.ld"
$CRT0        = "crt0.S"
$LibUart     = "lib/uart.c"

$exitCode = 0

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Phase 1 Expected-Output Regression Test" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "-- Toolchain version --" -ForegroundColor Yellow
$gccVer = cmd /c "$CC --version" 2>&1 | Select-Object -First 1
$objcopyVer = cmd /c "$OBJCOPY --version" 2>&1 | Select-Object -First 1
Write-Host "  GCC:    $gccVer"
Write-Host "  Objcopy:$objcopyVer"

if ($gccVer -notlike "*$RecordedGcc*") {
    Write-Host "  WARNING: GCC version differs from recorded baseline" -ForegroundColor Yellow
    Write-Host "    Recorded: $RecordedGcc" -ForegroundColor Yellow
    Write-Host "    Current:  $gccVer" -ForegroundColor Yellow
}
if ($objcopyVer -notlike "*$RecordedObjcopy*") {
    Write-Host "  WARNING: Objcopy version differs from recorded baseline" -ForegroundColor Yellow
}
Write-Host ""

if (Test-Path $ScratchDir) { Remove-Item -Recurse -Force $ScratchDir }
New-Item -ItemType Directory -Path $ScratchDir -Force | Out-Null
Copy-Item "$SwDir/crt0.S"        "$ScratchDir/"
Copy-Item "$SwDir/linker.ld"     "$ScratchDir/"
Copy-Item "$SwDir/bin_to_mem.py" "$ScratchDir/"
Copy-Item "$SwDir/lib"           "$ScratchDir/lib" -Recurse
Copy-Item "$SwDir/demos"         "$ScratchDir/demos" -Recurse
Copy-Item "$SwDir/benchmarks"    "$ScratchDir/benchmarks" -Recurse

Write-Host "-- Build and diff each program --" -ForegroundColor Yellow
$failedCount = 0
$passedCount = 0

function Invoke-External([string]$cmd) {
    Invoke-Expression $cmd
    return $LASTEXITCODE
}

foreach ($prog in $Programs) {
    $name   = $prog.Name
    $source = $prog.Source
    $expectedFile = "$ExpectedDir/$name.mem"

    if (-not (Test-Path $expectedFile)) {
        Write-Host "  FAIL  $name  (expected file missing: $expectedFile)" -ForegroundColor Red
        $failedCount++
        $exitCode = 1
        continue
    }

    Write-Host "  BUILD $name ..." -NoNewline

    Push-Location $ScratchDir

    # Step 1: Compile
    $rc = Invoke-External "$CC $CFLAGS_STR -T $LinkerScript $CRT0 $source $LibUart -o $name.elf 2>&1"
    if ($rc -ne 0) { Write-Host "FAIL (compile)" -ForegroundColor Red; Pop-Location; $failedCount++; $exitCode = 1; continue }

    # Step 2: objcopy
    $rc = Invoke-External "$OBJCOPY -O binary $name.elf $name.bin 2>&1"
    if ($rc -ne 0) { Write-Host "FAIL (objcopy)" -ForegroundColor Red; Pop-Location; $failedCount++; $exitCode = 1; continue }

    # Step 3: bin_to_mem.py
    $rc = Invoke-External "$PYTHON bin_to_mem.py $name.bin $name.mem 2>&1"
    if ($rc -ne 0) { Write-Host "FAIL (bin_to_mem)" -ForegroundColor Red; Pop-Location; $failedCount++; $exitCode = 1; continue }

    Pop-Location

    # Step 4: Compare fresh output against expected
    $freshPath = "$ScratchDir/$name.mem"
    $freshHash = (certutil -hashfile $freshPath SHA256 2>&1 | Select-String -Pattern '^[0-9a-f]{64}$' | Select-Object -First 1).ToString().Trim()
    $expectedHash = (certutil -hashfile $expectedFile SHA256 2>&1 | Select-String -Pattern '^[0-9a-f]{64}$' | Select-Object -First 1).ToString().Trim()

    if ($freshHash -eq $expectedHash) {
        Write-Host "PASS" -ForegroundColor Green
        $passedCount++
    } else {
        Write-Host "FAIL (hash mismatch)" -ForegroundColor Red
        Write-Host "        expected SHA256: $expectedHash" -ForegroundColor Red
        Write-Host "        got      SHA256: $freshHash" -ForegroundColor Red
        $failedCount++
        $exitCode = 1
    }
}

Write-Host ""
Write-Host "-- Results --" -ForegroundColor Yellow
Write-Host "  Passed: $passedCount / $($Programs.Count)" -ForegroundColor Green
if ($failedCount -gt 0) {
    Write-Host "  Failed: $failedCount / $($Programs.Count)" -ForegroundColor Red
}
Write-Host ""

if ($exitCode -eq 0) {
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "     ALL REGRESSION TESTS PASSED            " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "     REGRESSION TESTS FAILED                " -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
}

Remove-Item -Recurse -Force $ScratchDir -ErrorAction SilentlyContinue | Out-Null
exit $exitCode
