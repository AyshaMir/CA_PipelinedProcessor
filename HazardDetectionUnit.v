module HazardDetectionUnit(
    input  [4:0] IF_ID_rs1,
    input  [4:0] IF_ID_rs2,
    input  [4:0] ID_EX_rd,
    input ID_EX_MemRead,
    output reg   stall,
    output reg   ID_EX_flush
);
    always @(*) begin
        if (ID_EX_MemRead && (ID_EX_rd != 5'b0) &&
           ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2))) begin
            stall = 1'b1;
            ID_EX_flush = 1'b1;
        end
        else begin
            stall = 1'b0;
            ID_EX_flush = 1'b0;
        end
    end
endmodule