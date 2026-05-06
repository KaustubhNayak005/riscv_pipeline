/*
 * Module: instr_mem
 * Description: 1024-word ROM-style instruction memory initialized with the
 *              bundled sample program for Vivado xsim and FPGA inference.
 * Inputs: word_addr
 * Outputs: instr
 */
module instr_mem (
    input  logic [9:0]  word_addr,
    output logic [31:0] instr
);

    logic [31:0] memory [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000013;
        end

        memory[0]  = 32'h00500093;
        memory[1]  = 32'h00a00113;
        memory[2]  = 32'h002081b3;
        memory[3]  = 32'h40110233;
        memory[4]  = 32'h0020f2b3;
        memory[5]  = 32'h0020e333;
        memory[6]  = 32'h0020c3b3;
        memory[7]  = 32'h00302023;
        memory[8]  = 32'h00002403;
        memory[9]  = 32'h001404b3;
        memory[10] = 32'h00348533;
        memory[11] = 32'h009505b3;
        memory[12] = 32'h00108463;
        memory[13] = 32'h06300613;
        memory[14] = 32'h00100613;
        memory[15] = 32'h00208463;
        memory[16] = 32'h00200693;
        memory[17] = 32'h0080076f;
        memory[18] = 32'h07b00793;
        memory[19] = 32'h05400813;
        memory[20] = 32'h123458b7;
        memory[21] = 32'h00001917;
        memory[22] = 32'h06400993;
        memory[23] = 32'h00498a67;
        memory[24] = 32'h04d00a93;
        memory[25] = 32'h05800b13;
        memory[26] = 32'h00700b93;
        memory[27] = 32'h002b9c13;
        memory[28] = 32'h001c5c93;
        memory[29] = 32'h401cdd13;
        memory[30] = 32'h00a0ad93;
        memory[31] = 32'h00513e13;
        memory[32] = 32'h0020aeb3;
        memory[33] = 32'h00113f33;
    end

    assign instr = memory[word_addr];

endmodule
