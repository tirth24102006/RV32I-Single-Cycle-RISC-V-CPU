module register_file(Reg_output,read_data1,read_data2,write_data,rd,rs1,rs2,RegWrite,rst,clk);
input clk,rst,RegWrite;
input [4:0] rd,rs1,rs2;
output [31:0] read_data1,read_data2;
output reg [31:0] Reg_output;
input [31:0] write_data;
reg [31:0] Reg [0:31];
integer i;
always @ (posedge clk) begin
        if (rst) begin 
                for(i = 0; i < 32 ; i = i + 1) begin
                        Reg[i] <= 32'b0;
                end
                Reg_output <= 32'b0;
        end else begin
                if (RegWrite && rd != 5'b0) begin
                        Reg[rd] <= write_data;
                        Reg_output <= write_data;
                end else begin
                        Reg[rd] <= Reg[rd];
                        Reg_output <= Reg[rd];
                end
        end
end
assign read_data1 = (rs1 == 5'b0) ? 32'b0 : Reg[rs1];
assign read_data2 = (rs2 == 5'b0) ? 32'b0 : Reg[rs2];
endmodule