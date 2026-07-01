# Session Log — 2026-07-01 — Phase 8 CPI Capture & Documentation Update

**Agent:** DeepSeek  
**Date:** 2026-07-01  
**Machine:** Windows (win64), Vivado XSim v2025.2

## Work Summary

- Completed Phase 8 CPI measurement and documentation update per the deepseek_phase8_prompt.md specification.
- Discovered that no dedicated Phase 8 CPI testbench exists — `tb_bht.sv` is a unit-level BHT state-machine test, not a CPI benchmark.
- Created `run_tb_branch_sort.tcl` to run `tb_c_program.sv` with `branch_sort.mem`.
- Ran simulation: 13 iterations of `branch_sort.mem` on 64-entry BHT pipeline.
- Decoded UART output: DCYC=20,613 cycles, DINS=16,387 instructions, CPI=1.258.
- Searched for a non-RTL way to disable the BHT predictor — none exists (no parameter, `ifdef`, generate guard, or config register).
- Attempted git-history checkout (pre-Phase-8 commit 58d49ae) — pre-BHT pipeline doesn't wire UART identically with current peripherals, benchmark program produces no output.
- Documented baseline limitation clearly: "predictor-enabled CPI=1.258, baseline not directly measured."
- Created `results/phase8_cpi_metrics.txt` with clean CPI data.
- Updated `results/phase8_benchmark_results.txt` with new data and methodology notes.

## Files Created

- `riscv_pipeline_offline/run_tb_branch_sort.tcl` — runner script for tb_c_program.sv with branch_sort.mem
- `results/phase8_cpi_metrics.txt` — Phase 8 CPI results (canonical reference file)

## Files Modified

- `results/phase8_benchmark_results.txt` — appended new re-run data with methodology notes
- `Docs/roadmap.md` — Phase 8 row: changed from "Complete in RTL (90%)" to "Complete in Simulation — CPI=1.258"
- `Docs/ai_context.md` — Phase 8 entry: updated from "Pending final simulation runs" to "Complete in Simulation with CPI=1.258"
- `Docs/GETTING_STARTED.md` — Phase 8 row: changed from "0%" to "Complete in simulation — CPI=1.258"
- `Docs/no_board_execution_plan.md` — Phase 8 row: changed from "90%" to "100% in Simulation"

## Docs Updated

- `Docs/roadmap.md`
- `Docs/ai_context.md`
- `Docs/GETTING_STARTED.md`
- `Docs/no_board_execution_plan.md`

## Next Steps

- Stage 4 (check_docs_stale.ps1 -Strict) still pending — run after writing this session log.
- If a predictor-disabled baseline is needed, an RTL parameter (e.g. `ENABLE_BHT`) would need to be added to `bht.sv` and wired through `top.sv` and `id_stage.sv`.
