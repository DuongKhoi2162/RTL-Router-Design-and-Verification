`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 06:27:02 AM
// Design Name: 
// Module Name: router_test_top
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
module router_test_top ; 
parameter simulation_cycle = 100 ; 
bit SystemClock ; 
router_io top_io(SystemClock); 
test t(top_io);
router DUT(.reset_n(top_io.reset_n),
.clk(SystemClock), 
.frame_n(top_io.frame_n), 
.valid_n(top_io.valid_n),
.din(top_io.din), 
.dout(top_io.dout), 
.busy_n(top_io.busy_n) ,
.valido_n(top_io.valido_n),
.frameo_n(top_io.frameo_n)); 
initial begin
    SystemClock = 0 ;
    forever begin 
        #(simulation_cycle/2) SystemClock = !SystemClock ; 
        end
end 
endmodule 
 ////////////////////////////////////////////////
interface router_io(input bit clock);
logic reset_n ; 
logic  [15:0] frame_n;
logic  [15:0] valid_n;
logic  [15:0] din;
logic [15:0] dout;
logic  [15:0] busy_n;
logic [15:0] valido_n;
logic [15:0] frameo_n;
clocking cb @(posedge clock) ; 
    default input #1 output #1 ; 
    output reset_n ; 
    output din ; 
    output frame_n ; 
    output valid_n ; 
    input dout ; 
    input valido_n ; 
    input busy_n ; 
    input frameo_n ; 
 endclocking: cb 
 modport TB(clocking cb , output reset_n) ; 
 endinterface: router_io 
 ////////////////////////////////////////////////
 program automatic test( router_io.TB rtr_io);
 bit[3:0] sa ; 
 bit[3:0] da ; 
 logic[7:0] payload [$] ; 
 logic[7:0] pkt2ccmp_payload[$] ; 
 logic[4:0] packet_count = 0; 
 int run_for_n_packets = 21;
 initial begin 
 reset() ; 
 repeat(run_for_n_packets) begin
 gen() ; 
    fork
         send() ; 
         recv();
         packet_count = packet_count + 1 ;
    join
        check(); 
    end 
 end
 ///////////////////////////////////////////////////////////////////////////
 task reset();
    rtr_io.reset_n = 1'b0 ; 
    rtr_io.cb.frame_n <= 16'hFFFF ; 
    rtr_io.cb.valid_n <= 16'hFFFF ; 
    ##2 rtr_io.cb.reset_n <= 1'b1 ; 
    repeat(15) @(rtr_io.cb) ;
 endtask: reset
 ///////////////////////////////////////////////////////////////////////////
 task gen();
    sa = $random ;
    da = $random ;
    payload.delete();
    pkt2ccmp_payload.delete(); 
    payload.push_back($random) ; 
 endtask: gen
 ///////////////////////////////////////////////////////////////////////////
 task send();
    send_addrs();
    send_pad() ; 
    send_payload(); 
 endtask:send
 ///////////////////////////////////////////////////////////////////////////
 task send_addrs();
    integer i = 1 ; 
    rtr_io.cb.frame_n[sa] <= 1'b0 ; 
    rtr_io.cb.din[sa] <= da[0] ; ////
    repeat(3)@rtr_io.cb begin
        rtr_io.cb.din[sa] <= da[i] ; //
        i = i + 1 ; 
    end
 endtask: send_addrs
 ///////////////////////////////////////////////////////////////////////////
 task send_pad(); 
    rtr_io.cb.frame_n[sa] <= 1'b0 ; 
    rtr_io.cb.valid_n[sa] <= 1'b1 ;
    repeat(8)@rtr_io.cb;
endtask:send_pad 
///////////////////////////////////////////////////////////////////////////
task send_payload();
     integer i , j ; 
     foreach(payload[i])
     for(j = 0 ; j < 8 ; j = j + 1 ) begin 
        rtr_io.cb.din[sa] <= payload[i][j] ; 
        rtr_io.cb.valid_n[sa] <= 1'b0; 
        if(j==7) rtr_io.cb.frame_n[sa] <= 1'b1 ; 
        @rtr_io.cb ; 
     end
     rtr_io.cb.valid_n[sa] <= 1'b1 ;
endtask:send_payload
///////////////////////////////////////////////////////////////////////////
task recv();
    int r ; 
    get_payload() ; 
endtask: recv 
///////////////////////////////////////////////////////////////////////////
task get_payload();
    logic [7:0] actual_payload ; 
    repeat(13)@(rtr_io.cb) ; 
    for (int i = 0 ; i < 8 ; i = i + 1 ) begin 
         actual_payload[i] = rtr_io.cb.dout[da] ; 
        @rtr_io.cb ; 
    end 
    pkt2ccmp_payload.push_back(actual_payload);
endtask: get_payload
///////////////////////////////////////////////////////////////////////////
function bit compare();
    if(payload == pkt2ccmp_payload) return 1 ; 
    else return 0 ;  
endfunction:compare
///////////////////////////////////////////////////////////////////////////
task check() ;
    if(compare()) $display("Packet %d passed successfully, Expected payload: %d , Actual payload: %d",packet_count,payload[0],pkt2ccmp_payload[0]) ; 
    else $display("Packet %d failed , Expected payload: %d , Actual payload: %d",packet_count,payload[0],pkt2ccmp_payload[0]) ; 
endtask:check
 endprogram

