# Long-Term Practical Roadmap

This roadmap assumes the project is no longer constrained by a submission deadline. The goal is to make the processor as strong, demonstrable, and technically honest as possible while staying practical on the PYNQ-Z2 / Zynq-7020 FPGA.

The best direction is not to add the largest-sounding features first. The best direction is to turn the current working pipelined CPU into a small, usable, well-tested computer system.

---

## Current State

Verified from the Vivado project and generated reports.

| Area | Current Status |
|------|----------------|
| FPGA board/part | PYNQ-Z2, `xc7z020clg400-1` |
| Top module | `fpga_top` |
| CPU core | 5-stage pipelined RV32I-style core |
| Pipeline features | Forwarding, load-use stall, branch/jump flush |
| UART | TX and RX modules integrated through MMIO |
| UART address map | `0x80000000` status, `0x80000004` TX data, `0x80000008` RX data |
| Performance counters | Implemented and exposed through MMIO |
| Perf counter address map | `0xC0000000` cycles, `0xC0000004` instructions, `0xC0000008` stalls, `0xC000000C` flushes |
| Subword memory ops | `LB`, `LH`, `LBU`, `LHU`, `SB`, `SH` implemented and simulation-tested |
| Testbench | Self-checking pipeline, UART, MMIO, and performance counter tests |
| Latest sim result | PASS: pipeline + performance counters + UART |
| Bitstream | Generated |
| LUT utilization | 3,169 / 53,200 = 5.96% |
| Register utilization | 1,733 / 106,400 = 1.63% |
| BRAM utilization | 1 / 140 = 0.71% |
| DSP utilization | 0 / 220 = 0% |
| Timing | Met; routed WNS about +5.554 ns |

Important correction: performance counters are no longer future work. They are already implemented and tested.

The current core now has byte/halfword loads and stores. It should still be described as RV32I-style or RV32I-subset until minimal SYSTEM/FENCE behavior and trap behavior are added.

---

## What Is Already Done

### Completed or Nearly Completed

| Feature | Status | Notes |
|---------|--------|-------|
| 5-stage pipeline | Done | IF, ID, EX, MEM, WB structure exists |
| Forwarding | Done | EX/MEM and MEM/WB forwarding tested |
| Load-use hazard stall | Done | Tested in simulation |
| Branch/jump flush | Done | BEQ, JAL, JALR behavior tested |
| LUI/AUIPC | Done | Tested |
| Basic ALU ops | Done | ADD, SUB, logic, shifts, SLT/SLTU tested |
| Word load/store | Done | LW/SW path exists |
| Subword load/store | Done | LB/LH/LBU/LHU/SB/SH are implemented for aligned accesses and tested |
| UART MMIO | Done | TX/RX peripheral is integrated |
| UART pin constraints | Done | PMODA pins are constrained in XDC |
| Performance counters | Done | Cycle, instruction, stall, flush counters exist |
| UART performance report | Done in simulation | Program prints counter values over UART in sim |
| Bitstream generation | Done | Implementation and route completed |

### Still Needs Hardware Proof

| Item | Status |
|------|--------|
| Real UART terminal output on PYNQ-Z2 | Needs physical test |
| Saved terminal log or video demo | Not yet proven from files |
| Repeatable build/run instructions | Should be cleaned up |
| Hardware terminal proof | Deferred until a PYNQ-Z2 board is available |

---

## Roadmap Philosophy

Every feature should pass three proof gates:

1. Simulation proof: self-checking test passes.
2. Hardware proof: bitstream builds, timing meets, and a board demo works where relevant.
3. Documentation proof: memory map, limitations, and usage are clearly written.

If a feature cannot be demonstrated, do not make it a headline feature.

---

## Phase 0: Baseline Polish and Hardware Demo

**Priority: Highest**  
**Effort: 1-3 days**  
**Practicality: Very high**

This phase turns the current project into something confidently demonstrable.

### Tasks

