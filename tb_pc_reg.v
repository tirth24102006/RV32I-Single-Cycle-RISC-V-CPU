`timescale 1ns/ 1ps
module tb_pc_reg;
reg clk,rst;
wire [31:0] pc_out;
pc_reg A1 (pc_out,rst,clk);
initial begin
        clk = 1'b0;
        rst = 1'b0;
end
always #5 clk = ~clk;
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_pc_reg);
$monitor("at time %t: clk=%b rst=%b pc_out=%d",$time,clk,rst,pc_out);
                rst = 1'b1; #10;
                rst = 1'b0; #100;
                rst = 1'b1; #10;
        $finish;
end
endmodule