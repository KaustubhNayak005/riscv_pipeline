/*
 * Module: tb_top
 * Description: Self-checking Vivado xsim testbench for the 5-stage pipelined
 *              RV32I processor top level.
 * Inputs: none
 * Outputs: none
 */
`timescale 1ns/1ps

module tb_top;

    logic clk;
    logic rst;
    int failures;
    bit stall_seen;
    bit flush_seen;
    bit forward_ex_seen;
    bit forward_wb_seen;

    top uut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        $dumpfile("riscv_pipeline.vcd");
        $dumpvars(0, tb_top);
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        string program_path;
        int fd;

        if (!$value$plusargs("PROGRAM_MEM=%s", program_path)) begin
            program_path = "program.mem";
            fd = $fopen(program_path, "r");
            if (fd == 0) begin
                program_path = "../mem/program.mem";
                fd = $fopen(program_path, "r");
            end
            if (fd == 0) begin
                program_path = "mem/program.mem";
                fd = $fopen(program_path, "r");
            end
        end else begin
            fd = $fopen(program_path, "r");
        end
        if (fd != 0) begin
            $fclose(fd);
            $readmemh(program_path, uut.u_if_stage.u_instr_mem.memory);
            $display("Loaded instruction memory from %s", program_path);
        end else begin
            $fatal(1, "Could not find program.mem. Add mem/program.mem to Vivado simulation sources.");
        end
    end

    always @(posedge clk) begin
        if (uut.stall) begin
            stall_seen <= 1'b1;
        end
        if (uut.flush) begin
            flush_seen <= 1'b1;
        end
        if ((uut.forward_a == 2'b10) || (uut.forward_b == 2'b10)) begin
            forward_ex_seen <= 1'b1;
        end
        if ((uut.forward_a == 2'b01) || (uut.forward_b == 2'b01)) begin
            forward_wb_seen <= 1'b1;
        end
    end

    task automatic print_registers(input string label);
        int i;
        begin
            $display("\n--- %s ---", label);
            for (i = 0; i < 32; i = i + 1) begin
                $display("x%0d = 0x%08h (%0d)", i, uut.u_id_stage.u_reg_file.regs[i],
                         uut.u_id_stage.u_reg_file.regs[i]);
            end
        end
    endtask

    task automatic expect_reg(input int index, input logic [31:0] expected, input string message);
        logic [31:0] actual;
        begin
            actual = uut.u_id_stage.u_reg_file.regs[index];
            assert (actual == expected)
                $display("PASS: %s (x%0d = 0x%08h)", message, index, actual);
            else begin
                $error("FAIL: %s expected x%0d = 0x%08h, got 0x%08h",
                       message, index, expected, actual);
                failures++;
            end
        end
    endtask

    task automatic expect_bit(input bit actual, input string message);
        begin
            assert (actual)
                $display("PASS: %s", message);
            else begin
                $error("FAIL: %s", message);
                failures++;
            end
        end
    endtask

    task automatic run_cycles(input int count);
        int c;
        begin
            for (c = 0; c < count; c = c + 1) begin
                @(posedge clk);
            end
            #1;
        end
    endtask

    initial begin
        failures = 0;
        stall_seen = 1'b0;
        flush_seen = 1'b0;
        forward_ex_seen = 1'b0;
        forward_wb_seen = 1'b0;

        rst = 1'b1;
        run_cycles(3);
        rst = 1'b0;

        run_cycles(80);

        print_registers("Basic ALU instructions");
        expect_reg(3, 32'd15, "ADD result");
        expect_reg(4, 32'd5, "SUB result");
        expect_reg(5, 32'd0, "AND result");
        expect_reg(6, 32'd15, "OR result");
        expect_reg(7, 32'd15, "XOR result");

        print_registers("Load and store");
        expect_reg(8, 32'd15, "SW followed by LW memory round-trip");

        print_registers("Data hazard with forwarding");
        expect_reg(10, 32'd35, "Back-to-back dependent ADD with EX/MEM forwarding");
        expect_reg(11, 32'd55, "Chained ADD dependency");
        expect_bit(forward_ex_seen, "EX/MEM forwarding asserted");
        expect_bit(forward_wb_seen, "MEM/WB forwarding asserted");

        print_registers("Load-use hazard");
        expect_reg(9, 32'd20, "LW followed immediately by dependent ADD");
        expect_bit(stall_seen, "Load-use stall inserted");

        print_registers("Branch taken");
        expect_reg(12, 32'd1, "Taken BEQ flushed skipped instruction");
        expect_bit(flush_seen, "Flush asserted for taken branch or jump");

        print_registers("Branch not taken");
        expect_reg(13, 32'd2, "Not-taken BEQ continued sequential execution");

        print_registers("JAL and JALR");
        expect_reg(14, 32'h00000048, "JAL wrote PC+4 link");
        expect_reg(15, 32'd0, "JAL skipped wrong-path instruction");
        expect_reg(16, 32'd84, "JAL reached target");
        expect_reg(20, 32'h00000060, "JALR wrote PC+4 link");
        expect_reg(21, 32'd0, "JALR flushed first wrong-path instruction");
        expect_reg(22, 32'd0, "JALR flushed second wrong-path instruction");

        print_registers("LUI, AUIPC, shifts, and comparisons");
        expect_reg(17, 32'h12345000, "LUI upper immediate placement");
        expect_reg(18, 32'h00001054, "AUIPC added upper immediate to PC");
        expect_reg(23, 32'd7, "JALR target executed");
        expect_reg(24, 32'd28, "SLLI result");
        expect_reg(25, 32'd14, "SRLI result");
        expect_reg(26, 32'd7, "SRAI result");
        expect_reg(27, 32'd1, "SLTI result");
        expect_reg(28, 32'd0, "SLTIU result");
        expect_reg(29, 32'd1, "SLT result");
        expect_reg(30, 32'd0, "SLTU result");

        if (failures == 0) begin
            $display("\nALL TESTS PASSED");
        end else begin
            $display("\nTESTS FAILED: %0d failure(s)", failures);
            $fatal(1, "Self-checking testbench failed");
        end

        $finish;
    end

endmodule
