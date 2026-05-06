/*
 * Module: hazard_detection_unit
 * Description: Detects load-use hazards that require a one-cycle stall.
 * Inputs: id_ex_rd, id_ex_mem_read, if_id_rs1, if_id_rs2
 * Outputs: stall
 */
module hazard_detection_unit (
    input  logic [4:0] id_ex_rd,
    input  logic       id_ex_mem_read,
    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2,
    output logic       stall
);

    always_comb begin
        stall = id_ex_mem_read &&
                (id_ex_rd != 5'd0) &&
                ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));
    end

endmodule
