/*
 * Module: data_mem
 * Description: 1024-word data memory with word-aligned addressing,
 *              byte-write enables, asynchronous read, and synchronous reset
 *              in simulation.
 *              dbg_addr/dbg_data provide an async debug read port for the
 *              UART monitor.
 * Inputs: clk, rst, mem_read, mem_write, byte_en, word_addr, write_data, dbg_addr
 * Outputs: read_data, dbg_data
 */
module data_mem (
    input  logic        clk,
    input  logic        rst,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [3:0]  byte_en,
    input  logic [9:0]  word_addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data,
    input  logic [9:0]  dbg_addr,
    output logic [31:0] dbg_data
);

    logic [31:0] memory [0:1023];
    integer i;

`ifndef SYNTHESIS
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 32'd0;
            end
        end else if (mem_write) begin
            if (byte_en[0]) memory[word_addr][7:0]   <= write_data[7:0];
            if (byte_en[1]) memory[word_addr][15:8]  <= write_data[15:8];
            if (byte_en[2]) memory[word_addr][23:16] <= write_data[23:16];
            if (byte_en[3]) memory[word_addr][31:24] <= write_data[31:24];
        end
    end
`else
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'd0;
        end
    end

    always_ff @(posedge clk) begin
        if (mem_write) begin
            if (byte_en[0]) memory[word_addr][7:0]   <= write_data[7:0];
            if (byte_en[1]) memory[word_addr][15:8]  <= write_data[15:8];
            if (byte_en[2]) memory[word_addr][23:16] <= write_data[23:16];
            if (byte_en[3]) memory[word_addr][31:24] <= write_data[31:24];
        end
    end
`endif

    assign read_data = mem_read ? memory[word_addr] : 32'd0;
    assign dbg_data  = memory[dbg_addr];

endmodule
