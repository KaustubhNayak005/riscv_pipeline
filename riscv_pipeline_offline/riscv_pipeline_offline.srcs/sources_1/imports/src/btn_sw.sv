/*
 * Module: btn_sw
 * Description: Phase 12 MMIO button/switch input register.
 *              Address: 0xD0000004 (BTN_SW)
 *              Bits [1:0] = debounced raw_btn[1:0]
 *              Bits [3:2] = synchronized raw_sw[1:0]
 *              Bits [31:4] = 0
 *              Writes are silently ignored.
 *              raw_btn[0] is tied to 0 in fpga_top (BTN0 reserved for rst).
 *              Debounce depth: 20 cycles minimum stable value before latching.
 */
module btn_sw (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] bus_addr,
    input  logic        bus_re,
    output logic [31:0] bus_rdata,
    output logic        bus_ready,
    input  logic [1:0]  raw_btn,
    input  logic [1:0]  raw_sw
);

    localparam int DEBOUNCE_DEPTH = 20;

    logic [1:0] btn_sync1, btn_sync2;
    logic [1:0] sw_sync1, sw_sync2;
    logic [1:0] btn_debounced;
    logic [1:0] btn_stable;
    logic [4:0] btn1_counter, btn0_counter;
    logic       btn1_last, btn0_last;

    // 2-stage synchronizer for raw_btn
    always_ff @(posedge clk) begin
        if (rst) begin
            btn_sync1 <= 2'd0;
            btn_sync2 <= 2'd0;
        end else begin
            btn_sync1 <= raw_btn;
            btn_sync2 <= btn_sync1;
        end
    end

    // 2-stage synchronizer for raw_sw
    always_ff @(posedge clk) begin
        if (rst) begin
            sw_sync1 <= 2'd0;
            sw_sync2 <= 2'd0;
        end else begin
            sw_sync1 <= raw_sw;
            sw_sync2 <= sw_sync1;
        end
    end

    // Debounce BTN1 (button[1])
    always_ff @(posedge clk) begin
        if (rst) begin
            btn1_counter  <= 5'd0;
            btn1_last     <= 1'b0;
            btn_stable[1] <= 1'b0;
        end else begin
            if (btn_sync2[1] != btn1_last) begin
                btn1_counter <= 5'd0;
                btn1_last <= btn_sync2[1];
            end else if (btn1_counter < DEBOUNCE_DEPTH) begin
                btn1_counter <= btn1_counter + 5'd1;
            end else begin
                btn_stable[1] <= btn1_last;
            end
        end
    end

    // Debounce BTN0 (button[0])
    always_ff @(posedge clk) begin
        if (rst) begin
            btn0_counter  <= 5'd0;
            btn0_last     <= 1'b0;
            btn_stable[0] <= 1'b0;
        end else begin
            if (btn_sync2[0] != btn0_last) begin
                btn0_counter <= 5'd0;
                btn0_last <= btn_sync2[0];
            end else if (btn0_counter < DEBOUNCE_DEPTH) begin
                btn0_counter <= btn0_counter + 5'd1;
            end else begin
                btn_stable[0] <= btn0_last;
            end
        end
    end

    assign btn_debounced = btn_stable;

    always_comb begin
        bus_rdata = 32'd0;
        if (bus_re)
            bus_rdata = {28'd0, sw_sync2, btn_debounced};
    end

    assign bus_ready = 1'b1;

endmodule
