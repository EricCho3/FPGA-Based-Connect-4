`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/01/2026 03:39:32 PM
// Design Name: 
// Module Name: VGA_Sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      VGA timing calculation for 640x480 pixels @ 60hz
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Sync(
    input clk, //100Mhz
    input rst,
    output H_sync, //ON = HIGH ACTIVE; OFF = LOW ACTIVE
    output V_sync, //ON = HIGH ACTIVE; OFF = LOW ACTIVE
    output reg [9:0] H_counter, //x coord (0-799 in decimal)
    output reg [9:0] V_counter, //y coord (0-520 in decimal)
    output is_video_on //when x coord and y coord are in the 640x480 display range
    );

    //respectively: sync pulse, display time, pulse width, front porch, back porch for 640x480 @60hz
    localparam Vs = 521, Vdisp = 480, Vpw = 2, Vfp = 10, Vbp = 29; //vertical
    localparam Hs = 800, Hdisp = 640, Hpw = 96, Hfp = 16, Hbp = 48; //horizontal 
    
    wire clk_25; //25Mhz clk
    clk_25Mhz instance1 (clk, rst, clk_25);

    always @(posedge clk_25, posedge rst) begin //(since the vector starts at zero, the values here are postively offset by one)
        if (rst) begin
            H_counter <= 0;
            V_counter <= 0;
        end 
        else if (H_counter == (Hs - 1)) begin //when H_counter reaches the max clk count
            H_counter <= 0; //roll over

            if(V_counter == (Vs - 1)) //vector starts at zero
                V_counter <= 0; //roll over once new frame starts
            else
                V_counter <= V_counter + 1; //increases when respective horizontal sync finishes
        end 
        else
            H_counter <= H_counter + 1; //next horizontal sync line (top to bottom of the screen)
    end

    //we only want to turn off (low active) V/H sync when in the pulse width region
    //from start: display time -> front porch -> pulse width -> back porch -> display time ...
    //thus, for V/H sync, we must select their respective pulse width region to low active
    assign H_sync = (H_counter < (Hdisp + Hfp)) || ((Hdisp + Hfp + Hpw) <= H_counter); //note that the vector starts at zero when choosing inequality
    assign V_sync = (V_counter < (Vdisp + Vfp)) || ((Vdisp + Vfp + Vpw) <= V_counter); //logical OR always yields one bit values (comparisons)
    assign is_video_on = (H_counter < Hdisp) && (V_counter < Vdisp); // if the coordinates are within 640x480

endmodule
