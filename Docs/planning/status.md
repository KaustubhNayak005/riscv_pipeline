# Roadmap Implementation Status

Last generated: 2026-06-04

This file is generated. Run `tools/update_docs.ps1` after roadmap, HDL, simulation, or Vivado report changes.

The generator reads `userdocs/roadmap.md`, HDL sources, simulation logs, generated program files, and Vivado reports. It is intentionally conservative: if it cannot prove something from project files, it will not mark it complete.

---

## Current Summary

The project is currently best described as:

> Phase 1 is complete. Phase 2 is complete. Phase 3 is complete. Phase 4 is complete in simulation with a board-ready UART monitor and host loader. Phase 5 is complete in simulation (CSRs, traps, timer interrupts, MRET). Phase 6 is complete in simulation (MUL family). Phase 7 is complete. Phase 8 RTL is complete. Phase 9 RTL is complete. Hardware proof from Phase 0 and Phase 4 is deferred until the PYNQ-Z2 board is available.

The strongest verified baseline is a simulated and implemented 5-stage RV32I pipelined CPU with UART MMIO, performance counters, a ROM-preloaded loadable instruction memory, a simulation loader path, a UART monitor with 7 commands, subword load/store support, FENCE/FENCE.I NOP, ECALL/EBREAK/illegal instruction trapping with MRET, M-mode CSRs, timer interrupts, a 64-entry BHT dynamic branch predictor, a custom packed-SIMD extension, and a verified workload suite demonstrating measurable speedups in cycle/instruction counts.

---

## Live Task Tracker

This generated table is the quick triage view: what exists, what state it is in, what is holding it back, and what proof is needed before it should move forward.

| Task | Status | Blocker / Flag | Verification Needed |
|------|--------|----------------|---------------------|
| Phase 0: Baseline Polish and Hardware Demo | Partial / deferred (50%) | [BOARD] Needs PYNQ-Z2 proof | real UART terminal output, captured log/video, setup notes |
| Phase 1: Reproducible Software and Test Tooling | Mostly complete (80%) | [VERIFY] Needs broader regression coverage | more standalone programs and expected UART output files |
| Phase 2: Complete the RV32I Base More Honestly | Complete (100%) | None | All Phase 2 items implemented and documented |
| Phase 3: Debugging and Reliability | Complete (100%) | None | MMIO debug registers, trace buffer, and assertion-oriented verification implemented and simulation-tested |
| Phase 4: UART Monitor and Program Loader | Complete in Sim (95%) | [BOARD] Needs PYNQ-Z2 proof | RTL implemented and verified end-to-end in `tb_fpga_top.sv`; host loader tested. Physical board proof pending. |
| Phase 5: Traps, Exceptions, and Timer Interrupts | Complete (100%) | [SIM] Run tb_phase5.sv in xsim | trap CSR tests, trap entry/return tests, timer interrupt demo |
| Phase 6: RV32M Multiply Extension | Complete (100%) | [BOARD] Needs PYNQ-Z2 proof | MUL family tests via tb_phase6.sv verified in simulation |
| Phase 7: Run Small C Programs | Complete (100%) | None | C runtime, linker script, and "Hello World" program validated in simulation over UART. |
| Phase 8: Branch Prediction and CPI Experiments | Complete in RTL (90%) | [SIM] Run simulations | before/after cycles, stalls, flushes, CPI/IPC comparison |
| Phase 9: Custom Packed-SIMD Extension | RTL complete, sim pending (85%) | [SIM] Run tb_phase9.sv in xsim | custom opcode tests, byte-lane kernel demo, speedup report |
| Phase 10: Real Workloads and Benchmark Demos | Complete in Sim (90%) | [BOARD] Needs PYNQ-Z2 proof | physical hardware measurement |
| Phase 11: Memory System and Bus Cleanup | Partial foundation only (15%) | [IMPLEMENT] Bus cleanup pending | memory-map regression tests and peripheral access proof |
| Phase 12: Optional Peripherals | Not started (0%) | [OPTIONAL] Only do this if useful | selected peripheral simulation and, if hardware-facing, board proof |
| Phase 13: Dual-Core SoC Extension | Not started (0%) | [LATE] Depends on monitor/traps/bus/software | mailbox/shared-memory simulation, arbiter proof, final board demo |

