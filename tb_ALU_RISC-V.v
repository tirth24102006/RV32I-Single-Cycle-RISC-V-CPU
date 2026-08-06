`timescale 1ns / 1ps
module tb_ALU_RISC_V;
reg [31:0] operand1,operand2;
reg [2:0] alu_opcode;
wire [31:0] result;
reg flag;
ALU_RISCV A1(result,operand1,operand2,alu_opcode,flag);
initial begin
        operand1 = 32'b0;
        operand2 = 32'b0;
        alu_opcode = 3'b000;
        flag=1'b0;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0, tb_ALU_RISC_V);
$monitor("at time %t: operand1=%b operand2=%b alu_opcode=%b flag=%b result=%b",$time,operand1,operand2,alu_opcode,flag,result);
                operand1 = 32'b00000000000000000000000000000101; operand2 = 32'b00000000000000000000000000000110; alu_opcode = 3'b000; #10;
                alu_opcode = 3'b001; #10;
                alu_opcode = 3'b010; #10;
                alu_opcode = 3'b011; #10;
                alu_opcode = 3'b100; #10;
                alu_opcode = 3'b101; #10;
                alu_opcode = 3'b110; #10;
                alu_opcode = 3'b111; #10;
                flag =1'b1;alu_opcode = 3'b101; operand1 = 32'b10000000000000000000000000000101; operand2 = 32'b10000000000000000000000000000110; #10;
        $finish;
end
endmodule