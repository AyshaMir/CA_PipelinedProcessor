`timescale 1ns / 1ps
module ID_EX(
    input  clk,
    input  rst,
    input  flush,

    // Control signals in
    input  RegWrite_in,
    input  ALUSrc_in,
    input  MemRead_in,
    input  MemWrite_in,
    input  MemtoReg_in,
    input  Branch_in,
    input  [1:0] ALUOp_in,
    input  [1:0] BranchType_in,

    // Data in
    input  [31:0] PC_in,
    input  [31:0] ReadData1_in,
    input  [31:0] ReadData2_in,
    input  [31:0] Imm_in,
    input  [4:0]  rs1_in,
    input  [4:0]  rs2_in,
    input  [4:0]  rd_in,
    input  [2:0]  funct3_in,
    input         funct7_5_in,

    // Control signals out
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,
    output reg [1:0] ALUOp,
    output reg [1:0] BranchType,

    // Data out
    output reg [31:0] PC,
    output reg [31:0] ReadData1,
    output reg [31:0] ReadData2,
    output reg [31:0] Imm,
    output reg [4:0]  rs1,
    output reg [4:0]  rs2,
    output reg [4:0]  rd,
    output reg [2:0]  funct3,
    output reg        funct7_5
);

    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            RegWrite   <= 1'b0;
            ALUSrc     <= 1'b0;
            MemRead    <= 1'b0;
            MemWrite   <= 1'b0;
            MemtoReg   <= 1'b0;
            Branch     <= 1'b0;
            ALUOp      <= 2'b00;
            BranchType <= 2'b00;

            PC         <= 32'b0;
            ReadData1  <= 32'b0;
            ReadData2  <= 32'b0;
            Imm        <= 32'b0;
            rs1        <= 5'b0;
            rs2        <= 5'b0;
            rd         <= 5'b0;
            funct3     <= 3'b0;
            funct7_5   <= 1'b0;
        end
        else begin
            RegWrite   <= RegWrite_in;
            ALUSrc     <= ALUSrc_in;
            MemRead    <= MemRead_in;
            MemWrite   <= MemWrite_in;
            MemtoReg   <= MemtoReg_in;
            Branch     <= Branch_in;
            ALUOp      <= ALUOp_in;
            BranchType <= BranchType_in;

            PC         <= PC_in;
            ReadData1  <= ReadData1_in;
            ReadData2  <= ReadData2_in;
            Imm        <= Imm_in;
            rs1        <= rs1_in;
            rs2        <= rs2_in;
            rd         <= rd_in;
            funct3     <= funct3_in;
            funct7_5   <= funct7_5_in;
        end
    end

endmodule