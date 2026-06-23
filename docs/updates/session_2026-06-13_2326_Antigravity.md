# Session Log

## Work Done
1. **Identified Synthesis Bottleneck**: The previous UART monitor design used a highly concurrent combinational assignment loop across a `tx_buf` array. Vivado unrolled this into a massive mutliplexer network during the `synth_design` phase, leading to memory exhaustion and infinite hangs.
2. **Refactored `uart_monitor.sv`**: Rewrote the FSM specifically focusing on `ST_PRINT_HEX`. We completely removed the `tx_buf` array and replaced it with a 256-bit shift register. Characters are now formatted and shifted into the TX FIFO strictly one byte per clock cycle.
3. **Simulation Verification**: Created a new testbench `tb_fpga_top.sv` to test the new monitor logic directly from the top-level FPGA wrapper (`fpga_top.sv`). Executed the simulation live in Vivado using a custom Tcl script. The FSM successfully responded to `help` and `regs` commands over simulated UART RX/TX.
4. **Phase 5 Planning**: Generated `implementation_plan.md` to define the architecture for adding Machine-mode CSRs (`mepc`, `mcause`, `mtvec`), trapping logic for `ECALL`/illegal instructions, and the memory-mapped Timer peripheral. User approved the plan for the next session.

## Next Steps
- Implement Phase 5 according to the approved implementation plan.
- The `csr_file.sv` needs to be created and wired into the `id_stage.sv` and `control_unit.sv`.
- The global pipeline flush logic needs to be updated to support traps and `MRET`.
