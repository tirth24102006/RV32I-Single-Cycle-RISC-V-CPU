module instr_mem(instruction,address,number,pc_addr);
input [31:0] pc_addr,address,number;
output [31:0] instruction;
reg [31:0] mem [0:63];
always @(*) begin
        mem[address[31:0]] = number;
end
assign instruction = mem[pc_addr[31:2]];
endmodule