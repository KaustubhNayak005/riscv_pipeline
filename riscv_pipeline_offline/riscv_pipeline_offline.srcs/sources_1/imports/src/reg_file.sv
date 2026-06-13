/*
 * Module: reg_file
 * Description: 32 x 32-bit register file. Register x0 is hardwired to zero.
 *              dbg_addr/dbg_data provide an async debug read port for the
 *              UART monitor.
 * Inputs: clk, rst, reg_write, rs1, rs2, rd, write_data, dbg_addr
 * Outputs: rs1_data, rs2_data, dbg_data
 */
module reg_file (
    input  logic        clk,
    input  logic        rst,
    input  logic        reg_write,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    input  logic [4:0]  dbg_addr,
    output logic [31:0] dbg_data
);

    (* DONT_TOUCH = "yes" *)
    logic [31:0] regs [0:31];

    integer i;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end else begin
            if (reg_write && (rd != 5'd0)) begin
                regs[rd] <= write_data;
            end
            regs[0] <= 32'd0;
        end
    end

    assign rs1_data = (rs1 == 5'd0) ? 32'd0 :
                      ((reg_write && (rd == rs1) && (rd != 5'd0)) ? write_data : regs[rs1]);
    assign rs2_data = (rs2 == 5'd0) ? 32'd0 :
                      ((reg_write && (rd == rs2) && (rd != 5'd0)) ? write_data : regs[rs2]);

    assign dbg_data = (dbg_addr == 5'd0) ? 32'd0 : regs[dbg_addr];

endmodule