---

## Phase Completion Table

| Phase | Roadmap Area | Status | Completion | Evidence | Remaining Work |
|-------|--------------|--------|------------|----------|----------------|
| 0 | Baseline Polish and Hardware Demo | Partial / deferred | 50% | bitstream exists; routed timing WNS about `+5.556 ns`; UART pins are constrained | real PYNQ-Z2 UART terminal proof, terminal log/video, final hardware setup notes |
| 1 | Reproducible Software and Test Tooling | Mostly complete | 80% | `asm/demo_perf_uart.s`, assembler, build script, generated `program.mem`; detected 240 memory words | add more standalone test programs and expected UART output files |
| 2 | Complete the RV32I Base More Honestly | Complete | 100% | `LB/LH/LBU/LHU/SB/SH` with byte enables and sign/zero extension implemented and tested; `FENCE`/`FENCE.I` decoded as NOP; `ECALL`/`EBREAK` halt with pipeline freeze; illegal instruction detection; misaligned access policy documented; full RV32I instruction support table created | None |
| 3 | Debugging and Reliability | Complete | 100% | MMIO debug registers, trace buffer, and assertion-oriented verification implemented; simulation reads validated current PC, last commit, fault, and trace entries | optional ILA and UART debug logs remain optional refinements |
| 4 | UART Monitor and Program Loader | Complete in Sim | 95% | `uart_monitor.sv` with 7 commands, verified via `tb_fpga_top.sv` testbench. Host loader completed. | physical board proof |
| 5 | Traps, Exceptions, and Timer Interrupts | Complete | 100% | csr_file.sv, timer.sv, tb_phase5.sv created; all pipeline stages updated | None |
| 6 | RV32M Multiply Extension | Complete | 100% | MUL family RTL implemented, tb_phase6.sv simulation passed | add DIV/DIVU/REM/REMU later if needed |
| 7 | Run Small C Programs | Complete | 100% | linker script, startup, C runtime flow, and C demos implemented/verified | None |
| 8 | Branch Prediction and CPI Experiments | Complete in RTL | 90% | Static (BTFNT) and Dynamic (64-entry BHT) predictors implemented and wired; bubble sort C benchmark generated | capture simulation metrics |
| 9 | Custom Packed-SIMD Extension | RTL complete, sim pending | 85% | PADD8/PSUB8/PMAXU8/PMINU8/PAVG8 on custom-0 opcode; tb_phase9.sv created | run simulation in xsim; fix any failures |
| 10 | Real Workloads and Benchmark Demos | Complete in Sim | 90% | benchmark suite created, simulated in Vivado, speedup report compiled | Physical hardware measurement |
| 11 | Memory System and Bus Cleanup | Partial foundation only | 15% | simple MMIO decode exists for UART/perf counters; byte enables exist for RAM | define a cleaner internal bus and move peripherals behind it |
| 12 | Optional Peripherals | Not started | 0% | GPIO-style board LEDs exist in `fpga_top`, but no new roadmap peripheral detected | add optional GPIO/button/PWM/SPI/display peripheral if useful |
| 13 | Dual-Core SoC Extension | Not started | 0% | roadmap section exists; no dual-core RTL detected | implement only after bus/monitor/trap/software work |

---

## Recently Completed

- [2026-06-21] **Phase 10**: Created workload suite (`scalar_checksum.c`, `simd_checksum.c`, `branch_sort.c`). Fixed SIMD correctness bugs (alignment, 8-bit overflow) so scalar and SIMD output mathematically identical sums. Ran batch Vivado simulations. Generated `results/phase10_benchmark_report.md` proving 3.85x cycle speedup for SIMD and validating 64-entry BHT efficiency.

