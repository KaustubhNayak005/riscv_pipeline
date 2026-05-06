/*
 * Module: id_stage
 * Description: Instruction decode, immediate generation, control decode, and
 *              register-file read stage.
 * Inputs: clk, rst, if_id_instr, if_id_pc, flush, wb write-back interface
 * Outputs: decoded values and controls for the ID/EX register
 */
module id_stage (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] if_id_instr,
    input  logic [31:0] if_id_pc,
    input  logic        flush,
    input  logic        wb_reg_write,
    input  logic [4:0]  wb_rd,
    input  logic [31:0] wb_write_data,
    output logic [31:0] id_ex_pc,
    output logic [31:0] id_ex_rs1_data,
    output logic [31:0] id_ex_rs2_data,
    output logic [31:0] id_ex_imm,
    output logic [4:0]  id_ex_rs1,
    output logic [4:0]  id_ex_rs2,
    output logic [4:0]  id_ex_rd,
    output logic [2:0]  id_ex_funct3,
    output logic [6:0]  id_ex_opcode,
    output logic [3:0]  id_ex_alu_control,
    output logic        id_ex_reg_write,
    output logic        id_ex_mem_read,
    output logic        id_ex_mem_write,
    output logic        id_ex_mem_to_reg,
    output logic        id_ex_alu_src,
    output logic        id_ex_branch,
    output logic        id_ex_jump
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_bit5;
    logic [3:0] alu_op;
    logic       reg_write_dec;
    logic       mem_read_dec;
    logic       mem_write_dec;
    logic       mem_to_reg_dec;
    logic       alu_src_dec;
    logic       branch_dec;
    logic       jump_dec;
    logic [31:0] imm_dec;
    logic [3:0] alu_control_dec;

    assign opcode      = if_id_instr[6:0];
    assign id_ex_rd    = if_id_instr[11:7];
    assign funct3      = if_id_instr[14:12];
    assign id_ex_rs1   = if_id_instr[19:15];
    assign id_ex_rs2   = if_id_instr[24:20];
    assign funct7_bit5 = if_id_instr[30];

    assign id_ex_pc     = if_id_pc;
    assign id_ex_imm    = imm_dec;
    assign id_ex_funct3 = funct3;
    assign id_ex_opcode = opcode;

    control_unit u_control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_bit5(funct7_bit5),
        .reg_write(reg_write_dec),
        .mem_read(mem_read_dec),
        .mem_write(mem_write_dec),
        .mem_to_reg(mem_to_reg_dec),
        .alu_src(alu_src_dec),
        .branch(branch_dec),
        .jump(jump_dec),
        .alu_op(alu_op)
    );

    alu_control u_alu_control (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_bit5(funct7_bit5),
        .alu_ctrl(alu_control_dec)
    );

    imm_gen u_imm_gen (
        .instr(if_id_instr),
        .imm(imm_dec)
    );

    reg_file u_reg_file (
        .clk(clk),
        .rst(rst),
        .reg_write(wb_reg_write),
        .rs1(id_ex_rs1),
        .rs2(id_ex_rs2),
        .rd(wb_rd),
        .write_data(wb_write_data),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data)
    );

    always_comb begin
        if (rst || flush) begin
            id_ex_alu_control = 4'd0;
            id_ex_reg_write   = 1'b0;
            id_ex_mem_read    = 1'b0;
            id_ex_mem_write   = 1'b0;
            id_ex_mem_to_reg  = 1'b0;
            id_ex_alu_src     = 1'b0;
            id_ex_branch      = 1'b0;
            id_ex_jump        = 1'b0;
        end else begin
            id_ex_alu_control = alu_control_dec;
            id_ex_reg_write   = reg_write_dec;
            id_ex_mem_read    = mem_read_dec;
            id_ex_mem_write   = mem_write_dec;
            id_ex_mem_to_reg  = mem_to_reg_dec;
            id_ex_alu_src     = alu_src_dec;
            id_ex_branch      = branch_dec;
            id_ex_jump        = jump_dec;
        end
    end

endmodule
