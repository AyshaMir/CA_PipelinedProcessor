`timescale 1ns / 1ps
// IF/ID Pipeline Register
// Holds: PC+4 and fetched instruction between Fetch and Decode stages
module IF_ID(
    input  clk,
    input  rst,
    input  stall,     // from hazard detection unit - freezes the register
    input  flush,     // from branch logic - inserts NOP (bubble)
    input  [31:0] IF_PC4,
    input  [31:0] IF_Instruction,
    output reg [31:0] ID_PC4,
    output reg [31:0] ID_Instruction
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            ID_PC4        <= 32'b0;
            ID_Instruction <= 32'b0;  // NOP = all zeros
        end
        else if (!stall) begin
            ID_PC4        <= IF_PC4;
            ID_Instruction <= IF_Instruction;
        end
        // if stall: hold current values (do nothing)
    end
endmodule