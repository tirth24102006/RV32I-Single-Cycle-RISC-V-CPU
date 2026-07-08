`timescale 1ns / 1ps
module tb_riscv_core;
reg rst,clk;
wire [31:0] pc_out;
riscv_core uut (pc_out,rst,clk);
initial begin
        clk = 1'b0;
        rst = 1'b0;
end
always #5 clk = ~clk;
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_riscv_core);
$monitor("at time %t : clk = %b rst = %b pc_out=%b",$time,clk,rst,pc_out);
                rst = 1'b1; #10;
                uut.A2.mem[0] = 32'h00500093;
                uut.A2.mem[1] = 32'h00A00113;
                uut.A2.mem[2] = 32'h002081B3;
                uut.A2.mem[3] = 32'hFFD18213;
                uut.A2.mem[4] = 32'h004202B3;
                uut.A2.mem[5] = 32'hFFA00313;
                uut.A2.mem[6] = 32'h006283B3;
                uut.A2.mem[7] = 32'h40638433;
                rst = 1'b0;#10;
                #70;
                $display("---- Final Register Values ----");
                $display("x1 = %0d (expected 5)",  uut.A5.Reg[1]);
                $display("x2 = %0d (expected 10)", uut.A5.Reg[2]);
                $display("x3 = %0d (expected 15)", uut.A5.Reg[3]);
                $display("x4 = %0d (expected 12)", uut.A5.Reg[4]);
                $display("x5 = %0d (expected 24)", uut.A5.Reg[5]);
                $display("x6 = %0d (expected -6)", $signed(uut.A5.Reg[6]));
                $display("x7 = %0d (expected 18)", uut.A5.Reg[7]);
                $display("x8 = %0d (expected 24)", uut.A5.Reg[8]);
        $finish;
end
endmodule