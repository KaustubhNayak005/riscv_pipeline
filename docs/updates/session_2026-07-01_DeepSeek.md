# Session Log — 2026-07-01 — Phase 1 Expected-Output Regression (Issue 3)

**Agent:** DeepSeek  
**Date:** 2026-07-01  
**Machine:** Windows (win64)

## Work Summary

- Completed Issue 3: Phase 1 Expected-Output Regression.
- Built all 9 programs from C source in an isolated scratch copy using the xPack RISC-V GCC 15.2.0 toolchain.
- All 9 freshly-built `.mem` files are byte-for-byte identical to the committed versions (diff-empty).
- Created `tests/expected/` with 9 `.mem` baselines.
- Created `tools/run_phase1_regression.ps1` that rebuilds each program, diffs via SHA256, and reports PASS/FAIL.
- Regression tested 3 times: PASS on clean, FAIL on deliberately corrupted file, PASS again after restoration.
- Discovered `sw/Makefile` hardcodes `demos/$(TARGET).c` — 3 programs (branch_sort, scalar_checksum, simd_checksum) are under `benchmarks/` and cannot be built with plain `make TARGET=name`. Regression script handles this via hardcoded per-program `Source` paths.
- Updated docs: GETTING_STARTED.md Phase 1 row, roadmap.md Live Task Tracker and Phase Completion Table rows.
- Removed dead references to `asm/demo_perf_uart.s` and `tools/build_program.ps1` from docs.

## Files Created

- `tests/expected/` (directory) — 9 `.mem` baseline files
- `tools/run_phase1_regression.ps1` — regression test script
- `tools/run_phase1_build.cmd` — batch helper for per-program build (kept as reference)

## Files Modified

- `Docs/GETTING_STARTED.md` — Phase 1 row updated
- `Docs/roadmap.md` — Phase 1 Live Task Tracker and Phase Completion Table rows updated

## Docs Updated

- `Docs/GETTING_STARTED.md`
- `Docs/roadmap.md`

## Next Steps

- The regression script is standalone and not wired into git hooks. If needed, a future session can add it to `install_hooks.ps1` or a `run_all_regressions.ps1` orchestrator.
