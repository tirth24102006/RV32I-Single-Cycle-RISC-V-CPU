`timescale 1ns / 1ps
module tb_alu_control;
reg [6:0] opcode,funct7;
reg [2:0] funct3;
wire [2:0] alu_opcode;
alu_control A1 (alu_opcode,funct3,funct7,opcode);
initial begin
        opcode = 7'b0110011;
        funct7 = 7'b0;
        funct3 = 3'b0;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_alu_control);
$monitor("at time %t: opcode=%b funct7=%b funct3=%b alu_opcode=%b",$time,opcode,funct7,funct3,alu_opcode);
                #10;//000
                funct7 = 7'b0100000; #10;//001
                opcode = 7'b0010011; #10;//000
        $finish;
end
endmodule 