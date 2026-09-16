`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 08/28/2026 01:00:56 AM
// Design Name: 
// Module Name: bitboard_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Win condition handling based on the chess bitboard system
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bitboard_logic(
    output reg [41:0] p1_board, //42 bits (player 1) (reg stores the data - flip flop)
    output reg [41:0] p2_board, //42 bits (player 2) (note: reg cannot be declared as inputs)
    output p1_win,
    output p2_win,
    input [2:0] input_placement, //index value of placement (which column)
    input rst,
    input clk,
    input player_turn, // 1 for player 1; 0 for player 2 (based on state)
    output invalid_input,
    input place_obj,
    input [2:0] state
    );
    
    //let 43 be invalid
    //"if slot is filled, then check this"
    wire [41:0] occupied = p1_board | p2_board;
    wire [5:0] open_slot;

    //Finds the next empty slot within the column across both players (start highest first such that we place from bottom to top - inverted)
    assign open_slot = ~occupied[input_placement + 35] ? input_placement + 35 :
                       ~occupied[input_placement + 28] ? input_placement + 28 : //rows in the same column are found by a multiple of 7 (increases by 7 each time)
                       ~occupied[input_placement + 21] ? input_placement + 21 :
                       ~occupied[input_placement + 14] ? input_placement + 14 :
                       ~occupied[input_placement + 7]  ? input_placement + 7  :
                       ~occupied[input_placement]      ? input_placement      : 43;

    assign invalid_input = (open_slot == 43);

    //data storage
    always @(posedge clk) begin
        if (rst || state == 0 || state == 3 || state == 4 || state == 5) begin //reset board state if reset, start screen, or end screen (p1/p2 win + draw) (resets so the end screen condition in FSM doesnt constantly get the end state due to board win)
            p1_board <= 0;
            p2_board <= 0;
        end
        else if (open_slot != 43 && place_obj) //if not invalid and if player pressed the button to place object
            case (player_turn) 
                1'b1: p1_board[open_slot] <= 1;
                1'b0: p2_board[open_slot] <= 1;
            endcase
    end

    //the indices of the p1/p2 board vectors start at the bottom right and end at the top left, going right to left
    //this bitboard uses combinational bit shift to compare elements for matches
    //then uses an OR reduction operator to calculate player win state
    //since these operations are run in parallel, they would be quicker to compute than using a loop in an always block
    
    localparam [41:0] exceed_right = {6{7'b0001111}}; //for horizontal and left diagonal checks
    localparam [41:0] exceed_left = {6{7'b1111000}}; // for right diagonal check
    
    //checks if there are 4 in a row either diagonally, horizontally, or vertically by comparing shifted bits
    wire [41:0] p1_horizontal_check = (p1_board & (p1_board >> 1) & (p1_board >> 2) & (p1_board >> 3) & exceed_right); //prevents cases such as indices: 6, 7, 8, 9 triggering a win. thus, we can create 6 columns of 7'b0001111 since the winning row values are the four bits from LSB (has to include very middle column). to prevent win cases with other rows, since we know the right four columns must be included in horizontal checks, we can add a condition to ensure it remains in the same row
    wire [41:0] p1_vertical_check = p1_board & (p1_board >> 7) & (p1_board >> 14) & (p1_board >> 21); //no condition needed since vector roll over with logical right shift operator does not do roll over, and instead fills with zeros
    wire [41:0] p1_diagonal_right = p1_board & (p1_board >> 6) & (p1_board >> 12) & (p1_board >> 18) & exceed_left; //prevents cases with indices: 23, 29, 35, 41 from causing a false win (right diagonal is only possible in the left 4 columns)
    wire [41:0] p1_diagonal_left = p1_board & (p1_board >> 8) & (p1_board >> 16) & (p1_board >> 24) & exceed_right; //prevents cases such as indicecs: 12, 20, 28, 36 all being high triggering a win (left diagonal is only possible within the right four columns)

    //compares each bit in 42-bit-0bus vector for a high bit (win)
    assign p1_win = |(p1_horizontal_check | p1_vertical_check | p1_diagonal_left | p1_diagonal_right); //uses reduction operator at front
    
    //player 2 check is the same as player 1 check
    wire [41:0] p2_horizontal_check = (p2_board & (p2_board >> 1) & (p2_board >> 2) & (p2_board >> 3) & exceed_right); 
    wire [41:0] p2_vertical_check = p2_board & (p2_board >> 7) & (p2_board >> 14) & (p2_board >> 21);
    wire [41:0] p2_diagonal_right = p2_board & (p2_board >> 6) & (p2_board >> 12) & (p2_board >> 18) & exceed_left;
    wire [41:0] p2_diagonal_left = p2_board & (p2_board >> 8) & (p2_board >> 16) & (p2_board >> 24) & exceed_right;
    
    assign p2_win = |(p2_horizontal_check | p2_vertical_check | p2_diagonal_left | p2_diagonal_right);
    
endmodule
