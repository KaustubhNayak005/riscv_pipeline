/*
 * Module: pwm
 * Description: Phase 12 MMIO PWM peripheral.
 *              Counter counts from 0 to PWM_PERIOD-1, then wraps.
 *              When enabled, pwm_out is high while counter < PWM_DUTY.
 *              When disabled, pwm_out is forced to the polarity-inactive level
 *              (0 if polarity=0, 1 if polarity=1).
 *              If PWM_DUTY > PWM_PERIOD: clamp — output stays permanently
 *              high (or low if polarity=1).
 *
 * Register map:
 *   0xD0000008 = PWM_PERIOD  (default reset: 1000)
 *   0xD000000C = PWM_DUTY    (default reset: 500)
 *   0xD0000010 = PWM_CTRL    (bit 0 = enable, bit 1 = polarity_invert)
 *                             default reset: 0x0
 */
module pwm (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] bus_addr,
    input  logic [31:0] bus_wdata,
    input  logic        bus_we,
    input  logic        bus_re,
    output logic [31:0] bus_rdata,
    output logic        bus_ready,
    output logic        pwm_out
);

    localparam logic [3:0] REG_PERIOD  = 4'h8;
    localparam logic [3:0] REG_DUTY    = 4'hC;
    localparam logic [3:0] REG_CTRL    = 4'h0;   // 0xD0000010 -> addr[3:0] = 0

    logic [31:0] period;
    logic [31:0] duty;
    logic        enable;
    logic        polarity;

    logic [31:0] counter;
    logic        duty_exceeded;
    logic        raw_high;

    assign duty_exceeded = duty > period;
    assign raw_high = duty_exceeded || (counter < duty);

    always_comb begin
        pwm_out = 1'b0;
        if (enable) begin
            pwm_out = polarity ? ~raw_high : raw_high;
        end else begin
            pwm_out = polarity;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            period   <= 32'd1000;
            duty     <= 32'd500;
            enable   <= 1'b0;
            polarity <= 1'b0;
            counter  <= 32'd0;
        end else begin
            if (bus_we) begin
                unique case (bus_addr[3:0])
                    REG_PERIOD: period   <= bus_wdata;
                    REG_DUTY:   duty     <= bus_wdata;
                    REG_CTRL: begin
                        enable   <= bus_wdata[0];
                        polarity <= bus_wdata[1];
                    end
                    default: ;
                endcase
            end

            if (enable) begin
                if (counter >= (period - 32'd1))
                    counter <= 32'd0;
                else
                    counter <= counter + 32'd1;
            end else begin
                counter <= 32'd0;
            end
        end
    end

    always_comb begin
        bus_rdata = 32'd0;
        if (bus_re) begin
            unique case (bus_addr[3:0])
                REG_PERIOD: bus_rdata = period;
                REG_DUTY:   bus_rdata = duty;
                REG_CTRL:   bus_rdata = {30'd0, polarity, enable};
                default:    bus_rdata = 32'd0;
            endcase
        end
    end

    assign bus_ready = 1'b1;

endmodule
