`timescale 1ns/1ps

module tb_fpga_top;

    logic clk;
    logic rst;
    logic [3:0] led;
    logic uart_txd;
    logic uart_rxd;

    // 125 MHz system clock
    initial begin
        clk = 0;
        forever #4 clk = ~clk;
    end

    // DUT
    fpga_top uut (
        .clk(clk),
        .rst(rst),
        .led(led),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd)
    );

    // 115200 Baud = 8680 ns per bit
    localparam real BIT_PERIOD_NS = 8680.55;

    task automatic send_uart_byte(input logic [7:0] byte_in);
        int i;
        uart_rxd = 0; // Start bit
        #(BIT_PERIOD_NS);
        for (i = 0; i < 8; i++) begin
            uart_rxd = byte_in[i];
            #(BIT_PERIOD_NS);
        end
        uart_rxd = 1; // Stop bit
        #(BIT_PERIOD_NS);
    endtask

    task automatic send_uart_string(input string str);
        int i;
        for (i = 0; i < str.len(); i++) begin
            send_uart_byte(str.getc(i));
        end
    endtask

    initial begin
        uart_rxd = 1;
        rst = 1'b1; // Reset active high
        #100;
        rst = 1'b0; // Release reset
        
        // Wait for PLL lock and reset sequence (arbitrary wait)
        #20000;

        $display("Sending 'help' command...");
        send_uart_string("help\r\n");

        #500000;

        $display("Sending 'regs' command...");
        send_uart_string("regs\r\n");

        #2000000;

        $display("Simulation complete.");
        $finish;
    end

    // Monitor TX output
    logic [7:0] captured_byte;
    initial begin
        forever begin
            @(negedge uart_txd);
            #(BIT_PERIOD_NS / 2); // Center of start bit
            if (!uart_txd) begin
                #(BIT_PERIOD_NS);
                for (int i=0; i<8; i++) begin
                    captured_byte[i] = uart_txd;
                    #(BIT_PERIOD_NS);
                end
                $display("[UART TX] Time %0t: 0x%02h (%c)", $time, captured_byte, captured_byte);
            end
        end
    end

endmodule
