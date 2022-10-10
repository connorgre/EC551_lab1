`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2022 08:09:28 PM
// Design Name: 
// Module Name: InstrDecode
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

// need to implement immediates and jump targets
module InstrDecode(
    input [15:0] instr,
    output [3:0] opCode,
    output [3:0] arg1,
    output [3:0] arg2
    );
    assign opCode = instr[15:12];
    assign arg1   = instr[8:6];
    assign arg2   = instr[2:0];
endmodule
