`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2022 12:15:19 AM
// Design Name: 
// Module Name: cpu_tb
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

module cpu_tb();

    wire [15:0] out;
    reg         clk, fullReset, resetPc, loadInstr;
    reg  [3:0]  op;
    reg  [5:0]  arg1, arg2;
    wire [15:0] instr;
    assign instr[15:12] = op;
    assign instr[11:6]  = arg1;
    assign instr[5:0]   = arg2;
    CPU cpuUUT (.out(out), 
                .clk(clk), 
                .fullReset(fullReset), 
                .resetPc(resetPc), 
                .loadInstr(loadInstr), 
                .instr(instr));
                
    always begin
        #5;
        // only run the clock when we aren't loading instructions in
        if (fullReset == 1'b0 && resetPc == 1'b0 && loadInstr == 1'b0)
            clk = ~clk;
    end
    initial begin
        clk         = 1'b1;
        fullReset   = 1'b0;
        resetPc     = 1'b1;
        loadInstr   = 1'b1;
        {op, arg1, arg2} = 16'h0000;
        // pulse the reset
        #1 fullReset = 1'b1;
        #1 fullReset = 1'b0;
        // allow the Pc to increment on clocks
        #1 resetPc = 1'b0;
        
        // right now, memory and registers all == 0.
        // loadInstr == 1, fullReset == 0, resetPc == 0, clk == 0.
        // now to start running the clock loading instructions in.
        op   = `movIOp;
        arg1 = `r1;
        arg2 = 6'd10;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `movIOp;
        arg1 = `r2;
        arg2 = 6'd20;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `movOp;
        arg1 = `r3;
        arg2 = `r1;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `addOp;
        arg1 = `r3;
        arg2 = `r2;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        op   = `haltOp;
        arg1 = `r0;
        arg2 = `r0;
        #5 clk = ~clk;
        #5 clk = ~clk;
        
        resetPc = 1'b1;
        loadInstr = 1'b0;
        #5 clk = ~clk;
        resetPc = 1'b0;
        // now the program should start running
        #100;
        $finish;
    end

endmodule
