/*
 * Module: data_mem
 * Description: 1024-word data memory with word-aligned addressing,
 *              synchronous write, asynchronous read, and synchronous reset.
 * Inputs: clk, rst, mem_read, mem_write, word_addr, write_data
 * Outputs: read_data
 */
module data_mem (
    input  logic        clk,
    input  logic        rst,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [9:0]  word_addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
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
            memory[word_addr] <= write_data;
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
            memory[word_addr] <= write_data;
        end
    end
`endif

    assign read_data = mem_read ? memory[word_addr] : 32'd0;

endmodule
