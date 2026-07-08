`timescale 1ns / 1ps
module tb_imm_gen;
reg [31:0] instruction;
wire [31:0] imm_out;
imm_gen A1(imm_out,instruction);
initial begin
        instruction = 32'b0;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0, tb_imm_gen);
$monitor("at time %t: instruction=%b imm_out=%b",$time,instruction,imm_out);
                instruction = 32'b00000000000000000000000000000101; #10;
                instruction = 32'b11111111111111111111111111111010; #10;
                instruction = 32'b10000000000000001111111111111010; #10;
                instruction = 32'b01111111111111110000000000000101; #10;
        $finish;
end
endmodule