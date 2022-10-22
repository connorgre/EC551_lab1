`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2022 06:47:15 PM
// Design Name: 
// Module Name: StallController
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

// stall condition: 
//      >   when loading a reg from memory, and then reading from that reg on
//          the next instruction, we need to stall the pipeline at decode and fetch.
//          This allows the memData to get into WB stage, and the forwarding unit
//          will then be able to send that back to EX stage where it gets used.
//          Detect this when the read is in EX.
//
//          Realistically, the memory could be made asynchronos (or just negedge of clk)
//          to fix this as well, but I know this works and don't wanna deal with other
//          issues that could bring up.
//
//      >   Doing a cmp, we need to stall long enough for 
module StallController(readMem_EX, readReg_EX, useReg2_ID, reg1_ID, reg2_ID, stall);
    input           readMem_EX,
                    useReg2_ID;
    input   [2:0]   readReg_EX, 
                    reg1_ID, 
                    reg2_ID;
    output reg      stall;
    
    always@(*) begin
        stall = 1'b0;
        if (readMem_EX) begin
            if (readReg_EX == reg1_ID)
                stall = 1'b1;
            else if(useReg2_ID && (readReg_EX == reg2_ID))
                stall = 1'b1;
        end
    end
    
    
    
endmodule
