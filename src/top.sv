/*
 * Module: top
 * Description: Top-level 32-bit 5-stage pipelined RV32I processor. Instantiates
 *              fetch, decode, execute, memory, write-back, pipeline registers,
 *              hazard detection, forwarding, instruction memory, data memory,
 *              and register file through their stage modules.
 * Inputs: clk, rst
 * Outputs: optional debug trace for FPGA wrappers and external checkers
 */
(* keep_hierarchy = "yes" *)
module top (
    input  logic        clk,
    input  logic        rst,
    output logic [31:0] debug_pc_current,
    output logic        debug_wb_reg_write,
    output logic [4:0]  debug_wb_rd,
    output logic [31:0] debug_wb_write_data
);

    logic [31:0] pc_current;
    logic [31:0] if_pc;
    logic [31:0] if_instr;
    logic [31:0] if_id_pc;
    logic [31:0] if_id_instr;

    logic [31:0] id_pc;
    logic [31:0] id_rs1_data;
    logic [31:0] id_rs2_data;
    logic [31:0] id_imm;
    logic [4:0]  id_rs1;
    logic [4:0]  id_rs2;
    logic [4:0]  id_rd;
    logic [2:0]  id_funct3;
    logic [6:0]  id_opcode;
    logic [3:0]  id_alu_control;
    logic        id_reg_write;
    logic        id_mem_read;
    logic        id_mem_write;
    logic        id_mem_to_reg;
    logic        id_alu_src;
    logic        id_branch;
    logic        id_jump;

    logic [31:0] id_ex_pc;
    logic [31:0] id_ex_rs1_data;
    logic [31:0] id_ex_rs2_data;
    logic [31:0] id_ex_imm;
    logic [4:0]  id_ex_rs1;
    logic [4:0]  id_ex_rs2;
    logic [4:0]  id_ex_rd;
    logic [2:0]  id_ex_funct3;
    logic [6:0]  id_ex_opcode;
    logic [3:0]  id_ex_alu_control;
    logic        id_ex_reg_write;
    logic        id_ex_mem_read;
    logic        id_ex_mem_write;
    logic        id_ex_mem_to_reg;
    logic        id_ex_alu_src;
    logic        id_ex_branch;
    logic        id_ex_jump;

    logic [31:0] ex_alu_result;
    logic [31:0] ex_rs2_data;
    logic [31:0] ex_branch_target;
    logic [4:0]  ex_rd;
    logic        ex_branch_taken;
    logic        ex_reg_write;
    logic        ex_mem_read;
    logic        ex_mem_write;
    logic        ex_mem_to_reg;

    logic [31:0] ex_mem_alu_result;
    logic [31:0] ex_mem_rs2_data;
    logic [31:0] ex_mem_branch_target;
    logic [4:0]  ex_mem_rd;
    logic        ex_mem_branch_taken;
    logic        ex_mem_reg_write;
    logic        ex_mem_mem_read;
    logic        ex_mem_mem_write;
    logic        ex_mem_mem_to_reg;

    logic [31:0] mem_alu_result;
    logic [31:0] mem_read_data;
    logic [4:0]  mem_rd;
    logic        mem_reg_write;
    logic        mem_mem_to_reg;

    logic [31:0] mem_wb_alu_result;
    logic [31:0] mem_wb_mem_read_data;
    logic [4:0]  mem_wb_rd;
    logic        mem_wb_reg_write;
    logic        mem_wb_mem_to_reg;

    logic [31:0] wb_write_data;
    logic [4:0]  wb_rd;
    logic        wb_reg_write;

    logic        stall;
    logic        flush;
    logic        pc_sel;
    logic [31:0] branch_target;
    logic [1:0]  forward_a;
    logic [1:0]  forward_b;

    logic [4:0] if_id_rs1_for_hazard;
    logic [4:0] if_id_rs2_for_hazard;
    logic       if_id_uses_rs1;
    logic       if_id_uses_rs2;

    assign flush = pc_sel;

    always_comb begin
        unique case (if_id_instr[6:0])
            7'b0110011,
            7'b0100011,
            7'b1100011: begin
                if_id_uses_rs1 = 1'b1;
                if_id_uses_rs2 = 1'b1;
            end
            7'b0010011,
            7'b0000011,
            7'b1100111: begin
                if_id_uses_rs1 = 1'b1;
                if_id_uses_rs2 = 1'b0;
            end
            default: begin
                if_id_uses_rs1 = 1'b0;
                if_id_uses_rs2 = 1'b0;
            end
        endcase
    end

    assign if_id_rs1_for_hazard = if_id_uses_rs1 ? if_id_instr[19:15] : 5'd0;
    assign if_id_rs2_for_hazard = if_id_uses_rs2 ? if_id_instr[24:20] : 5'd0;

    (* DONT_TOUCH = "yes" *) if_stage u_if_stage (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .pc_sel(pc_sel),
        .branch_target(branch_target),
        .if_id_pc(if_pc),
        .if_id_instr(if_instr),
        .pc_current(pc_current)
    );

    (* DONT_TOUCH = "yes" *) if_id_reg u_if_id_reg (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .pc_in(if_pc),
        .instr_in(if_instr),
        .pc_out(if_id_pc),
        .instr_out(if_id_instr)
    );

    (* DONT_TOUCH = "yes" *) hazard_detection_unit u_hazard_detection_unit (
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .if_id_rs1(if_id_rs1_for_hazard),
        .if_id_rs2(if_id_rs2_for_hazard),
        .stall(stall)
    );

    (* DONT_TOUCH = "yes" *) id_stage u_id_stage (
        .clk(clk),
        .rst(rst),
        .if_id_instr(if_id_instr),
        .if_id_pc(if_id_pc),
        .flush(flush),
        .wb_reg_write(wb_reg_write),
        .wb_rd(wb_rd),
        .wb_write_data(wb_write_data),
        .id_ex_pc(id_pc),
        .id_ex_rs1_data(id_rs1_data),
        .id_ex_rs2_data(id_rs2_data),
        .id_ex_imm(id_imm),
        .id_ex_rs1(id_rs1),
        .id_ex_rs2(id_rs2),
        .id_ex_rd(id_rd),
        .id_ex_funct3(id_funct3),
        .id_ex_opcode(id_opcode),
        .id_ex_alu_control(id_alu_control),
        .id_ex_reg_write(id_reg_write),
        .id_ex_mem_read(id_mem_read),
        .id_ex_mem_write(id_mem_write),
        .id_ex_mem_to_reg(id_mem_to_reg),
        .id_ex_alu_src(id_alu_src),
        .id_ex_branch(id_branch),
        .id_ex_jump(id_jump)
    );

    (* DONT_TOUCH = "yes" *) id_ex_reg u_id_ex_reg (
        .clk(clk),
        .rst(rst),
        .stall(1'b0),
        .flush(flush || stall),
        .pc_in(id_pc),
        .rs1_data_in(id_rs1_data),
        .rs2_data_in(id_rs2_data),
        .imm_in(id_imm),
        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .rd_in(id_rd),
        .funct3_in(id_funct3),
        .opcode_in(id_opcode),
        .alu_control_in(id_alu_control),
        .reg_write_in(id_reg_write),
        .mem_read_in(id_mem_read),
        .mem_write_in(id_mem_write),
        .mem_to_reg_in(id_mem_to_reg),
        .alu_src_in(id_alu_src),
        .branch_in(id_branch),
        .jump_in(id_jump),
        .pc_out(id_ex_pc),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3),
        .opcode_out(id_ex_opcode),
        .alu_control_out(id_ex_alu_control),
        .reg_write_out(id_ex_reg_write),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .alu_src_out(id_ex_alu_src),
        .branch_out(id_ex_branch),
        .jump_out(id_ex_jump)
    );

    (* DONT_TOUCH = "yes" *) ex_stage u_ex_stage (
        .id_ex_pc(id_ex_pc),
        .id_ex_rs1_data(id_ex_rs1_data),
        .id_ex_rs2_data(id_ex_rs2_data),
        .id_ex_imm(id_ex_imm),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_funct3(id_ex_funct3),
        .id_ex_opcode(id_ex_opcode),
        .id_ex_alu_control(id_ex_alu_control),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_mem_to_reg(id_ex_mem_to_reg),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_branch(id_ex_branch),
        .id_ex_jump(id_ex_jump),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_write_data(wb_write_data),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .ex_mem_alu_result_in(ex_alu_result),
        .ex_mem_rs2_data_in(ex_rs2_data),
        .ex_mem_branch_target_in(ex_branch_target),
        .ex_mem_rd_in(ex_rd),
        .ex_mem_branch_taken_in(ex_branch_taken),
        .ex_mem_reg_write_in(ex_reg_write),
        .ex_mem_mem_read_in(ex_mem_read),
        .ex_mem_mem_write_in(ex_mem_write),
        .ex_mem_mem_to_reg_in(ex_mem_to_reg),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .pc_sel(pc_sel),
        .branch_target(branch_target)
    );

    (* DONT_TOUCH = "yes" *) ex_mem_reg u_ex_mem_reg (
        .clk(clk),
        .rst(rst),
        .stall(1'b0),
        .flush(1'b0),
        .alu_result_in(ex_alu_result),
        .rs2_data_in(ex_rs2_data),
        .branch_target_in(ex_branch_target),
        .rd_in(ex_rd),
        .branch_taken_in(ex_branch_taken),
        .reg_write_in(ex_reg_write),
        .mem_read_in(ex_mem_read),
        .mem_write_in(ex_mem_write),
        .mem_to_reg_in(ex_mem_to_reg),
        .alu_result_out(ex_mem_alu_result),
        .rs2_data_out(ex_mem_rs2_data),
        .branch_target_out(ex_mem_branch_target),
        .rd_out(ex_mem_rd),
        .branch_taken_out(ex_mem_branch_taken),
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg)
    );

    (* DONT_TOUCH = "yes" *) mem_stage u_mem_stage (
        .clk(clk),
        .rst(rst),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rs2_data(ex_mem_rs2_data),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_mem_to_reg(ex_mem_mem_to_reg),
        .mem_wb_alu_result_in(mem_alu_result),
        .mem_wb_mem_read_data_in(mem_read_data),
        .mem_wb_rd_in(mem_rd),
        .mem_wb_reg_write_in(mem_reg_write),
        .mem_wb_mem_to_reg_in(mem_mem_to_reg)
    );

    (* DONT_TOUCH = "yes" *) mem_wb_reg u_mem_wb_reg (
        .clk(clk),
        .rst(rst),
        .stall(1'b0),
        .flush(1'b0),
        .alu_result_in(mem_alu_result),
        .mem_read_data_in(mem_read_data),
        .rd_in(mem_rd),
        .reg_write_in(mem_reg_write),
        .mem_to_reg_in(mem_mem_to_reg),
        .alu_result_out(mem_wb_alu_result),
        .mem_read_data_out(mem_wb_mem_read_data),
        .rd_out(mem_wb_rd),
        .reg_write_out(mem_wb_reg_write),
        .mem_to_reg_out(mem_wb_mem_to_reg)
    );

    (* DONT_TOUCH = "yes" *) wb_stage u_wb_stage (
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_read_data(mem_wb_mem_read_data),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_mem_to_reg(mem_wb_mem_to_reg),
        .wb_write_data(wb_write_data),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write)
    );

    assign debug_pc_current = pc_current;
    assign debug_wb_reg_write = wb_reg_write;
    assign debug_wb_rd = wb_rd;
    assign debug_wb_write_data = wb_write_data;

endmodule
