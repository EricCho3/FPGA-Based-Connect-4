`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 08/23/2026 06:24:56 PM
// Design Name: 
// Module Name: sseg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  Seven segment display LEDs display information to the players: start screen, player turn in conjunction with LEDs, and which player won.
//  The LEDs above the switches underline which player's turn it is based on their respective location on 7 segment
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//this sseg is to test the fsm states to ensure proper clocked states

module sseg(
    input clk,
    output reg [7:0] sseg,
    output reg [7:0] an, //if using in a always block make this reg 
    input rst,
    output reg [7:0] player_1_led, 
    output reg [7:0] player_2_led, //indicates which player turn
    input [2:0] state 
    );
    
     //calcualted 20:0, but there was ghosting, so we are using lower freq
     //we are only using 0 and 1 hz bc we are only testing one segment, which means it doesnt need to cycle through all the segments
    reg [20:0] freq;
    
    always @(posedge clk) begin//begin not necessary bc its only 1 line inside
        if(rst)
            freq <= 0; //can only assign values in one always block 
        else
            freq <= freq + 1; // each positive edge clock of internal clock, would add one to the counter
    end
    
    always @(*) begin //quickly swaps between segments
        case(freq[20:17])
            3'b111: an = 8'b11111110; // AN0 ON 
            3'b110: an = 8'b11111101; // AN1 ON 
            3'b101: an = 8'b11111011; // AN2 ON 
            3'b100: an = 8'b11110111; // AN3 ON 
            3'b011: an = 8'b11101111; // AN4 ON 
            3'b010: an = 8'b11011111; // AN5 ON 
            3'b001: an = 8'b10111111; // AN6 ON 
            3'b000: an = 8'b01111111; // AN7 ON 
            default: an = 8'b11111111; //should set default as all off bc we dont want every segment always on
        endcase
    end 
    
    reg [3:0] seg_on;
    
    always @(*) begin //choosing what to display on segement
        if (state == 0) begin
            player_1_led = 0;
            player_2_led = 0;
        
            case(an)
                8'b11111110 : seg_on = 0;
                8'b11111101 : seg_on = 1;
                8'b11111011 : seg_on = 9;
                8'b11110111 : seg_on = 7;
                8'b11101111 : seg_on = 1;
                8'b11011111 : seg_on = 8;
                8'b10111111 : seg_on = 8;
                8'b01111111 : seg_on = 8;
                default: seg_on = 8; //default to off
            endcase
        end
        if (state == 1) begin
            player_1_led = 8'b11111111; 
            player_2_led = 0;
            
            case(an)
                8'b11111110 : seg_on = 2;
                8'b11111101 : seg_on = 3;
                8'b11111011 : seg_on = 5;
                8'b11110111 : seg_on = 8;
                8'b11101111 : seg_on = 1;
                8'b11011111 : seg_on = 6;
                8'b10111111 : seg_on = 4;
                8'b01111111 : seg_on = 2;
                default: seg_on = 8;
            endcase
        end
        if (state == 2) begin
            player_1_led = 0;
            player_2_led = 8'b11111111; 
            
            case(an)
                8'b11111110 : seg_on = 2;
                8'b11111101 : seg_on = 3;
                8'b11111011 : seg_on = 5;
                8'b11110111 : seg_on = 8;
                8'b11101111 : seg_on = 1;
                8'b11011111 : seg_on = 6;
                8'b10111111 : seg_on = 4;
                8'b01111111 : seg_on = 2;
                default: seg_on = 8;
            endcase
        end
        if (state == 3) begin
            player_1_led = 0;
            player_2_led = 0;
            
            case(an)
                8'b11111110 : seg_on = 2;
                8'b11111101 : seg_on = 3;
                8'b11111011 : seg_on = 5;
                8'b11110111 : seg_on = 8;
                8'b11101111 : seg_on = 6;
                8'b11011111 : seg_on = 4;
                8'b10111111 : seg_on = 2;
                8'b01111111 : seg_on = 3;
                default: seg_on = 8;
            endcase
        end
        if (state == 4) begin
            player_1_led = 0;
            player_2_led = 0;
            
            case(an)
                8'b11111110 : seg_on = 1;
                8'b11111101 : seg_on = 6;
                8'b11111011 : seg_on = 4;
                8'b11110111 : seg_on = 2;
                8'b11101111 : seg_on = 6;
                8'b11011111 : seg_on = 4;
                8'b10111111 : seg_on = 2;
                8'b01111111 : seg_on = 3;
                default: seg_on = 8;
            endcase
        end
        if (state == 5) begin
            player_1_led = 0;
            player_2_led = 0;
            
            case(an)
                8'b11111110 : seg_on = 8;
                8'b11111101 : seg_on = 4'hA;
                8'b11111011 : seg_on = 7;
                8'b11110111 : seg_on = 9;
                8'b11101111 : seg_on = 6;
                8'b11011111 : seg_on = 4;
                8'b10111111 : seg_on = 8;
                8'b10111111 : seg_on = 8;
                default: seg_on = 8;
            endcase
        end
        /*
        else begin
            player_1_led = 0;
            player_2_led = 0;
            seg_on = 8;
        end         
        */
    end
    
    always @(*) begin //what to choose from for segment
        begin
            case(seg_on)       //GFEDCBA (low active)
                4'h0 : sseg = 8'b10010010; // S
                4'h1 : sseg = 8'b10000111; // t
                4'h2 : sseg = 8'b11000000; // O
                4'h3 : sseg = 8'b11001000; // n
                4'h4 : sseg = 8'b11100001; // _|
                4'h5 : sseg = 8'b10000110; // E
                4'h6 : sseg = 8'b11000011; // |_
                4'h7 : sseg = 8'b10101111; // r
                4'h8 : sseg = 8'b11111111; // OFF
                4'h9 : sseg = 8'b10001000; // A
                4'hA : sseg = 8'b10100001; // d
                default: sseg = 8'b11111111;
            endcase
        end        
    end 
    
endmodule
