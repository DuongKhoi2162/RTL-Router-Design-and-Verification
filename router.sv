`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2024 01:14:29 PM
// Design Name: 
// Module Name: router
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


module router(
input  reset_n,
input  clk,
input  [15:0] frame_n,
input  [15:0] valid_n,
input  [15:0] din,
output reg [15:0] dout,
output  [15:0] busy_n,
output reg [15:0] valido_n,
output reg [15:0] frameo_n
    );
bit [2:0] state[15:0];
bit [2:0] i[15:0];
bit [3:0] addr_dest[15:0];
bit [3:0] port;
reg [15:0] temp_busy  = 0 ; 
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        for(port = 0; port < 16; port = port + 1) begin
        state[port] = 0;
        i[port] = 0;
        frameo_n[port] = 1;
        valido_n[port] = 1;
        temp_busy[port] = 0;
        end
    end
    else begin
        for(port = 0; port < 16; port = port + 1) begin
            if(state[port] == 0 && frame_n[port] == 0 ) begin        
            state[port] = 1; 
            end
            else if(state[port] == 1 && i[port] == 4) begin
            if(temp_busy[addr_dest[port]]==0) begin
            temp_busy[addr_dest[port]] = 1 ; 
            state[port] = 3 ; 
            i[port] = 0;
            end
            else begin 
            state[port] =  2 ;
            i[port] = 0 ; 
            end
            end
            else if(state[port] == 2 ) begin 
                if(frame_n[port] == 1 ) state[port] = 0 ; 
                else if (temp_busy[addr_dest[port]] == 0) begin
                state[port] = 3;
                temp_busy[addr_dest[port]] = 1 ; 
                end
            end
            else if(state[port] == 3 && frame_n[port] == 1)  begin
                state[port] = 4;
            end
            else if(state[port]==4) begin
                state[port] = 0 ; 
                dout[addr_dest[port]] = 1'bx ;
                break; 
            end 
        end
    end
end
always @(posedge clk) begin
    for(port = 0; port < 16; port = port + 1) begin
        if((state[port] == 0 | state[port] == 1)) begin
         if(frame_n[port]==0) begin
            addr_dest[port][i[port]] = din[port];
            i[port] = i[port] + 1;
            end
        end
       else if(state[port] == 2 ) begin 
            if(temp_busy[addr_dest[port]] == 0) state[port]=3 ; 
       end
       else if(state[port] == 3 ) begin
            frameo_n[addr_dest[port]] = frame_n[port];
            valido_n[addr_dest[port]] = valid_n[port]; 
            if(valid_n[port] == 0 && frame_n[port] == 0 ) begin 
                dout[addr_dest[port]] = din[port];
            end
            else begin
                dout[addr_dest[port]] = 1'bx;
            end  
        end
       else if(state[port] == 4) begin 
            temp_busy[addr_dest[port]] = 0 ;
            frameo_n[addr_dest[port]] = 1'b1;
            valido_n[addr_dest[port]] = valid_n[port];  
             if(valid_n[port] == 0 ) begin 
                dout[addr_dest[port]] = din[port];
            end
            else begin
                dout[addr_dest[port]] = 1'bx;
            end  
       end 
    end
end
assign busy_n = temp_busy ;

endmodule


