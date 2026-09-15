#CONNECT 4 IN VERILOG

Hello! My name is Eric Cho, and I am studying computer engineering. In my free time, I wanted to gain more experience with Verilog
aside from completing most of the HDLbits problems. Thus, I decided to create a game on a Nexys A7 FPGA. Back in my 11th-grade
computer science class, I created a game of Connect 4 in Java that ran synchronously (only in main) and outputted to the terminal.
I wanted to compare my synchronous implementation in Java to a fully functioning version in Verilog with parallel and synchronous logic in mind.
This implementation in Verilog will include VGA/7 seg/led output, game win logic, and a finite state machine.

#OVERVIEW OF THE MODULES

FSM: finite state machine - determines which screen the game is currently at (start screen, in game screen for p1/p2, and win screen for p1/p2)

sseg: seven-segment display - displays information on 7-segment and LEDs based on the state from FSM 

bitboard_logic: determines if p1 or p2 won by analyzing their respective piece placements

clk_25Mhz: divides the internal clock of 100Mhz by 4 to achieve 25Mhz for 640x480 @ 60hz for VGA

VGA_Sync: handles the VGA timing states and clock cycles for the current pixel row being drawn (row by row) (instantiates clk_25Mhz here)

VGA_Start: VGA output for the starting screen state (logo and button to start)

VGA_Game: VGA output for p1/p2 in game state (cursor and board with placed pieces)

VGA_End: VGA output for p1/p2 end state (which player won and button to restart)

VGA_Top_module: creates the instances of every VGA output module

Top_Module: creates an instance of VGA_Top_module, bitboard_logic, VGA_Sync, sseg, FSM

ascii_ROM: from "FPGADUDE" on GitHub; it contains the ASCII data to output characters in block RAM (8x16 pixels per character)

Debounce: takes a positive-edge button input and outputs the same press with a ~21 ms delay