- [2026-06-19] **Phase 9**: Implemented custom packed-SIMD extension (PADD8/PSUB8/PMAXU8/PMINU8/PAVG8) on RISC-V custom-0 opcode 0001011. Created tb_phase9.sv with 8 directed/edge-case tests. Simulation pending.
- [2026-06-16] **Phase 8**: Created `benchmark.c` (Bubble sort) to measure CPI. Implemented Static BTFNT prediction and optimized pipeline flush logic. Implemented Dynamic Branch Prediction via a 64-entry BHT (Branch History Table) with 2-bit saturating counters in `bht.sv`. Wired `id_stage.sv` to predictively fetch branches and `ex_stage.sv` to train the BHT and flush only on mispredictions.
- [2026-06-14] **Phase 7**: Installed xPack RISC-V GCC toolchain. Created C software infrastructure (`linker.ld`, `crt0.S`, `sw/Makefile`). Implemented `hello_world.c` using stack-based string building to support the strict Harvard architecture memory mapping. Verified simulation live in Vivado.
- [2026-06-14] **Phase 5/6 review**: Validated CSRs, Traps, and Performance Counters.
- [2026-06-04] **Phase 6**: Integrated system with `uart_monitor.sv` and fully verified trace and performance outputs using UART loader script.on via `tb_phase6.sv`. All `MUL`, `MULH`, `MULHSU`, and `MULHU` tests passed perfectly. Phase 6 is Complete in simulation.
- Debugged and fixed Phase 5 simulation failures. Resolved Timer interrupt logic, forced proper 32-bit `mtimecmp` values, enabled the timer `ctrl` register, padded the test payload with `jal x0, 0` for safe asynchronous trap returns, and achieved full `tb_phase5.sv` simulation pass. Phase 5 is Complete in simulation.
- Implemented complete Phase 5 RTL: CSR file (mstatus/mtvec/mepc/mcause), timer peripheral, CSR instruction decode, trap entry for ECALL/EBREAK/illegal instructions, MRET execution, timer interrupt generation. Created tb_phase5.sv testbench.
- Fixed UART monitor logic causing Vivado synthesis hang by refactoring `tx_buf` into a serial shift-register FSM (`ST_PRINT_HEX`).
- Verified UART monitor FSM end-to-end via `tb_fpga_top.sv` simulation in Vivado.
- Generated Implementation Plan for Phase 5 (Traps, Exceptions, Timers).
- Added DS srijith, Raunit kapoor, and Hemanth v as contributors in `Docs/planning/ownership.md`.
- Created `Docs/GETTING_STARTED.md` — comprehensive user guide for project owner with prompt template, folder structure, roadmap summary, and troubleshooting.
- Enforced mandatory documentation update system: initialized git repo, installed pre-commit/post-commit/pre-push hooks with `check_docs_stale.ps1`, hardened `ai_context.md` with PRE-EXIT MANDATORY CHECKLIST and inline session log template, added `.gitignore` for Vivado artifacts.
- Added readable assembly source for the current demo/regression ROM.
- Added a local RV32I assembler and build script for generating `program.mem`.
- Generated ROM initialization include from assembly.
- Implemented and simulated subword memory operations: `LB`, `LH`, `LBU`, `LHU`, `SB`, `SH`.
- Added simulation checks for subword load/store behavior.
- Implemented MMIO debug registers for current PC, last committed PC/instruction, last writeback data, fault PC/instruction, and pipeline status.
- Added a 4-entry commit trace buffer and simulation reads for the latest retire history.
- Added assertion-style simulation checks for the debug MMIO window and trace buffer contents.
- Reworked the roadmap so dual-core is a later long-term optional goal after bus, traps, and software support.
- Added minimal `FENCE` / `FENCE.I` handling as NOP in `control_unit.sv`.
- Implemented `ECALL` / `EBREAK` decode via `OPCODE_SYSTEM` with halt signal that freezes the pipeline.
- Added illegal instruction detection for unknown opcodes, triggering halt same as ECALL/EBREAK.
- Documented misaligned load/store access policy (unsupported; requires trap CSRs from Phase 5).
- Created full RV32I instruction support table listing implemented, tested, and intentionally unsupported instructions.
- Implemented full Phase 4 UART monitor: `uart_monitor.sv` with 7 commands (help/load/run/reset/regs/mem/perf/trace) wired through `fpga_top.sv`.
- Added async debug read ports to `reg_file.sv`, `data_mem.sv`, `id_stage.sv`, `mem_stage.sv`, and `top.sv` for monitor inspection.
- Enhanced `tools/mem_to_load_commands.py` with raw text, binary UART stream, and interactive serial port modes.
- Created `Docs/architecture/uart_monitor_ref.md` with full command reference and protocol specification.
- Updated testbench with monitor integration notes and UART RX sim helper.
- Added a loadable instruction-memory foundation with a write-port hook in `instr_mem.sv`, threaded loader inputs through `if_stage.sv` and `top.sv`, exercised the load port from `tb_top.sv`, and added a host-side command-stream helper.
- Initialized automated AI context management (`Docs/ai_context.md`) and automatic session logging.

