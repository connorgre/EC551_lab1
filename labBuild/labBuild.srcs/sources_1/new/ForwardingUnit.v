`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2022 04:23:51 PM
// Design Name: 
// Module Name: ForwardingUnit
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
// Forwards inputs to avoid datapath hazards
module ForwardingUnit(reg1_ID, reg2_ID, wbReg_WB, writeEn_WB,
                      fw1, fw2);

    input [2:0]      reg1_ID,
                     reg2_ID,
                     wbReg_WB;
    input            writeEn_WB;
    output reg  fw1, fw2;

    always@(*) begin
        fw1 = 1'b0;
        fw2 = 1'b0;
        if (writeEn_WB) begin
            if (reg1_ID == wbReg_WB)
                fw1 = 1'b1;
            if (reg2_ID == wbReg_WB)
                fw2 = 1'b1;
        end
    end
endmodule
