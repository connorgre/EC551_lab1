`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2022 11:40:55 PM
// Design Name: 
// Module Name: IncrementPC
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


module IncrementPC(pcIn, pcOut);
    parameter bitLen = 16;
    input  [bitLen-1:0] pcIn;
    output [bitLen-1:0] pcOut;
    // since memory is word-indexed, only need to increment pc by 1
    assign pcOut = pcIn + 1'b1;
endmodule
