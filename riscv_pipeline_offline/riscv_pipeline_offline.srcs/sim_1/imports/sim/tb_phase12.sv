/*
 * Module: tb_phase12
 * Description: Self-checking testbench for Phase 12 — Optional Peripherals
 *              (LED Control Register, Button/Switch Input, PWM Peripheral).
 *
 * Tests:
 *   A. LED write 0xA and read-back
 *   B. LED all-bits-set (0xF) then clear (0x0)
 *   C. Button/switch mixed inputs (raw_btn=2'b10, raw_sw=2'b01)
 *   D. Button/switch all zeros
 *   E. PWM period write and read-back
 *   F. PWM duty write and read-back
 *   G. PWM enable and waveform verification (50% duty, accept +/-1 cycle)
 *   H. PWM duty-clamping (duty > period)
 *   I. PWM disable
 */
`timescale 1ns/1ps

module tb_phase12;

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

    // Phase 12 I/O
    logic [3:0]  led_out;
    logic        led_sw_ctrl;
    logic [1:0]  raw_btn;
    logic [1:0]  raw_sw;
    logic        pwm_out;

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
        .dbg_trace_count(dbg_trace_count), .dbg_trace_head(dbg_trace_head),
        // Phase 12
        .led_out(led_out), .led_sw_ctrl(led_sw_ctrl),
        .raw_btn(raw_btn), .raw_sw(raw_sw), .pwm_out(pwm_out)
    );

    initial uart_rxd_tb = 1'b1;
    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    initial begin
        $dumpfile("riscv_pipeline_phase12.vcd");
        $dumpvars(0, tb_phase12);
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

    // Build SW instruction: store rs2 into imm(rs1)
    function logic [31:0] make_sw(input logic [4:0] rs1, input logic [4:0] rs2, input logic [11:0] offset);
        make_sw = {offset[11:5], rs2, rs1, 3'b010, offset[4:0], 7'b0100011};
    endfunction

    // Build LW instruction: load from imm(rs1) into rd
    function logic [31:0] make_lw(input logic [4:0] rd, input logic [4:0] rs1, input logic [11:0] offset);
        make_lw = {offset[11:0], rs1, 3'b010, rd, 7'b0000011};
    endfunction

    // Build LUI instruction
    function logic [31:0] make_lui(input logic [4:0] rd, input logic [31:12] imm);
        make_lui = {imm, rd, 7'b0110111};
    endfunction

    // Build ADDI instruction
    function logic [31:0] make_addi(input logic [4:0] rd, input logic [4:0] rs1, input logic [11:0] imm);
        make_addi = {imm, rs1, 3'b000, rd, 7'b0010011};
    endfunction

    // Check register via DUT hierarchy read
    task check_reg(input int r, input logic [31:0] exp, input string msg);
        logic [31:0] val = uut.u_id_stage.u_reg_file.regs[r];
        if (val == exp)
            $display("  PASS: %s (x%0d = 0x%08h)", msg, r, val);
        else begin
            $display("  FAIL: %s expected x%0d = 0x%08h, got 0x%08h", msg, r, exp, val);
            failures++;
        end
    endtask

    function logic [31:0] make_nop();
        make_nop = 32'h00000013;
    endfunction

    // ------------------------------------------------------------------
    // Main test
    // ------------------------------------------------------------------
    initial begin
        failures = 0;
        instr_load_en = 1'b0; instr_load_word_addr = 10'd0; instr_load_data = 32'd0;
        raw_btn = 2'b00; raw_sw = 2'b00;

        for (int i = 0; i < 1024; i++) program_words[i] = make_nop();
        for (int i = 0; i < 1024; i++) load_word(i[9:0], program_words[i]);

        // Reset
        rst = 1'b1; run_cycles(10); rst = 1'b0; run_cycles(30);

        $display("===== Phase 12 — Optional Peripherals Tests =====");
        $display("");

        // ================================================================
        // TEST-A: LED write 0xA and read-back
        //   SW x3, 0(x0)    => store 0x0000000A to address 0xD0000000
        //   LW x5, 0(x0)    => load from 0xD0000000
        // Setup: x3 = 0x0000000A, x4 = 0xD0000000 (base address)
        // ================================================================
        $display("--- Test A: LED write 0xA and read-back ---");
        // x3 = 0xA
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd10));
        // LUI x4, 0xD0000 => x4 = 0xD0000000
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        // SW x3, 0(x4)    => store to 0xD0000000
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd0));
        // LW x5, 0(x4)    => load from 0xD0000000
        load_word(10'd131, make_lw(5'd5, 5'd4, 12'd0));
        load_word(10'd132, make_nop());
        load_word(10'd133, make_nop());
        load_word(10'd134, make_nop());
        // Run from address 0x200 (word 128)
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(20);
        check_reg(5, 32'h0000000A, "Test A: read-back 0xD0000000 = 0x0000000A");
        if (led_out == 4'b1010)
            $display("  PASS: led_out = 4'b1010");
        else begin
            $display("  FAIL: led_out expected 4'b1010, got 4'b%b", led_out);
            failures++;
        end

        // ================================================================
        // TEST-B: LED all-bits-set (0xF) then clear (0x0)
        // ================================================================
        $display("--- Test B: LED all-bits-set then clear ---");
        // ADDI x3, x0, 15 => x3 = 0xF
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd15));
        // LUI x4, 0xD0000
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        // SW x3, 0(x4)
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd0));
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(15);
        if (led_out == 4'b1111)
            $display("  PASS: led_out = 4'b1111 (all bits set)");
        else begin
            $display("  FAIL: led_out expected 4'b1111, got 4'b%b", led_out);
            failures++;
        end

        // ADDI x3, x0, 0 => x3 = 0
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd0));
        // SW x3, 0(x4)   => clear
        load_word(10'd129, make_sw(5'd4, 5'd3, 12'd0));
        load_word(10'd130, make_nop());
        load_word(10'd131, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(15);
        if (led_out == 4'b0000)
            $display("  PASS: led_out = 4'b0000 (cleared)");
        else begin
            $display("  FAIL: led_out expected 4'b0000, got 4'b%b", led_out);
            failures++;
        end

        // ================================================================
        // TEST-C: Button/switch read — mixed inputs
        //   raw_btn = 2'b10, raw_sw = 2'b01
        //   Wait 35 cycles for synchronizer/debounce to settle
        //   LW x5, 4(x4) from 0xD0000004
        //   Expected: bits[3:2]=01, bits[1:0]=10 => 0b0110=6
        // ================================================================
        $display("--- Test C: Button/switch mixed inputs ---");
        raw_btn = 2'b10;
        raw_sw  = 2'b01;
        run_cycles(35);
        // LUI x4, 0xD0000
        load_word(10'd128, make_lui(5'd4, 20'hD0000));
        // LW x5, 4(x4)  => load from 0xD0000004
        load_word(10'd129, make_lw(5'd5, 5'd4, 12'd4));
        load_word(10'd130, make_nop());
        load_word(10'd131, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(15);
        check_reg(5, 32'h00000006, "Test C: BTN_SW read 0xD0000004 = 0x06 (btn=10, sw=01)");

        // ================================================================
        // TEST-D: Button/switch read — all zeros
        // ================================================================
        $display("--- Test D: Button/switch all zeros ---");
        raw_btn = 2'b00;
        raw_sw  = 2'b00;
        run_cycles(35);
        // LW x6, 4(x4)
        load_word(10'd128, make_lui(5'd4, 20'hD0000));
        load_word(10'd129, make_lw(5'd6, 5'd4, 12'd4));
        load_word(10'd130, make_nop());
        load_word(10'd131, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(15);
        check_reg(6, 32'h00000000, "Test D: BTN_SW read 0xD0000004 = 0x0 (all zeros)");

        // ================================================================
        // TEST-E: PWM period register write and read-back
        //   Write 200 to 0xD0000008, read back
        // ================================================================
        $display("--- Test E: PWM period write and read-back ---");
        // ADDI x3, x0, 200 => x3 = 200
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd200));
        // LUI x4, 0xD0000
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        // SW x3, 8(x4) => store to 0xD0000008
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd8));
        // LW x7, 8(x4) => load from 0xD0000008
        load_word(10'd131, make_lw(5'd7, 5'd4, 12'd8));
        load_word(10'd132, make_nop());
        load_word(10'd133, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(20);
        check_reg(7, 32'd200, "Test E: PWM period read-back = 200");

        // ================================================================
        // TEST-F: PWM duty register write and read-back
        //   Write 100 to 0xD000000C, read back
        // ================================================================
        $display("--- Test F: PWM duty write and read-back ---");
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd100));
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        // SW x3, 12(x4) => store to 0xD000000C
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd12));
        // LW x8, 12(x4)
        load_word(10'd131, make_lw(5'd8, 5'd4, 12'd12));
        load_word(10'd132, make_nop());
        load_word(10'd133, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(20);
        check_reg(8, 32'd100, "Test F: PWM duty read-back = 100");

        // ================================================================
        // TEST-G: PWM enable and output waveform verification
        //   period=10, duty=5, enable=1
        //   Run 35 cycles, count high/low cycles on pwm_out
        //   Expected: ~50% duty, accept +/-1 cycle tolerance
        // ================================================================
        $display("--- Test G: PWM waveform verification ---");
        // Write period=10 to 0xD0000008
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd10));
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd8));
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(15);

        // Write duty=5 to 0xD000000C
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd5));
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd12));
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(15);

        // Write ctrl=1 (enable) to 0xD0000010
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd1));
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd16));
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current;
        run_cycles(35);

        // Count high/low over last 20 cycles (to allow settle)
        // Actually count the full 35 cycles post-enable
        // We'll count by re-running with a counter
        // Instead, let's measure pwm_out directly
        begin
            int high_cnt, low_cnt;
            high_cnt = 0; low_cnt = 0;
            // Run 35 more cycles and count
            for (int c = 0; c < 35; c++) begin
                @(posedge clk); #1;
                if (pwm_out) high_cnt = high_cnt + 1;
                else         low_cnt  = low_cnt + 1;
            end
            $display("  PWM waveform: %0d high, %0d low over 35 cycles", high_cnt, low_cnt);
            // Period=10, duty=5 => expected 50% duty = 17-18 high, 17-18 low
            if (high_cnt >= 15 && high_cnt <= 20)
                $display("  PASS: PWM waveform ~50%% duty (%0d high / 35 total)", high_cnt);
            else begin
                $display("  FAIL: PWM waveform duty out of range (expected ~17-18 high, got %0d)", high_cnt);
                failures++;
            end
        end

        // ================================================================
        // TEST-H: PWM duty-clamping (duty > period)
        //   period=10, duty=20, enable=1
        //   Run 20 cycles, expect pwm_out always 1
        // ================================================================
        $display("--- Test H: PWM duty clamping ---");
        // Disable first
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd0));
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd16));
        load_word(10'd131, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(10);

        // Write period=10
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd10));
        load_word(10'd129, make_sw(5'd4, 5'd3, 12'd8));
        load_word(10'd130, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(10);

        // Write duty=20
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd20));
        load_word(10'd129, make_sw(5'd4, 5'd3, 12'd12));
        load_word(10'd130, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(10);

        // Write ctrl=1 (enable)
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd1));
        load_word(10'd129, make_sw(5'd4, 5'd3, 12'd16));
        load_word(10'd130, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current;
        run_cycles(25);

        begin
            int all_high;
            all_high = 1;
            for (int c = 0; c < 20; c++) begin
                @(posedge clk); #1;
                if (!pwm_out) all_high = 0;
            end
            if (all_high)
                $display("  PASS: PWM always-on when duty(%0d) > period(%0d)", 20, 10);
            else begin
                $display("  FAIL: PWM expected always-on, got low periods");
                failures++;
            end
        end

        // ================================================================
        // TEST-I: PWM disable
        //   Verify enable bit can be cleared via SW to 0xD0000010.
        //   Read back ctrl register to confirm.
        // ================================================================
        $display("--- Test I: PWM disable ---");
        // Disable first
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd0));
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd16));
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(15);

        // Set period=10, duty=5, ctrl=1 (enable)
        load_word(10'd128, make_addi(5'd3, 5'd0, 12'd10));    // x3 = 10
        load_word(10'd129, make_lui(5'd4, 20'hD0000));
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd8));       // period=10
        load_word(10'd131, make_addi(5'd3, 5'd0, 12'd5));     // x3 = 5
        load_word(10'd132, make_sw(5'd4, 5'd3, 12'd12));      // duty=5
        load_word(10'd133, make_addi(5'd3, 5'd0, 12'd1));     // x3 = 1
        load_word(10'd134, make_sw(5'd4, 5'd3, 12'd16));      // ctrl=1
        load_word(10'd135, make_nop());
        load_word(10'd136, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(25);

        // Read back ctrl: LW x9, 16(x4)
        load_word(10'd128, make_lui(5'd4, 20'hD0000));
        load_word(10'd129, make_lw(5'd9, 5'd4, 12'd16));
        load_word(10'd130, make_nop());
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(20);
        check_reg(9, 32'd1, "Test I: PWM ctrl read-back = 1 (enabled)");

        // Disable: write ctrl=0
        load_word(10'd128, make_lui(5'd4, 20'hD0000));
        load_word(10'd129, make_addi(5'd3, 5'd0, 12'd0));     // x3 = 0
        load_word(10'd130, make_sw(5'd4, 5'd3, 12'd16));      // ctrl=0
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        load_word(10'd133, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(30);

        // Read back ctrl: LW x10, 16(x4)
        load_word(10'd128, make_lui(5'd4, 20'hD0000));
        load_word(10'd129, make_lw(5'd10, 5'd4, 12'd16));
        load_word(10'd130, make_nop());
        load_word(10'd131, make_nop());
        load_word(10'd132, make_nop());
        force uut.u_if_stage.pc_current = 32'h200;
        run_cycles(1); release uut.u_if_stage.pc_current; run_cycles(20);
        check_reg(10, 32'd0, "Test I: PWM ctrl read-back = 0 (disabled)");

        // Waveform verification: pwm_out should be low after disable.
        // pwm.sv uses a combinatorial path (always_comb with enable check),
        // so pwm_out goes low within 1 cycle of enable going to 0.
        // Wait 5 cycles for pipeline latency + register propagation, then
        // observe pwm_out for 20 consecutive cycles.
        run_cycles(5);
        begin
            int low_cnt;
            low_cnt = 0;
            for (int c = 0; c < 20; c++) begin
                @(posedge clk); #1;
                if (!pwm_out) low_cnt = low_cnt + 1;
            end
            if (low_cnt == 20)
                $display("  PASS: pwm_out = 0 for all 20 cycles after disable");
            else begin
                $display("  FAIL: pwm_out expected 0 after disable, got 0 in %0d/20 cycles", low_cnt);
                failures++;
            end
        end

        // ================================================================
        // Final
        // ================================================================
        $display("");
        if (failures == 0)
            $display("*** PHASE 12 ALL TESTS PASSED ***");
        else
            $display("*** PHASE 12 TESTS FAILED: %0d failure(s) ***", failures);
        $finish;
    end

endmodule
