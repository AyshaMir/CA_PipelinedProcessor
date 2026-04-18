`timescale 1ns / 1ps
module EX_MEM(
    input clk,
    input rst,
    input flush,

    // Control signals in
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemtoReg_in,
    input Branch_in,
    input [1:0] BranchType_in,
    input Zero_in,
    input Sign_in,
    input Less_in,

    // Data in
    input [31:0] BranchTarget_in,
    input [31:0] ALUResult_in,
    input [31:0] WriteData_in,
    input [4:0] rd_in,

    // Control signals out
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,
    output reg [1:0] BranchType,
    output reg Zero,
    output reg Sign,
    output reg Less,

    // Data out
    output reg [31:0] BranchTarget,
    output reg [31:0] ALUResult,
    output reg [31:0] WriteData,
    output reg [4:0] rd
);

always @(posedge clk or posedge rst) begin
    if (rst || flush) begin
        RegWrite     <= 1'b0;
        MemRead      <= 1'b0;
        MemWrite     <= 1'b0;
        MemtoReg     <= 1'b0;
        Branch       <= 1'b0;
        BranchType   <= 2'b00;
        Zero         <= 1'b0;
        Sign         <= 1'b0;
        Less         <= 1'b0;
        BranchTarget <= 32'b0;
        ALUResult    <= 32'b0;
        WriteData    <= 32'b0;
        rd           <= 5'b0;
    end
    else begin
        RegWrite     <= RegWrite_in;
        MemRead      <= MemRead_in;
        MemWrite     <= MemWrite_in;
        MemtoReg     <= MemtoReg_in;
        Branch       <= Branch_in;
        BranchType   <= BranchType_in;
        Zero         <= Zero_in;
        Sign         <= Sign_in;
        Less         <= Less_in;
        BranchTarget <= BranchTarget_in;
        ALUResult    <= ALUResult_in;
        WriteData    <= WriteData_in;
        rd           <= rd_in;
    end
end

endmodule