- Test UART output on real PYNQ-Z2 hardware using a USB-UART adapter.
- Capture a terminal log showing cycle, instruction, stall, flush, and IPC/CPI values.
- Write a short hardware setup guide:
  - PMODA TX/RX pins
  - USB-UART wiring
  - baud rate
  - reset behavior
  - expected terminal output
- Add or update a clear top-level README.
- Record exact Vivado version and build steps.
- Save the latest utilization and timing numbers.
- Fix document encoding issues in project notes if needed.

### Why This Matters

This gives you a clean baseline. Before adding new features, you should have proof that the current CPU runs on actual FPGA hardware, not only in simulation.

---

## Phase 1: Reproducible Software and Test Tooling

**Priority: Very high**  
**Effort: 3-7 days**  
**Practicality: Very high**

Right now the instruction memory contains hardcoded machine words. That works, but it makes the project harder to maintain and extend.

### Tasks

- Create assembly source for the current test/demo program.
- Add a script or Makefile flow that converts assembly into `.mem`.
- Keep `program.mem` generated from source instead of editing raw hex by hand.
- Add small standalone test programs:
  - ALU tests
  - branch/jump tests
  - load/store tests
  - UART tests
  - performance counter tests
- Add expected-output files for UART demos.

### Recommended Approach

Use either:

- a small custom assembler script for the supported subset, or
- a standard RISC-V GNU assembler flow with a linker script and `objcopy`.

The GNU assembler route is better long-term because it prepares the project for C programs later.

---

## Phase 2: Complete the RV32I Base More Honestly

**Priority: Very high**  
**Status: Complete**  
**Practicality: High**

A complete, well-tested RV32I core is much stronger than an incomplete core with a loosely defined accelerator.

### Completed in This Phase

| Feature | Status |
|---------|--------|
| `LB`, `LH`, `LBU`, `LHU` | Implemented and tested |
| `SB`, `SH` | Implemented and tested |
| Byte write enables | Implemented in data memory |
| Load sign/zero extension | Implemented in MEM stage |
| `FENCE` / `FENCE.I` as NOP | Implemented in `control_unit.sv` |
| `ECALL` / `EBREAK` halt | Implemented via `OPCODE_SYSTEM` decode; latches halt signal to freeze pipeline |
| Illegal instruction detection | Implemented; unknown opcodes set `illegal_instr` and trigger halt |
| Misaligned access policy | Documented in `Docs/architecture.md` (unsupported; traps require Phase 5) |
| RV32I instruction support table | Created in `Docs/architecture.md` with implemented/tested/unsupported categories |

### Deliverable

A document or table listing each RV32I instruction and whether it is:

- implemented
- tested
- not applicable
- intentionally unsupported

This is excellent evidence of engineering maturity.

---

## Phase 3: Debugging and Reliability

**Priority: High**  
**Status: Complete**  
**Effort: 1-2 weeks**  
**Practicality: High**

Before adding larger architectural features, make the CPU easier to trust and easier to debug.

### Tasks

- Add memory-mapped debug registers for:
  - current PC
  - last committed instruction PC
  - last writeback register/value
  - faulting instruction
  - trap or fault cause
  - pipeline status bits
- Add an assertion-oriented verification layer:
  - timeout/deadlock detection
  - pipeline freeze detection
  - branch or control-flow mismatch detection
  - illegal opcode detection
- Add a small trace buffer in BRAM:
  - PC
  - instruction
  - writeback register
  - writeback data
  - stall/flush flags
- Add UART debug logs only after a monitor/debug path exists.
- Optionally add a Vivado ILA configuration for PC, instruction, stall, flush, and UART signals.

### Completed

- Implemented MMIO debug registers for current PC, last committed PC/instruction, last writeback data, fault PC/instruction, and pipeline status.
- Implemented a 4-entry commit trace buffer that records PC, instruction, writeback data, and packed status.
- Added assertion-oriented simulation checks that verify the debug MMIO window and trace buffer contents.

### Why This Matters

