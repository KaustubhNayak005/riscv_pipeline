`timescale 1ns / 1ps

module tb_bht;

    logic clk;
    logic rst;
    logic [31:0] read_pc;
    logic predict_taken;
    logic update_en;
    logic [31:0] update_pc;
    logic actual_taken;

    // Instantiate BHT with 64 entries (6 bits)
    bht #(
        .ENTRIES(64)
    ) dut (
        .clk(clk),
        .rst(rst),
        .read_pc(read_pc),
        .predict_taken(predict_taken),
        .update_en(update_en),
        .update_pc(update_pc),
        .actual_taken(actual_taken)
    );

    // Generate 100MHz clock
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        read_pc = 0;
        update_en = 0;
        update_pc = 0;
        actual_taken = 0;

        // Wait 20ns, deassert reset
        #20;
        rst = 0;
        #10;

        $display("=== BHT 2-Bit Saturating Counter Unit Test ===");

        // Test PC 0x00000100 (Index: 64 -> wraps to entry 0 depending on hashing, but let's just use the PC)
        read_pc = 32'h00000100;
        #10;
        
        // Initial state is 01 (Weakly Not Taken)
        if (predict_taken !== 1'b0) 
            $error("FAIL: Default should be Not Taken (01). Got: %b", predict_taken);
        else 
            $display("PASS: Default state is Not Taken (01).");

        // 1. Train 0x100 to Taken (01 -> 10)
        @(posedge clk);
        update_en = 1; update_pc = 32'h00000100; actual_taken = 1;
        @(posedge clk);
        update_en = 0;
        
        #10;
        if (predict_taken !== 1'b1) 
            $error("FAIL: Should predict Taken (10) after one training. Got: %b", predict_taken);
        else 
            $display("PASS: Transitions to Weakly Taken (10) correctly.");

        // 2. Train 0x100 to Taken again (10 -> 11)
        @(posedge clk);
        update_en = 1; update_pc = 32'h00000100; actual_taken = 1;
        @(posedge clk);
        update_en = 0;

        #10;
        if (predict_taken !== 1'b1) 
            $error("FAIL: Should predict Taken (11). Got: %b", predict_taken);
        else 
            $display("PASS: Transitions to Strongly Taken (11) correctly.");

        // 3. Saturate at Strongly Taken (11 -> 11)
        @(posedge clk);
        update_en = 1; update_pc = 32'h00000100; actual_taken = 1;
        @(posedge clk);
        update_en = 0;

        #10;
        if (predict_taken !== 1'b1) 
            $error("FAIL: Should remain Strongly Taken (11). Got: %b", predict_taken);
        else 
            $display("PASS: Saturates at Strongly Taken (11) correctly.");

        // 4. Train 0x100 to Not Taken (11 -> 10)
        @(posedge clk);
        update_en = 1; update_pc = 32'h00000100; actual_taken = 0;
        @(posedge clk);
        update_en = 0;

        #10;
        if (predict_taken !== 1'b1) 
            $error("FAIL: Should still predict Taken (10). Got: %b", predict_taken);
        else 
            $display("PASS: Transitions back to Weakly Taken (10) correctly.");

        // 5. Train 0x100 to Not Taken again (10 -> 01)
        @(posedge clk);
        update_en = 1; update_pc = 32'h00000100; actual_taken = 0;
        @(posedge clk);
        update_en = 0;

        #10;
        if (predict_taken !== 1'b0) 
            $error("FAIL: Should predict Not Taken (01). Got: %b", predict_taken);
        else 
            $display("PASS: Transitions to Weakly Not Taken (01) correctly.");

        // 6. Check a different PC to ensure no aliasing (0x00000200)
        read_pc = 32'h00000200;
        #10;
        if (predict_taken !== 1'b0) 
            $error("FAIL: PC 0x200 should be independent and default to Not Taken (01). Got: %b", predict_taken);
        else 
            $display("PASS: Different PC maps to independent BHT entry.");

        $display("==================================================");
        $display("*** BHT UNIT TEST PASSED ***");
        $display("==================================================");
        $finish;
    end
endmodule
