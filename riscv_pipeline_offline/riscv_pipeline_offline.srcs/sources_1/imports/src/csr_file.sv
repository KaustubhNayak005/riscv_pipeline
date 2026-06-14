/*
 * Module: csr_file
 * Description: Machine-mode CSR register file for RV32I trap handling.
 *              Implements mstatus, mtvec, mepc, mcause with trap entry
 *              hardware write and MRET execution.
 *
 * CSR address map:
 *   0x300 = mstatus  (bit 3 = MIE)
 *   0x305 = mtvec    (trap handler base, lower 2 bits = mode)
 *   0x341 = mepc     (exception PC)
 *   0x342 = mcause   (trap cause)
 *
 * Trap causes (mcause):
 *   2  = illegal instruction
 *   11 = ECALL from M-mode
 *   Interrupt flag (bit 31) set for interrupts:
 *   0x80000007 = Machine timer interrupt
 */
module csr_file (
    input  logic        clk,
    input  logic        rst,
    // CSR read interface (combinational, used in ID stage)
    input  logic [11:0] csr_read_addr,
    output logic [31:0] csr_read_data,
    // CSR write interface (sequential, used in WB stage)
    input  logic        csr_write_en,
    input  logic [11:0] csr_write_addr,
    input  logic [31:0] csr_write_data,
    // Trap entry (hardware writes mepc/mcause on trap)
    input  logic        trap_taken,
    input  logic [31:0] trap_cause,
    input  logic [31:0] trap_pc,
    // MRET execution
    input  logic        mret_exec,
    // Outputs for PC redirect and interrupt control
    output logic [31:0] mepc,
    output logic [31:0] mtvec,
    output logic        mie
);

    localparam logic [11:0] CSR_MSTATUS = 12'h300;
    localparam logic [11:0] CSR_MTVEC   = 12'h305;
    localparam logic [11:0] CSR_MEPC    = 12'h341;
    localparam logic [11:0] CSR_MCAUSE  = 12'h342;

    localparam int MSTATUS_MIE_BIT = 3;

    logic [31:0] mstatus_reg;
    logic [31:0] mtvec_reg;
    logic [31:0] mepc_reg;
    logic [31:0] mcause_reg;

    assign mepc  = mepc_reg;
    assign mtvec = mtvec_reg;
    assign mie   = mstatus_reg[MSTATUS_MIE_BIT];

    // CSR read (combinational)
    always_comb begin
        csr_read_data = 32'd0;
        unique case (csr_read_addr)
            CSR_MSTATUS: csr_read_data = mstatus_reg;
            CSR_MTVEC:   csr_read_data = mtvec_reg;
            CSR_MEPC:    csr_read_data = mepc_reg;
            CSR_MCAUSE:  csr_read_data = mcause_reg;
            default:     csr_read_data = 32'd0;
        endcase
    end

    // CSR write and trap entry (sequential, at posedge clk)
    always_ff @(posedge clk) begin
        if (rst) begin
            mstatus_reg <= 32'd0;
            mtvec_reg   <= 32'd0;
            mepc_reg    <= 32'd0;
            mcause_reg  <= 32'd0;
        end else begin
            // MRET: restore MIE
            if (mret_exec) begin
                mstatus_reg[MSTATUS_MIE_BIT] <= 1'b1;
            end

            // CSR instruction write
            if (csr_write_en) begin
                unique case (csr_write_addr)
                    CSR_MSTATUS: mstatus_reg <= csr_write_data;
                    CSR_MTVEC:   mtvec_reg   <= csr_write_data;
                    CSR_MEPC:    mepc_reg    <= csr_write_data;
                    CSR_MCAUSE:  mcause_reg  <= csr_write_data;
                    default: ;
                endcase
            end

            // Trap entry: hardware writes mepc/mcause (last, overrides CSR write)
            if (trap_taken) begin
                mepc_reg    <= trap_pc;
                mcause_reg  <= trap_cause;
                mstatus_reg[MSTATUS_MIE_BIT] <= 1'b0;
            end
        end
    end

endmodule
