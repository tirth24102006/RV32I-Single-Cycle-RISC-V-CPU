`timescale 1ns / 1ps
module tb_address_sel;
reg jump;
reg [31:0] address,pc_out;
wire [31:0] fetch_address;
address_sel a1 (fetch_address,jump,address,pc_out);
initial begin
        jump=1'b0;
end
initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0,tb_address_sel);
        $monitor("at time : %t | jump = %b |address = %d | pc_out = %d | fetch_address=%d | ",$time,jump,address,pc_out,fetch_address);
        jump = 1'b1 ; address = 32'd1;#10;//4
        jump = 1'b0 ; pc_out = 32'd1;#10;//1
        $finish;
end
endmodule