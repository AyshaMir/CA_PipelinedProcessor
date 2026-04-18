`timescale 1ns / 1ps

module TopLevelProccessor(
    input clk,
    input rst
);
    // IF stage
    wire [31:0] PC, PC_next, PC_plus4, instruction;

    // IF/ID
    wire [31:0] ID_PC, ID_instruction;

    // ID stage decode fields
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire funct7_5;

    // ID control
    wire RegWrite_ID, ALUSrc_ID, MemRead_ID, MemWrite_ID, MemtoReg_ID, Branch_ID;
    wire [1:0] ALUOp_ID;
    wire [1:0] BranchType_ID;

    // ID data
    wire [31:0] ReadData1_ID, ReadData2_ID, Imm_ID;

    // Hazard
    wire stall, ID_EX_flush_hazard;

    // ID/EX
    wire RegWrite_EX, ALUSrc_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, Branch_EX;
    wire [1:0] ALUOp_EX;
    wire [1:0] BranchType_EX;
    wire [31:0] PC_EX, ReadData1_EX, ReadData2_EX, Imm_EX;
    wire [4:0] rs1_EX, rs2_EX, rd_EX;
    wire [2:0] funct3_EX;
    wire funct7_5_EX;

    // Forwarding
    wire [1:0] ForwardA, ForwardB;
    wire [31:0] ForwardedA, ForwardedB;

    // EX stage
    wire [3:0] ALUControl_EX;
    wire [31:0] ALU_B_input, ALUResult_EX;
    wire Zero_EX, Sign_EX, Less_EX;
    wire [31:0] BranchTarget_EX;

    // EX/MEM
    wire RegWrite_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM, Branch_MEM;
    wire [1:0] BranchType_MEM;
    wire Zero_MEM, Sign_MEM, Less_MEM;
    wire [31:0] BranchTarget_MEM, ALUResult_MEM, WriteData_MEM;
    wire [4:0] rd_MEM;

    // Branch
    wire branch_taken;

    // MEM stage
    wire [31:0] ReadData_MEM;

    // MEM/WB
    wire RegWrite_WB, MemtoReg_WB;
    wire [31:0] ReadData_WB, ALUResult_WB;
    wire [4:0] rd_WB;

    // WB
    wire [31:0] WriteBackData;

    // Branch type encoding
    localparam BR_BEQ = 2'b00;
    localparam BR_BGE = 2'b01;

    // Branch taken logic, Branch resolves in MEM stage
    // BGE branches when NOT Less (A >= B)
    // BEQ branches when Zero
    assign branch_taken =
           (Branch_MEM && (BranchType_MEM == BR_BEQ) &&  Zero_MEM)
        || (Branch_MEM && (BranchType_MEM == BR_BGE) && !Less_MEM);

    // IF stage
    ProgramCounter pc_reg (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .PC_Next(PC_next),
        .PC(PC)
    );

    PCAdder pcadder (
        .PC(PC),
        .PC_add4(PC_plus4)
    );

    InstructionMemory ins_mem (
        .instAddress(PC),
        .instruction(instruction)
    );

    mux2 pc_mux (
        .in0(PC_plus4),
        .in1(BranchTarget_MEM),
        .select(branch_taken),
        .out(PC_next)
    );

    // IF/ID
    // Flush on branch taken (branch resolves in MEM,
    // so instructions in IF, ID, EX are wrong - flush all 3)
    IF_ID if_id (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(branch_taken),
        .IF_PC(PC),
        .IF_Instruction(instruction),
        .ID_PC(ID_PC),
        .ID_Instruction(ID_instruction)
    );

    // ID stage
    assign opcode= ID_instruction[6:0];
    assign rd = ID_instruction[11:7];
    assign funct3  = ID_instruction[14:12];
    assign rs1 = ID_instruction[19:15];
    assign rs2  = ID_instruction[24:20];
    assign funct7_5 = ID_instruction[30];

    main_control main_ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .RegWrite(RegWrite_ID),
        .ALUSrc(ALUSrc_ID),
        .MemRead(MemRead_ID),
        .MemWrite(MemWrite_ID),
        .MemtoReg(MemtoReg_ID),
        .Branch(Branch_ID),
        .ALUOp(ALUOp_ID),
        .BranchType(BranchType_ID)
    );

    registerfile rf (
        .clk(clk),
        .rst(rst),
        .WriteEnable(RegWrite_WB),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd_WB),
        .WriteData(WriteBackData),
        .readdata1(ReadData1_ID),
        .readdata2(ReadData2_ID)
    );

    immGen immgen (
        .instruction(ID_instruction),
        .Imm(Imm_ID)
    );

    HazardDetectionUnit hazard (
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .ID_EX_rd(rd_EX),
        .ID_EX_MemRead(MemRead_EX),
        .stall(stall),
        .ID_EX_flush(ID_EX_flush_hazard)
    );

    // ID/EX
    // Flush on load-use hazard OR branch taken
    ID_EX id_ex (
        .clk(clk),
        .rst(rst),
        .flush(ID_EX_flush_hazard | branch_taken),

        .RegWrite_in(RegWrite_ID),
        .ALUSrc_in(ALUSrc_ID),
        .MemRead_in(MemRead_ID),
        .MemWrite_in(MemWrite_ID),
        .MemtoReg_in(MemtoReg_ID),
        .Branch_in(Branch_ID),
        .ALUOp_in(ALUOp_ID),
        .BranchType_in(BranchType_ID),

        .PC_in(ID_PC),
        .ReadData1_in(ReadData1_ID),
        .ReadData2_in(ReadData2_ID),
        .Imm_in(Imm_ID),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .funct3_in(funct3),
        .funct7_5_in(funct7_5),

        .RegWrite(RegWrite_EX),
        .ALUSrc(ALUSrc_EX),
        .MemRead(MemRead_EX),
        .MemWrite(MemWrite_EX),
        .MemtoReg(MemtoReg_EX),
        .Branch(Branch_EX),
        .ALUOp(ALUOp_EX),
        .BranchType(BranchType_EX),

        .PC(PC_EX),
        .ReadData1(ReadData1_EX),
        .ReadData2(ReadData2_EX),
        .Imm(Imm_EX),
        .rs1(rs1_EX),
        .rs2(rs2_EX),
        .rd(rd_EX),
        .funct3(funct3_EX),
        .funct7_5(funct7_5_EX)
    );

    // EX stage
    ForwardingUnit fwd (
        .ID_EX_rs1(rs1_EX),
        .ID_EX_rs2(rs2_EX),
        .EX_MEM_rd(rd_MEM),
        .EX_MEM_RegWrite(RegWrite_MEM),
        .MEM_WB_rd(rd_WB),
        .MEM_WB_RegWrite(RegWrite_WB),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    mux3 fwdA (
        .in0(ReadData1_EX),
        .in1(WriteBackData),
        .in2(ALUResult_MEM),
        .select(ForwardA),
        .out(ForwardedA)
    );

    mux3 fwdB (
        .in0(ReadData2_EX),
        .in1(WriteBackData),
        .in2(ALUResult_MEM),
        .select(ForwardB),
        .out(ForwardedB)
    );

    mux2 alu_src (
        .in0(ForwardedB),
        .in1(Imm_EX),
        .select(ALUSrc_EX),
        .out(ALU_B_input)
    );

    alu_control alu_ctrl (
        .ALUOp(ALUOp_EX),
        .funct3(funct3_EX),
        .funct7_5(funct7_5_EX),
        .ALUControl(ALUControl_EX)
    );

    alu alu_unit (
        .A(ForwardedA),
        .B(ALU_B_input),
        .ALUControl(ALUControl_EX),
        .ALUResult(ALUResult_EX),
        .Zero(Zero_EX),
        .Sign(Sign_EX),
        .Less(Less_EX)
    );

    BranchAdder badder (
        .PC(PC_EX),
        .imm(Imm_EX),
        .branchTarget(BranchTarget_EX)
    );

    // EX/MEM
    // Also flush on branch taken - the instruction
    // that was in EX when branch resolves must be squashed
    EX_MEM ex_mem (
        .clk(clk),
        .rst(rst),
        .flush(branch_taken),

        .RegWrite_in(RegWrite_EX),
        .MemRead_in(MemRead_EX),
        .MemWrite_in(MemWrite_EX),
        .MemtoReg_in(MemtoReg_EX),
        .Branch_in(Branch_EX),
        .BranchType_in(BranchType_EX),
        .Zero_in(Zero_EX),
        .Sign_in(Sign_EX),
        .Less_in(Less_EX),

        .BranchTarget_in(BranchTarget_EX),
        .ALUResult_in(ALUResult_EX),
        .WriteData_in(ForwardedB),
        .rd_in(rd_EX),

        .RegWrite(RegWrite_MEM),
        .MemRead(MemRead_MEM),
        .MemWrite(MemWrite_MEM),
        .MemtoReg(MemtoReg_MEM),
        .Branch(Branch_MEM),
        .BranchType(BranchType_MEM),
        .Zero(Zero_MEM),
        .Sign(Sign_MEM),
        .Less(Less_MEM),

        .BranchTarget(BranchTarget_MEM),
        .ALUResult(ALUResult_MEM),
        .WriteData(WriteData_MEM),
        .rd(rd_MEM)
    );

    // MEM stage
    datamemory dmem (
        .clk(clk),
        .MemRead(MemRead_MEM),
        .MemWrite(MemWrite_MEM),
        .address(ALUResult_MEM),
        .write_data(WriteData_MEM),
        .read_data(ReadData_MEM)
    );

    // MEM/WB
    MEM_WB mem_wb (
        .clk(clk),
        .rst(rst),
        .RegWrite_in(RegWrite_MEM),
        .MemtoReg_in(MemtoReg_MEM),
        .ReadData_in(ReadData_MEM),
        .ALUResult_in(ALUResult_MEM),
        .rd_in(rd_MEM),
        .RegWrite(RegWrite_WB),
        .MemtoReg(MemtoReg_WB),
        .ReadData(ReadData_WB),
        .ALUResult(ALUResult_WB),
        .rd(rd_WB)
    );

    // WB stage
    mux2 wb_mux (
        .in0(ALUResult_WB),
        .in1(ReadData_WB),
        .select(MemtoReg_WB),
        .out(WriteBackData)
    );

endmodule