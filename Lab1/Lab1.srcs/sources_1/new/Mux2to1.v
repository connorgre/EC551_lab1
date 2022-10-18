`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2022 11:50:14 PM
// Design Name: 
// Module Name: 2to1Mux
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


module Mux2to1(out, in1, in2, select);
    parameter N = 16;
    input       [N-1:0] in1, in2;
    input               select;
    output      [N-1:0] out;
    
    assign out = select ? in1 : in2;
endmodule
