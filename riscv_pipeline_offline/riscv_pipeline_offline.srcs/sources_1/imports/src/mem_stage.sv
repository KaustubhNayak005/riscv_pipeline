/*
 * Module: mem_stage
 * Description: Memory access stage. Supports SRAM, UART MMIO, and
 *              read-only performance-counter MMIO.
 *
 *   Address decode:
 *     0x0... -> data_mem          (word address = alu_result[11:2])
 *     0x8... -> uart_peripheral   (register select = alu_result[3:0])
 *     0xC... -> perf counters     (register select = alu_result[3:2])
 *
 * Inputs: clk, rst, EX/MEM values and controls, perf counters, uart_rxd pin,
 *         dbg_dmem_addr
 * Outputs: MEM/WB candidate values and controls, uart_txd pin, dbg_dmem_data
 */
module mem_stage (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] ex_mem_alu_result,
    input  logic [31:0] ex_mem_rs2_data,
    input  logic [4:0]  ex_mem_rd,
    input  logic [2:0]  ex_mem_funct3,
    input  logic        ex_mem_reg_write,
    input  logic        ex_mem_mem_read,
    input  logic        ex_mem_mem_write,
    input  logic        ex_mem_mem_to_reg,
    output logic [31:0] mem_wb_alu_result_in,
    output logic [31:0] mem_wb_mem_read_data_in,
    output logic [4:0]  mem_wb_rd_in,
    output logic        mem_wb_reg_write_in,
    output logic        mem_wb_mem_to_reg_in,
    input  logic [31:0] perf_cycle_count,
    input  logic [31:0] perf_instr_count,
    input  logic [31:0] perf_stall_count,
    input  logic [31:0] perf_flush_count,
    input  logic [31:0] debug_pc_current,
    input  logic [31:0] debug_last_commit_pc,
    input  logic [31:0] debug_last_commit_instr,
    input  logic [31:0] debug_last_wb_data,
    input  logic [4:0]  debug_last_wb_rd,
    input  logic        debug_last_wb_reg_write,
    input  logic [31:0] debug_fault_pc,
    input  logic [31:0] debug_fault_instr,
    input  logic        debug_halt,
    input  logic        debug_illegal,
    input  logic        debug_stall,
    input  logic        debug_flush,
    input  logic        debug_pc_sel,
    input  logic        debug_commit_valid,
    input  logic [31:0] debug_commit_pc,
    input  logic [31:0] debug_commit_instr,
    input  logic [4:0]  debug_commit_rd,
    input  logic        debug_commit_reg_write,
    input  logic [31:0] debug_commit_wb_data,
    // UART physical pins
    input  logic        uart_rxd,
    output logic        uart_txd,
    // Debug read port for UART monitor
    input  logic [9:0]  dbg_dmem_addr,
    output logic [31:0] dbg_dmem_data,
    output logic [31:0] mon_trace_pc,
    output logic [31:0] mon_trace_instr,
    output logic [31:0] mon_trace_wb_data,
    output logic [31:0] mon_trace_status,
    output logic [2:0]  mon_trace_count,
    output logic [1:0]  mon_trace_head,
    input  logic [1:0]  mon_trace_sel
);

    // ------------------------------------------------------------------
    // Address decode
    // ------------------------------------------------------------------
    logic        ram_sel;
    logic        uart_sel;
    logic        perf_sel;
    logic        debug_sel;
    logic [31:0] perf_read_data;
    logic [31:0] debug_read_data;

    localparam int TRACE_DEPTH = 4;
    logic [31:0] trace_pc     [0:TRACE_DEPTH-1];
    logic [31:0] trace_instr   [0:TRACE_DEPTH-1];
    logic [31:0] trace_wb_data [0:TRACE_DEPTH-1];
    logic [31:0] trace_status  [0:TRACE_DEPTH-1];
    logic [1:0]  trace_head;
    logic [2:0]  trace_count;
    integer      trace_index;

    assign ram_sel  = (ex_mem_alu_result[31:28] == 4'h0);
    assign uart_sel = (ex_mem_alu_result[31:28] == 4'h8);
    assign perf_sel = (ex_mem_alu_result[31:28] == 4'hC);
    assign debug_sel = (ex_mem_alu_result[31:28] == 4'hC) &&
                       (ex_mem_alu_result[7:4] >= 4'h1);

    // Gate RAM enable signals so MMIO does not touch data memory.
    logic ram_mem_read;
    logic ram_mem_write;
    assign ram_mem_read  = ex_mem_mem_read  & ram_sel;
    assign ram_mem_write = ex_mem_mem_write & ram_sel;

    // ------------------------------------------------------------------
    // Debug trace buffer
    // ------------------------------------------------------------------
    // A tiny rotating history of recently committed instructions. Each entry
    // stores the retired PC, instruction, writeback data, and a compact status
    // word so the testbench can inspect execution history over MMIO.
    always_ff @(posedge clk) begin
        if (rst) begin
            trace_head  <= 2'd0;
            trace_count <= 3'd0;
            for (trace_index = 0; trace_index < TRACE_DEPTH; trace_index = trace_index + 1) begin
                trace_pc[trace_index]     <= 32'd0;
                trace_instr[trace_index]   <= 32'h00000013;
                trace_wb_data[trace_index] <= 32'd0;
                trace_status[trace_index]  <= 32'd0;
            end
        end else if (debug_commit_valid) begin
            trace_pc[trace_head]     <= debug_commit_pc;
            trace_instr[trace_head]   <= debug_commit_instr;
            trace_wb_data[trace_head] <= debug_commit_wb_data;
            trace_status[trace_head]  <= {
                15'd0,
                debug_pc_sel,
                debug_flush,
                debug_stall,
                debug_halt,
                debug_illegal,
                debug_commit_reg_write,
                debug_commit_valid,
                5'd0,
                debug_commit_rd
            };

            trace_head <= trace_head + 2'd1;
            if (trace_count != 3'd4)
                trace_count <= trace_count + 3'd1;
        end
    end

    // ------------------------------------------------------------------
    // Data SRAM
    // ------------------------------------------------------------------
    logic [31:0] ram_read_data;
    logic [31:0] ram_write_data;
    logic [3:0]  ram_byte_en;
    logic [7:0]  load_byte;
    logic [15:0] load_halfword;
    logic [31:0] ram_load_data;
    logic        ram_load_aligned;

    always_comb begin
        ram_write_data = ex_mem_rs2_data;
        ram_byte_en    = 4'b0000;

        if (ram_mem_write) begin
            unique case (ex_mem_funct3)
                3'b000: begin // SB
                    unique case (ex_mem_alu_result[1:0])
                        2'b00: begin
                            ram_byte_en = 4'b0001;
                            ram_write_data = {24'd0, ex_mem_rs2_data[7:0]};
                        end
                        2'b01: begin
                            ram_byte_en = 4'b0010;
                            ram_write_data = {16'd0, ex_mem_rs2_data[7:0], 8'd0};
                        end
                        2'b10: begin
                            ram_byte_en = 4'b0100;
                            ram_write_data = {8'd0, ex_mem_rs2_data[7:0], 16'd0};
                        end
                        2'b11: begin
                            ram_byte_en = 4'b1000;
                            ram_write_data = {ex_mem_rs2_data[7:0], 24'd0};
                        end
                        default: begin
                            ram_byte_en = 4'b0000;
                            ram_write_data = 32'd0;
                        end
                    endcase
                end

                3'b001: begin // SH, aligned halfwords only
                    unique case (ex_mem_alu_result[1:0])
                        2'b00: begin
                            ram_byte_en = 4'b0011;
                            ram_write_data = {16'd0, ex_mem_rs2_data[15:0]};
                        end
                        2'b10: begin
                            ram_byte_en = 4'b1100;
                            ram_write_data = {ex_mem_rs2_data[15:0], 16'd0};
                        end
                        default: begin
                            ram_byte_en = 4'b0000;
                            ram_write_data = 32'd0;
                        end
                    endcase
                end

                3'b010: begin // SW, aligned words only
                    if (ex_mem_alu_result[1:0] == 2'b00) begin
                        ram_byte_en = 4'b1111;
                        ram_write_data = ex_mem_rs2_data;
                    end
                end

                default: begin
                    ram_byte_en = 4'b0000;
                    ram_write_data = 32'd0;
                end
            endcase
        end
    end

    data_mem u_data_mem (
        .clk       (clk),
        .rst       (rst),
        .mem_read  (ram_mem_read),
        .mem_write (ram_mem_write),
        .byte_en   (ram_byte_en),
        .word_addr (ex_mem_alu_result[11:2]),
        .write_data(ram_write_data),
        .read_data (ram_read_data),
        .dbg_addr  (dbg_dmem_addr),
        .dbg_data  (dbg_dmem_data)
    );

    always_comb begin
        unique case (ex_mem_alu_result[1:0])
            2'b00: load_byte = ram_read_data[7:0];
            2'b01: load_byte = ram_read_data[15:8];
            2'b10: load_byte = ram_read_data[23:16];
            2'b11: load_byte = ram_read_data[31:24];
            default: load_byte = 8'd0;
        endcase

        unique case (ex_mem_alu_result[1])
            1'b0: load_halfword = ram_read_data[15:0];
            1'b1: load_halfword = ram_read_data[31:16];
            default: load_halfword = 16'd0;
        endcase

        unique case (ex_mem_funct3)
            3'b000,
            3'b100:  ram_load_aligned = 1'b1;                         // LB/LBU
            3'b001,
            3'b101:  ram_load_aligned = (ex_mem_alu_result[0] == 1'b0); // LH/LHU
            3'b010:  ram_load_aligned = (ex_mem_alu_result[1:0] == 2'b00); // LW
            default: ram_load_aligned = 1'b0;
        endcase

        ram_load_data = 32'd0;
        if (ram_mem_read && ram_load_aligned) begin
            unique case (ex_mem_funct3)
                3'b000:  ram_load_data = {{24{load_byte[7]}}, load_byte};         // LB
                3'b001:  ram_load_data = {{16{load_halfword[15]}}, load_halfword}; // LH
                3'b010:  ram_load_data = ram_read_data;                            // LW
                3'b100:  ram_load_data = {24'd0, load_byte};                       // LBU
                3'b101:  ram_load_data = {16'd0, load_halfword};                   // LHU
                default: ram_load_data = 32'd0;
            endcase
        end
    end

    // ------------------------------------------------------------------
    // UART peripheral
    // ------------------------------------------------------------------
    logic [31:0] uart_read_data;

    uart_peripheral #(.CLKS_PER_BIT(217)) u_uart (
        .clk       (clk),
        .rst       (rst),
        .uart_sel  (uart_sel),
        .mem_read  (ex_mem_mem_read),
        .mem_write (ex_mem_mem_write),
        .reg_addr  (ex_mem_alu_result[3:0]),
        .write_data(ex_mem_rs2_data),
        .read_data (uart_read_data),
        .uart_rxd  (uart_rxd),
        .uart_txd  (uart_txd)
    );

    // ------------------------------------------------------------------
    // Performance counter MMIO (read-only)
    // ------------------------------------------------------------------
    always_comb begin
        perf_read_data = 32'd0;
        if (perf_sel && ex_mem_mem_read) begin
            unique case (ex_mem_alu_result[3:2])
                2'b00:   perf_read_data = perf_cycle_count;
                2'b01:   perf_read_data = perf_instr_count;
                2'b10:   perf_read_data = perf_stall_count;
                2'b11:   perf_read_data = perf_flush_count;
                default: perf_read_data = 32'd0;
            endcase
        end
    end

    always_comb begin
        debug_read_data = 32'd0;
        if (debug_sel && ex_mem_mem_read) begin
            unique case (ex_mem_alu_result[7:4])
                4'h1: begin
                    unique case (ex_mem_alu_result[3:2])
                        2'b00: debug_read_data = debug_pc_current;
                        2'b01: debug_read_data = debug_last_commit_pc;
                        2'b10: debug_read_data = debug_last_commit_instr;
                        2'b11: debug_read_data = debug_last_wb_data;
                    endcase
                end

                4'h2: begin
                    unique case (ex_mem_alu_result[3:2])
                        2'b00: debug_read_data = {26'd0, debug_last_wb_reg_write, debug_last_wb_rd};
                        2'b01: debug_read_data = debug_fault_pc;
                        2'b10: debug_read_data = debug_fault_instr;
                        2'b11: debug_read_data = {
                            20'd0,
                            debug_halt,
                            debug_illegal,
                            debug_stall,
                            debug_flush,
                            debug_pc_sel,
                            debug_commit_valid,
                            debug_last_wb_reg_write,
                            debug_last_wb_rd
                        };
                    endcase
                end

                4'h3: begin
                    unique case (ex_mem_alu_result[3:2])
                        2'b00: debug_read_data = {27'd0, trace_count, trace_head};
                        2'b01: debug_read_data = {25'd0, debug_commit_valid, debug_last_wb_reg_write, debug_last_wb_rd};
                        2'b10: debug_read_data = {
                            20'd0,
                            debug_halt,
                            debug_illegal,
                            debug_stall,
                            debug_flush,
                            debug_pc_sel,
                            debug_commit_valid,
                            debug_last_wb_reg_write,
                            debug_last_wb_rd
                        };
                        2'b11: debug_read_data = 32'd0;
                    endcase
                end

                4'h4,
                4'h5,
                4'h6,
                4'h7: begin
                    unique case (ex_mem_alu_result[3:2])
                        2'b00: debug_read_data = trace_pc[ex_mem_alu_result[5:4]];
                        2'b01: debug_read_data = trace_instr[ex_mem_alu_result[5:4]];
                        2'b10: debug_read_data = trace_wb_data[ex_mem_alu_result[5:4]];
                        2'b11: debug_read_data = trace_status[ex_mem_alu_result[5:4]];
                    endcase
                end
            endcase
        end
    end

    // ------------------------------------------------------------------
    // Read-data mux: select MMIO or SRAM based on address
    // ------------------------------------------------------------------
    always_comb begin
        mem_wb_mem_read_data_in = 32'd0;
        if (debug_sel) begin
            mem_wb_mem_read_data_in = debug_read_data;
        end else if (uart_sel) begin
            mem_wb_mem_read_data_in = uart_read_data;
        end else if (perf_sel) begin
            mem_wb_mem_read_data_in = perf_read_data;
        end else if (ram_sel) begin
            mem_wb_mem_read_data_in = ram_load_data;
        end
    end

    // Pass-through signals
    assign mem_wb_alu_result_in = ex_mem_alu_result;
    assign mem_wb_rd_in         = ex_mem_rd;
    assign mem_wb_reg_write_in  = ex_mem_reg_write;
    assign mem_wb_mem_to_reg_in = ex_mem_mem_to_reg;

    // Trace readback for UART monitor
    assign mon_trace_pc     = trace_pc[mon_trace_sel];
    assign mon_trace_instr   = trace_instr[mon_trace_sel];
    assign mon_trace_wb_data = trace_wb_data[mon_trace_sel];
    assign mon_trace_status  = trace_status[mon_trace_sel];
    assign mon_trace_count   = trace_count;
    assign mon_trace_head    = trace_head;

endmodule
