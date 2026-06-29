# Verification Status

> **Last updated:** 2026-06-26
> **Simulation tool:** Vivado XSim v2025.2 (win64)  
> **Testbench location:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv)

## Summary Table
| Category                   | Total | ✅ PASS | ❌ FAIL | ⏳ TODO |
|----------------------------|-------|---------|---------|---------|
| Pipeline Tests             | 1     | 1       | 0       | 0       |
| Hazard Tests               | 1     | 1       | 0       | 0       |
| Forwarding Tests           | 1     | 1       | 0       | 0       |
| Branch / Jump Tests        | 1     | 1       | 0       | 0       |
| Load / Store Tests         | 1     | 1       | 0       | 0       |
| UART Tests                 | 1     | 1       | 0       | 0       |
| MMIO Tests                 | 1     | 1       | 0       | 0       |
| CSR / System Tests         | 1     | 1       | 0       | 0       |
| Performance Counter Tests  | 1     | 1       | 0       | 0       |
| FPGA Validation            | 1     | 0       | 0       | 1       |
| UART Monitor Tests         | 1     | 1       | 0       | 0       |
| Phase 5: Traps & CSRs      | 1     | 1       | 0       | 0       |
| Phase 6: RV32M Multiply    | 1     | 1       | 0       | 0       |
| Phase 7: Run C Programs    | 1     | 0       | 0       | 1       |
| Phase 8: Branch Prediction | 1     | 1       | 0       | 0       |
| Phase 9: Custom SIMD       | 9     | 9       | 0       | 0       |
| Phase 10: C Programs       | 1     | 1       | 0       | 0       |
| Phase 11: MMIO Bus         | 1     | 1       | 0       | 0       |
| Phase 12: Peripherals      | 9     | 9       | 0       | 0       |
| **Total**                  | **35**| **33**  | **0**   | **2**   |

---

## Pipeline Tests
#### TEST-001: Pipeline baseline test
- **Status:** ✅ PASS
- **Category:** Pipeline
- **Description:** Basic pipeline execution and register writeback validation (ADD, SUB, AND, OR, XOR results).
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L377-L385)
- **Last run:** 2026-06-03
- **Notes:** Verified basic ALU instruction output matches register file state.

## Hazard Tests
#### TEST-002: Hazard detection
- **Status:** ✅ PASS
- **Category:** Hazard
- **Description:** Verifies load-use stalls (LW followed immediately by dependent ADD).
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L395-L397)
- **Last run:** 2026-06-03
- **Notes:** Confirmed that `stall_seen` flag assertions passed.

## Forwarding / Bypassing Tests
#### TEST-003: Data forwarding
- **Status:** ✅ PASS
- **Category:** Forwarding
- **Description:** Verifies data forwarding from EX/MEM and MEM/WB.
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L389-L393)
- **Last run:** 2026-06-03
- **Notes:** Confirmed that forwarding was asserted in the EX/MEM and MEM/WB paths.

## Branch and Jump Tests
#### TEST-004: Control flow instructions
- **Status:** ✅ PASS
- **Category:** Branch
- **Description:** Verifies correct branching (BEQ taken/not taken) and jump instructions (JAL/JALR).
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L399-L413)
- **Last run:** 2026-06-03
- **Notes:** Flush logic verified on taken branches and jumps. Sequential execution confirmed for not-taken branches.

## Load and Store Tests
#### TEST-005: Memory operations
- **Status:** ✅ PASS
- **Category:** Load/Store
- **Description:** Verifies subword (LB, LBU, LH, LHU, SB, SH) and word loads/stores.
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L653-L665)
- **Last run:** 2026-06-03
- **Notes:** Verified sign-extension, zero-extension, and correct byte lane writes.

## UART Tests
#### TEST-006: UART communication
- **Status:** ✅ PASS
- **Category:** UART
- **Description:** Verifies UART TX and RX functionality by receiving cycles, instructions, stalls, flushes, and IPC values printed from the program.
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L680-L709)
- **Last run:** 2026-06-03
- **Notes:** Smoke tests decoded printed metrics successfully over UART.

## MMIO Tests
#### TEST-007: Memory Mapped IO
- **Status:** ✅ PASS
- **Category:** MMIO
- **Description:** Verifies memory mapping to UART registers, performance counters, and debug registers.
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L501-L522)
- **Last run:** 2026-06-03
- **Notes:** Verified correct addresses decoder selection in MEM stage.

