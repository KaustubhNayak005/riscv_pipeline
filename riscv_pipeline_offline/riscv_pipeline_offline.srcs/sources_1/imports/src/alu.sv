/*
 * Module: alu
 * Description: 32-bit RV32I arithmetic logic unit.
 * Inputs: alu_ctrl, operand_a, operand_b
 * Outputs: result, zero
 */
module alu (
    input  logic [3:0]  alu_ctrl,
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] result,
    output logic        zero
);

    logic signed [63:0] mul_ss;
    logic signed [63:0] mul_su;
    logic        [63:0] mul_uu;

    assign mul_ss = $signed(operand_a) * $signed(operand_b);
    assign mul_su = $signed(operand_a) * $signed({1'b0, operand_b});
    assign mul_uu = operand_a * operand_b;

    always_comb begin
        unique case (alu_ctrl)
            4'b0000: result = operand_a + operand_b;
            4'b0001: result = operand_a - operand_b;
            4'b0010: result = operand_a & operand_b;
            4'b0011: result = operand_a | operand_b;
            4'b0100: result = operand_a ^ operand_b;
            4'b0101: result = operand_a << operand_b[4:0];
            4'b0110: result = operand_a >> operand_b[4:0];
            4'b0111: result = $signed(operand_a) >>> operand_b[4:0];
            4'b1000: result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
            4'b1001: result = (operand_a < operand_b) ? 32'd1 : 32'd0;
            4'b1010: result = mul_ss[31:0];   // MUL
            4'b1011: result = mul_ss[63:32];  // MULH
            4'b1100: result = mul_su[63:32];  // MULHSU
            4'b1101: result = mul_uu[63:32];  // MULHU
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);

endmodule
