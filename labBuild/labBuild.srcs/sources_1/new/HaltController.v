`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2022 03:14:59 PM
// Design Name: 
// Module Name: HaltController
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


module HaltController(haltOut, haltSig, haltReset, reset);
    output reg  haltOut;
    input       haltSig, haltReset, reset;

    always@(posedge haltSig, posedge reset, posedge haltReset) begin
        if (reset)
            haltOut = 1'b0;
        else if (haltReset)
            haltOut = 1'b0;
        else if (haltSig)
            haltOut = 1'b1;
    end
endmodule
