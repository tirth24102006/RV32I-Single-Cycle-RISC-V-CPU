module ALU_RISCV(result,operand1,operand2,alu_opcode);
input [31:0] operand1,operand2;
input [2:0] alu_opcode;
output [31:0] result;
reg [31:0] res;
always @(*) begin
        res = 32'b0;
        case(alu_opcode)
                3'b000: res = operand1 + operand2; // ADD
                3'b001: res = operand1 - operand2; // SUB
                3'b010: res = operand1 & operand2; // AND
                3'b011: res = operand1 | operand2; // OR
                3'b100: res = operand1 ^ operand2; // XOR
                3'b101: res = (operand1 < operand2) ? 32'b1 : 32'b0; // SLT
                3'b110: res = operand1 << operand2[4:0]; // SLL
                3'b111: res = operand1 >> operand2[4:0]; // SRL
                default : res = 32'b0;
        endcase
end
assign result = res;
endmodule
