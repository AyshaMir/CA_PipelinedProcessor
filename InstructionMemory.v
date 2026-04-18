module InstructionMemory(
    input  [31:0] instAddress,
    output [31:0] instruction
);

    reg [31:0] memory [0:255];

    initial begin
        $readmemh("instructions.mem", memory);
    end

    assign instruction = memory[instAddress[31:2]];

endmodule