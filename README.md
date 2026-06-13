# Pipelined RV32I RISC-V Processor

A 32-bit, 5-stage pipelined RISC-V processor core implementing the RV32I base integer instruction set. The core is written in SystemVerilog and designed for FPGA implementation.

## Architecture Highlights
* **ISA**: RV32I Base Integer Instruction Set
* **Pipeline**: 5-stage (Fetch, Decode, Execute, Memory, Writeback)
* **Language**: SystemVerilog
* **Target Environment**: Xilinx Vivado

## Repository Structure
* `riscv_pipeline_offline.srcs/` - Contains all SystemVerilog source files, modules, and testbenches.
* `tools/` - Python and TCL automation scripts.
* `Docs/` - Project documentation and development notes.

## Getting Started

This project is built using Xilinx Vivado. To open and build the project:

1. Clone the repository to your local machine.
2. Open Vivado and load the `.xpr` project file.
3. Alternatively, you can use the provided TCL scripts in the root directory to automate the build process from the Vivado TCL console:
   * `source run_synthesis.tcl` - Runs RTL synthesis.
   * `source run_build.tcl` - Runs the full synthesis and implementation flow.

## License
This project is licensed under the Apache License 2.0.
