`timescale 1ns / 1ps
module tb_alu_control;
reg [6:0] opcode,funct7;
reg [2:0] funct3;
wire [2:0] alu_opcode;
wire flag;
alu_control A1 (alu_opcode,flag,funct3,funct7,opcode);
initial begin
        opcode = 7'b0110011;
        funct7 = 7'b0;
        funct3 = 3'b0;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_alu_control);
$monitor("at time %t: opcode=%b funct7=%b funct3=%b alu_opcode=%b flag=%b",$time,opcode,funct7,funct3,alu_opcode,flag);
                opcode = 7'b0110011; funct7 = 7'b0000000; funct3 = 3'b000; #10;
                funct7 = 7'b0100000; funct3 = 3'b000; #10;
                funct3 = 3'b001; #10;
                funct3 = 3'b010; #10;
                funct3 = 3'b011; #10;
                funct3 = 3'b100; #10;
                funct3 = 3'b101; #10;
                funct3 = 3'b110; #10;
                funct3 = 3'b111; #10;
                opcode = 7'b0010011; funct3 = 3'b000; #10;
                funct3 = 3'b001; #10;
                funct3 = 3'b010; #10;
                funct3 = 3'b011; #10;
                funct3 = 3'b100; #10;
                funct3 = 3'b101; #10;
                funct3 = 3'b110; #10;
                funct3 = 3'b111; #10;
                opcode = 7'b0000000; #10;
        $finish;
end
endmodule 