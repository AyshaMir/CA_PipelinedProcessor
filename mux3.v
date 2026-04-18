// select: 00 = register file, 01 = MEM/WB forward, 10 = EX/MEM forward
module mux3(
    input  [31:0] in0,
    input  [31:0] in1,
    input  [31:0] in2,
    input  [1:0]  select,
    output [31:0] out
);
    assign out = (select == 2'b10) ? in2 :
                 (select == 2'b01) ? in1 : in0;
endmodule