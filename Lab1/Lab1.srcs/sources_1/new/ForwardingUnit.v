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
module ForwardingUnit(reg1_EX, reg2_EX, wbReg_ME, wbReg_WB, write_ME, write_WB, 
                        fwReg1, fwReg2);

    input [2:0]      reg1_EX,
                     reg2_EX,
                     wbReg_ME,
                     wbReg_WB;
    input            write_ME,
                     write_WB;
    output reg [1:0] fwReg1,
                     fwReg2;

    always@(*) begin
        if ((reg1_EX == wbReg_ME) && (write_ME == 1'b1))
            fwReg1 = `fwME;
        else if ((reg1_EX == wbReg_WB) && (write_WB == 1'b1))
            fwReg1 = `fwWB;
        else
            fwReg1 = `noFw;

        if ((reg2_EX == wbReg_ME) && (write_ME == 1'b1))
            fwReg2 = `fwME;
        else if ((reg2_EX == wbReg_WB) && (write_WB == 1'b1))
            fwReg2 = `fwWB;
        else
            fwReg2 = `noFw;
    end
endmodule
