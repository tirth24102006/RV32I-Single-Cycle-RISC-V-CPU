`timescale 1ns / 1ps
module tb_register_file;
reg rst,clk,RegWrite;
reg [4:0] rd,rs1,rs2;
reg [31:0] write_data;
wire [31:0] read_data1,read_data2,Reg_out;
register_file A1(Reg_out,read_data1,read_data2,write_data,rd,rs1,rs2,RegWrite,rst,clk);
initial begin
        clk = 1'b0;
        rst = 1'b0;
        RegWrite = 1'b0;
        rd = 5'b00000;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        write_data = 32'b0;
end
always #5 clk=~clk;
initial begin
$dumpfile("dump.vcd");
$dumpvars(0, tb_register_file);
$timeformat(-9, 2, " ns", 10);
$monitor("at time %t: clk=%b rst=%b RegWrite=%b rd=%b rs1=%b rs2=%b write_data=%b read_data1=%b read_data2=%b Reg_out=%d",$time,clk,rst,RegWrite,rd,rs1,rs2,write_data,read_data1,read_data2,Reg_out);
                rst = 1'b1; #10;//0//0//0
                rst = 1'b0; RegWrite = 1'b1; rd = 5'b00001; write_data = 32'b00000000000000000000000000000101; #10;//0//0//5
                rd = 5'b00010; write_data = 32'b00000000000000000000000000001010; #10;//0//0//10
                RegWrite = 1'b0; rs1 = 5'b00001; rs2 = 5'b00010; #10;//101//1010//10
                rs1 = 5'b00000; rs2 = 5'b00001; #10;//0//101//10
                rs1 = 5'b00010; rs2 = 5'b00000; #10;//1010//0//10
        $finish;
end
endmodule