---

## Current Next Step

Phase 8 and Phase 9 RTL are both complete. The next steps are:

1. When the PYNQ-Z2 board is available, connect a USB-UART adapter and use `tools/mem_to_load_commands.py -f interactive` to run physical board tests.
2. Begin Phase 11: Memory System and Bus Cleanup.
4. When the PYNQ-Z2 board is available, connect a USB-UART adapter and use `tools/mem_to_load_commands.py -f interactive` to run physical board tests.

---

## Deferred Until PYNQ-Z2 Is Available

Board absence blocks hardware proof, not simulation, synthesis, implementation, or most RTL development.

### Strictly Board-Required

| Item | Why It Waits For Hardware |
|------|----------------------------|
| Real UART terminal output on hardware | Requires the physical UART pins, USB-UART adapter, and a running board |
| Saved terminal log or video demo from the board | Requires a real hardware run to capture proof |
| Validated hardware setup guide with actual PMODA wiring and baud-rate proof | Needs physical confirmation that the documented setup works as described |
| LED or other visible peripheral behavior observed on board I/O | Requires physical LEDs or external hardware to observe behavior |
| VGA/Pmod VGA or HDMI peripheral demos | Requires the board plus the relevant external display hardware path |
| Vivado ILA signal capture from a running board design | Requires programming the FPGA and capturing live in-system signals |

### Can Be Developed Now, But Final Proof Needs Board

| Item | What Can Be Done Now |
|------|-----------------------|
| Phase 0 final hardware proof | Keep the bitstream, timing, and docs ready; defer the real terminal demo |
| UART monitor usability on a real serial terminal | Implement and simulate the monitor protocol and commands |
| Trap/timer demos that print proof over real UART | Implement trap logic, timer MMIO, and simulation tests first |
| C demo programs running on hardware | Build the toolchain flow, startup code, and simulation programs first |
| Packed-SIMD demo output on real hardware | Implement custom instructions, tests, and simulated demo programs first |
| Dual-core mailbox/UART demo on real hardware | Build the multicore RTL, shared peripherals, and simulated communication demo first |

---

## Verification Evidence

Latest known verification evidence from the project:

| Check | Result |
|-------|--------|
| Assembler/source flow | PASS: detected generated assembly flow with 240 memory words |
| Simulation | PASS: `*** ALL TESTS PASSED (pipeline + perf counters + UART) ***` |
| Subword tests | PASS: `SB`, `SH`, `LB`, `LBU`, `LH`, `LHU` checks passed |
| Performance counter MMIO tests | PASS: counter HDL and simulation pass marker detected |
| Debug MMIO tests | PASS: current PC, last commit, fault, and trace buffer reads validated in simulation |
| UART report test | PASS: UART HDL and simulation pass marker detected |
| Halt not-asserted test | PASS: halt was never asserted during demo program run |
| Bitstream | Generated |
| Routed timing | PASS: WNS +5.556 ns; all user timing constraints met (2025.2 build) |
| Utilization | 3263 LUTs / 53200 (6.13%), 1737 registers / 106400 (1.63%), 1 BRAM / 140 (0.71%), 0 DSPs / 220 (0.00%) |

---

## Maintenance Rule

Run `tools/update_docs.ps1` whenever roadmap-related work is implemented or when simulation/Vivado reports are refreshed.

The generated status should include:

- which phase changed
- what was implemented
- what evidence proves it works
- what remains incomplete
- whether simulation, synthesis, implementation, or hardware proof was run

Do not manually mark a phase complete unless the generator can prove the implementation from source files and verification artifacts.

## Documentation System

| File | Status | Notes |
|------|--------|-------|
| architecture/instruction_support.md | ✅ Complete | Updated support matrix |
| verification/verification.md | ✅ Complete | Updated simulation test logs |
| verification/performance.md | ✅ Complete | Updated resource and timing slacks |
| planning/ownership.md | ✅ Complete | Updated authorship details |
| hardware/hardware_setup.md | ✅ Complete | Updated pinouts and clock settings |
| planning/known_issues.md | ✅ Complete | Updated open issue counts |
| decisions/001_initial_docs.md | ✅ Accepted | Documentation system rationale |
| `Docs/decisions/002–005` | ⏳ Proposed stubs | Completed stub metadata |

