`timescale 1ns / 1ps
module tb_riscv_core;
reg rst,clk,jump;
reg [31:0] address,number;
wire [31:0] Reg_output;
integer errors = 0;
integer test_num = 0;
riscv_core uut (Reg_output,address,number,jump,rst,clk);
initial begin
        clk = 1'b0;
        rst = 1'b0;
        jump = 1'b0;
end
always #5 clk = ~clk;
task load_program;
        input test_rst;
        input test_jump;
        input [31:0] test_address;
        input [31:0] test_number;
        input [31:0] exp_Reg_output;
        begin
                address = test_address;
                number = test_number;
                rst = test_rst;
                jump = test_jump;
                @(posedge clk);#1;
                test_num = test_num + 1;
                if(Reg_output !== exp_Reg_output) begin
                        $display("Test %d failed: expected Reg_output = %d, got Reg_output = %d", test_num, $signed(exp_Reg_output), $signed(Reg_output));
                        errors = errors + 1;
                end else begin
                        $display("Test %d passed: Reg_output = %d", test_num, $signed(Reg_output));
                end
        end                
endtask
initial begin
$dumpfile("dump.vcd");
$dumpvars(0,tb_riscv_core);
$timeformat(-9, 2, " ns", 10);
//$monitor("at time %t : | clk = %b | rst = %b | jump=%b |address = %d | number = %d | Reg_output = %d",$time,clk,rst,jump,address,number,Reg_output);
end
initial begin
        $display("----------------------------------------------------------------------------------------");
        $display("--------- start tasting ---------");
        $display("----------------------------------------------------------------------------------------");
        load_program(1'b1,1'b0,32'd0,32'b0,32'd0);
        load_program(1'b0,1'b0,32'd0,32'h00500093,32'h00000005);
        load_program(1'b0,1'b0,32'd1,32'h00A00113,32'h0000000A);
        load_program(1'b0,1'b0,32'd2,32'h002081B3,32'h0000000F);
        load_program(1'b0,1'b0,32'd3,32'hFFD18213,32'h0000000C);
        load_program(1'b0,1'b0,32'd4,32'h004202B3,32'h00000018);
        load_program(1'b0,1'b0,32'd5,32'hFFA00313,32'hFFFFFFFA);
        load_program(1'b0,1'b0,32'd6,32'h006283B3,32'h00000012);
        load_program(1'b0,1'b0,32'd7,32'h40638433,32'h00000018);
        load_program(1'b0,1'b0,32'd8,32'h0083F4B3,32'h00000010);
        load_program(1'b0,1'b0,32'd9,32'h0083E533,32'h0000001A);
        load_program(1'b0,1'b0,32'd10,32'h0083C5B3,32'h0000000A);
        load_program(1'b0,1'b0,32'd11,32'h0083B633,32'h00000001);
        load_program(1'b0,1'b0,32'd12,32'h0063A6B3,32'h0);
        load_program(1'b0,1'b0,32'd13,32'h00761733,32'h00040000);
        load_program(1'b0,1'b0,32'd14,32'h007757B3,32'h00000001);
        load_program(1'b0,1'b0,32'd15,32'h0103F813,32'h00000010);
        load_program(1'b0,1'b0,32'd16,32'h0103E893,32'h00000012);
        load_program(1'b0,1'b0,32'd17,32'h0103C913,32'h00000002);
        load_program(1'b0,1'b0,32'd18,32'h00239993,32'h00000048);
        load_program(1'b0,1'b0,32'd19,32'h0029DA13,32'h00000012);
        load_program(1'b0,1'b0,32'd20,32'h0023BA93,32'h0);
        load_program(1'b0,1'b0,32'd21,32'hFFE32B13,32'h00000001);
        load_program(1'b0,1'b1,32'd63,32'h0123F813,32'h00000012);
        load_program(1'b0,1'b0,32'd22,32'h0103F813,32'h00000010);
        load_program(1'b0,1'b1,32'd50,32'h0003F813,32'h0);
        load_program(1'b1,1'b0,32'b0,32'b0,32'b0);
        $display("----------------------------------------------------------------------------------------");
        if(errors == 0) begin
                $display("--------- All tests passed ---------");
        end else if (errors == 1) begin
                $display(" %d test failed ",errors);
        end else begin
                $display(" %d tests failed ",errors);
        end
        $display("----------------------------------------------------------------------------------------");
        $finish;
end
endmodule