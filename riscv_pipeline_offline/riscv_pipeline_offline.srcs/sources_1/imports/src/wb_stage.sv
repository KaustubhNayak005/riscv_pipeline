/*
 * Module: wb_stage
 * Description: Write-back mux for selecting memory data or ALU result.
 *              Also drives CSR write data to the CSR file.
 * Inputs: mem_wb_alu_result, mem_wb_mem_read_data, mem_wb_rd, mem_wb_reg_write,
 *         mem_wb_mem_to_reg, CSR write signals
 * Outputs: wb_write_data, wb_rd, wb_reg_write, csr_write_en, csr_addr,
 *          csr_write_data
 */
module wb_stage (
    input  logic [31:0] mem_wb_alu_result,
    input  logic [31:0] mem_wb_mem_read_data,
    input  logic [4:0]  mem_wb_rd,
    input  logic        mem_wb_reg_write,
    input  logic        mem_wb_mem_to_reg,
    input  logic        mem_wb_is_csr_inst,
    input  logic        mem_wb_csr_write,
    input  logic [11:0] mem_wb_csr_addr,
    input  logic [31:0] mem_wb_csr_write_data,
    output logic [31:0] wb_write_data,
    output logic [4:0]  wb_rd,
    output logic        wb_reg_write,
    output logic        csr_write_en,
    output logic [11:0] csr_addr,
    output logic [31:0] csr_write_data
);

    assign wb_write_data = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result;
    assign wb_rd = mem_wb_rd;
    assign wb_reg_write = mem_wb_reg_write;

    assign csr_write_en   = mem_wb_is_csr_inst && mem_wb_csr_write;
    assign csr_addr       = mem_wb_csr_addr;
    assign csr_write_data = mem_wb_csr_write_data;

endmodule
