module alu_control(alu_opcode,funct3,funct7,opcode);
input [2:0] funct3;
input [6:0] funct7, opcode;
output reg [2:0] alu_opcode;
always @ (*) begin
        case(opcode)
                7'b0110011 : begin
                        case(funct3)
                                3'b000 : alu_opcode = (funct7 == 7'b0100000) ? 3'b001 : 3'b000;
                                default : alu_opcode = 3'b0;
                        endcase
                end
                7'b0010011 : begin
                        alu_opcode = 3'b000;
                end
                default : alu_opcode = 3'b000;
        endcase
end
endmodule