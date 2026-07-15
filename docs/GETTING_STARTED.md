# Getting Started — RISC-V Pipeline Project

This guide will help you set up the development environment, build the processor, and run simulations for this FPGA project (RV32I pipelined SoC on PYNQ-Z2).

---

## 1. Prerequisites

You will need the following tools installed:
- **Xilinx Vivado** (2024.x or 2025.x): Required for FPGA design, synthesis, bitstream generation, and xsim simulations.
- **Git**: For version control.
- **xPack RISC-V GCC toolchain**: Required for compiling C programs.
- **Python 3.x**: Runs helper scripts (like the program loader `tools/mem_to_load_commands.py`).
- **PowerShell**: For running build scripts.

---

## 2. Getting the Project

Clone the repository and open the project in Vivado:

```bash
git clone https://github.com/KaustubhNayak005/riscv_pipeline.git
cd riscv32-processor
```

Open Vivado, and navigate to the project directory to open the `.xpr` file:
```
riscv_pipeline_offline/riscv_pipeline_offline.xpr
```

---

## 3. Running Simulations

The project contains self-checking testbenches for each phase. To run a simulation:
1. Open the Vivado GUI.
2. Under "Simulation" in the Flow Navigator, set the top module to the desired testbench (e.g., `tb_top.sv` or `tb_phase5.sv`).
3. Click "Run Simulation".

Alternatively, you can run TCL scripts in batch mode or use the local `run_tb_top.tcl` / `run_sim_only.tcl` scripts to automate simulation runs.

---

## 4. Building for Hardware

To build the bitstream and program the PYNQ-Z2 board:
1. Open Vivado.
2. Ensure the top module is set to `fpga_top.sv`.
3. Run **Synthesis**.
4. Run **Implementation** and **Generate Bitstream**.
5. Open the Hardware Manager, connect to the PYNQ-Z2 board, and program the FPGA with the generated `.bit` file.

Once the board is running, connect a USB-UART adapter to the designated PMOD pins to interact with the UART monitor. Use the included Python script for interacting with the board:
```bash
python tools/mem_to_load_commands.py -f interactive
```

---

## 5. C Software

The project includes a C runtime and linker script for running software on the processor.

To compile C programs into `.mem` files that the processor can load:
1. Ensure the xPack RISC-V GCC toolchain is in your PATH.
2. Navigate to the `sw/` directory.
3. Run the Makefile:
   ```bash
   make
   ```
4. This will generate the necessary `.mem` files which can be preloaded into `instr_mem.sv` or loaded via UART.

---

## 6. Contribution Workflow

We follow a standard Git workflow:
1. **Branch**: Create a new branch for your feature or bugfix (`git checkout -b feature-name`).
2. **Change**: Make your changes in the RTL (`.sv`) or software (`.c`/`.s`).
3. **Test**: Run the relevant simulation testbenches to verify your changes.
4. **Commit**: Write clear, descriptive commit messages.
5. **Pull Request**: Push your branch and open a PR for review.

For more technical details, refer to the files in `docs/architecture/` (e.g., `overview.md`, `instruction-set.md`, `uart-monitor.md`) and `docs/hardware/`.
