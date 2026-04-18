`timescale 1ns / 1ps
// Array input:   23, 12, 5, 44, 98, 53, 6, 89, 32, 65
// Expected out:   5,  6, 12, 23, 32, 44, 53, 65, 89, 98
module tb_TopLevelProccessor;
    reg clk;
    reg rst;
    always #5 clk = ~clk;

    TopLevelProccessor dut (
        .clk(clk),
        .rst(rst)
    );

    // Pipeline stage tracking wires
    wire [31:0] PC_wire = dut.PC;
    wire [31:0] instr_fetch = dut.instruction;
    wire [31:0] ifid_instr = dut.ID_instruction;
    wire [31:0] ifid_pc = dut.ID_PC;

    wire [4:0]  idex_rd = dut.rd_EX;
    wire [4:0]  exmem_rd = dut.rd_MEM;
    wire [4:0]  memwb_rd = dut.rd_WB;

    wire idex_RegWrite  = dut.RegWrite_EX;
    wire idex_MemRead   = dut.MemRead_EX;

    wire Stall = dut.stall;
    wire Branch_taken = dut.branch_taken;

    wire [1:0]  ForwardA = dut.ForwardA;
    wire [1:0]  ForwardB = dut.ForwardB;

    // Memory wires
    // Watch all 10 array slots directly in waveform
    // datamemory uses byte-addressed indexing in this setup
    wire [31:0] mem_0 = dut.dmem.mem[256];
    wire [31:0] mem_1 = dut.dmem.mem[260];
    wire [31:0] mem_2 = dut.dmem.mem[264];
    wire [31:0] mem_3 = dut.dmem.mem[268];
    wire [31:0] mem_4 = dut.dmem.mem[272];
    wire [31:0] mem_5 = dut.dmem.mem[276];
    wire [31:0] mem_6 = dut.dmem.mem[280];
    wire [31:0] mem_7 = dut.dmem.mem[284];
    wire [31:0] mem_8 = dut.dmem.mem[288];
    wire [31:0] mem_9 = dut.dmem.mem[292];

    // Print array task
    integer i;
    task print_array;
        input [31:0] cycle_num;
        begin
            $display("----------------------------------------------");
            $display("Cycle %0d - Data Memory Array (base 0x100):", cycle_num);
            $display("  Index | Address  | Value");
            for (i = 0; i < 10; i = i + 1) begin
                $display("  [%0d]   | 0x%0h | %0d",
                    i,
                    256 + (i * 4),
                    dut.dmem.mem[256 + (i * 4)]
                );
            end
            $display("----------------------------------------------");
        end
    endtask

    // Main simulation
    initial begin
        clk = 0;
        rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        $display("==============================================");
        $display("  RISC-V Pipelined Processor - Bubble Sort   ");
        $display("  Assignment 3            ");
        $display("==============================================");

        repeat(30) @(posedge clk);

        $display("");
        $display(">>> BEFORE SORTING <<<");
        print_array(30);

        repeat(2000) @(posedge clk);

        $display("");
        $display(">>> AFTER SORTING <<<");
        print_array(2030);

        $display("");
        $display("Expected: 5, 6, 12, 23, 32, 44, 53, 65, 89, 98");
        $display("");

        $display("=== VERIFICATION ===");
        begin : verify
            reg [31:0] expected [0:9];
            expected[0] =  5;  expected[1] =  6;
            expected[2] = 12;  expected[3] = 23;
            expected[4] = 32;  expected[5] = 44;
            expected[6] = 53;  expected[7] = 65;
            expected[8] = 89;  expected[9] = 98;

            for (i = 0; i < 10; i = i + 1) begin
                if (dut.dmem.mem[256 + (i * 4)] === expected[i])
                    $display("  arr[%0d] = %0d  CORRECT", i, dut.dmem.mem[256 + (i * 4)]);
                else
                    $display("  arr[%0d] = %0d  WRONG (expected %0d)",
                        i, dut.dmem.mem[256 + (i * 4)], expected[i]);
            end
        end

        $display("==============================================");
        $display("  Simulation complete");
        $display("==============================================");
        $finish;
    end
    initial begin
        $dumpfile("pipeline_sim.vcd");
        $dumpvars(0, tb_TopLevelProccessor);
    end
    initial begin
        #100000;
        $display("TIMEOUT - simulation exceeded 100000ns");
        $finish;
    end

endmodule