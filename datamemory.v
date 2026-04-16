`timescale 1ns / 1ps
module datamemory(
    input clk,
    input MemRead,
    input MemWrite,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [31:0] mem [0:511];

// Write operation
always @(posedge clk) begin
    if (MemWrite)
        mem[address[8:0]] <= write_data;
end

// Read operation
assign read_data = (MemRead) ? mem[address[8:0]] : 32'b0;

endmodule