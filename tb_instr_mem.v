`timescale 1ns / 1ps
module tb_instr_mem;
reg [31:0] pc_addr;
wire [31:0] instruction;
instr_mem A1 (instruction,pc_addr);
initial begin
        pc_addr = 32'b0;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_instr_mem);
$monitor("at time %t : pc_adder=%b instruction=%b",$time,pc_addr,instruction);
                A1.mem[0] = 32'b1;#10;//1
                A1.mem[25] = 32'b0;#10;
                pc_addr = 32'd100; #10;//00
                pc_addr = 32'd10; #10;//X
        $finish;
end
endmodule