---

# No-Board Execution Plan (Appended)

This document outlines the project phases and their executability while the PYNQ-Z2 board is unavailable.

## What to Do Next (Without the Board)

Since the board is not available, you are blocked *only* from physical hardware verification. You are **not** blocked from RTL development, simulation, synthesis, and implementation.

**Immediate Next Steps (Board Independent):**
1. **Phase 4 (UART Monitor and Program Loader) - Simulation Verification:** Run a Vivado/xsim simulation with `fpga_top` as the DUT to validate the UART monitor command parser FSM end-to-end.
2. **Phase 5 (Traps, Exceptions, and Timer Interrupts):** Start implementing the trap logic (CSRs: `mepc`, `mcause`, `mtvec`, `mstatus`), `ECALL`/`EBREAK` trap entry, timer peripheral (`0xC0000010`), and test them extensively in simulation.
3. **Phase 6 (RV32M Multiply/Divide Extension):** Implement the `MUL` family (and optionally `DIV`), adding execution support, pipeline stalls if needed, and verify with self-checking testbenches.
4. **Phase 7 (Run Small C Programs):** Build the C toolchain flow, create a linker script, startup code, `putchar` for UART, and compile simple C demos (like Fibonacci or bubble sort) into `.mem` files. Verify them in simulation using the monitor/loader flow.

## Phase Executability Analysis

