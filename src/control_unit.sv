/*
 * Module: control_unit
 * Description: RV32I subset main decoder. Produces pipeline control signals
 *              and an ALU operation class from opcode/funct fields.
 * Inputs: opcode, funct3, funct7_bit5
 * Outputs: reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch, jump, alu_op
 */
module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       funct7_bit5,
    output logic       reg_write,
    output logic       mem_read,
    output logic       mem_write,
    output logic       mem_to_reg,
    output logic       alu_src,
    output logic       branch,
    output logic       jump,
    output logic [3:0] alu_op
);

    localparam logic [6:0] OPCODE_RTYPE  = 7'b0110011;
    localparam logic [6:0] OPCODE_ITYPE  = 7'b0010011;
    localparam logic [6:0] OPCODE_LOAD   = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_JALR   = 7'b1100111;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;

    localparam logic [3:0] ALU_OP_ADD    = 4'b0000;
    localparam logic [3:0] ALU_OP_BRANCH = 4'b0001;
    localparam logic [3:0] ALU_OP_RTYPE  = 4'b0010;
    localparam logic [3:0] ALU_OP_ITYPE  = 4'b0011;

    always_comb begin
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        alu_src   = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        alu_op    = ALU_OP_ADD;

        unique case (opcode)
            OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_op    = ALU_OP_RTYPE;
            end

            OPCODE_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_ITYPE;
            end

            OPCODE_LOAD: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                mem_to_reg = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_ADD;
            end

            OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_ADD;
            end

            OPCODE_BRANCH: begin
                branch    = 1'b1;
                alu_op    = ALU_OP_BRANCH;
            end

            OPCODE_JAL,
            OPCODE_JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_ADD;
            end

            OPCODE_LUI,
            OPCODE_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_ADD;
            end

            default: begin
                reg_write = 1'b0;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_src   = 1'b0;
                branch    = 1'b0;
                jump      = 1'b0;
                alu_op    = ALU_OP_ADD;
            end
        endcase
    end

endmodule
