`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/07/2026 10:47:28 AM
// Design Name: 
// Module Name: Top_Module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  Connects all the modules together for the game to be implemented into the Nexys A7
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top_Module(
    input clk,
    input rst, //start screen switch and end screen switch
    output [7:0] sseg_out, //outputs driven by modules must be wires
    output [7:0] an, 
    output [7:0] player_1_led, 
    output [7:0] player_2_led,
    output H_sync,
    output V_sync,
    output [11:0] RGB,
    input [2:0] buttons //100 = right; 001 = left; 010 = place (sw[0])
    );

    wire [9:0] H_counter, V_counter;
    wire [2:0] state;
    wire is_video_on, p1_win, p2_win, invalid_input, player_turn, enable, draw;
    wire [41:0] p1_board, p2_board;

    assign player_turn = (state == 1); //if player 1's turn; else, its player 2's turn
    assign draw = ((&(p1_board | p2_board)) && ~p1_win && ~p2_win);

    reg [2:0] input_placement; //where to place the object horizontally
    reg place_obj, start;

    reg [2:0] buttons_d;
    wire [2:0] button_delayed;
    wire [2:0] posedge_button = buttons_d & ~button_delayed; //bitwise AND (posedge on delayed button NOT inputted button)

    Debounce instance6 (clk, rst, buttons, button_delayed);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            place_obj <= 0;
            input_placement <= 0;
            buttons_d <= 0;
        end else begin
            buttons_d <= button_delayed; //gets previous button state
            place_obj <= 0;
            //if there was a posedge on the button (button pressed)
            if (posedge_button[2] && input_placement < 6 ) //right 
                    input_placement <= input_placement + 1; 
            else if (posedge_button[0] && input_placement > 0) //left
                input_placement <= input_placement - 1;
            else if (posedge_button[1]) // place
                place_obj <= 1;
        end
    end
    
    //instantiating each module
    FSM instance1 (clk, rst, place_obj, p1_win, p2_win, state, invalid_input, draw); //note: the FSM module is located in sseg file path
    sseg instance2 (clk, sseg_out, an, rst, player_1_led, player_2_led, state);
    VGA_Sync instance3 (clk, rst, H_sync, V_sync, H_counter, V_counter, is_video_on);
    bitboard_logic instance4 (p1_board, p2_board, p1_win, p2_win, input_placement, rst, clk, player_turn, invalid_input, place_obj, state);
    VGA_Top_Module instance5 (clk, rst, state, RGB, H_counter, V_counter, p1_board, p2_board, input_placement, player_turn, is_video_on);

endmodule