Debug visibility and reliability checks are a better next investment than bigger features. They reduce the time cost of every later change, and this phase is now in place.

---

## Phase 4: UART Monitor and Program Loader

**Priority: High**  
**Effort: 1-3 weeks**  
**Practicality: High**  
**Status: Substantially complete (RTL done)**

This is the point where the project starts feeling like a tiny computer rather than a fixed demo ROM.

Implementation status: `uart_monitor.sv` is a full command-parser FSM with 7 commands (help/load/run/reset/regs/mem/perf/trace), wired through `fpga_top.sv` with UART mux and CPU reset control. Debug read ports are added to `reg_file.sv`, `data_mem.sv`, `id_stage.sv`, `mem_stage.sv`, and `top.sv`. The host-side loader (`tools/mem_to_load_commands.py`) supports raw text, binary UART stream, and interactive serial port modes. Full `fpga_top` simulation and physical board proof remain pending.

### Tasks

- Convert instruction memory from fixed ROM to loadable instruction RAM or boot ROM + instruction RAM.
- Add a UART bootloader or monitor mode.
- Support commands such as:
  - `help`
  - `load`
  - `run`
  - `reset`
  - `regs`
  - `mem`
  - `perf`
  - `trace`
- Add a simple host-side script to send a `.mem` or binary file over UART.

### Practical Scope

Start simple:

- load words into instruction RAM
- run from address 0
- print performance counters after completion

Do not try to build an operating system at this stage.

---

## Phase 5: Traps, Exceptions, and Timer Interrupts

**Priority: High**  
**Effort: 2-4 weeks**  
**Practicality: High if scoped carefully**

This is the strongest early system-level upgrade and should come before multicore or ambitious acceleration work.

### Core Behavior

- treat `FENCE` as a NOP
- add `ECALL` / `EBREAK`
- add illegal instruction detection
- define misaligned access behavior clearly

### Minimal Trap System

Add a small machine-mode-style trap mechanism:

| Register | Purpose |
|----------|---------|
| `mepc` | PC where trap occurred |
| `mcause` | trap reason |
| `mtvec` | trap handler address |
| `mstatus` | minimal interrupt enable/status bits |

### Trap Sources

- illegal instruction
- `ECALL`
- `EBREAK`
- misaligned load/store, if unsupported
- timer interrupt

### Timer Peripheral

Add memory-mapped timer registers:

| Address | Register |
|---------|----------|
| `0xC0000010` | timer current value |
| `0xC0000014` | timer compare value |
| `0xC0000018` | timer control/status |

### Deliverable

A demo program that:

1. sets a timer interrupt,
2. runs a loop,
3. enters the trap handler,
4. prints proof over UART,
5. returns to normal execution.

---

## Phase 6: RV32M Multiply/Divide Extension

**Priority: Medium-high**  
**Effort: 1-3 weeks**  
**Practicality: High for multiply, medium for divide**

This is more defensible than jumping directly to multicore or wide SIMD.

### Recommended Scope

Start with:

- `MUL`
- `MULH`
- `MULHU`
- `MULHSU`

Then add if time permits:

- `DIV`
- `DIVU`
- `REM`
- `REMU`

### Implementation Choices

| Option | Pros | Cons |
|--------|------|------|
| Single-cycle DSP multiply | Simple at 25 MHz | May need timing care at higher clocks |
| Pipelined multiply | Faster clock potential | More pipeline control complexity |
| Iterative divide | FPGA-efficient | Requires multi-cycle stall logic |

### Why This Is Worth Doing

RV32IM is a recognizable and useful target. It also prepares the design for compiled C benchmarks.

---

## Phase 7: Run Small C Programs

**Priority: Medium-high**  
**Effort: 1-3 weeks after Phase 4/5/6**  
**Practicality: Medium-high**

This is a major credibility upgrade if done cleanly.

### Requirements

- better memory layout
- stack pointer setup
- linker script
- startup code
- UART `putchar`
- subword loads/stores from Phase 2
- program loading flow from Phase 4, or ROM generation from ELF

