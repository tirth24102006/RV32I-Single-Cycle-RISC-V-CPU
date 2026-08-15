module pc_reg(pc_out,jump,rst,clk);
input rst,clk,jump;
output reg [31:0] pc_out;
always @ (posedge clk) begin
        if (rst) begin
                pc_out <= 32'b0;
        end else begin
                if(jump) begin
                        pc_out<=pc_out;
                end else begin
                        pc_out <= pc_out + 32'd4;
                end     
        end
end
endmodule       