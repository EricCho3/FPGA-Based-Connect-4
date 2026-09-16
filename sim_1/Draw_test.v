`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/15/2026 05:43:13 PM
// Design Name: 
// Module Name: Draw_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      check if state is able to reach draw state and restart back to the starting screen
//      note: I have been having issues with the draw state, so this testbench makes debugging much much quicker than synthesizing, implementing, gen bitstream, then testing on fpga
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Draw_test( //note: max run time in simulation settigns is set to 10000 increased from, 1000
    );
    
    //inputs
    reg rst, clk, player_turn, place_obj;
    reg [2:0] input_placement;
    
    //outputs
    wire p1_win, p2_win, invalid_input, draw;
    wire [41:0] p1_board, p2_board;
    wire [2:0] state;

    assign draw = ((&(p1_board | p2_board)) && ~p1_win && ~p2_win);

    //instance of bit board module
    bitboard_logic instance1 (p1_board, p2_board, p1_win, p2_win, input_placement, rst, clk, player_turn, invalid_input, place_obj, state); //assignment by order
    //instantiate FSM module to handle states
    FSM instance2 (clk, rst, place_obj, p1_win, p2_win, state, invalid_input, draw);

    

    //since the clk is repeating
    initial clk = 0; //initial value of clk
    always 
        #10 clk = ~clk; //every 10 ns clk is inverted 

    //since player_turn is also repeating
    initial player_turn = 1; //start at player 1
    always begin
        @(posedge clk);
        player_turn <= (state == 1); 
    end

    initial place_obj = 0; 
    always begin
        @(posedge clk);
         place_obj <= ~place_obj; //flips switch every clk cycle
     end 

    integer repeat_count;

    //testing values starts
    //since player 1 and 2 logic are the same, we only need to test for one player
    initial begin

        input_placement = 0;
        place_obj = 0;
        rst = 0;
        repeat_count = 0;
        
        //change states to in game screen
        @(posedge clk);
        @(posedge clk); 
        
        repeat (6) begin
            repeat_count = repeat_count + 1;
            
            @(posedge clk); //two clks needed for posedge input in fsm (past and present input)
            @(posedge clk);
            input_placement <= (repeat_count > 3) ? 1 : 0; //first move
            @(posedge clk); 
            @(posedge clk);
            input_placement <= (repeat_count > 3) ? 0 : 1; //first move
        end
        
        #1
        repeat_count = 0;
        
        repeat (6) begin 
            repeat_count = repeat_count + 1; //starting at 1 ending at 6
            
            @(posedge clk); 
            @(posedge clk);
            input_placement <= (repeat_count > 3) ? 3 : 2; //first move
            @(posedge clk);  //flipping switch 3 ns after clk
            @(posedge clk);
            input_placement <= (repeat_count > 3) ? 2 : 3; //first move
        end
        
        #1
        repeat_count = 0;
        
        repeat (6) begin
            repeat_count = repeat_count + 1;
            
            @(posedge clk); 
            @(posedge clk);
            input_placement <= (repeat_count > 3) ? 5 : 4; //first move
            @(posedge clk); 
            @(posedge clk);
            input_placement <= (repeat_count > 3) ? 4 : 5; //first move
        end
        
        
        repeat (6) begin
            
            @(posedge clk); 
            @(posedge clk);
            input_placement <= 6; //first move

        end
        
        //player 1 should win here and change to state 3 (p1 win screen)
        repeat (3) @(posedge clk);
        $display("state 5 == %d?", state); 
        
        repeat (2) begin
            @(posedge clk); 
            input_placement <= 6; //first move
            $display("state 5 == %d?", state); 
        end 
            
        repeat (4) @(posedge clk);
        
        $finish; //ends the test bench here

    end
    
    
endmodule
