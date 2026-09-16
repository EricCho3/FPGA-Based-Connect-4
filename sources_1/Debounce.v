`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/14/2026 09:31:26 PM
// Design Name: 
// Module Name: Debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
    //the goal of this module is to add a 10ms delay 
    //this delay will be based on the internal clk of 100Mhz

    //(100Mhz * 0.015s) = 1,500,000 cycles 
    // 2^n = 1,500,00 => use natural log rules => n = 20.5165
    //if we round to n=21 and work backwords, we get
    // @n=21, t = 20.97ms
    //thus, a vector [20:0] would be reasonable for debounce.
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Debounce(
    input clk,
    input rst,
    input [2:0] button, //button press
    output reg [2:0] button_delay //delayed button press by ~21ms
    );

    reg [20:0] counter;

    always @(posedge clk) begin

        if (rst) begin
            counter <= 0;
            button_delay <= 0;
        end
        else if (|(button ^ button_delay)) begin//when button is pressed and the output isnt true yet (waiting ~21ms)
            counter <= counter + 1;

            if (&counter) begin//ANDs all the bits (only true if all 21 bits are high - max value)
                counter <= 0; //if reaches the max, then stop counting until it is reset
                button_delay <= button;
            end
        end
        else    
            counter <= 0; //once button and button_delay are the same value, we reset the counter to zero
    end

    //assign enable = (counter == {21{1'b1}}) ? 1 : 0; //replication operator instead of typing 21 1's

endmodule
