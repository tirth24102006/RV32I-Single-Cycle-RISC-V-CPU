module imm_gen(imm_out,instruction);
input [31:0] instruction;
output [31:0] imm_out;
assign imm_out = {{20{instruction[31]}},instruction[31:20]};
endmodule