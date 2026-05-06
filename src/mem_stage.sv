/*
 * Module: mem_stage
 * Description: Memory access stage with internal data memory instance.
 * Inputs: clk, rst, EX/MEM values and controls
 * Outputs: MEM/WB candidate values and controls
 */
module mem_stage (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] ex_mem_alu_result,
    input  logic [31:0] ex_mem_rs2_data,
    input  logic [4:0]  ex_mem_rd,
    input  logic        ex_mem_reg_write,
    input  logic        ex_mem_mem_read,
    input  logic        ex_mem_mem_write,
    input  logic        ex_mem_mem_to_reg,
    output logic [31:0] mem_wb_alu_result_in,
    output logic [31:0] mem_wb_mem_read_data_in,
    output logic [4:0]  mem_wb_rd_in,
    output logic        mem_wb_reg_write_in,
    output logic        mem_wb_mem_to_reg_in
);

    data_mem u_data_mem (
        .clk(clk),
        .rst(rst),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .word_addr(ex_mem_alu_result[11:2]),
        .write_data(ex_mem_rs2_data),
        .read_data(mem_wb_mem_read_data_in)
    );

    assign mem_wb_alu_result_in = ex_mem_alu_result;
    assign mem_wb_rd_in = ex_mem_rd;
    assign mem_wb_reg_write_in = ex_mem_reg_write;
    assign mem_wb_mem_to_reg_in = ex_mem_mem_to_reg;

endmodule
