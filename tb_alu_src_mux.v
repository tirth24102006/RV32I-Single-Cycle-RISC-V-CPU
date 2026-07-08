`timescale 1ns / 1ps
module tb_alu_src_mux;
reg ALUsrc;
reg [31:0] read_data2,imm_out;
wire [31:0] operand2;
alu_src_mux A1(operand2,imm_out,read_data2,ALUsrc);
initial begin
        ALUsrc = 1'b0;
        read_data2 = 32'b0;
        imm_out = 32'b0;
end
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_alu_src_mux);
$monitor("at time %t : ALUsrc=%b read_data2=%b imm_out=%b operand2=%b",$time,ALUsrc,read_data2,imm_out,operand2);
                read_data2 = 32'b01010; imm_out = 32'b01011; #10;//01010
                ALUsrc = 1'b1; #10; //01011
        $finish;
end
endmodule
