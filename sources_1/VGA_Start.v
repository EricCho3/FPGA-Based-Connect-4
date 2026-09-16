`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/02/2026 04:20:59 AM
// Design Name: 
// Module Name: VGA_Start
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      VGA RGB information for the starting screen
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Start(
    input clk,
    input rst,
    output reg [11:0] RGB, // R[11:8], G[7:4], B[3:0]
    input [9:0] H_counter,
    input [9:0] V_counter,
    input is_video_on
    );
    
    //variable scale of the ascii characters
    reg [1:0] scale = 3;
    reg [3:0] V_count_scaled;
    reg [2:0] H_count_scaled;

    always @* begin
        case(scale) //varies how fast the scaled vertical and horizonal counters increase
        0 : begin   
                V_count_scaled = V_counter[3:0]; //how quickly the row is fetched from ROM (vertical order)
                H_count_scaled = H_counter[2:0]; //how quickly the row is drawn from the fetched ROM data
            end 
        1 : begin   
                V_count_scaled = V_counter[4:1];
                H_count_scaled = H_counter[3:1];
            end 
        2 : begin   
                V_count_scaled = V_counter[5:2];
                H_count_scaled = H_counter[4:2];
            end      
        3 : begin   
                V_count_scaled = V_counter[6:3];
                H_count_scaled = H_counter[5:3];
            end 
        endcase 
    end    

    wire [7:0] char_counter = H_counter[9:6];
    wire [9:0] char_counter_extended = H_counter[8:4];
    reg [7:0] ascii_char = "4";
    wire [10:0] address = {ascii_char, V_count_scaled}; //the closer you get to the MSB, the slower the ticks will get, thus, making it larger
    wire [7:0] ascii_data;
    
    ascii_rom instance2 (clk, address, ascii_data);        
    wire in_title = (H_counter < 560 && H_counter >= 80) && (V_counter < 100 && V_counter >= 0); //search 640x480 pixel canvas for refernece
    wire in_4 = (H_counter < 640 && H_counter >= 0) && (V_counter < 250 && V_counter >= 100); 
    wire in_start = (H_counter < 640 && H_counter >= 0) && (V_counter < 445 && V_counter >= 415);
    
    reg is_video_on_d, in_title_d, in_4_d, in_start_d;
    always @(posedge clk) begin //since Block ram takes 1 clk to be updated, like a FF
        is_video_on_d <= is_video_on;
        in_title_d <= in_title; //D Flip Flops
        in_4_d <= in_4;
        in_start_d <= in_start;
    end
    
    //gets the ascii data for the respective case
    always @(*) begin
        if (in_title_d) begin
            scale = 3;
            case (char_counter) //we can change the case condition to shift the characters left/right since the rest would be filled by blanks (default)
                8: ascii_char = "T";
                7: ascii_char = "C";
                6: ascii_char = "E";
                5: ascii_char = "N";
                4: ascii_char = "N";
                3: ascii_char = "O";
                2: ascii_char = "C"; 
                default: ascii_char = " "; //when it finishes displaying, C, the counter fills the gap with empty spaces
            endcase 
        end
        else if (in_4_d) begin
            scale = 3;
            case (char_counter) 
                6: ascii_char = "R";
                5: ascii_char = "U";
                4: ascii_char = "O";
                3: ascii_char = "F";
                default: ascii_char = " ";
            endcase
        end   
        else if (in_start_d) begin
            scale = 1;
            case (char_counter_extended) //note: the ascii rom characters has one column of empty space (causes the gap) (characters are drawn by the placement of 1's)
                26: ascii_char = "T";
                25: ascii_char = "R";
                24: ascii_char = "A";
                23: ascii_char = "T";
                22: ascii_char = "S";
                21: ascii_char = " ";
                20: ascii_char = "O";
                19: ascii_char = "T";
                18: ascii_char = " ";
                17: ascii_char = "]";
                16: ascii_char = "0";
                15: ascii_char = "[";
                14: ascii_char = "W";
                13: ascii_char = "S";
                default: ascii_char = " ";
            endcase 
        end
        else begin
            scale = 2;
            ascii_char = " ";
        end
    end

    //which pixels to colour from ascii_char data
    always @(*) begin
        if(~is_video_on_d)
            RGB = 12'h000; //black (everything not within 640x480)
        else if ((in_title_d || in_4_d || in_start_d) && ascii_data[7 - H_count_scaled])//H_count loop continously runs, thus, we only print text when the region is true (in the printing region)
            RGB = 12'hFFF; //white
        else    
            RGB = 12'hF00; //red
    end
    
endmodule