### Good Demo Programs

- UART hello world
- Fibonacci
- memory copy
- bubble sort
- CRC or checksum
- small benchmark that prints cycle count and CPI

### Avoid

Do not promise Linux or a general-purpose OS. This core is a small bare-metal soft CPU.

---

## Phase 8: Branch Prediction and CPI Experiments

**Priority: Medium**  
**Effort: 1-2 weeks**  
**Practicality: Medium-high**

This is a very good architecture feature because you already have performance counters.

### Possible Features

- static not-taken baseline, already effectively present
- static backward-taken / forward-not-taken prediction
- 1-bit or 2-bit branch history table
- small branch target buffer

### Deliverable

Run the same loop-heavy programs before and after prediction and report:

- cycles
- instructions
- branch flushes
- CPI or IPC improvement

This gives a much stronger story than simply saying "branch predictor added."

---

## Phase 9: Custom Packed-SIMD Extension

**Priority: Optional**  
**Effort: 2-4 weeks for a clean subset**  
**Practicality: Medium if scoped narrowly**

This should replace broad vector-accelerator claims.

### Recommended First Version

Do not start with a 4-lane 32-bit vector unit. Start with packed operations inside the existing 32-bit integer registers.

Example custom instructions:

| Instruction | Meaning |
|-------------|---------|
| `PADD8` | four parallel 8-bit additions |
| `PSUB8` | four parallel 8-bit subtractions |
| `PMAXU8` | four unsigned 8-bit max operations |
| `PMINU8` | four unsigned 8-bit min operations |
| `PAVG8` | four unsigned 8-bit averages |

Use the RISC-V `custom-0` opcode space.

### Demo

Use a concrete data-parallel demo:

- grayscale brightness adjustment
- pixel thresholding
- packed byte min/max
- checksum-style byte processing

### Optional Later Upgrade

Only after the scalar packed-SIMD path works:

- 8-entry vector register file
- 128-bit vector registers
- vector load/store
- wider lane-based ALU experiments

Do not claim RVV compliance. Full RISC-V Vector is far beyond the practical scope of this project.

---

## Phase 10: Real Workloads and Benchmark Demos

**Priority: Optional but valuable**  
**Effort: 1-3 weeks after SIMD or C support**  
**Practicality: Medium-high**

This phase is about proving that the architecture work leads to measurable results.

### Good Workloads

- packed-byte image-style processing
- checksum and reduction kernels
- fixed-point filtering or simple DSP-style operations
- matrix-style kernels only if they match the implemented datapath honestly

### Outputs

- before/after cycle counts
- CPI or IPC comparisons
- branch or SIMD speedup comparisons
- benchmark notes that explain what the architecture change actually improved

Avoid vague "AI-style" wording unless a concrete fixed-point kernel and measurement exist.

---

## Phase 11: Memory System and Bus Cleanup

**Priority: Optional but useful**  
**Effort: 2-5 weeks**  
**Practicality: Medium**

The current MMIO decode is simple and fine for the current project. If the system grows, create a cleaner internal bus.

### Practical Work

- define a simple internal memory/peripheral bus:
  - address
  - write data
  - read data
  - byte enables
  - read enable
  - write enable
  - ready/valid
- move UART, timer, performance counters, debug registers, and RAM behind this bus
- add a simple memory map document

### Cache Reality Check

A cache is not very useful while the CPU only talks to small on-chip BRAM. A cache becomes meaningful only after you have a cleaner bus and a larger or slower memory path.

Recommended order:

1. clean bus
2. larger BRAM memory
3. loader
4. optional AXI or DDR bridge
5. only then consider cache

---

## Phase 12: Optional Peripherals

**Priority: Low**  
**Effort: 2-6 weeks depending on scope**  
**Practicality: Medium**

Peripheral work is fine, but it should not outrank debug, software support, or core architecture completeness.

### Better Peripheral Ideas Than Full Display First

