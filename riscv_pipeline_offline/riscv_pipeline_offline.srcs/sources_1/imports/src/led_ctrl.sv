/*
 * Module: led_ctrl
 * Description: Phase 12 MMIO LED control register.
 *              Address: 0xD0000000 (LED_CTRL)
 *              Bit [3:0] drives led_out. Bits [31:4] are zero/ignored.
 *              led_sw_ctrl is asserted whenever the register has been
 *              written at least once, switching LEDs from heartbeat
 *              mode to CPU-controlled mode.
 */
module led_ctrl (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] bus_addr,
    input  logic [31:0] bus_wdata,
    input  logic        bus_we,
    input  logic        bus_re,
    output logic [31:0] bus_rdata,
    output logic        bus_ready,
    output logic [3:0]  led_out,
    output logic        led_sw_ctrl
);

    logic [3:0]  led_reg;
    logic        ctrl_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            led_reg   <= 4'd0;
            ctrl_reg  <= 1'b0;
        end else begin
            if (bus_we) begin
                led_reg  <= bus_wdata[3:0];
                ctrl_reg <= 1'b1;
            end
        end
    end

    assign led_out     = led_reg;
    assign led_sw_ctrl = ctrl_reg;

    always_comb begin
        bus_rdata = 32'd0;
        if (bus_re)
            bus_rdata = {28'd0, led_reg};
    end

    assign bus_ready = 1'b1;

endmodule
