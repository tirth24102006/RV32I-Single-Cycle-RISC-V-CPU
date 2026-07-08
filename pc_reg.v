module pc_reg(pc_out,rst,clk);
input rst,clk;
output reg [31:0] pc_out;
always @ (posedge clk) begin
        if (rst) begin
                pc_out <= 32'b0;
        end else begin
                pc_out <= pc_out + 32'b00000000000000000000000000000100;
        end
end
endmodule       