- GPIO peripheral
- button or switch input
- LED control register
- PWM or audio tone generator
- simple SPI master

### Display Options

| Option | Practicality | Notes |
|--------|--------------|-------|
| Pmod VGA text console | Feasible | Needs external Pmod VGA adapter |
| HDMI through Zynq PS | More complex | Involves PS/PL integration |
| UART terminal | Already best value | Much easier and more useful for CPU debug |

If you add display output, make it a peripheral demo, not the main architecture milestone.

---

## Phase 13: Dual-Core SoC Extension

**Priority: Long-term optional**  
**Effort: 4-8 weeks after bus, traps, and software support**  
**Practicality: Medium if kept simple**

This is practical only if it is treated as a small shared-memory dual-core experiment, not as a modern cache-coherent multicore processor.

### Practical Target

- 2 cores
- 1 thread per core
- shared BRAM or mailbox peripheral
- shared UART/timer/performance registers
- simple round-robin bus arbiter
- no caches, no coherency

### Stretch Goals

- 4 cores after dual-core works
- simple software scheduling via timer interrupts

### Avoid

- SMT
- cache-coherent multicore
- Linux-style OS threads

The first useful demo should be simple: core 0 and core 1 run separate programs or separate loops, communicate through a mailbox or shared memory, and print proof through the shared UART.

---

## Features to Remove or Deprioritize

| Old Idea | Decision | Reason |
|----------|----------|--------|
| Full RISC-V Vector / RVV | Remove | Too large for this project scope |
| "AI-style acceleration" | Remove unless concretely demonstrated | Misleading without a real datapath and benchmark |
| 4-lane 32-bit vector unit as the first SIMD milestone | Deprioritize and reshape | Packed-SIMD inside scalar registers is much more practical first |
| Educational OS or tiny RTOS as a headline feature | Remove for now | Not the best next step for this project |
| Cache as a near-term feature | Deprioritize | Not meaningful without a better bus and larger/slower memory |
| VGA before monitor/debug support | Deprioritize | UART monitor and debug visibility give more engineering value |
| Line-count targets | Remove | Quality, tests, and demos matter more than LOC |
| SMT, cache-coherent multicore, or Linux-style threading | Avoid | Too complex for the practical scope of this project |

---

## Recommended Priority Order

```text
1. Hardware UART proof and clean documentation        [1-3 days]
2. Complete RV32I behavior and instruction table      [1-2 weeks]
3. Debugging and reliability infrastructure           [1-2 weeks]
4. UART monitor and program loader                    [1-3 weeks]
5. Traps, exceptions, and timer interrupts            [2-4 weeks]
6. RV32M multiply/divide                              [1-3 weeks]
7. Small C program flow                               [1-3 weeks]
8. Branch prediction with CPI comparison              [1-2 weeks]
9. Packed-SIMD custom instructions                    [2-4 weeks]
10. Real workloads and benchmark demos                [1-3 weeks]
11. Bus cleanup / optional memory growth              [optional]
12. Optional peripherals                              [optional]
13. Dual-core SoC extension                           [long-term optional]
```

---

## Best Final Project Identity

The strongest identity for this project is:

> A 5-stage pipelined RISC-V soft processor on PYNQ-Z2 with UART MMIO, performance counters, hardware-visible debug, and bare-metal software support.

If later phases are completed, this can become:

> A small RV32IM educational soft-core SoC with traps, timer interrupts, monitor/debug support, performance analysis, optional packed-SIMD extensions, and a later dual-core shared-memory variant.

That title is ambitious but still believable if the roadmap is implemented in order.

---

## Bottom Line

The project is already strong: it builds, routes, passes simulation, uses very little FPGA fabric, and has UART plus performance counters.

The best path forward is depth before breadth. Finish the scalar CPU properly, strengthen debugability and reliability, add a monitor/loader path, and then build traps, software support, and performance experiments on top of that base.

Packed-SIMD and dual-core work are still possible later, but they should come only after the single-core system is robust, measurable, and easy to explain.
