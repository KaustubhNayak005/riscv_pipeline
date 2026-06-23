# Session Log

## Work Summary
- Completed Phase 8 (Branch Prediction & CPI Experiments) RTL implementation.
- Developed a Bubble Sort benchmark program in C (`benchmark.c`) to measure pipeline flushes, cycles, and CPI.
- Implemented **Static Branch Prediction** (Backwards-Taken, Forwards-Not-Taken) in `id_stage.sv`.
- Optimized pipeline flush logic across `top.sv` and `ex_stage.sv` to only trigger full pipeline flushes upon an actual misprediction, preserving innocent instructions in the pipeline bubble.
- Upgraded the predictor to a **Dynamic Branch Prediction** model by designing and instantiating a 64-entry Branch History Table (BHT) with 2-bit saturating counters (`bht.sv`).
- Wired the branch prediction outcomes from the Execution stage back into the BHT to train the 2-bit counters on every branch resolution.

## Files Created
- `sw/demos/benchmark.c`
- `run_benchmark_sim.tcl`
- `riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/bht.sv`

## Files Modified
- `riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/id_stage.sv`
- `riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/ex_stage.sv`
- `riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/pipeline_registers.sv`
- `riscv_pipeline_offline/riscv_pipeline_offline.srcs/sources_1/imports/src/top.sv`

## Docs Updated (Complete)
- **`Docs/ai_context.md`**: Marked Phase 8 as Complete in RTL. Added recent updates for Static and Dynamic Branch Prediction. Updated next priority to capture Phase 8 metrics and begin Phase 9.
- **`Docs/planning/status.md`**: Updated the live phase tracker, completion table, recently completed tasks, and current next step to reflect Phase 8 progress.

## Verification Update (Post-Simulation)
- The human user successfully ran `run_benchmark_sim.tcl` and verified the output.
- Saved Phase 8 hardware performance metrics to `results/phase8_benchmark_results.txt`.
- Created `Docs/guides/Phase8_Verification_Guide.md` to document the verification procedure.
- Updated `Docs/GETTING_STARTED.md` and `Docs/ai_context.md` to track the new `results/` and `Docs/guides/` directories.
- Rewrote `run_benchmark_sim.tcl` to use absolute paths to resolve Vivado CWD issues.

## Next Steps
- Begin Phase 9 (Custom Packed-SIMD Extension) now that Phase 8 is completely verified.
