module address_sel(fetch_address,jump,address,pc_out);
input jump;
input [31:0] address,pc_out;
output [31:0] fetch_address;
assign fetch_address = jump ? address<<2'd2 : pc_out;
endmodule