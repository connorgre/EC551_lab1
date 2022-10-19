`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2022 09:45:38 PM
// Design Name: 
// Module Name: CompareHandle
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

`include "opCodes.vh"
module CompareHandle(cmpInstr, aluEqRes, reset, cmpResult);
    input           cmpInstr;
    input           aluEqRes;
    input           reset;
    output reg      cmpResult;
    
    always@(cmpInstr, aluEqRes, reset) begin
        if(reset == 1'b1)
            cmpResult = 1'b0;
        else if (cmpInstr == 1'b1)
            cmpResult = aluEqRes;
    end
    
endmodule
