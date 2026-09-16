`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 08/29/2026 03:51:50 AM
// Design Name: 
// Module Name: win_check
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      bitboard check for vertical win logic
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vertical_check( 
    );

    //inputs
    reg rst, clk, player_turn, place_obj;
    reg [2:0] input_placement;
    
    //outputs
    wire p1_win, p2_win, invalid_input;
    wire [41:0] p1_board, p2_board;
    wire [2:0] state;

    //instance of bit board module
    bitboard_logic instance1 (p1_board, p2_board, p1_win, p2_win, input_placement, rst, clk, player_turn, invalid_input, place_obj, state); //assignment by order
    //instantiate FSM module to handle states
    FSM instance2 (clk, rst, place_obj, p1_win, p2_win, state, invalid_input);

    //since the clk is repeating
    initial clk = 0; //initial value of clk
    always 
        #10 clk = ~clk; //every 10 ns clk is inverted 

    //since player_turn is also repeating
    initial player_turn = 1; //start at player 1
    always begin
        @(posedge clk);
        player_turn <= ~player_turn; 
    end

    always @(posedge clk) begin
        if (state == 3) begin //p1 win state
            $display("[%0t ns] Player 1 has won!", $time); //%0t to print time in log without extra space
        end
    end

    //testing values starts
    //since player 1 and 2 logic are the same, we only need to test for one player
    initial begin

        input_placement = 0;
        place_obj = 0;
        rst = 0;
        
        #4 //@ 4ns
        
        //vertical check
        input_placement = 0;
        //change states to in game screen
        @(posedge clk);
        place_obj <= 1;
        @(posedge clk);
        place_obj <= 0;
        @(posedge clk);
        place_obj <= 1;
   
        @(posedge clk); 
        place_obj <= 0;
        input_placement <= 1; //first move
        #3 //flipping switch 3 ns after clk
        place_obj = 1;
        
        repeat (3) begin //total of 3 times
            @(posedge clk); 
            place_obj <= 0;
            input_placement <= 0;
            #3
            place_obj = 1;
            @(posedge clk); 
            place_obj <= 0;
            input_placement <= 1;
            #3
            place_obj = 1;
        end
        
        //player 1 should win here and change to state 3 (p1 win screen)
        repeat (3) @(posedge clk);

        $finish; //ends the test bench here

    end

endmodule
