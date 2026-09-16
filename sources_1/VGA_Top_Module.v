`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/05/2026 12:54:29 AM
// Design Name: 
// Module Name: VGA_top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Connects the VGA modules 
// Dependencies: 
//      
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Top_Module(
    input clk,
    input rst,
    input [2:0] state,
    output reg [11:0] RGB,
    input [9:0] H_counter, 
    input [9:0] V_counter,
    input [41:0] p1_board,
    input [41:0] p2_board,
    input [2:0] input_placement,
    input player_turn,
    input is_video_on
    );
    
    wire winner;
    
    wire [11:0] RGB_start, RGB_game, RGB_end;

    VGA_Start instance2 (clk, rst, RGB_start, H_counter, V_counter, is_video_on);
    VGA_Game instance3 (clk, rst, RGB_game, H_counter, V_counter, is_video_on, p1_board, p2_board, input_placement, player_turn);
    VGA_End instance4 (clk, rst, RGB_end, H_counter, V_counter, is_video_on, state); //forgot to add state to module instance declaration...spent that time debugging incorrect draw image
    //VGA_Draw instance5 (clk, rst, RGB_end, H_counter, V_counter, is_video_on, state);

    always @* begin 
        if (state == 0) //start screen
            RGB = RGB_start;
        else if (state == 1 || state == 2) //game screen: player 1/2 turn state
            RGB = RGB_game;
        else if (state == 3 || state == 4 || state == 5) //end screen: player 1/2 win state & draw
            RGB = RGB_end;
        //else if (state == 5)
        //    RGB = RGB_draw;
        else    
            RGB = 12'hF00;
    end

endmodule
