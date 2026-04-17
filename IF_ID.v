`timescale 1ns / 1ps
module IF_ID(
    input  clk,
    input  rst,
    input  stall,
    input  flush,
    input  [31:0] IF_PC,
    input  [31:0] IF_Instruction,
    output reg [31:0] ID_PC,
    output reg [31:0] ID_Instruction
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            ID_PC         <= 32'b0;
            ID_Instruction <= 32'b0;
        end
        else if (!stall) begin
            ID_PC         <= IF_PC;
            ID_Instruction <= IF_Instruction;
        end
    end
endmodule