/*
 * Module: timer
 * Description: Memory-mapped timer peripheral with interrupt generation.
 *              Address space: 0xC0000200 region
 *
 * Register map:
 *   0xC0000200 = mtime (32-bit free-running counter, read/write)
 *   0xC0000204 = mtimecmp (compare value, read/write)
 *   0xC0000208 = timer_ctrl (control register: bit 0 = enable, bit 1 = pending)
 *
 * Interrupt: asserted when mtime >= mtimecmp and timer is enabled.
 * Clear interrupt by writing 0 to control bit 1 (write-1-to-clear).
 */
module timer (
    input  logic        clk,
    input  logic        rst,
    // MMIO interface
    input  logic        timer_sel,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [3:0]  reg_addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data,
    output logic        timer_irq
);

    localparam logic [3:0] REG_MTIME    = 4'h0;
    localparam logic [3:0] REG_MTIMECMP = 4'h4;
    localparam logic [3:0] REG_CTRL     = 4'h8;

    logic [31:0] mtime;
    logic [31:0] mtimecmp;
    logic [1:0]  ctrl;

    assign timer_irq = ctrl[0] && (mtime >= mtimecmp);

    // Free-running mtime counter (increments every cycle)
    always_ff @(posedge clk) begin
        if (rst) begin
            mtime    <= 32'd0;
            mtimecmp <= 32'd0;
            ctrl     <= 2'b00;
        end else begin
            mtime <= mtime + 32'd1;

            if (mem_write && timer_sel) begin
                unique case (reg_addr)
                    REG_MTIME:
                        mtime <= write_data;
                    REG_MTIMECMP:
                        mtimecmp <= write_data;
                    REG_CTRL: begin
                        ctrl[0] <= write_data[0];
                        ctrl[1] <= ctrl[1] && !write_data[1]; // write-1-to-clear
                    end
                    default: ;
                endcase
            end else if (timer_irq) begin
                // Auto-set pending bit when IRQ fires
                ctrl[1] <= 1'b1;
            end
        end
    end

    always_comb begin
        read_data = 32'd0;
        if (mem_read && timer_sel) begin
            unique case (reg_addr)
                REG_MTIME:    read_data = mtime;
                REG_MTIMECMP: read_data = mtimecmp;
                REG_CTRL:     read_data = {30'd0, ctrl};
                default:      read_data = 32'd0;
            endcase
        end
    end

endmodule
