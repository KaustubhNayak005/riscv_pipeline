/*
 * Module: uart_monitor
 * Description: Clean, synthesis-optimized UART monitor for RV32I.
 */
module uart_monitor #(
    parameter int CLKS_PER_BIT = 217
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        uart_rxd,
    output logic        uart_txd,
    output logic        cpu_reset_n,
    output logic        monitor_mode,
    output logic        instr_load_en,
    output logic [9:0]  instr_load_word_addr,
    output logic [31:0] instr_load_data,
    input  logic [31:0] dbg_reg_data,
    output logic [4:0]  dbg_reg_addr,
    input  logic [31:0] dbg_dmem_data,
    output logic [9:0]  dbg_dmem_addr,
    input  logic [31:0] dbg_perf_cycle,
    input  logic [31:0] dbg_perf_instr,
    input  logic [31:0] dbg_perf_stall,
    input  logic [31:0] dbg_perf_flush,
    input  logic [31:0] dbg_trace_pc,
    input  logic [31:0] dbg_trace_instr,
    input  logic [31:0] dbg_trace_wb_data,
    input  logic [31:0] dbg_trace_status,
    input  logic [2:0]  dbg_trace_count,
    input  logic [1:0]  dbg_trace_head,
    output logic [1:0]  dbg_trace_sel
);

    logic       rx_valid;
    logic [7:0] rx_data;
    logic       tx_start;
    logic [7:0] tx_data;
    logic       tx_busy;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_mon_rx (
        .clk(clk), .rst(rst),
        .rx_serial(uart_rxd),
        .rx_valid(rx_valid),
        .rx_data(rx_data)
    );

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_mon_tx (
        .clk(clk), .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(),
        .tx_serial(uart_txd)
    );

    typedef enum logic [4:0] {
        ST_IDLE,
        ST_PARSE,
        ST_EXEC_HELP,
        ST_EXEC_LOAD,
        ST_EXEC_RUN,
        ST_EXEC_RESET,
        ST_EXEC_REGS_WAIT,
        ST_EXEC_REGS_SEND,
        ST_EXEC_MEM_WAIT,
        ST_EXEC_MEM_SEND,
        ST_EXEC_PERF_SEND_1,
        ST_EXEC_PERF_SEND_2,
        ST_EXEC_TRACE_SEND,
        ST_TRACE_NEXT_1,
        ST_TRACE_NEXT_2,
        ST_PRINT_HEX,
        ST_PASSTHROUGH
    } state_t;

    state_t state, next_state, hex_return_state;

    localparam int CMD_BUF_LEN = 80;
    logic [7:0] cmd_buf [0:CMD_BUF_LEN-1];
    logic [6:0] cmd_len;
    logic [6:0] cmd_ptr;

    localparam int TX_BUF_LEN = 256;
    logic [7:0] tx_buf [0:TX_BUF_LEN-1];
    logic [7:0] tx_wr_ptr;
    logic [7:0] tx_rd_ptr;

    logic [31:0] arg_val;
    logic [3:0]  arg_nibble_count;
    logic        load_got_addr;
    logic [9:0]  load_addr;
    logic [31:0] load_data;
    logic        mem_got_addr;
    logic [9:0]  mem_addr;

    logic [4:0]  regs_index;
    logic [2:0]  trace_index;
    logic [31:0] perf_val;
    logic [2:0]  esc_seq;

    logic [31:0] hex_val_reg;
    logic [3:0]  hex_count;
    logic [7:0]  hex_prefix;
    logic [7:0]  hex_suffix;

    function automatic logic [3:0] hex_to_nibble(input logic [7:0] ch);
        if (ch >= "0" && ch <= "9") return ch[3:0];
        if (ch >= "A" && ch <= "F") return ch[3:0] + 4'd10;
        if (ch >= "a" && ch <= "f") return ch[3:0] + 4'd10;
        return 4'd0;
    endfunction

    function automatic logic [7:0] nibble_to_hex(input logic [3:0] nib);
        if (nib < 10) return {4'h3, nib};
        return {4'h3, nib - 4'd9};
    endfunction

    always_ff @(posedge clk) begin
        if (rst) begin
            state          <= ST_IDLE;
            cpu_reset_n    <= 1'b0;
            monitor_mode   <= 1'b1;
            instr_load_en  <= 1'b0;
            instr_load_word_addr <= 10'd0;
            instr_load_data <= 32'd0;
            dbg_reg_addr   <= 5'd0;
            dbg_dmem_addr  <= 10'd0;
            dbg_trace_sel  <= 2'd0;
            cmd_len        <= 7'd0;
            cmd_ptr        <= 7'd0;
            tx_wr_ptr      <= 8'd0;
            tx_rd_ptr      <= 8'd0;
            tx_start       <= 1'b0;
            tx_data        <= 8'd0;
            arg_val        <= 32'd0;
            arg_nibble_count <= 4'd0;
            load_got_addr  <= 1'b0;
            load_addr      <= 10'd0;
            load_data      <= 32'd0;
            mem_got_addr   <= 1'b0;
            mem_addr       <= 10'd0;
            regs_index     <= 5'd0;
            trace_index    <= 3'd0;
            perf_val       <= 32'd0;
            esc_seq        <= 3'd0;
            hex_val_reg    <= 32'd0;
            hex_count      <= 4'd0;
            hex_prefix     <= 8'd0;
            hex_suffix     <= 8'd0;
        end else begin
            tx_start <= 1'b0;
            if (!tx_busy && (tx_rd_ptr != tx_wr_ptr)) begin
                tx_start <= 1'b1;
                tx_data  <= tx_buf[tx_rd_ptr];
                tx_rd_ptr <= tx_rd_ptr + 8'd1;
            end

            if (rx_valid) begin
                if (state == ST_PASSTHROUGH) begin
                    if (rx_data == "!") begin
                        esc_seq <= esc_seq + 3'd1;
                        if (esc_seq == 3'd2) begin
                            cpu_reset_n  <= 1'b0;
                            monitor_mode <= 1'b1;
                            state        <= ST_IDLE;
                            esc_seq      <= 3'd0;
                        end
                    end else begin
                        esc_seq <= 3'd0;
                    end
                end else if (rx_data == 8'h0A || rx_data == 8'h0D) begin
                    if (cmd_len > 0) state <= ST_PARSE;
                end else if (cmd_len < CMD_BUF_LEN - 1) begin
                    cmd_buf[cmd_len] <= rx_data;
                    cmd_len <= cmd_len + 7'd1;
                end
            end

            case (state)
                ST_IDLE: begin
                    cmd_len <= 7'd0;
                    cmd_ptr <= 7'd0;
                end

                ST_PARSE: begin
                    cmd_ptr <= 7'd0;
                    if ((cmd_buf[0] == "h" || cmd_buf[0] == "H") && (cmd_buf[1] == "e" || cmd_buf[1] == "E")) begin
                        state <= ST_EXEC_HELP;
                    end else if ((cmd_buf[0] == "l" || cmd_buf[0] == "L") && (cmd_buf[1] == "o" || cmd_buf[1] == "O")) begin
                        load_got_addr <= 1'b0; arg_val <= 32'd0; arg_nibble_count <= 4'd0; cmd_ptr <= 7'd5;
                        state <= ST_EXEC_LOAD;
                    end else if ((cmd_buf[0] == "r" || cmd_buf[0] == "R") && (cmd_buf[1] == "u" || cmd_buf[1] == "U")) begin
                        state <= ST_EXEC_RUN;
                    end else if ((cmd_buf[0] == "r" || cmd_buf[0] == "R") && (cmd_buf[1] == "e" || cmd_buf[1] == "E") && (cmd_buf[2] == "s" || cmd_buf[2] == "S")) begin
                        state <= ST_EXEC_RESET;
                    end else if ((cmd_buf[0] == "r" || cmd_buf[0] == "R") && (cmd_buf[1] == "e" || cmd_buf[1] == "E") && (cmd_buf[2] == "g" || cmd_buf[2] == "G")) begin
                        regs_index <= 5'd0;
                        state <= ST_EXEC_REGS_WAIT;
                    end else if ((cmd_buf[0] == "m" || cmd_buf[0] == "M") && (cmd_buf[1] == "e" || cmd_buf[1] == "E")) begin
                        arg_val <= 32'd0; cmd_ptr <= 7'd4;
                        state <= ST_EXEC_MEM_WAIT;
                    end else if ((cmd_buf[0] == "p" || cmd_buf[0] == "P") && (cmd_buf[1] == "e" || cmd_buf[1] == "E") && (cmd_buf[2] == "r" || cmd_buf[2] == "R")) begin
                        state <= ST_EXEC_PERF_SEND_1;
                    end else if ((cmd_buf[0] == "t" || cmd_buf[0] == "T") && (cmd_buf[1] == "r" || cmd_buf[1] == "R") && (cmd_buf[2] == "a" || cmd_buf[2] == "A")) begin
                        trace_index <= 3'd0; dbg_trace_sel <= 2'd0;
                        state <= ST_EXEC_TRACE_SEND;
                    end else begin
                        tx_buf[tx_wr_ptr] <= "?"; tx_wr_ptr <= tx_wr_ptr + 8'd1;
                        state <= ST_IDLE;
                    end
                end

                ST_EXEC_HELP: begin
                    tx_buf[tx_wr_ptr] <= "H"; tx_wr_ptr <= tx_wr_ptr + 8'd1;
                    state <= ST_IDLE;
                end

                ST_EXEC_LOAD: begin
                    if (cmd_ptr < cmd_len) begin
                        if (cmd_buf[cmd_ptr] == " " || cmd_buf[cmd_ptr] == 8'h09) begin
                            cmd_ptr <= cmd_ptr + 7'd1;
                        end else if (!load_got_addr) begin
                            arg_val <= {arg_val[27:0], hex_to_nibble(cmd_buf[cmd_ptr])};
                            arg_nibble_count <= arg_nibble_count + 4'd1;
                            cmd_ptr <= cmd_ptr + 7'd1;
                        end else begin
                            load_data <= {load_data[27:0], hex_to_nibble(cmd_buf[cmd_ptr])};
                            cmd_ptr <= cmd_ptr + 7'd1;
                        end
                    end else begin
                        if (!load_got_addr) begin
                            load_addr <= arg_val[9:0];
                            load_got_addr <= 1'b1;
                            arg_val <= 32'd0;
                            arg_nibble_count <= 4'd0;
                            cmd_ptr <= 7'd0;
                        end else begin
                            instr_load_en <= 1'b1;
                            instr_load_word_addr <= load_addr;
                            instr_load_data <= load_data;
                            state <= ST_IDLE;
                        end
                    end
                end

                ST_EXEC_RUN: begin
                    cpu_reset_n  <= 1'b1;
                    monitor_mode <= 1'b0;
                    esc_seq <= 3'd0;
                    tx_buf[tx_wr_ptr] <= "R"; tx_wr_ptr <= tx_wr_ptr + 8'd1;
                    state <= ST_PASSTHROUGH;
                end

                ST_EXEC_RESET: begin
                    cpu_reset_n  <= 1'b0;
                    monitor_mode <= 1'b1;
                    tx_buf[tx_wr_ptr] <= "S"; tx_wr_ptr <= tx_wr_ptr + 8'd1;
                    state <= ST_IDLE;
                end

                ST_EXEC_REGS_WAIT: begin
                    dbg_reg_addr <= regs_index;
                    state <= ST_EXEC_REGS_SEND;
                end

                ST_EXEC_REGS_SEND: begin
                    hex_prefix <= "X"; hex_suffix <= "\n";
                    hex_val_reg <= dbg_reg_data; hex_count <= 8;
                    if (regs_index == 5'd31) hex_return_state <= ST_IDLE;
                    else hex_return_state <= ST_EXEC_REGS_WAIT;
                    regs_index <= regs_index + 5'd1;
                    state <= ST_PRINT_HEX;
                end

                ST_EXEC_MEM_WAIT: begin
                    if (cmd_ptr < cmd_len) begin
                        if (cmd_buf[cmd_ptr] == " " || cmd_buf[cmd_ptr] == 8'h09) begin
                            cmd_ptr <= cmd_ptr + 7'd1;
                        end else begin
                            arg_val <= {arg_val[27:0], hex_to_nibble(cmd_buf[cmd_ptr])};
                            cmd_ptr <= cmd_ptr + 7'd1;
                        end
                    end else begin
                        mem_addr <= arg_val[11:2];
                        dbg_dmem_addr <= arg_val[11:2];
                        state <= ST_EXEC_MEM_SEND;
                    end
                end

                ST_EXEC_MEM_SEND: begin
                    hex_prefix <= "M"; hex_suffix <= "\n";
                    hex_val_reg <= dbg_dmem_data; hex_count <= 8;
                    hex_return_state <= ST_IDLE;
                    state <= ST_PRINT_HEX;
                end

                ST_EXEC_PERF_SEND_1: begin
                    hex_prefix <= "P"; hex_suffix <= " ";
                    hex_val_reg <= dbg_perf_cycle; hex_count <= 8;
                    hex_return_state <= ST_EXEC_PERF_SEND_2;
                    state <= ST_PRINT_HEX;
                end
                
                ST_EXEC_PERF_SEND_2: begin
                    hex_prefix <= " "; hex_suffix <= "\n";
                    hex_val_reg <= dbg_perf_instr; hex_count <= 8;
                    hex_return_state <= ST_IDLE;
                    state <= ST_PRINT_HEX;
                end

                ST_EXEC_TRACE_SEND: begin
                    if (trace_index < dbg_trace_count) begin
                        if (trace_index > 0) begin
                            if (dbg_trace_sel == 2'd0) dbg_trace_sel <= 2'd3;
                            else dbg_trace_sel <= dbg_trace_sel - 2'd1;
                        end
                        state <= ST_TRACE_NEXT_1;
                    end else begin
                        state <= ST_IDLE;
                    end
                end

                ST_TRACE_NEXT_1: begin
                    hex_prefix <= "T"; hex_suffix <= " ";
                    hex_val_reg <= dbg_trace_pc; hex_count <= 8;
                    hex_return_state <= ST_TRACE_NEXT_2;
                    state <= ST_PRINT_HEX;
                end

                ST_TRACE_NEXT_2: begin
                    hex_prefix <= " "; hex_suffix <= "\n";
                    hex_val_reg <= dbg_trace_instr; hex_count <= 8;
                    trace_index <= trace_index + 3'd1;
                    hex_return_state <= ST_EXEC_TRACE_SEND;
                    state <= ST_PRINT_HEX;
                end

                ST_PRINT_HEX: begin
                    if (hex_prefix != 8'd0) begin
                        tx_buf[tx_wr_ptr] <= hex_prefix;
                        tx_wr_ptr <= tx_wr_ptr + 8'd1;
                        hex_prefix <= 8'd0;
                    end else if (hex_count > 0) begin
                        tx_buf[tx_wr_ptr] <= nibble_to_hex(hex_val_reg[31:28]);
                        tx_wr_ptr <= tx_wr_ptr + 8'd1;
                        hex_val_reg <= {hex_val_reg[27:0], 4'd0};
                        hex_count <= hex_count - 4'd1;
                    end else if (hex_suffix != 8'd0) begin
                        tx_buf[tx_wr_ptr] <= hex_suffix;
                        tx_wr_ptr <= tx_wr_ptr + 8'd1;
                        hex_suffix <= 8'd0;
                    end else begin
                        state <= hex_return_state;
                    end
                end

                ST_PASSTHROUGH: begin
                    cmd_len <= 7'd0;
                end

                default: state <= ST_IDLE;
            endcase

            if (instr_load_en) instr_load_en <= 1'b0;
        end
    end
endmodule
