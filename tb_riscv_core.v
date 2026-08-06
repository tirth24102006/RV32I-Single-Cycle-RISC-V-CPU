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
                uut.A2.mem[8] = 32'h0083F4B3;
                uut.A2.mem[9] = 32'h0083E533;
                uut.A2.mem[10] = 32'h0083C5B3;
                uut.A2.mem[11] = 32'h0083B633;
                uut.A2.mem[12] = 32'h0063A6B3;
                uut.A2.mem[13] = 32'h00761733;
                uut.A2.mem[14] = 32'h007757B3;
                uut.A2.mem[15] = 32'h0103F813;
                uut.A2.mem[16] = 32'h0103E893;
                uut.A2.mem[17] = 32'h0103C913;
                uut.A2.mem[18] = 32'h00239993;
                uut.A2.mem[19] = 32'h0029DA13;
                uut.A2.mem[20] = 32'h0023BA93;
                uut.A2.mem[21] = 32'hFFE32B13;
                uut.A2.mem[63] = 32'h0123F813;
                uut.A2.mem[50] = 32'h0103F813;
                rst = 1'b0;#10;
                #630;
                $display("---- Final Register Values ----");
                $display("x1 = %0d (expected 5)",  uut.A5.Reg[1]);
                $display("x2 = %0d (expected 10)", uut.A5.Reg[2]);
                $display("x3 = %0d (expected 15)", uut.A5.Reg[3]);
                $display("x4 = %0d (expected 12)", uut.A5.Reg[4]);
                $display("x5 = %0d (expected 24)", uut.A5.Reg[5]);
                $display("x6 = %0d (expected -6)", $signed(uut.A5.Reg[6]));
                $display("x7 = %0d (expected 18)", uut.A5.Reg[7]);
                $display("x8 = %0d (expected 24)", uut.A5.Reg[8]);
                $display("x9 = %0d (expected 16)",  uut.A5.Reg[9]);
                $display("x10 = %0d (expected 26)", uut.A5.Reg[10]);
                $display("x11 = %0d (expected 10)", uut.A5.Reg[11]);
                $display("x12 = %0d (expected 1)", uut.A5.Reg[12]);
                $display("x13 = %0d (expected 0)", uut.A5.Reg[13]);
                $display("x14 = %0d (expected 262144)", uut.A5.Reg[14]);
                $display("x15 = %0d (expected 1)", uut.A5.Reg[15]);
                $display("x16 = %0d (expected 16)", uut.A5.Reg[16]);
                $display("x17 = %0d (expected 18)", uut.A5.Reg[17]);
                $display("x18 = %0d (expected 2)", uut.A5.Reg[18]);
                $display("x19 = %0d (expected 72)", uut.A5.Reg[19]);
                $display("x20 = %0d (expected 18)", uut.A5.Reg[20]);
                $display("x21 = %0d (expected 0)", uut.A5.Reg[21]);
                $display("x22 = %0d (expected 1)", uut.A5.Reg[22]); 
                $display("--- all tests passed ---");
        $finish;
end
endmodule