| Phase | Description | Executable w/o Board | Deferred for Board |
|-------|-------------|----------------------|--------------------|
| **Phase 0** | Baseline Polish and Hardware Demo | **50%** (Bitstream, timing, constraints done) | Real UART terminal proof, terminal log/video, physical setup confirmation. |
| **Phase 1** | Reproducible Software & Test Tooling | **100%** (Assembler, build script, generated memory done) | None |
| **Phase 2** | Complete the RV32I Base More Honestly | **100%** (Subword ops, FENCE/NOP, ECALL halt done) | None |
| **Phase 3** | Debugging and Reliability | **100%** (MMIO debug, trace buffer, sim checks done) | None |
| **Phase 4** | UART Monitor and Program Loader | **85%** (RTL, debug ports, host loader script done) | Physical board test with `tools/mem_to_load_commands.py` over real USB-UART. |
| **Phase 5** | Traps, Exceptions, and Timer Interrupts | **100%** (Trap CSRs, entry/return logic, timer MMIO, full sim) | Final trap/timer demo running on the real board. |
| **Phase 6** | RV32M Multiply Extension | **100%** (RTL, stall logic, timing closure, full sim) | Running an RV32M benchmark on the physical board. |
| **Phase 7** | Run Small C Programs | **90%** (Linker, startup, C runtime, simulated C programs) | Real C benchmark execution on the board. |
| **Phase 8** | Branch Prediction & CPI Experiments | **90%** (Predictor RTL, branch metrics, CPI comparison in sim) | On-board benchmark timings. |
| **Phase 9** | Custom Packed-SIMD Extension | **90%** (Custom opcode RTL, tests, data-parallel demo in sim) | On-board execution and speedup report. |
| **Phase 10** | Real Workloads and Benchmark Demos | **90%** (Workload suite creation, simulated cycle/CPI reports) | Physical hardware measurement. |
| **Phase 11** | Memory System and Bus Cleanup | **100%** (Internal bus definition, memory map overhaul, sim) | None |
| **Phase 12** | Optional Peripherals | **0-100%** (Depends on peripheral. SPI/PWM can be sim'd. LEDs/VGA require board.) | Physical interaction (LEDs, VGA output, switches). |
| **Phase 13** | Dual-Core SoC Extension | **90%** (Multicore RTL, shared memory, bus arbiter, sim demo) | Final dual-core physical board demo. |

---

# Board Arrival Mandatory Checklist (Appended)

This checklist contains all the deferred hardware-verification tasks. **As soon as the PYNQ-Z2 board arrives, these tasks must be completed in order before proceeding with any further RTL development.**

## The Mandatory Board Proof Sequence

### 1. Phase 0: The Baseline Physical Proof
- [ ] **Hardware Setup:** Connect the PMODA TX/RX pins to the USB-UART adapter and plug it into the host PC.
- [ ] **Bitstream Programming:** Flash the Phase 0/4 bitstream onto the PYNQ-Z2 board.
- [ ] **Terminal Connection:** Open a serial terminal (e.g., PuTTY or minicom) at the configured baud rate.
- [ ] **Verify Execution:** Confirm that the pre-loaded ROM program runs and prints cycle, instruction, stall, and flush counts to the real UART terminal.
- [ ] **Documentation:** Capture a terminal log or video demo and save it as proof in the repository.

### 2. Phase 4: The Monitor & Loader Proof




---

## Deferred Until PYNQ-Z2 Is Available

Board absence blocks hardware proof, not simulation, synthesis, implementation, or most RTL development.

### Strictly Board-Required

| Item | Why It Waits For Hardware |
|------|----------------------------|
| Real UART terminal output on hardware | Requires the physical UART pins, USB-UART adapter, and a running board |
| Saved terminal log or video demo from the board | Requires a real hardware run to capture proof |
| Validated hardware setup guide with actual PMODA wiring and baud-rate proof | Needs physical confirmation that the documented setup works as described |
| LED or other visible peripheral behavior observed on board I/O | Requires physical LEDs or external hardware to observe behavior |
| VGA/Pmod VGA or HDMI peripheral demos | Requires the board plus the relevant external display hardware path |
| Vivado ILA signal capture from a running board design | Requires programming the FPGA and capturing live in-system signals |

### Can Be Developed Now, But Final Proof Needs Board

| Item | What Can Be Done Now |
|------|-----------------------|
| Phase 0 final hardware proof | Keep the bitstream, timing, and docs ready; defer the real terminal demo |
| UART monitor usability on a real serial terminal | Implement and simulate the monitor protocol and commands |
| Trap/timer demos that print proof over real UART | Implement trap logic, timer MMIO, and simulation tests first |
| C demo programs running on hardware | Build the toolchain flow, startup code, and simulation programs first |
| Packed-SIMD demo output on real hardware | Implement custom instructions, tests, and simulated demo programs first |
| Dual-core mailbox/UART demo on real hardware | Build the multicore RTL, shared peripherals, and simulated communication demo first |

---

## Verification Evidence

Latest known verification evidence from the project:

| Check | Result |
|-------|--------|
| Assembler/source flow | PASS: detected generated assembly flow with 240 memory words |
| Simulation | PASS: `*** ALL TESTS PASSED (pipeline + perf counters + UART) ***` |
| Subword tests | PASS: `SB`, `SH`, `LB`, `LBU`, `LH`, `LHU` checks passed |
| Performance counter MMIO tests | PASS: counter HDL and simulation pass marker detected |
| Debug MMIO tests | PASS: current PC, last commit, fault, and trace buffer reads validated in simulation |
| UART report test | PASS: UART HDL and simulation pass marker detected |
| Halt not-asserted test | PASS: halt was never asserted during demo program run |
| Bitstream | Generated |
| Routed timing | PASS: WNS +5.556 ns; all user timing constraints met (2025.2 build) |
| Utilization | 3263 LUTs / 53200 (6.13%), 1737 registers / 106400 (1.63%), 1 BRAM / 140 (0.71%), 0 DSPs / 220 (0.00%) |

---

## Maintenance Rule

Run `tools/update_docs.ps1` whenever roadmap-related work is implemented or when simulation/Vivado reports are refreshed.

The generated status should include:

- which phase changed
- what was implemented
- what evidence proves it works
- what remains incomplete
- whether simulation, synthesis, implementation, or hardware proof was run

Do not manually mark a phase complete unless the generator can prove the implementation from source files and verification artifacts.

## Documentation System

| File | Status | Notes |
|------|--------|-------|
| architecture/instruction_support.md | ✅ Complete | Updated support matrix |
| verification/verification.md | ✅ Complete | Updated simulation test logs |
| verification/performance.md | ✅ Complete | Updated resource and timing slacks |
| planning/ownership.md | ✅ Complete | Updated authorship details |
| hardware/hardware_setup.md | ✅ Complete | Updated pinouts and clock settings |
| planning/known_issues.md | ✅ Complete | Updated open issue counts |
| decisions/001_initial_docs.md | ✅ Accepted | Documentation system rationale |
| `Docs/decisions/002–005` | ⏳ Proposed stubs | Completed stub metadata |

---

# No-Board Execution Plan (Appended)

This document outlines the project phases and their executability while the PYNQ-Z2 board is unavailable.

## What to Do Next (Without the Board)

Since the board is not available, you are blocked *only* from physical hardware verification. You are **not** blocked from RTL development, simulation, synthesis, and implementation.

**Immediate Next Steps (Board Independent):**
1. **Phase 4 (UART Monitor and Program Loader) - Simulation Verification:** Run a Vivado/xsim simulation with `fpga_top` as the DUT to validate the UART monitor command parser FSM end-to-end.
2. **Phase 5 (Traps, Exceptions, and Timer Interrupts):** Start implementing the trap logic (CSRs: `mepc`, `mcause`, `mtvec`, `mstatus`), `ECALL`/`EBREAK` trap entry, timer peripheral (`0xC0000010`), and test them extensively in simulation.
3. **Phase 6 (RV32M Multiply/Divide Extension):** Implement the `MUL` family (and optionally `DIV`), adding execution support, pipeline stalls if needed, and verify with self-checking testbenches.
4. **Phase 7 (Run Small C Programs):** Build the C toolchain flow, create a linker script, startup code, `putchar` for UART, and compile simple C demos (like Fibonacci or bubble sort) into `.mem` files. Verify them in simulation using the monitor/loader flow.

## Phase Executability Analysis

| Phase | Description | Executable w/o Board | Deferred for Board |
|-------|-------------|----------------------|--------------------|
| **Phase 0** | Baseline Polish and Hardware Demo | **50%** (Bitstream, timing, constraints done) | Real UART terminal proof, terminal log/video, physical setup confirmation. |
| **Phase 1** | Reproducible Software & Test Tooling | **100%** (Assembler, build script, generated memory done) | None |
| **Phase 2** | Complete the RV32I Base More Honestly | **100%** (Subword ops, FENCE/NOP, ECALL halt done) | None |
| **Phase 3** | Debugging and Reliability | **100%** (MMIO debug, trace buffer, sim checks done) | None |
| **Phase 4** | UART Monitor and Program Loader | **85%** (RTL, debug ports, host loader script done) | Physical board test with `tools/mem_to_load_commands.py` over real USB-UART. |
| **Phase 5** | Traps, Exceptions, and Timer Interrupts | **100%** (Trap CSRs, entry/return logic, timer MMIO, full sim) | Final trap/timer demo running on the real board. |
| **Phase 6** | RV32M Multiply Extension | **100%** (RTL, stall logic, timing closure, full sim) | Running an RV32M benchmark on the physical board. |
| **Phase 7** | Run Small C Programs | **90%** (Linker, startup, C runtime, simulated C programs) | Real C benchmark execution on the board. |
| **Phase 8** | Branch Prediction & CPI Experiments | **90%** (Predictor RTL, branch metrics, CPI comparison in sim) | On-board benchmark timings. |
| **Phase 9** | Custom Packed-SIMD Extension | **90%** (Custom opcode RTL, tests, data-parallel demo in sim) | On-board execution and speedup report. |
| **Phase 10** | Real Workloads and Benchmark Demos | **90%** (Workload suite creation, simulated cycle/CPI reports) | Physical hardware measurement. |
| **Phase 11** | Memory System and Bus Cleanup | **100%** (Internal bus definition, memory map overhaul, sim) | None |
| **Phase 12** | Optional Peripherals | **0-100%** (Depends on peripheral. SPI/PWM can be sim'd. LEDs/VGA require board.) | Physical interaction (LEDs, VGA output, switches). |
| **Phase 13** | Dual-Core SoC Extension | **90%** (Multicore RTL, shared memory, bus arbiter, sim demo) | Final dual-core physical board demo. |

---

# Board Arrival Mandatory Checklist (Appended)

This checklist contains all the deferred hardware-verification tasks. **As soon as the PYNQ-Z2 board arrives, these tasks must be completed in order before proceeding with any further RTL development.**

## The Mandatory Board Proof Sequence

### 1. Phase 0: The Baseline Physical Proof
- [ ] **Hardware Setup:** Connect the PMODA TX/RX pins to the USB-UART adapter and plug it into the host PC.
- [ ] **Bitstream Programming:** Flash the Phase 0/4 bitstream onto the PYNQ-Z2 board.
- [ ] **Terminal Connection:** Open a serial terminal (e.g., PuTTY or minicom) at the configured baud rate.
- [ ] **Verify Execution:** Confirm that the pre-loaded ROM program runs and prints cycle, instruction, stall, and flush counts to the real UART terminal.
- [ ] **Documentation:** Capture a terminal log or video demo and save it as proof in the repository.

### 2. Phase 4: The Monitor & Loader Proof
- [ ] **Interactive Loader Test:** Use `tools/mem_to_load_commands.py -f interactive` to connect to the board.
- [ ] **Command Execution:** Run the `help`, `regs`, `perf`, and `trace` commands to verify the monitor FSM responds correctly.
- [ ] **Program Loading:** Load a new small program over UART using the `load` command and execute it using `run`. Verify it works identically to simulation.

### 3. Phase-Specific Board Demos (If implemented prior to board arrival)
- [ ] **Phase 5 (Traps & Timers):** Load and run the timer interrupt demo over UART. Verify the trap handler executes and prints proof over UART.
- [ ] **Phase 6 (RV32M):** Load and run an RV32M multiply/divide benchmark over UART.
- [ ] **Phase 7 (C Programs):** Load and run the compiled C "Hello World" or Fibonacci program.
- [ ] **Phase 8-10 (Benchmarks):** Run any implemented prediction/SIMD/workload benchmarks and record physical timing and CPI outputs.

## Standing Rules for Status Reporting and Verification
(Add this section to Docs/ai_context.md - applies to every future session, not just one task)

### Rule 1: No claim of "done," "passing," or "complete" without the actual output behind it
- "Tests pass" must mean you ran them and are pasting/summarizing the real
  transcript, not that you re-derived expected values by hand and believe
  they're now correct.
- If something is SKIPPED, UNTESTED, or INFERRED rather than directly
  verified, say so explicitly in the status itself - do not fold it into
  an "ALL PASS" or "ALL TESTS PASSED" headline. A skipped test reported
  under an "all pass" banner is worse than no report at all, because it
  is actively misleading.
- If you believe something is safe based on reasoning rather than a run
  (e.g. "I only added new opcode cases, so existing paths are
  unaffected"), label it explicitly as an UNVERIFIED ASSUMPTION, not a
  result. Then actually go run the regression if it's available.

### Rule 2: Every session must end by syncing status docs to actual state
Before ending any work session, update, in this order:
1. Docs/planning/status.md - the per-phase status line must reflect
   exactly what has real proof behind it right now: RTL written,
   simulated, regression-clean, documented, demo built, hardware-tested.
   Use these precise states, not vague percentages: NOT STARTED / RTL
   WRITTEN (unsimulated) / SIM PASSING / REGRESSION CLEAN / DOCUMENTED /
   HARDWARE PROVEN. Do not advance a phase to the next state until the
   previous state's proof actually exists.
2. Docs/ai_context.md - update project state, priorities, and what the
   next session should pick up. Assume the next reader has no memory of
   this session.
3. A session log in Docs/updates/ summarizing exactly what changed, what
   was proven (with how), and what remains open - including anything
   skipped or deferred and why.

### Rule 3: Distinguish proof gates explicitly
Per this project's roadmap philosophy, every feature needs three proof
gates: simulation, hardware, documentation. When reporting status, state
which gates are cleared and which are not - do not let "simulation
passing" imply "feature complete" if documentation or the demo/deliverable
for that phase is still outstanding. A phase is only "complete" when every
gate the roadmap defines for it has real evidence behind it.

### Rule 4: When a test is replaced, not just skipped, say so precisely
If a test fails or can't run for tooling/environment reasons and you
substitute a different test to prove the same property, you must:
- name the original test and why it couldn't run (root cause, not just
  "race condition" - what is actually racing)
- name the replacement test(s) and confirm they exercise the same
  underlying logic path
- report the replacement's real result
A substituted test is acceptable. An unexplained skip reported as a pass
is not.