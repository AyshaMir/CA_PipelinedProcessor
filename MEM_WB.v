`timescale 1ns / 1ps
// MEM/WB Pipeline Register
// Holds: memory read data or ALU result between Memory and Writeback stages
module MEM_WB(
    input  clk,
    input  rst,

    // Control signals in
    input  RegWrite_in,
    input  MemtoReg_in,

    // Data in
    input  [31:0] ReadData_in,   // data from data memory
    input  [31:0] ALUResult_in,  // ALU result passed through
    input  [4:0]  rd_in,

    // Control signals out
    output reg RegWrite,
    output reg MemtoReg,

    // Data out
    output reg [31:0] ReadData,
    output reg [31:0] ALUResult,
    output reg [4:0]  rd
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWrite  <= 1'b0;
            MemtoReg  <= 1'b0;
            ReadData  <= 32'b0;
            ALUResult <= 32'b0;
            rd        <= 5'b0;
        end
        else begin
            RegWrite  <= RegWrite_in;
            MemtoReg  <= MemtoReg_in;
            ReadData  <= ReadData_in;
            ALUResult <= ALUResult_in;
            rd        <= rd_in;
        end
    end
endmodule