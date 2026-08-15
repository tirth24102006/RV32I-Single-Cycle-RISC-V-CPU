`timescale 1ns/ 1ps
module tb_pc_reg;
reg clk,rst,jump;
wire [31:0] pc_out;
pc_reg A1 (pc_out,jump,rst,clk);
initial begin
        clk = 1'b0;
        rst = 1'b0;
        jump = 1'b0;
end
always #5 clk = ~clk;
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_pc_reg);
$monitor("at time %t: clk=%b rst=%b jump=%b pc_out=%d",$time,clk,rst,jump,pc_out);
                rst = 1'b1; #10;
                rst = 1'b0; #100;
                jump = 1'b1; #40;
                jump = 1'b0 ; rst = 1'b1; #10;
        $finish;
end
endmodule