## CSR and System Instruction Tests
#### TEST-008: System instructions
- **Status:** ✅ PASS
- **Category:** CSR
- **Description:** Verifies that FENCE/FENCE.I decode as NOP, ECALL/EBREAK halt the pipeline, and illegal instructions raise halt.
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L712-L724)
- **Last run:** 2026-06-03
- **Notes:** Checked that halt stayed low during regression and ECALL/EBREAK halt/illegal latch decode properly.

## Performance Counter Tests
#### TEST-009: Counter accuracy
- **Status:** ✅ PASS
- **Category:** Perf
- **Description:** Verifies cycle, instruction, stall, and flush counter MMIO register tracking.
- **Test file:** [tb_top.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/riscv_pipeline/sim/tb_top.sv#L434-L498)
- **Last run:** 2026-06-03
- **Notes:** Confirmed non-zero cycle and instruction count retire tracking.

## FPGA Validation
#### TEST-010: Hardware test
- **Status:** ⏳ TODO (Deferred)
- **Category:** FPGA
- **Description:** Verifies physical board execution on the PYNQ-Z2 board via PMODA UART.
- **Test file:** N/A (requires hardware board)
- **Last run:** N/A
- **Notes:** Deferred until physical board is available. Routed timing and bitstream generation are successfully completed in Vivado.

## UART Monitor Tests
#### TEST-011: UART monitor command parser
- **Status:** ✅ PASS
- **Category:** UART Monitor
- **Description:** Verifies the UART monitor command parser FSM with `fpga_top` as DUT. Tests help, load, run, reset, regs, mem, perf, and trace commands.
- **Test file:** `riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/sim/tb_fpga_top.sv`
- **Last run:** 2026-06-13
- **Notes:** Verified via `tb_fpga_top.sv`. `help` and `regs` commands exercised end-to-end through UART FSM using xsim. Clean `$finish` exit. Debug read ports are connected. The `tb_top.sv` already includes `sim_uart_tx_byte()` helper. Full end-to-end simulation needs xsim with fpga_top as DUT. Host-side loader (`tools/mem_to_load_commands.py`) supports interactive mode.

## Phase 5 Tests
#### TEST-012: Traps and CSRs
- **Status:** ✅ PASS
- **Category:** Phase 5
- **Description:** Verifies tb_phase5 (CSR file, trap entry, MRET, and timer interrupts).
- **Last run:** 2026-06-14

## Phase 6 Tests
#### TEST-013: RV32M Multiply
- **Status:** ✅ PASS
- **Category:** Phase 6
- **Description:** Verifies tb_phase6 (MUL, MULH, MULHU, MULHSU).
- **Last run:** 2026-06-14

## Phase 8 Tests
#### TEST-014: Branch Prediction
- **Status:** ✅ PASS
- **Category:** Phase 8
- **Description:** Verifies tb_bht (64-entry BHT logic and prediction accuracy).
- **Last run:** 2026-06-16

## Phase 7 Tests
#### TEST-015: Run C Programs (No Testbench)
- **Status:** ⏳ TODO
- **Category:** Phase 7
- **Description:** Compile and run C programs on the processor in simulation. Requires C toolchain setup (linker script, startup code, `putchar` for UART), compilation of simple C demos into `.mem` files, and simulation verification via the monitor/loader flow.
- **Test file:** N/A (not yet created)
- **Last run:** N/A
- **Notes:** No testbench exists. Phase 7 C program execution is planned but not yet implemented.

## Phase 10 Tests
#### TEST-016: C Benchmark Programs
- **Status:** ✅ PASS
- **Category:** Phase 10
- **Description:** Verifies tb_c_program (compiled C benchmark programs run correctly in simulation).
- **Last run:** 2026-06-21

## Phase 11 Tests
#### TEST-017: MMIO Bus Regression
- **Status:** ✅ PASS
- **Category:** Phase 11 / MMIO
- **Description:** Verifies `tb_memory_map.sv` — RAM read/write, UART
  isolation from RAM, performance-counter read-only access, timer MMIO
  read/write and IRQ assertion, a debug register read, and an unmapped-
  address safety check, against the Phase 11 internal peripheral bus in
  `mem_stage.sv`.
- **Test file:** [tb_memory_map.sv](../../riscv_pipeline_offline/riscv_pipeline_offline.srcs/sim_1/imports/sim/tb_memory_map.sv)
- **Last run:** 2026-06-26
- **Notes:** All 6 checks passed with the *** ALL TESTS PASSED ***
  marker. Part of the Phase 11 internal peripheral bus verification.

## Phase 9 Tests
#### TEST-018: PADD8
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PADD8: 0x01020304 + 0x04030201 = 0x05050505
- **Expected result:** x5 = 0x05050505
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-019: PSUB8
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PSUB8: 0x0A0B0C0D - 0x03020104 = 0x07090B09
- **Expected result:** x5 = 0x07090b09
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-020: PMAXU8
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PMAXU8: max(0x10A0F005, 0x2080FF50) = 0x20A0FF50
- **Expected result:** x5 = 0x20a0ff50
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-021: PMINU8
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PMINU8: min(0x10A0F005, 0x2080FF50) = 0x1080F005
- **Expected result:** x5 = 0x1080f005
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-022: PAVG8
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PAVG8: avg(0x02020202, 0x0A0A0A0A) = 0x06060606
- **Expected result:** x5 = 0x06060606
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-023: PADD8 wraparound
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PADD8: LUI-loaded 0x12345000 + 0x6789A000 = 0x79BDF000
- **Expected result:** x5 = 0x79bdf000
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-024: PSUB8 underflow
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PSUB8 wrap: 0x00 - 0x01 = 0xFF across all lanes
- **Expected result:** x5 = 0xffffffff
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-025: PAVG8 rounding
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** PAVG8 floor: (0x01030105 + 0) >> 1 = 0x00010002
- **Expected result:** x5 = 0x00010002
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

#### TEST-026: Reserved funct3=101 (illegal instruction)
- **Status:** ✅ PASS
- **Category:** Custom SIMD Extension
- **Description:** Custom-0 funct3=101: x6 NOT written (illegal)
- **Expected result:** x6 = 0x00000000
- **Test file:** tb_phase9.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase9.txt

## Phase 12 Tests
#### TEST-027: LED write and read-back
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Writes 0xA to LED_CTRL (0xD0000000), reads back. Verifies led_out = 4'b1010.
- **Expected result:** x5 = 0x0000000a, led_out = 4'b1010
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-028: LED all-bits-set then clear
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Writes 0xF to LED_CTRL, verifies led_out = 4'b1111. Writes 0x0, verifies led_out = 4'b0000.
- **Expected result:** led_out = 4'b1111 (all bits set), led_out = 4'b0000 (cleared)
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-029: Button/switch mixed inputs
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Drives raw_btn[1:0]=2'b10, raw_sw[1:0]=2'b01. Reads BTN_SW (0xD0000004). Verifies debounced value.
- **Expected result:** x5 = 0x00000006 (btn=10, sw=01)
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-030: Button/switch all zeros
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Drives raw_btn=0, raw_sw=0. Reads BTN_SW, verifies all zeros including bit 0.
- **Expected result:** x6 = 0x00000000
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-031: PWM period write and read-back
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Writes period=200 to PWM_PERIOD (0xD0000008). Reads back and verifies.
- **Expected result:** x7 = 0x000000c8
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-032: PWM duty write and read-back
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Writes duty=100 to PWM_DUTY (0xD000000C). Reads back and verifies.
- **Expected result:** x8 = 0x00000064
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-033: PWM waveform verification
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Monitors pwm_out over 35 cycles with period=40, duty=20. Counts high and low cycles.
- **Expected result:** ~50% duty (20 high / 35 total)
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-034: PWM duty clamping
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Sets duty=20, period=10. Verifies pwm_out stays high (always-on when duty > period).
- **Expected result:** PWM always-on
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt

#### TEST-035: PWM disable
- **Status:** ✅ PASS
- **Category:** Optional Peripherals
- **Description:** Writes CTRL=1 to PWM_CTRL (0xD0000010), reads back. Writes CTRL=0, reads back. Includes both register read-back verification and 20-cycle waveform observation of pwm_out after disable.
- **Expected result:** x9 = 0x00000001 (enabled), x10 = 0x00000000 (disabled), pwm_out = 0 for all 20 cycles after disable
- **Test file:** tb_phase12.sv
- **Last run:** 2026-06-28
- **Verified by:** results/final_clean_phase12.txt