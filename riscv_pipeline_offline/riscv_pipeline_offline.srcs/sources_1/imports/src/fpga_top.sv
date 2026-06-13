/*
 * Module: fpga_top
 * Description: PYNQ Z2 board wrapper for the RV32I pipeline demo.
 *              Generates a 25 MHz CPU clock from the 125 MHz board clock,
 *              drives LEDs with heartbeat/running/pass/fail status, and
 *              integrates the UART monitor for Phase 4.
 */




module fpga_top (
    input  logic       clk,
    input  logic       rst,
    output logic [3:0] led,
    // UART pins
    input  logic       uart_rxd,
    output logic       uart_txd
);

    localparam logic [5:0] LAST_EXPECT_INDEX = 6'd26;
    localparam logic [31:0] TIMEOUT_CYCLES = 32'd5_000_000;

    logic pll_clk;
    logic cpu_clk;
    logic clkfb;
    logic clkfb_buf;
    logic pll_locked;
    logic unused_clkout1;
    logic unused_clkout2;
    logic unused_clkout3;
    logic unused_clkout4;
    logic unused_clkout5;

    PLLE2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT(8),
        .CLKFBOUT_PHASE(0.0),
        .CLKIN1_PERIOD(8.000),
        .CLKOUT0_DIVIDE(40),
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT0_PHASE(0.0),
        .DIVCLK_DIVIDE(1),
        .REF_JITTER1(0.010),
        .STARTUP_WAIT("FALSE")
    ) u_cpu_pll (
        .CLKIN1(clk),
        .CLKFBIN(clkfb_buf),
        .RST(rst),
        .PWRDWN(1'b0),
        .CLKFBOUT(clkfb),
        .CLKOUT0(pll_clk),
        .CLKOUT1(unused_clkout1),
        .CLKOUT2(unused_clkout2),
        .CLKOUT3(unused_clkout3),
        .CLKOUT4(unused_clkout4),
        .CLKOUT5(unused_clkout5),
        .LOCKED(pll_locked)
    );

    BUFG u_clkfb_buf (
        .I(clkfb),
        .O(clkfb_buf)
    );

    BUFG u_cpu_clk_buf (
        .I(pll_clk),
        .O(cpu_clk)
    );

    logic [1:0] cpu_rst_sync;
    logic       cpu_rst;
    logic       cpu_rst_async;

    assign cpu_rst_async = rst | ~pll_locked;
    assign cpu_rst = cpu_rst_sync[1];

    always_ff @(posedge cpu_clk or posedge cpu_rst_async) begin
        if (cpu_rst_async) begin
            cpu_rst_sync <= 2'b11;
        end else begin
            cpu_rst_sync <= {cpu_rst_sync[0], 1'b0};
        end
    end

    logic [31:0] debug_pc_current;
    logic        debug_wb_reg_write;
    logic [4:0]  debug_wb_rd;
    logic [31:0] debug_wb_write_data;
    logic        cpu_halt;

    // UART monitor signals
    logic        cpu_reset_n;
    logic        monitor_mode;
    logic        cpu_uart_txd;
    logic        mon_uart_txd;
    logic        mon_instr_load_en;
    logic [9:0]  mon_instr_load_word_addr;
    logic [31:0] mon_instr_load_data;
    logic [4:0]  mon_dbg_reg_addr;
    logic [31:0] mon_dbg_reg_data;
    logic [9:0]  mon_dbg_dmem_addr;
    logic [31:0] mon_dbg_dmem_data;
    logic [1:0]  mon_dbg_trace_sel;
    logic [31:0] mon_dbg_trace_pc;
    logic [31:0] mon_dbg_trace_instr;
    logic [31:0] mon_dbg_trace_wb_data;
    logic [31:0] mon_dbg_trace_status;
    logic [2:0]  mon_dbg_trace_count;
    logic [1:0]  mon_dbg_trace_head;
    logic [31:0] cpu_dbg_perf_cycle;
    logic [31:0] cpu_dbg_perf_instr;
    logic [31:0] cpu_dbg_perf_stall;
    logic [31:0] cpu_dbg_perf_flush;

    // UART mux: when in monitor mode, txd comes from monitor.
    // When running, txd comes from CPU. rxd always goes to monitor
    // (which forwards bytes to CPU in passthrough mode).
    logic mon_rxd;
    assign mon_rxd = uart_rxd;

    // CPU rxd: in monitor-mode, idle=1 (CPU UART isn't connected to wire).
    // In passthrough mode, rxd comes from the physical pin.
    logic cpu_uart_rxd;
    logic uart_rxd_sync;
    assign cpu_uart_rxd = monitor_mode ? 1'b1 : uart_rxd_sync;

    assign uart_txd = monitor_mode ? mon_uart_txd : cpu_uart_txd;

    // CPU reset: active when cpu_reset_n is 0 OR during board power-on reset
    logic cpu_rst_effective;
    assign cpu_rst_effective = cpu_rst || ~cpu_reset_n;

    // 2-stage synchroniser for uart_rxd into cpu_clk domain
    // (uart_rx inside also has its own 2-FF synchroniser for belt-and-braces)
    logic [1:0] uart_rx_sync;

    always_ff @(posedge cpu_clk or posedge cpu_rst_async) begin
        if (cpu_rst_async)
            uart_rx_sync <= 2'b11;
        else
            uart_rx_sync <= {uart_rx_sync[0], uart_rxd};
    end
    assign uart_rxd_sync = uart_rx_sync[1];

    uart_monitor #(.CLKS_PER_BIT(217)) u_monitor (
        .clk                  (cpu_clk),
        .rst                  (cpu_rst),
        .uart_rxd             (mon_rxd),
        .uart_txd             (mon_uart_txd),
        .cpu_reset_n          (cpu_reset_n),
        .monitor_mode         (monitor_mode),
        .instr_load_en        (mon_instr_load_en),
        .instr_load_word_addr (mon_instr_load_word_addr),
        .instr_load_data      (mon_instr_load_data),
        .dbg_reg_addr         (mon_dbg_reg_addr),
        .dbg_reg_data         (mon_dbg_reg_data),
        .dbg_dmem_addr        (mon_dbg_dmem_addr),
        .dbg_dmem_data        (mon_dbg_dmem_data),
        .dbg_perf_cycle       (cpu_dbg_perf_cycle),
        .dbg_perf_instr       (cpu_dbg_perf_instr),
        .dbg_perf_stall       (cpu_dbg_perf_stall),
        .dbg_perf_flush       (cpu_dbg_perf_flush),
        .dbg_trace_pc         (mon_dbg_trace_pc),
        .dbg_trace_instr      (mon_dbg_trace_instr),
        .dbg_trace_wb_data    (mon_dbg_trace_wb_data),
        .dbg_trace_status     (mon_dbg_trace_status),
        .dbg_trace_count      (mon_dbg_trace_count),
        .dbg_trace_head       (mon_dbg_trace_head),
        .dbg_trace_sel        (mon_dbg_trace_sel)
    );

    top u_cpu (
        .clk                 (cpu_clk),
        .rst                 (cpu_rst_effective),
        .debug_pc_current    (debug_pc_current),
        .debug_wb_reg_write  (debug_wb_reg_write),
        .debug_wb_rd         (debug_wb_rd),
        .debug_wb_write_data (debug_wb_write_data),
        .halt                (cpu_halt),
        .instr_load_en       (mon_instr_load_en),
        .instr_load_word_addr(mon_instr_load_word_addr),
        .instr_load_data     (mon_instr_load_data),
        // UART pins
        .uart_rxd            (cpu_uart_rxd),
        .uart_txd            (cpu_uart_txd),
        // Debug read ports for UART monitor
        .dbg_reg_addr        (mon_dbg_reg_addr),
        .dbg_reg_data        (mon_dbg_reg_data),
        .dbg_dmem_addr       (mon_dbg_dmem_addr),
        .dbg_dmem_data       (mon_dbg_dmem_data),
        .dbg_perf_cycle      (cpu_dbg_perf_cycle),
        .dbg_perf_instr      (cpu_dbg_perf_instr),
        .dbg_perf_stall      (cpu_dbg_perf_stall),
        .dbg_perf_flush      (cpu_dbg_perf_flush),
        .dbg_trace_sel       (mon_dbg_trace_sel),
        .dbg_trace_pc        (mon_dbg_trace_pc),
        .dbg_trace_instr     (mon_dbg_trace_instr),
        .dbg_trace_wb_data   (mon_dbg_trace_wb_data),
        .dbg_trace_status    (mon_dbg_trace_status),
        .dbg_trace_count     (mon_dbg_trace_count),
        .dbg_trace_head      (mon_dbg_trace_head)
    );

    logic [5:0]  pass_index;
    logic [31:0] timeout_counter;
    logic        pass_latched;
    logic        fail_latched;

    function automatic logic [4:0] expected_rd(input logic [5:0] index);
        case (index)
            6'd0:  expected_rd = 5'd1;
            6'd1:  expected_rd = 5'd2;
            6'd2:  expected_rd = 5'd3;
            6'd3:  expected_rd = 5'd4;
            6'd4:  expected_rd = 5'd5;
            6'd5:  expected_rd = 5'd6;
            6'd6:  expected_rd = 5'd7;
            6'd7:  expected_rd = 5'd8;
            6'd8:  expected_rd = 5'd9;
            6'd9:  expected_rd = 5'd10;
            6'd10: expected_rd = 5'd11;
            6'd11: expected_rd = 5'd12;
            6'd12: expected_rd = 5'd13;
            6'd13: expected_rd = 5'd14;
            6'd14: expected_rd = 5'd16;
            6'd15: expected_rd = 5'd17;
            6'd16: expected_rd = 5'd18;
            6'd17: expected_rd = 5'd19;
            6'd18: expected_rd = 5'd20;
            6'd19: expected_rd = 5'd23;
            6'd20: expected_rd = 5'd24;
            6'd21: expected_rd = 5'd25;
            6'd22: expected_rd = 5'd26;
            6'd23: expected_rd = 5'd27;
            6'd24: expected_rd = 5'd28;
            6'd25: expected_rd = 5'd29;
            6'd26: expected_rd = 5'd30;
            default: expected_rd = 5'd0;
        endcase
    endfunction

    function automatic logic [31:0] expected_data(input logic [5:0] index);
        case (index)
            6'd0:  expected_data = 32'd5;
            6'd1:  expected_data = 32'd10;
            6'd2:  expected_data = 32'd15;
            6'd3:  expected_data = 32'd5;
            6'd4:  expected_data = 32'd0;
            6'd5:  expected_data = 32'd15;
            6'd6:  expected_data = 32'd15;
            6'd7:  expected_data = 32'd15;
            6'd8:  expected_data = 32'd20;
            6'd9:  expected_data = 32'd35;
            6'd10: expected_data = 32'd55;
            6'd11: expected_data = 32'd1;
            6'd12: expected_data = 32'd2;
            6'd13: expected_data = 32'h00000048;
            6'd14: expected_data = 32'd84;
            6'd15: expected_data = 32'h12345000;
            6'd16: expected_data = 32'h00001054;
            6'd17: expected_data = 32'd100;
            6'd18: expected_data = 32'h00000060;
            6'd19: expected_data = 32'd7;
            6'd20: expected_data = 32'd28;
            6'd21: expected_data = 32'd14;
            6'd22: expected_data = 32'd7;
            6'd23: expected_data = 32'd1;
            6'd24: expected_data = 32'd0;
            6'd25: expected_data = 32'd1;
            6'd26: expected_data = 32'd0;
            default: expected_data = 32'd0;
        endcase
    endfunction

    always_ff @(posedge cpu_clk) begin
        if (cpu_rst) begin
            pass_index <= 6'd0;
            timeout_counter <= 32'd0;
            pass_latched <= 1'b0;
            fail_latched <= 1'b0;
        end else if (!pass_latched && !fail_latched) begin
            if (timeout_counter >= TIMEOUT_CYCLES) begin
                fail_latched <= 1'b1;
            end else begin
                timeout_counter <= timeout_counter + 32'd1;
            end

            if (debug_wb_reg_write && (debug_wb_rd != 5'd0)) begin
                if ((debug_wb_rd == expected_rd(pass_index)) &&
                    (debug_wb_write_data == expected_data(pass_index))) begin
                    if (pass_index == LAST_EXPECT_INDEX) begin
                        pass_latched <= 1'b1;
                    end else begin
                        pass_index <= pass_index + 6'd1;
                    end
                end else begin
                    fail_latched <= 1'b1;
                end
            end
        end
    end

    logic [24:0] heartbeat_counter;
    logic [1:0]  pass_sync;
    logic [1:0]  fail_sync;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            heartbeat_counter <= 25'd0;
            pass_sync <= 2'b00;
            fail_sync <= 2'b00;
            led <= 4'b0000;
        end else begin
            heartbeat_counter <= heartbeat_counter + 25'd1;
            pass_sync <= {pass_sync[0], pass_latched};
            fail_sync <= {fail_sync[0], fail_latched};
            led <= {
                fail_sync[1],
                pass_sync[1],
                pll_locked && !pass_sync[1] && !fail_sync[1],
                heartbeat_counter[24]
            };
        end
    end

endmodule
