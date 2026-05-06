/*
 * Module: if_stage
 * Description: Instruction fetch stage with program counter register and
 *              instruction-memory access.
 * Inputs: clk, rst, stall, pc_sel, branch_target
 * Outputs: if_id_pc, if_id_instr, pc_current
 */
module if_stage (
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,
    input  logic        pc_sel,
    input  logic [31:0] branch_target,
    output logic [31:0] if_id_pc,
    output logic [31:0] if_id_instr,
    output logic [31:0] pc_current
);

    logic [31:0] pc_next;

    assign if_id_pc = pc_current;
    assign pc_next = pc_sel ? branch_target : (pc_current + 32'd4);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_current <= 32'd0;
        end else if (!stall) begin
            pc_current <= pc_next;
        end
    end

    instr_mem u_instr_mem (
        .word_addr(pc_current[11:2]),
        .instr(if_id_instr)
    );

endmodule
