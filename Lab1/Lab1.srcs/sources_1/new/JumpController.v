`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2022 09:38:47 PM
// Design Name: 
// Module Name: JumpController
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
// ~technically~ this should have a stall for jeOp and jneOp, as ~technically~ we
// can't guarantee that cmpResult has been determined until the EX stage is done.
// I don't feel like implementing that and am going to assume the clock will be
// slow enough for now...
module JumpController(opCode, cmpResult, reset, doJump);
    input [3:0]     opCode;
    input           cmpResult;
    input           reset;
    output reg      doJump;
                            
    always@(opCode, cmpResult, reset)begin
        if (reset == 1'b0) begin
            if (opCode == `jmpOp)
                doJump = 1'b1;
            else if ((opCode == `jeOp)  && (cmpResult == 1'b1))
                doJump = 1'b1;
            else if ((opCode == `jneOp) && (cmpResult == 1'b0))
                doJump = 1'b1;
            else
                doJump = 1'b0;
        end else
            doJump = 1'b0;
    end
    
endmodule
