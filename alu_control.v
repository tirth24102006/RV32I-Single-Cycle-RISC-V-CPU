module alu_control(alu_opcode,flag,funct3,funct7,opcode);
input [2:0] funct3;
input [6:0] funct7, opcode;
output reg [2:0] alu_opcode;
output flag;
always @ (*) begin
        case(opcode)
                7'b0110011 : begin
                        case(funct3)
                                3'b000 : alu_opcode = (funct7 == 7'b0100000) ? 3'b001 : 3'b000;
                                3'b001 : alu_opcode = 3'b110;
                                3'b010 : alu_opcode = 3'b101;
                                3'b011 : alu_opcode = 3'b101;
                                3'b100 : alu_opcode = 3'b100;
                                3'b101 : alu_opcode = 3'b111;
                                3'b110 : alu_opcode = 3'b011;
                                3'b111 : alu_opcode = 3'b010;
                                default : alu_opcode = 3'b0;
                        endcase
                end
                7'b0010011 : begin
                        case(funct3)
                                3'b000 : alu_opcode = 3'b000;
                                3'b001 : alu_opcode = 3'b110;
                                3'b010 : alu_opcode = 3'b101;
                                3'b011 : alu_opcode = 3'b101;
                                3'b100 : alu_opcode = 3'b100;
                                3'b101 : alu_opcode = 3'b111;
                                3'b110 : alu_opcode = 3'b011;
                                3'b111 : alu_opcode = 3'b010;
                                default : alu_opcode = 3'b0;
                        endcase
                end
                default : alu_opcode = 3'b000;
        endcase
end
assign flag = funct3==3'b010;
endmodule