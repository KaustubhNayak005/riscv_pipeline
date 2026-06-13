/*
 * Module: ex_stage
 * Description: Execute stage with operand forwarding, ALU operation, branch
 *              condition evaluation, and jump target generation.
 * Inputs: ID/EX values, EX/MEM forwarding source, MEM/WB forwarding source
 * Outputs: EX/MEM candidate values, branch redirect, forwarding selects
 */
module ex_stage (
    input  logic [31:0] id_ex_pc,
    input  logic [31:0] id_ex_rs1_data,
    input  logic [31:0] id_ex_rs2_data,
    input  logic [31:0] id_ex_imm,
    input  logic [4:0]  id_ex_rs1,
    input  logic [4:0]  id_ex_rs2,
    input  logic [4:0]  id_ex_rd,
    input  logic [2:0]  id_ex_funct3,
    input  logic [6:0]  id_ex_opcode,
    input  logic [3:0]  id_ex_alu_control,
    input  logic        id_ex_reg_write,
    input  logic        id_ex_mem_read,
    input  logic        id_ex_mem_write,
    input  logic        id_ex_mem_to_reg,
    input  logic        id_ex_alu_src,
    input  logic        id_ex_branch,
    input  logic        id_ex_jump,
    input  logic [31:0] ex_mem_alu_result,
    input  logic [4:0]  ex_mem_rd,
    input  logic        ex_mem_reg_write,
    input  logic [31:0] mem_wb_write_data,
    input  logic [4:0]  mem_wb_rd,
    input  logic        mem_wb_reg_write,
    output logic [31:0] ex_mem_alu_result_in,
    output logic [31:0] ex_mem_rs2_data_in,
    output logic [31:0] ex_mem_branch_target_in,
    output logic [4:0]  ex_mem_rd_in,
    output logic [2:0]  ex_mem_funct3_in,
    output logic        ex_mem_branch_taken_in,
    output logic        ex_mem_reg_write_in,
    output logic        ex_mem_mem_read_in,
    output logic        ex_mem_mem_write_in,
    output logic        ex_mem_mem_to_reg_in,
    output logic [1:0]  forward_a,
    output logic [1:0]  forward_b,
    output logic        pc_sel,
    output logic [31:0] branch_target
);

    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_JALR   = 7'b1100111;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;

    logic [31:0] operand_a_forwarded;
    logic [31:0] operand_b_forwarded;
    logic [31:0] operand_b_selected;
    logic [31:0] alu_result_raw;
    logic        alu_zero;
    logic        branch_condition_met;

    forwarding_unit u_forwarding_unit (
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    always_comb begin
        unique case (forward_a)
            2'b10: operand_a_forwarded = ex_mem_alu_result;
            2'b01: operand_a_forwarded = mem_wb_write_data;
            default: operand_a_forwarded = id_ex_rs1_data;
        endcase

        unique case (forward_b)
            2'b10: operand_b_forwarded = ex_mem_alu_result;
            2'b01: operand_b_forwarded = mem_wb_write_data;
            default: operand_b_forwarded = id_ex_rs2_data;
        endcase
    end

    assign operand_b_selected = id_ex_alu_src ? id_ex_imm : operand_b_forwarded;

    alu u_alu (
        .alu_ctrl(id_ex_alu_control),
        .operand_a(operand_a_forwarded),
        .operand_b(operand_b_selected),
        .result(alu_result_raw),
        .zero(alu_zero)
    );

    always_comb begin
        unique case (id_ex_funct3)
            3'b000: branch_condition_met = (operand_a_forwarded == operand_b_forwarded);
            3'b001: branch_condition_met = (operand_a_forwarded != operand_b_forwarded);
            3'b100: branch_condition_met = ($signed(operand_a_forwarded) < $signed(operand_b_forwarded));
            3'b101: branch_condition_met = ($signed(operand_a_forwarded) >= $signed(operand_b_forwarded));
            3'b110: branch_condition_met = (operand_a_forwarded < operand_b_forwarded);
            3'b111: branch_condition_met = (operand_a_forwarded >= operand_b_forwarded);
            default: branch_condition_met = 1'b0;
        endcase
    end

    always_comb begin
        ex_mem_branch_target_in = id_ex_pc + id_ex_imm;

        if (id_ex_opcode == OPCODE_JALR) begin
            ex_mem_branch_target_in = (operand_a_forwarded + id_ex_imm) & 32'hFFFF_FFFE;
        end

        ex_mem_branch_taken_in = (id_ex_branch && branch_condition_met) || id_ex_jump;
        pc_sel = ex_mem_branch_taken_in;
        branch_target = ex_mem_branch_target_in;

        unique case (id_ex_opcode)
            OPCODE_LUI:   ex_mem_alu_result_in = id_ex_imm;
            OPCODE_AUIPC: ex_mem_alu_result_in = id_ex_pc + id_ex_imm;
            OPCODE_JAL,
            OPCODE_JALR:  ex_mem_alu_result_in = id_ex_pc + 32'd4;
            default:      ex_mem_alu_result_in = alu_result_raw;
        endcase

        ex_mem_rs2_data_in   = operand_b_forwarded;
        ex_mem_rd_in         = id_ex_rd;
        ex_mem_funct3_in     = id_ex_funct3;
        ex_mem_reg_write_in  = id_ex_reg_write;
        ex_mem_mem_read_in   = id_ex_mem_read;
        ex_mem_mem_write_in  = id_ex_mem_write;
        ex_mem_mem_to_reg_in = id_ex_mem_to_reg;
    end

endmodule
