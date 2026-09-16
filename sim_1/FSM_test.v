`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/14/2026 07:08:46 PM
// Design Name: 
// Module Name: FSM_test
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


module FSM_test(
    );

    //inputs
    reg clk, rst, in, p1_win, p2_win, invalid_input, draw;

    //output
    wire [2:0] state;

    initial clk = 0;
    always 
        #10 clk <= ~clk;

    initial in = 0;
    always 
        #5 in <= ~in;

    FSM instance1 (clk, rst, in, p1_win, p2_win, state, invalid_input, draw);

    initial begin

        rst = 0;
        in = 0;
        p1_win = 0;
        p2_win = 0;
        invalid_input = 0;
        draw = 0;

        @(posedge clk);

        //checks swapping between game states
        repeat(3) begin
            @(posedge clk);
            #1
            $display ("state %d @ %0t", state, $realtime); //state one and two (in should have posedge each clk cycle)
        end

        @(posedge clk);
        p1_win = 1;
        
        $display ("state %d @ %0t", state, $realtime); //p1 win (state = 3)
        @(posedge clk);
        
        rst = 1;
        @(posedge clk);//rst 1 -> 0
        rst = 0;
        p1_win = 0;
        @(posedge clk); //off start state
        @(posedge clk);
        p2_win = 1;
        @(posedge clk);
        $display ("state %d @ %0t", state, $realtime); //p2 win (state = 4)
        p2_win = 0;
        @(posedge clk); //win state should go to start state
        @(posedge clk);
        @(posedge clk);
        draw = 1;
        @(posedge clk);
        $display ("state %d @ %0t", state, $realtime); //draw (state = 5)
        @(posedge clk);

        $finish;

    end


endmodule
