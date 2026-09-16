`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/02/2026 04:20:59 AM
// Design Name: 
// Module Name: VGA_Game
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      VGA RGB information for the in game screen
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module VGA_Game(
    input clk,
    input rst,
    output reg [11:0] RGB, // R[11:8], G[7:4], B[3:0]
    input [9:0] H_counter,
    input [9:0] V_counter,
    input is_video_on,
    input [41:0] p1_board,
    input [41:0] p2_board,
    input [2:0] input_placement,
    input player_turn //1 = player 1; 0 = player 2
    );

    // for Veritical and horizontal board lines   
    wire in_board_H = (H_counter == 40 || H_counter == 120 || H_counter == 200 || H_counter == 280 || H_counter == 360 || H_counter == 440 || H_counter == 520 || H_counter == 600) && (60 <= V_counter && V_counter < 420); 
    wire in_board_V = (40 < H_counter && H_counter <= 600) && (V_counter == 60 || V_counter == 120 || V_counter == 180 || V_counter == 240 || V_counter == 300 || V_counter == 360 || V_counter == 420); 
    
    //object to be dropped
    wire cursor_middle = (55 + input_placement*80 < H_counter && H_counter <= 105 + input_placement*80) && (10 < V_counter && V_counter <= 50);
    wire cursor_bottom = (62 + input_placement*80 < H_counter && H_counter <= 98 + input_placement*80) && (50 < V_counter && V_counter <= 55);
    wire cursor_top = (62 + input_placement*80 < H_counter && H_counter <= 98 + input_placement*80) && (5 < V_counter && V_counter <= 10);
    wire in_cursor = cursor_top || cursor_middle || cursor_bottom;

    wire in_grid = (H_counter > 40 && H_counter <= 600) && (V_counter > 60 && V_counter <= 420);
    
    //which column/row box we are in (out of the 42 boxes)
    wire [2:0] column_index = (H_counter <= 120) ? 3'd0 : //if H_counter reaches the starting edge of the first of the possible 7 columns (left to right)
                              (H_counter <= 200) ? 3'd1 : 
                              (H_counter <= 280) ? 3'd2 :
                              (H_counter <= 360) ? 3'd3 :
                              (H_counter <= 440) ? 3'd4 :
                              (H_counter <= 520) ? 3'd5 : 3'd6;

    wire [2:0] row_index =  (V_counter <= 120) ? 3'd0 : //if V_counter reaches the starting edge of the first of the possible 6 rows (top to bottom - inverted in bitboard_logic module)
                            (V_counter <= 180) ? 3'd1 :
                            (V_counter <= 240) ? 3'd2 :
                            (V_counter <= 300) ? 3'd3 :
                            (V_counter <= 360) ? 3'd4 : 3'd5;
    
    //board index (42 possible spots) (note: vector starts at zero; hence, adding column index)
    wire [5:0] board_index = (row_index * 7) + column_index;

    // Relative Cell Coordinates for Drawing Tokens
    wire [9:0] index_H_edge = 40 + (column_index * 80);
    wire [9:0] index_V_edge = 60 + (row_index * 60);
    //once V/H counter passes one index, the next index is essentially reset to be drawn again; hence, the subtraction
    wire [9:0] relative_H = H_counter - index_H_edge;
    wire [9:0] relative_V = V_counter - index_V_edge;

    //circle inside active 80x60 division area
    wire in_board_top = (relative_H > 22 && relative_H <= 58) && (relative_V > 5 && relative_V <= 10); //top
    wire in_board_middle = (relative_H > 15 && relative_H <= 65) && (relative_V > 10 && relative_V <= 50); //middle
    wire in_board_bottom = (relative_H > 22 && relative_H <= 58) && (relative_V > 50 && relative_V <= 55); //bottom
    wire is_circle_in_board = in_board_bottom || in_board_middle || in_board_top;
    
    //Color allocation
    always @(*) begin
        if (~is_video_on)
            RGB = 12'h000; //black
        else if (in_board_H || in_board_V)
            RGB = 12'hFFF; // White grid lines
        else if (in_cursor) begin
            RGB = player_turn ? 12'hF00 : 12'hFF0; //colour of object cursor based on whose turn it is
        end else if (in_grid && is_circle_in_board) begin //all placed objects within both boards (only board can only occupy one index)
            if (p1_board[board_index])
                RGB = 12'hF00; // Red 
            else if (p2_board[board_index])
                RGB = 12'hFF0; // Yellow 
            else
                RGB = 12'h000; // black
        end else
            RGB = 12'h000; //black
    end

endmodule
