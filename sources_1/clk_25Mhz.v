`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Eric Cho
// 
// Create Date: 09/01/2026 10:19:14 AM
// Design Name: 
// Module Name: clk_25Mhz
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Divides the 100Mhz internal clk of the Nexys A7 into a 25Mhz clk
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_25Mhz(

    input clk_100, //100mhz
    input rst,
    output clk_25 //25mhz

    );

    reg [1:0] clk_25_counter; // only active on one of the bits: 2'b11; not on 2'b00, 2'b01, 2'b10; hence 1/4 of 100Mhz = 25Mhz 
    always @(posedge clk_100, posedge rst) begin 
        if(rst)
            clk_25_counter <= 0;
        else    
            clk_25_counter <= clk_25_counter + 1; 
    end

    assign clk_25 = (clk_25_counter == 2'b11); //once the counter reaches 2'b11 it will roll over 

endmodule
