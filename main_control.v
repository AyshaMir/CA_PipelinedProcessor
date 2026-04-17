module main_control(
    input wire [6:0] opcode,
    input wire [2:0] funct3,

    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,
    output reg [1:0] ALUOp,
    output reg [1:0] BranchType
);

localparam OP_RTYPE  = 7'b0110011;
localparam OP_ITYPE  = 7'b0010011;
localparam OP_LOAD   = 7'b0000011;
localparam OP_STORE  = 7'b0100011;
localparam OP_BRANCH = 7'b1100011;

// BranchType encoding
localparam BR_BEQ = 2'b00;
localparam BR_BGE = 2'b01;
always @(*) begin
    RegWrite   = 0;
    ALUSrc     = 0;
    MemRead    = 0;
    MemWrite   = 0;
    MemtoReg   = 0;
    Branch     = 0;
    ALUOp      = 2'b00;
    BranchType = BR_BEQ;

    case (opcode)
        OP_RTYPE: begin
            RegWrite = 1;
            ALUOp    = 2'b10;
        end

        OP_ITYPE: begin
            RegWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b11;
        end

        OP_LOAD: begin
            RegWrite = 1;
            ALUSrc   = 1;
            MemRead  = 1;
            MemtoReg = 1;
            ALUOp    = 2'b00;
        end

        OP_STORE: begin
            ALUSrc   = 1;
            MemWrite = 1;
            ALUOp    = 2'b00;
        end

        OP_BRANCH: begin
            Branch = 1;
            ALUOp  = 2'b01;

            case (funct3)
                3'b000: BranchType = BR_BEQ; // BEQ
                3'b101: BranchType = BR_BGE; // BGE
                default: BranchType = BR_BEQ;
            endcase
        end
    endcase
end

endmodule