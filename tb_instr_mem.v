`timescale 1ns / 1ps
module tb_instr_mem;
reg [31:0] pc_addr,number,address;
wire [31:0] instruction;
instr_mem A1 (instruction,address,number,pc_addr);
initial begin
        pc_addr = 32'b0;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_instr_mem);
$monitor("at time %t : pc_adder=%b address=%b number=%b instruction=%d",$time,pc_addr,address,number,instruction);
                address = 32'b1; number = 32'd2; pc_addr = 32'd4;//2
        $finish;
end
endmodule