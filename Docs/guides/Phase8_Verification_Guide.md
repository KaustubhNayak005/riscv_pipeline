# Phase 8 Verification Guide: Dynamic Branch Prediction

This guide provides step-by-step instructions to verify that Phase 8 (Dynamic Branch Prediction) is successfully implemented and working as intended. 

We introduced a **64-entry Branch History Table (BHT)** using 2-bit saturating counters. The goal of this phase is to drastically reduce pipeline flushes (`F`) caused by branch mispredictions, lowering the overall Cycles Per Instruction (CPI).

---

## Method 1: System-Level Simulation (The Benchmark)
The most definitive proof of the predictor is running a real C program. We wrote `sw/demos/benchmark.c` (a Bubble Sort algorithm) heavily reliant on backwards looping branches.

### Steps to Verify
1. Open Vivado on your desktop.
2. Load the project: `File > Project > Open...` and select `riscv_pipeline_offline/riscv_pipeline_offline.xpr`.
3. Open the **Tcl Console** at the bottom of the Vivado window.
4. Run the automated simulation script by typing:
   ```tcl
   source C:/Users/nayak/Desktop/riscv32-processor/run_benchmark_sim.tcl
   ```
   *(Note: Using the absolute path ensures Vivado finds the script regardless of its current working directory).*
5. Wait for the simulation to finish (it simulates ~3 milliseconds of hardware time).

### What to Look For
Check the Vivado Tcl Console output. The simulated UART will print:
```text
C: 0001D291  (Cycles: 119,441)
I: 00011A1E  (Instructions: 72,222)
S: 00005B16  (Stalls: 23,318)
F: 0000011F  (Flushes: 287)
```
**The Verdict:** If the `F` (Flushes) counter is remarkably low compared to the `I` (Instructions) counter (e.g., 287 flushes for 72,222 instructions), the dynamic branch predictor is successfully learning and predicting the loop branches.

---

## Method 2: Unit Testing the BHT (`tb_bht.sv`)
If you want to verify the exact logic of the 2-bit saturating counters independently from the pipeline, run the BHT unit test.

### Steps to Verify
1. In Vivado, navigate to the **Sources** pane.
2. Expand `Simulation Sources > sim_1`.
3. Right-click on `tb_bht.sv` and select **Set as Top**.
4. Click **Run Simulation > Run Behavioral Simulation** in the Flow Navigator.

### What to Look For
1. **Console Output:** The testbench will print pass/fail results for state machine transitions (e.g., training a branch to go from *Weakly Not Taken* to *Strongly Taken*). You should see `*** BHT UNIT TEST PASSED ***`.
2. **Waveforms:** Open the Waveform viewer. Add `predict_taken` and `actual_taken`. Watch how the module reacts when `update_en` is pulsed. You will physically see the 2-bit internal state saturate at `11` (Strongly Taken) even if you keep training it.

---

## Method 3: Real FPGA Hardware Verification
Once you are ready to synthesize and program the physical PYNQ-Z2 board, you can verify the performance counters on silicon.

### Steps to Verify
1. Generate the bitstream in Vivado and program the PYNQ-Z2 board.
2. Open a Serial Terminal (PuTTY/TeraTerm) at `115200` baud.
3. Use the Python loader script to push the compiled benchmark to the board:
   ```bash
   python tools/mem_to_load_commands.py sw/demos/benchmark.mem -f interactive --port COM3
   ```
4. In the interactive prompt, type `run` to execute the program.
5. Once the program completes, type `perf` to dump the hardware performance counters.

### What to Look For
The hardware `perf` command will dump the exact same Cycles, Instructions, Stalls, and Flushes. Because physical silicon runs at 25MHz, this test will finish instantly, proving that the branch predictor accelerates real-world workloads!
