@echo off
rem run_phase1_build.cmd <target> <source>
rem Example: run_phase1_build.cmd benchmark demos/benchmark.c
setlocal
set CC=riscv-none-elf-gcc
set OBJCOPY=riscv-none-elf-objcopy
set TARGET=%1
set SOURCE=%2
set CFLAGS=-march=rv32im -mabi=ilp32 -O1 -ffreestanding -nostdlib -fno-builtin

%CC% %CFLAGS% -T linker.ld crt0.S %SOURCE% lib/uart.c -o %TARGET%.elf
if errorlevel 1 exit /b 1

%OBJCOPY% -O binary %TARGET%.elf %TARGET%.bin
if errorlevel 1 exit /b 1

python bin_to_mem.py %TARGET%.bin %TARGET%.mem
exit /b %errorlevel%
