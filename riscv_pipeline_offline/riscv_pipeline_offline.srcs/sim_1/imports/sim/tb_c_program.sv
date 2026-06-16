`timescale 1ns/1ps

module tb_c_program;

    logic clk;
    logic rst;

    logic uart_txd;
    logic uart_rxd_tb;
    logic instr_load_en;
    logic [9:0]  instr_load_word_addr;
    logic [31:0] instr_load_data;
    logic [31:0] program_words [0:1023];
    event program_loaded;

    top uut (
        .clk      (clk),
        .rst      (rst),
        .instr_load_en       (instr_load_en),
        .instr_load_word_addr(instr_load_word_addr),
        .instr_load_data     (instr_load_data),
        .uart_rxd (uart_rxd_tb),
        .uart_txd (uart_txd)
    );

    initial uart_rxd_tb = 1'b1;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        string program_path;
        int fd;

        if (!$value$plusargs("PROGRAM_MEM=%s", program_path)) begin
            program_path = "../../../../../sw/hello_world.mem";
        end
        
        for (int i = 0; i < 1024; i++) begin
            program_words[i] = 32'h00000013; // NOP padding
        end
        $readmemh(program_path, program_words);
        for (int i = 0; i < 1024; i++) begin
            @(negedge clk);
            instr_load_en        = 1'b1;
            instr_load_word_addr = i[9:0];
            instr_load_data      = program_words[i];
            @(posedge clk);
            #1;
            instr_load_en        = 1'b0;
        end
        $display("Loaded C program memory from %s", program_path);
        -> program_loaded;
    end

    // UART RX monitor
    localparam real BIT_PERIOD_NS = 2170.0;
    localparam real HALF_BIT_NS   = BIT_PERIOD_NS / 2.0;

    initial begin
        logic [7:0] captured;
        forever begin
            @(negedge uart_txd);
            #(HALF_BIT_NS);
            if (!uart_txd) begin
                #(BIT_PERIOD_NS);
                for (int i = 0; i < 8; i++) begin
                    captured[i] = uart_txd;
                    if (i < 7) #(BIT_PERIOD_NS);
                end
                #(BIT_PERIOD_NS);
                $display("[C-PROGRAM UART] t=%0t  %c", $time, captured);
            end
        end
    end

    initial begin
        instr_load_en = 1'b0;
        instr_load_word_addr = 10'd0;
        instr_load_data = 32'd0;

        @program_loaded;

        rst = 1'b1;
        repeat(3) @(posedge clk);
        rst = 1'b0;

        // Run for 3 milliseconds (enough for C program + UART)
        #20000000;
        
        $display("\n[TESTBENCH] Simulation completed.");
        $finish;
    end


endmodule
