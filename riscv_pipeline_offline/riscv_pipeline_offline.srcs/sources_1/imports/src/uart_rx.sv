/*
 * Module: uart_rx
 * Description: 8N1 UART receiver. Includes a 2-stage synchroniser on the
 *              rx_serial input to avoid metastability.  Samples the centre of
 *              each bit.  rx_valid pulses for one clock cycle when a complete
 *              byte has been received; rx_data holds that byte.
 *              CLKS_PER_BIT must equal (cpu_freq / baud_rate).
 *              At 25 MHz / 115200 baud → CLKS_PER_BIT = 217.
 */
module uart_rx #(
    parameter int CLKS_PER_BIT = 217
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       rx_serial,   // raw async UART RX pin
    output logic       rx_valid,    // pulses for 1 cycle when byte is ready
    output logic [7:0] rx_data      // received byte (valid when rx_valid)
);

    // ---------------------------------------------------------------
    // State encoding
    // ---------------------------------------------------------------
    localparam logic [1:0] IDLE      = 2'b00;
    localparam logic [1:0] START_BIT = 2'b01;
    localparam logic [1:0] DATA_BITS = 2'b10;
    localparam logic [1:0] STOP_BIT  = 2'b11;

    // ---------------------------------------------------------------
    // Internal signals
    // ---------------------------------------------------------------
    logic [1:0]                         rx_sync;     // 2-FF synchroniser
    logic                               rx_clean;    // synchronised RX line

    logic [1:0]                         state;
    logic [$clog2(CLKS_PER_BIT)-1 : 0] clk_count;
    logic [2:0]                         bit_index;
    logic [7:0]                         rx_shift_reg;

    // ---------------------------------------------------------------
    // 2-stage synchroniser (mandatory – rx_serial is async to clk)
    // ---------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            rx_sync <= 2'b11;          // idle high
        else
            rx_sync <= {rx_sync[0], rx_serial};
    end
    assign rx_clean = rx_sync[1];

    // ---------------------------------------------------------------
    // State machine
    // ---------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            rx_valid     <= 1'b0;
            rx_data      <= 8'h00;
            clk_count    <= '0;
            bit_index    <= '0;
            rx_shift_reg <= '0;
        end else begin
            rx_valid <= 1'b0;   // default: deasserted

            unique case (state)

                // ----- IDLE ------------------------------------------
                IDLE: begin
                    if (!rx_clean) begin   // falling edge → start bit
                        clk_count <= '0;
                        state     <= START_BIT;
                    end
                end

                // ----- START BIT: sample at mid-point ----------------
                START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT / 2) - 1) begin
                        if (!rx_clean) begin  // confirm still low (not a glitch)
                            clk_count <= '0;
                            bit_index <= '0;
                            state     <= DATA_BITS;
                        end else begin
                            state <= IDLE;    // glitch, ignore
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                // ----- DATA BITS: sample centre of each bit ----------
                DATA_BITS: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count                   <= '0;
                        rx_shift_reg[bit_index]     <= rx_clean;  // LSB first
                        if (bit_index == 3'd7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                // ----- STOP BIT: wait full bit, output result --------
                STOP_BIT: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        rx_data   <= rx_shift_reg;
                        rx_valid  <= 1'b1;
                        clk_count <= '0;
                        state     <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
