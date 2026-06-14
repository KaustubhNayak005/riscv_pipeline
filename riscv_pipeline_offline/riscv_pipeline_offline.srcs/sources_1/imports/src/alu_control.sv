/*
 * Module: alu_control
 * Description: Decodes control-unit ALU operation class and instruction fields
 *              into a concrete ALU operation.
 * Inputs: alu_op, funct3, funct7_bit5
 * Outputs: alu_ctrl
 */
module alu_control (
    input  logic [3:0] alu_op,
    input  logic [2:0] funct3,
    input  logic       funct7_bit5,
    input  logic       funct7_bit0,
    output logic [3:0] alu_ctrl
);

    localparam logic [3:0] ALU_OP_ADD    = 4'b0000;
    localparam logic [3:0] ALU_OP_BRANCH = 4'b0001;
    localparam logic [3:0] ALU_OP_RTYPE  = 4'b0010;
    localparam logic [3:0] ALU_OP_ITYPE  = 4'b0011;

    always_comb begin
        alu_ctrl = 4'b0000;

        unique case (alu_op)
            ALU_OP_ADD: begin
                alu_ctrl = 4'b0000;
            end

            ALU_OP_BRANCH: begin
                alu_ctrl = 4'b0001;
            end

            ALU_OP_RTYPE: begin
                if (funct7_bit0) begin
                    unique case (funct3)
                        3'b000: alu_ctrl = 4'b1010; // MUL
                        3'b001: alu_ctrl = 4'b1011; // MULH
                        3'b010: alu_ctrl = 4'b1100; // MULHSU
                        3'b011: alu_ctrl = 4'b1101; // MULHU
                        default: alu_ctrl = 4'b0000;
                    endcase
                end else begin
                    unique case (funct3)
                        3'b000: alu_ctrl = funct7_bit5 ? 4'b0001 : 4'b0000;
                        3'b001: alu_ctrl = 4'b0101;
                        3'b010: alu_ctrl = 4'b1000;
                        3'b011: alu_ctrl = 4'b1001;
                        3'b100: alu_ctrl = 4'b0100;
                        3'b101: alu_ctrl = funct7_bit5 ? 4'b0111 : 4'b0110;
                        3'b110: alu_ctrl = 4'b0011;
                        3'b111: alu_ctrl = 4'b0010;
                        default: alu_ctrl = 4'b0000;
                    endcase
                end
            end

            ALU_OP_ITYPE: begin
                unique case (funct3)
                    3'b000: alu_ctrl = 4'b0000;
                    3'b001: alu_ctrl = 4'b0101;
                    3'b010: alu_ctrl = 4'b1000;
                    3'b011: alu_ctrl = 4'b1001;
                    3'b100: alu_ctrl = 4'b0100;
                    3'b101: alu_ctrl = funct7_bit5 ? 4'b0111 : 4'b0110;
                    3'b110: alu_ctrl = 4'b0011;
                    3'b111: alu_ctrl = 4'b0010;
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            default: begin
                alu_ctrl = 4'b0000;
            end
        endcase
    end

endmodule
