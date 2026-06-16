/*
 * Module: bht
 * Description: Branch History Table with 2-bit saturating counters.
 *              Used for dynamic branch prediction.
 */
module bht #(
    parameter ENTRIES = 64
)(
    input  logic        clk,
    input  logic        rst,
    
    // Read port (combinatorial, used in ID stage)
    input  logic [31:0] read_pc,
    output logic        predict_taken,
    
    // Update port (synchronous, used by EX stage)
    input  logic        update_en,
    input  logic [31:0] update_pc,
    input  logic        actual_taken
);

    localparam INDEX_BITS = $clog2(ENTRIES);
    
    // 2-bit saturating counters
    // 00: Strongly Not Taken
    // 01: Weakly Not Taken
    // 10: Weakly Taken
    // 11: Strongly Taken
    logic [1:0] counters [0:ENTRIES-1];
    
    logic [INDEX_BITS-1:0] read_idx;
    logic [INDEX_BITS-1:0] update_idx;
    
    assign read_idx   = read_pc[INDEX_BITS+1:2];
    assign update_idx = update_pc[INDEX_BITS+1:2];
    
    // Predict taken if the counter is 10 or 11 (MSB is 1)
    assign predict_taken = counters[read_idx][1];
    
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < ENTRIES; i++) begin
                counters[i] <= 2'b01; // Default to Weakly Not Taken
            end
        end else if (update_en) begin
            case (counters[update_idx])
                2'b00: counters[update_idx] <= actual_taken ? 2'b01 : 2'b00;
                2'b01: counters[update_idx] <= actual_taken ? 2'b10 : 2'b00;
                2'b10: counters[update_idx] <= actual_taken ? 2'b11 : 2'b01;
                2'b11: counters[update_idx] <= actual_taken ? 2'b11 : 2'b10;
            endcase
        end
    end

endmodule
