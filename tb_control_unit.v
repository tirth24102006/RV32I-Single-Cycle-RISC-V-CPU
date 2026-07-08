`timescale 1ns / 1ps
module tb_control_unit;
reg [6:0] opcode;
wire RegWrite,ALUSrc;
control_unit A1(RegWrite,ALUSrc,opcode);
initial begin
        opcode = 7'b0000000;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_control_unit);
$monitor("at time %t: opcode=%b RegWrite=%b ALUSrc=%b",$time,opcode,RegWrite,ALUSrc);
                opcode = 7'b0110011; #10;
                opcode = 7'b0010011; #10;
                opcode = 7'b0000000; #10;
        $finish;
end
endmodule