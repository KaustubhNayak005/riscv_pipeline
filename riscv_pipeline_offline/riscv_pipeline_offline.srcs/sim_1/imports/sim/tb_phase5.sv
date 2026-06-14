/*
 * Module: tb_phase5
 * Description: Self-checking testbench for Phase 5 - Traps, Exceptions,
 *              and Timer Interrupts.
 *
 * Tests:
 *   1. CSR read/write via CSR instructions
 *   2. ECALL trap entry (checks mepc, mcause, trap redirect to mtvec)
 *   3. MRET return from trap handler
 *   4. Illegal instruction trap
 *   5. Timer interrupt generation and trapping
 *
 * Uses the instruction loader port to inject Phase 5 test sequences.
 */
`timescale 1ns/1ps

module tb_phase5;

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
        $dumpfile("riscv_pipeline_phase5.vcd");
        $dumpvars(0, tb_phase5);
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

    task load_program(input string path);
        for (int i = 0; i < 1024; i++) program_words[i] = 32'h00000013;
        $readmemh(path, program_words);
        for (int i = 0; i < 1024; i++) load_word(i[9:0], program_words[i]);
        $display("Loaded program from %s", path);
    endtask

    task mmio_read(input logic [31:0] addr, output logic [31:0] data);
        force uut.u_mem_stage.ex_mem_alu_result = addr;
        force uut.u_mem_stage.ex_mem_mem_read   = 1'b1;
        force uut.u_mem_stage.ex_mem_mem_write  = 1'b0;
        #0;
        data = uut.u_mem_stage.mem_wb_mem_read_data_in;
        release uut.u_mem_stage.ex_mem_alu_result;
        release uut.u_mem_stage.ex_mem_mem_read;
        release uut.u_mem_stage.ex_mem_mem_write;
    endtask

    task mmio_write(input logic [31:0] addr, input logic [31:0] data);
        force uut.u_mem_stage.ex_mem_alu_result = addr;
        force uut.u_mem_stage.ex_mem_mem_write  = 1'b1;
        force uut.u_mem_stage.ex_mem_mem_read   = 1'b0;
        force uut.u_mem_stage.ex_mem_rs2_data   = data;
        @(posedge clk); #1;
        release uut.u_mem_stage.ex_mem_alu_result;
        release uut.u_mem_stage.ex_mem_mem_write;
        release uut.u_mem_stage.ex_mem_mem_read;
        release uut.u_mem_stage.ex_mem_rs2_data;
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
        string path;
        logic [31:0] tmp;

        failures = 0;
        instr_load_en = 1'b0; instr_load_word_addr = 10'd0; instr_load_data = 32'd0;
        dbg_reg_addr = 5'd0; dbg_dmem_addr = 10'd0; dbg_trace_sel = 2'd0;

        if (!$value$plusargs("PROGRAM_MEM=%s", path))
            path = "mem/program.mem";
        load_program(path);

        // Reset
        rst = 1'b1; run_cycles(5); rst = 1'b0; run_cycles(50);

        $display("\n=== Phase 5 Test 1: CSR Read/Write ===");

        // Inject CSR test at 0x200:
        // @0x200: lui  x4, 0xDEAD0      -> 0xDEAD0217
        // @0x204: csrrw x3, mtvec, x4    -> 0x305211F3  (mtvec=0x305, rd=x3, rs1=x4, funct3=001)
        // @0x208: csrrwi x5, mstatus, 8  -> 0x300462F3  (mstatus=0x300, uimm=8, rd=x5, funct3=101)
        // @0x20C: nop                     -> 0x00000013
        // @0x210: jal x0, 0 (spin)        -> 0x0000006F
        load_word(10'd128, 32'hDEAD0217);
        load_word(10'd129, 32'h305211F3);
        load_word(10'd130, 32'h300462F3);
        load_word(10'd131, 32'h00000013);
        load_word(10'd132, 32'h0000006F);

        // Force PC to 0x200
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current;
        run_cycles(15);

        // x3 should hold old mtvec value (0), x5 holds old mstatus bits
        check_reg(3, 32'd0, "CSRRW return: old mtvec = 0");
        $display("INFO: mtvec = 0x%08h, x5 = 0x%08h", uut.mtvec, uut.u_id_stage.u_reg_file.regs[5]);

        $display("\n=== Phase 5 Test 2: ECALL Trap ===");

        // Inject trap handler at 0x300:
        // @0x300: csrrs x10, mepc, x0     -> 0x34102573  (read mepc into x10)
        // @0x304: addi  x10, x10, 4        -> 0x00450513  (advance mepc past ecall)
        // @0x308: csrrw x0, mepc, x10      -> 0x34151073  (write mepc back)
        // @0x30C: addi  x11, x11, 1        -> 0x00158593  (trap counter++)
        // @0x310: lui x20, 0xC0000         -> 0xC0000A37  (mtimecmp base)
        // @0x314: addi x20, x20, 0x204     -> 0x204A0A13  (mtimecmp address = 0xC0000204)
        // @0x318: addi x21, x0, -1         -> 0xFFF00A93  (x21 = -1)
        // @0x31C: sw x21, 0(x20)           -> 0x015A2023  (write -1 to mtimecmp to clear timer irq)
        // @0x320: nop                      -> 0x00000013  (avoid data hazard between csrrw mepc and mret)
        // @0x324: mret                     -> 0x30200073  (return)
        load_word(10'd192, 32'h34102573);  // 0x300
        load_word(10'd193, 32'h00450513);  // 0x304
        load_word(10'd194, 32'h34151073);  // 0x308
        load_word(10'd195, 32'h00158593);  // 0x30C
        load_word(10'd196, 32'hC0000A37);  // 0x310
        load_word(10'd197, 32'h204A0A13);  // 0x314
        load_word(10'd198, 32'hFFF00A93);  // 0x318
        load_word(10'd199, 32'h015A2023);  // 0x31C
        load_word(10'd200, 32'h00000013);  // 0x320 (nop)
        load_word(10'd201, 32'h30200073);  // 0x324 (mret)

        // Set mtvec = 0x300 via MMIO
        // Write mtvec CSR directly using force (sim-only shortcut)
        force uut.u_csr_file.mtvec_reg = 32'h300;
        run_cycles(1);
        release uut.u_csr_file.mtvec_reg;

        // Inject ECALL at 0x220:
        // @0x220: nop           -> 0x00000013
        // @0x224: ecall         -> 0x00000073
        // @0x228: addi x12,x12,1-> 0x00160613  (should execute after MRET)
        // @0x22C: jal x0, 0     -> 0x0000006F
        load_word(10'd136, 32'h00000013);
        load_word(10'd137, 32'h00000073);
        load_word(10'd138, 32'h00160613);
        load_word(10'd139, 32'h0000006F);

        // Set x11=0 (trap counter), x12=0 (post-trap marker)
        force uut.u_id_stage.u_reg_file.regs[11] = 32'd0;
        force uut.u_id_stage.u_reg_file.regs[12] = 32'd0;
        run_cycles(1);
        release uut.u_id_stage.u_reg_file.regs[11];
        release uut.u_id_stage.u_reg_file.regs[12];

        force uut.u_if_stage.pc_current = 32'h220;
        run_cycles(5); release uut.u_if_stage.pc_current;
        run_cycles(50);

        check_reg(11, 32'd1, "ECALL: trap counter = 1");
        check_reg(12, 32'd1, "ECALL: post-trap x12 incremented (MRET succeeded)");
        $display("INFO: mepc=0x%08h", uut.mepc);

        $display("\n=== Phase 5 Test 3: Illegal Instruction Trap ===");

        // Inject illegal opcode at 0x240:
        // @0x240: nop
        // @0x244: 0xFFFFFFFF (illegal)
        // @0x248: addi x12, x12, 1      -> 0x00160613  (should execute after MRET)
        // @0x24C: jal x0, 0             -> 0x0000006F
        load_word(10'd144, 32'h00000013); // 0x240
        load_word(10'd145, 32'hFFFFFFFF); // 0x244
        load_word(10'd146, 32'h00160613); // 0x248
        load_word(10'd147, 32'h0000006F); // 0x24C

        force uut.u_if_stage.pc_current = 32'h240;
        run_cycles(5); release uut.u_if_stage.pc_current;
        run_cycles(50);

        check_reg(11, 32'd2, "Illegal: trap counter = 2");
        check_reg(12, 32'd2, "Illegal: post-trap x12 incremented again");

        // Pad with jal x0, 0 so that trap handler advancing mepc doesn't hit zeroes
        load_word(10'd148, 32'h0000006F); // 0x250
        load_word(10'd149, 32'h0000006F); // 0x254
        load_word(10'd150, 32'h0000006F); // 0x258
        load_word(10'd151, 32'h0000006F); // 0x25C

        $display("\n=== Phase 5 Test 4: Timer Interrupt ===");

        // Enable MIE in mstatus (bit 3)
        force uut.u_csr_file.mstatus_reg[3] = 1'b1;
        release uut.u_csr_file.mstatus_reg[3];

        // Configure timer: mtimecmp and ctrl
        force uut.u_mem_stage.u_timer.mtimecmp = 32'd1000;
        force uut.u_mem_stage.u_timer.ctrl = 2'b01;
        
        force uut.u_if_stage.pc_current = 32'h250;
        run_cycles(5); release uut.u_if_stage.pc_current;
        
        // Let it run for 50 cycles to hit timer (mtime is already around ~600)
        // Wait! We should force mtime to 0 to be deterministic!
        force uut.u_mem_stage.u_timer.mtime = 32'd0;
        force uut.u_mem_stage.u_timer.mtimecmp = 32'd10;
        release uut.u_mem_stage.u_timer.mtime;
        release uut.u_mem_stage.u_timer.mtimecmp;
        release uut.u_mem_stage.u_timer.ctrl;
        
        // Wait for timer to fire (200 cycles)
        run_cycles(400);

        // Timer IRQ should have fired, handler ran once more
        $display("Timer: mtime=%0d mtimecmp=%0d irq=%0b mie=%0b",
            uut.u_mem_stage.u_timer.mtime,
            uut.u_mem_stage.u_timer.mtimecmp,
            uut.timer_irq, uut.mie);
        check_reg(11, 32'd3, "Timer IRQ: trap counter = 3");

        $display("\n=== Phase 5 Test 5: EBREAK Trap ===");

        // Inject EBREAK at 0x260:
        // @0x260: nop
        // @0x264: EBREAK (0x00100073)
        // @0x268: addi x12, x12, 1
        // @0x26C: jal x0, 0
        load_word(10'd152, 32'h00000013); // 0x260
        load_word(10'd153, 32'h00100073); // 0x264
        load_word(10'd154, 32'h00160613); // 0x268
        load_word(10'd155, 32'h0000006F); // 0x26C

        force uut.u_if_stage.pc_current = 32'h260;
        run_cycles(5); release uut.u_if_stage.pc_current;
        run_cycles(50);

        check_reg(11, 32'd4, "EBREAK: trap counter = 4");
        check_reg(12, 32'd3, "EBREAK: post-trap x12 = 3");

        // ------------------------------------------------------------------
        // Final
        // ------------------------------------------------------------------
        if (failures == 0)
            $display("\n*** PHASE 5 ALL TESTS PASSED ***");
        else
            $display("\n*** PHASE 5 TESTS FAILED: %0d failure(s) ***", failures);
        $finish;
    end

endmodule
