`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2022 10:12:09 PM
// Design Name: 
// Module Name: NBitReg
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

// only writes inData to outData on posedge clk if enable is high
module NBitReg(inData, outData, enable, clk, reset);
    parameter N = 16;
    input [N-1:0] inData;
    input enable, clk, reset;
    output reg [N-1:0] outData;
    
    always @(posedge clk, posedge reset)
        if (reset)
            outData <= 0;
        else 
            if (enable)
                outData[N-1:0] <= inData[N-1:0];
endmodule
