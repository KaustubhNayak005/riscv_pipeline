/*
 * Module: forwarding_unit
 * Description: Generates forwarding mux selects for EX-stage operands.
 * Inputs: ex_mem_rd, mem_wb_rd, ex_mem_reg_write, mem_wb_reg_write, id_ex_rs1, id_ex_rs2
 * Outputs: forward_a, forward_b
 */
module forwarding_unit (
    input  logic [4:0] ex_mem_rd,
    input  logic [4:0] mem_wb_rd,
    input  logic       ex_mem_reg_write,
    input  logic       mem_wb_reg_write,
    input  logic [4:0] id_ex_rs1,
    input  logic [4:0] id_ex_rs2,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01;
        end

        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01;
        end
    end

endmodule
