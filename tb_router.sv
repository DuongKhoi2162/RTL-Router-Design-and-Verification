
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2024 02:34:56 PM
// Design Name: 
// Module Name: tb_router
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module tb_router();
reg  reset_n;
reg  clk = 0;
reg [15:0] frame_n;
reg [15:0] valid_n;
reg [15:0] din;
wire [15:0] dout;
wire [15:0] busy_n;
wire [15:0] valido_n;
wire [15:0] frameo_n;
router DUT(.reset_n(),
.clk(clk), 
.frame_n(frame_n), 
.valid_n(valid_n),
.din(din), 
.dout(dout), 
.busy_n(busy_n) ,
.valido_n(valido_n),
.frameo_n(frameo_n)); 
//test 
always #10 clk = !clk ; 
initial begin 
Test() ; 
end
task Test(); 
#0 frame_n = 16'hFFFF ; 
   valid_n = 16'hFFFF ; 
   reset_n = 1 ;
   clk = 1 ; 
#20 reset_n = 0 ;  
#20 reset_n = 1 ; 
    frame_n[1] = 0 ; 
    frame_n[10] = 0 ; 
    din[1] = 1 ; 
    din[10] = 1 ; 
#20 din[1] = 1 ; 
    din[10] = 0 ; 
#20 din[1] = 1 ; 
    din[10] = 1 ; 
#20 din[1] = 1 ; 
    din[10] = 0 ; 
    valid_n[1] = 0 ; 
    valid_n[10] = 0 ; 
repeat(15) begin
    #20 din[1] = $random ; 
    din[10] = $random ;
end 
#20 din[1] = 0; 
    din[10] = $random ; 
    frame_n = 16'hFFFF ;
#20 valid_n = 16'hFFFF ; 
    frame_n[3] = 0 ; 
    frame_n[4] = 0 ; 
    din[3] = 1 ; 
    din[4] = 1 ; 
#20 ; 
#20 ; 
#20 valid_n[3] = 0 ; 
    valid_n[4] = 1 ;  
repeat(15) begin
#20  din[3] = $random ;
    din[4] = 1'bx ; 
end 
#20 din[3] = $random ; 
    din[4] = 1'bx ; 
    frame_n[3] = 1 ; 
    valid_n[4] = 0 ; 
repeat(15) begin
#20  din[4] = $random ;
    din[3] = $random  ; 
end 
#20 din[4] = $random ; 
    din[3] = $random  ;
#20 frame_n = 16'hFFFF; 
    valid_n = 16'hFFFF;
    frame_n[9] = 0 ; 
    frame_n[2] = 0 ; 
    din[2] = 0 ; 
    din[9] = 0 ; 
#20 ; 
#20 ; 
#20 valid_n[2] = 0 ; 
    valid_n[9] = 0 ;  
repeat(10) begin
#20  din[2] = $random ;
     din[9] = $random ; 
end 
#20 valid_n[2] = 1 ;
    valid_n[9] = 1 ; 
repeat(5) begin 
#20  valid_n[2] = 0 ;
    valid_n[9] = 0 ; 
    din[2] = $random ;
    din[9] = $random ; 
end 
#20 din[2] = $random ; 
    din[9] = $random ; 
    frame_n = 16'hFFFF ; 
    valid_n = 16'hFFFF ;
$finish;
endtask
endmodule

