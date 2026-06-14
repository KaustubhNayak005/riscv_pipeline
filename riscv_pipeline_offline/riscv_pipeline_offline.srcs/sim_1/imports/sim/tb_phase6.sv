/*
 * Module: tb_phase6
 * Description: Self-checking testbench for Phase 6 - RV32M Multiply Extension.
 *
 * Tests:
 *   1. MUL
 *   2. MULH
 *   3. MULHSU
 *   4. MULHU
 *
 * Uses the instruction loader port to inject Phase 6 test sequences.
 */
`timescale 1ns/1ps

module tb_phase6;

    logic clk;
    logic rst;
    int   failures;

    logic uart_txd, uart_rxd_tb;
    logic instr_load_en;
    logic [9:0]  instr_load_word_addr;
    logic [31:0] instr_load_data;
    logic [31:0] program_words [0:1023];

    logic [31:0] debug_pc_current;
    logic        debug_wb_reg_write;
    logic [4:0]  debug_wb_rd;
    logic [31:0] debug_wb_write_data;
    logic        halt;
    logic [4:0]  dbg_reg_addr;
    logic [31:0] dbg_reg_data;
    logic [9:0]  dbg_dmem_addr;
    logic [31:0] dbg_dmem_data;
    logic [31:0] dbg_perf_cycle;
    logic [31:0] dbg_perf_instr;
    logic [31:0] dbg_perf_stall;
    logic [31:0] dbg_perf_flush;
    logic [1:0]  dbg_trace_sel;
    logic [31:0] dbg_trace_pc, dbg_trace_instr, dbg_trace_wb_data, dbg_trace_status;
    logic [2:0]  dbg_trace_count;
    logic [1:0]  dbg_trace_head;

    top uut (
        .clk(clk), .rst(rst),
        .debug_pc_current(debug_pc_current),
        .debug_wb_reg_write(debug_wb_reg_write),
        .debug_wb_rd(debug_wb_rd),
        .debug_wb_write_data(debug_wb_write_data),
        .halt(halt),
        .instr_load_en(instr_load_en),
        .instr_load_word_addr(instr_load_word_addr),
        .instr_load_data(instr_load_data),
        .uart_rxd(uart_rxd_tb), .uart_txd(uart_txd),
        .dbg_reg_addr(dbg_reg_addr), .dbg_reg_data(dbg_reg_data),
        .dbg_dmem_addr(dbg_dmem_addr), .dbg_dmem_data(dbg_dmem_data),
        .dbg_perf_cycle(dbg_perf_cycle), .dbg_perf_instr(dbg_perf_instr),
        .dbg_perf_stall(dbg_perf_stall), .dbg_perf_flush(dbg_perf_flush),
        .dbg_trace_sel(dbg_trace_sel),
        .dbg_trace_pc(dbg_trace_pc), .dbg_trace_instr(dbg_trace_instr),
        .dbg_trace_wb_data(dbg_trace_wb_data), .dbg_trace_status(dbg_trace_status),
        .dbg_trace_count(dbg_trace_count), .dbg_trace_head(dbg_trace_head)
    );

    initial uart_rxd_tb = 1'b1;
    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    initial begin
        $dumpfile("riscv_pipeline_phase6.vcd");
        $dumpvars(0, tb_phase6);
    end

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------
    task run_cycles(input int count);
        repeat (count) @(posedge clk);
        #1;
    endtask

    task load_word(input logic [9:0] addr, input logic [31:0] data);
        @(negedge clk);
        instr_load_en = 1'b1; instr_load_word_addr = addr; instr_load_data = data;
        @(posedge clk); #1;
        instr_load_en = 1'b0;
    endtask

    task check_reg(input int r, input logic [31:0] exp, input string msg);
        logic [31:0] val = uut.u_id_stage.u_reg_file.regs[r];
        if (val == exp)
            $display("PASS: %s (x%0d=0x%08h)", msg, r, val);
        else begin
            $error("FAIL: %s expected x%0d=0x%08h got 0x%08h", msg, r, exp, val);
            failures++;
        end
    endtask

    // ------------------------------------------------------------------
    // Main test
    // ------------------------------------------------------------------
    initial begin
        failures = 0;
        instr_load_en = 1'b0; instr_load_word_addr = 10'd0; instr_load_data = 32'd0;
        dbg_reg_addr = 5'd0; dbg_dmem_addr = 10'd0; dbg_trace_sel = 2'd0;

        // Reset
        rst = 1'b1; run_cycles(5); rst = 1'b0; run_cycles(10);

        $display("\n=== Phase 6 Test: RV32M Multiply Instructions ===");

        // Inject MUL test program at address 0x100
        // @0x100: addi x1, x0, -1    -> 0xFFF00093
        // @0x104: addi x2, x0, -1    -> 0xFFF00113
        // @0x108: mul x3, x1, x2     -> 0x022081B3
        // @0x10C: mulh x4, x1, x2    -> 0x02209233
        // @0x110: mulhsu x5, x1, x2  -> 0x0220A2B3
        // @0x114: mulhu x6, x1, x2   -> 0x0220B333
        // @0x118: jal x0, 0 (spin)   -> 0x0000006F
        
        load_word(10'd64, 32'hFFF00093);
        load_word(10'd65, 32'hFFF00113);
        load_word(10'd66, 32'h022081B3);
        load_word(10'd67, 32'h02209233);
        load_word(10'd68, 32'h0220A2B3);
        load_word(10'd69, 32'h0220B333);
        load_word(10'd70, 32'h0000006F);

        // Force PC to 0x100
        force uut.u_if_stage.pc_current = 32'h100;
        run_cycles(1); release uut.u_if_stage.pc_current;
        run_cycles(20);

        // x1 = 0xFFFFFFFF
        // x2 = 0xFFFFFFFF
        check_reg(1, 32'hFFFFFFFF, "Load x1");
        check_reg(2, 32'hFFFFFFFF, "Load x2");
        
        // x3 = MUL = 1
        check_reg(3, 32'h00000001, "MUL result");
        
        // x4 = MULH = 0
        check_reg(4, 32'h00000000, "MULH result");
        
        // x5 = MULHSU = 0xFFFFFFFF
        check_reg(5, 32'hFFFFFFFF, "MULHSU result");
        
        // x6 = MULHU = 0xFFFFFFFE
        check_reg(6, 32'hFFFFFFFE, "MULHU result");

        // ------------------------------------------------------------------
        // Final
        // ------------------------------------------------------------------
        if (failures == 0)
            $display("\n*** PHASE 6 ALL TESTS PASSED ***");
        else
            $display("\n*** PHASE 6 TESTS FAILED: %0d failure(s) ***", failures);
        $finish;
    end

endmodule
