`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2022 04:51:44 PM
// Design Name: 
// Module Name: Mux3to1
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
module ForwardMux(out, data_EX, data_ME, data_WB, select);
    parameter N=16;
    output  [N-1:0] out;
    input   [N-1:0] data_EX,
                    data_ME,
                    data_WB;
    input   [1:0]   select;
    
    // the last ternary is unnecessary, but I have it for error checking/ completeness
    assign out = (select == `noFw) ? data_EX : ((select == `fwME) ? data_ME :  data_WB);
            
endmodule
