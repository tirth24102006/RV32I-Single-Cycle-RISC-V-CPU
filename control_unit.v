module control_unit(RegWrite,ALUSrc,opcode);
input [6:0] opcode;
output RegWrite,ALUSrc;
assign RegWrite = (opcode == 7'b0110011 || opcode == 7'b0010011) ? 1'b1 : 1'b0;
assign ALUSrc = (opcode == 7'b0010011) ? 1'b1 : 1'b0;
endmodule 