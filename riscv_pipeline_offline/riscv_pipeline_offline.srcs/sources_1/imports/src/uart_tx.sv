/*
 * Module: uart_tx
 * Description: 8N1 UART transmitter. At 25 MHz with CLKS_PER_BIT=217 this
 *              achieves 115200 baud.  Drive tx_start high for exactly ONE
 *              clock cycle with the byte in tx_data to begin a transmission.
 *              tx_busy stays high for the full frame; tx_done pulses for
 *              one cycle when the stop bit finishes.
 */
module uart_tx #(
    parameter int CLKS_PER_BIT = 217   // 25_000_000 / 115_200
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,    // pulse high for 1 cycle to begin TX
    input  logic [7:0] tx_data,     // byte to transmit (latched on tx_start)
    output logic       tx_busy,     // high while frame is in progress
    output logic       tx_done,     // pulses high for 1 cycle at end of stop bit
    output logic       tx_serial    // UART TX line (idle = 1)
);

    // ---------------------------------------------------------------
    // State encoding
    // ---------------------------------------------------------------
    localparam logic [1:0] IDLE      = 2'b00;
    localparam logic [1:0] START_BIT = 2'b01;
    localparam logic [1:0] DATA_BITS = 2'b10;
    localparam logic [1:0] STOP_BIT  = 2'b11;

    // ---------------------------------------------------------------
    // Internal registers
    // ---------------------------------------------------------------
    logic [1:0]                         state;
    logic [$clog2(CLKS_PER_BIT)-1 : 0] clk_count;
    logic [2:0]                         bit_index;   // 0-7
    logic [7:0]                         tx_shift_reg;

    // ---------------------------------------------------------------
    // Combinational outputs
    // ---------------------------------------------------------------
    assign tx_busy = (state != IDLE);

    // ---------------------------------------------------------------
    // State machine
    // ---------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            tx_serial    <= 1'b1;
            tx_done      <= 1'b0;
            clk_count    <= '0;
            bit_index    <= '0;
            tx_shift_reg <= '0;
        end else begin
            tx_done <= 1'b0;   // default: deasserted

            unique case (state)

                // ----- IDLE ------------------------------------------
                IDLE: begin
                    tx_serial <= 1'b1;
                    if (tx_start) begin
                        tx_shift_reg <= tx_data;
                        clk_count    <= '0;
                        state        <= START_BIT;
                    end
                end

                // ----- START BIT (0) ---------------------------------
                START_BIT: begin
                    tx_serial <= 1'b0;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        bit_index <= '0;
                        state     <= DATA_BITS;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                // ----- DATA BITS (LSB first) -------------------------
                DATA_BITS: begin
                    tx_serial <= tx_shift_reg[bit_index];
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        if (bit_index == 3'd7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                // ----- STOP BIT (1) ----------------------------------
                STOP_BIT: begin
                    tx_serial <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        tx_done   <= 1'b1;
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
