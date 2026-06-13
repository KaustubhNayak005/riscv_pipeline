/*
 * Module: wb_stage
 * Description: Write-back mux for selecting memory data or ALU result.
 * Inputs: mem_wb_alu_result, mem_wb_mem_read_data, mem_wb_rd, mem_wb_reg_write, mem_wb_mem_to_reg
 * Outputs: wb_write_data, wb_rd, wb_reg_write
 */
module wb_stage (
    input  logic [31:0] mem_wb_alu_result,
    input  logic [31:0] mem_wb_mem_read_data,
    input  logic [4:0]  mem_wb_rd,
    input  logic        mem_wb_reg_write,
    input  logic        mem_wb_mem_to_reg,
    output logic [31:0] wb_write_data,
    output logic [4:0]  wb_rd,
    output logic        wb_reg_write
);

    assign wb_write_data = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result;
    assign wb_rd = mem_wb_rd;
    assign wb_reg_write = mem_wb_reg_write;

endmodule
