module instr_mem(instruction,pc_addr);
input [31:0] pc_addr;
output [31:0] instruction;
reg [31:0] mem [0:63];
assign instruction = mem[pc_addr[31:2]];
endmodule