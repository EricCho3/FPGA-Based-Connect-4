`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 08/12/2026 02:37:25 AM
// Design Name: 
// Module Name: FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Finite State Machine that controls what stage the game is currently at
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//moore fsm 
module FSM(
    input clk,
    input rst,
    input in,
    input p1_win,
    input p2_win,
    output reg [2:0] state,
    input invalid_input,
    input draw
    );
    
    parameter start_screen = 0, player_1 = 1, player_2 = 2, player_1_win = 3, player_2_win = 4, player_draw = 5; // decimal is oonverted to two bit binary when used in state reg
    reg [2:0] next_state;
    reg in_d; //store prev state
    
    wire in_posedge = in & ~in_d; //posedge logic (if current is high and the previous was low)
    
    always @(*) begin
        next_state = state; //if theres no input, then remain in the same state
    
        if(in_posedge) begin //if there is posedge in
            case(state) 
                start_screen: next_state = player_1; //start screen 
                player_1: next_state = invalid_input ? player_1 : player_2; //player 1 state; if the input is valid, then go to the next player's turn
                player_2: next_state = invalid_input ? player_2 : player_1; // player 2 state; game win check is based on clock not input
                player_1_win: next_state = start_screen; //end screen (option to restart)
                player_2_win: next_state = start_screen;
                player_draw: next_state = start_screen;
                default: next_state = start_screen;
            endcase
        end 
    end      

    always @(posedge clk or posedge rst) begin //async reset so there isnt a delay in resetting
        if (rst) begin
            state <= start_screen; 
            in_d <= 0;
        end
        else if (p1_win) //immediately checks for win (not based on input)
            state <= player_1_win;
        else if (p2_win) //becomes untrue when p2_board is reset in bitboard, allowing for case statement to function
            state <= player_2_win;   
        else if (draw ) //becomes untrue when p1/p2 board is reset in bitboard 
            state <= player_draw; 
        else begin
            state <= next_state;
            in_d <= in;
        end 
    end

endmodule
