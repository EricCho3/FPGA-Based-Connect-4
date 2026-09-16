`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 03:40:44 PM
// Design Name: 
// Module Name: clk_25Mhz_test
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


module clk_25Mhz_test(
    );
    
    wire clk_25;
    reg clk, rst;
    
    clk_25Mhz instance1 (clk, rst, clk_25);
    
    initial 
        clk = 0;
    always 
        #5 clk = ~clk;
        
        
    initial begin
        rst = 1; //rst 1 -> 0 since it starts as undefined
        #1
        rst = 0;
        #200 //run for 50 ns
        $finish;
    end
    
    
        
endmodule
