# Ownership and Contributions

> This document tracks who wrote what for transparency and project history.
> It is not a legal attribution document.

## Project Authors & Contributors

**Name / Handle:** Kaustubh  
**Role:** Primary designer and implementer of the RISC-V soft SoC.

**Name / Handle:** DS srijith  
**Role:** Primary designer and implementer of the RISC-V soft SoC.

---

## Author Contributions

- Designed the 5-stage pipelined RV32I-subset CPU core (`top.sv` and stage modules)
- Implemented data forwarding, hazard detection, and stall/flush logic
- Integrated UART TX/RX block through MMIO decode in the MEM stage
- Developed the local assembler and build scripts to generate `program.mem`
- Configured constraints and wrapper logic for PYNQ-Z2 deployment
- Resolved routed timing issues (+5.447 ns slack achieved)

---

## AI-Assisted Contributions

- Antigravity drafted `Docs/ai_context.md` initial structure and created the documentation system (2026-06-03)
- Codex implemented the Phase 3 debug/reliability slice: MMIO debug registers, trace buffer, assertion checks (2026-06-03)
- Codex implemented the Phase 4 instruction-memory loader foundation: write-port in `instr_mem.sv`, loader hooks in `if_stage.sv`/`top.sv`, `tools/mem_to_load_commands.py` (2026-06-04)
- Codex implemented the full Phase 4 UART monitor: `uart_monitor.sv` with 7 commands, `fpga_top.sv` UART mux, debug read ports in `reg_file.sv`/`data_mem.sv`/`id_stage.sv`/`mem_stage.sv`/`top.sv`, enhanced host loader with interactive mode (2026-06-04)

---

## Collaboration Notes

- The author designed the core SoC hardware and verification testbench.
- AI agents are assisting in documentation management, folder organization, and code analysis during subsequent feature additions.

---

## Future Contributors

_This section is reserved for future contributors._
