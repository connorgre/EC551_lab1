`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2022 05:35:22 PM
// Design Name: 
// Module Name: Btn_ctrl
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


module Btn_ctrl(
    input      clk, BTND, BTNR, BTNU, BTNL, BTNC, CPU_RESETN,
    output reg loadInstr, manualClk, unHalt, resetPc, fullReset
    );
    wire ldBtn = BTND;
    wire mClkBtn = BTNR;
    wire uHltBtn = BTNU;
    wire rPcBtn = BTNL;
    wire deBounce = BTNC;
    wire resetBtn = CPU_RESETN;
    
    reg loadInstrDebouncer;
    always@(posedge clk) begin
        if (deBounce) begin
            loadInstr = 1'b0;
            manualClk = 1'b0;
            unHalt    = 1'b0;
            resetPc   = 1'b0;
            fullReset = 1'b0;
        end
        if (loadInstrDebouncer) begin
            loadInstr           = 1'b0;
            loadInstrDebouncer  = 1'b0;
        end
        else begin 
            if (ldBtn)begin 
                if (resetPc == 1'b1) begin
                    loadInstrDebouncer = 1'b1;
                end
                loadInstr = 1'b1;
            end
            if (mClkBtn)
                manualClk = 1'b1;
            if (uHltBtn)
                unHalt = 1'b1;
            if (rPcBtn)
                resetPc = 1'b1;
            if (resetBtn)
                fullReset = 1'b1;
        end
    end
    
    
endmodule
