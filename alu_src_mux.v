module alu_src_mux(operand2,imm_out,read_data2,ALUsrc);
input ALUsrc;
input [31:0] imm_out ,read_data2;
output [31:0] operand2;
assign operand2 = ALUsrc ? imm_out : read_data2 ;
endmodule