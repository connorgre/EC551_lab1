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
`define cycleClk #1 clk = ~clk; #1 clk = ~clk
`define halt op = `haltOp; arg1 = `r0; arg2 = `r0
module cpu_tb();

    wire [15:0] out;
    reg         clk, fullReset, resetPc, loadInstr, resetHalt;
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
                .instr(instr),
                .resetHalt(resetHalt));
                
    always begin
        #2.5;
        // only run the clock when we aren't loading instructions in
        if (fullReset == 1'b0 && resetPc == 1'b0 && loadInstr == 1'b0)
            clk = ~clk;
    end
    
    always begin
        if (op == `haltOp)
            #50 resetHalt = 1'b1;
            #5 resetHalt = 1'b0;
    end

    initial begin
        resetHalt   = 1'b0;
        clk         = 1'b1;
        fullReset   = 1'b0;
        resetPc     = 1'b1;
        loadInstr   = 1'b1;
        {op, arg1, arg2} = 16'h0000;
        // pulse the reset, with a clock in between
        #1 fullReset = 1'b1;
        `cycleClk;
        #1 fullReset = 1'b0;
        // allow the Pc to increment on clocks
        `cycleClk;
        #1 resetPc = 1'b0;
        
        // right now, memory and registers all == -1.
        // loadInstr == 1, fullReset == 0, resetPc == 0, clk == 0.
        // now to start running the clock loading instructions in.
        
        
        // simple program to that loads 10 into memory location 13,
        // and then increments from 10 to 13 in a loop, then repeats.
        // 31: r1=10
        op   = `movIOp;
        arg1 = `r1;
        arg2 = 6'd10;
        `cycleClk;
        
        // 32: r2=3
        op   = `movIOp;
        arg1 = `r2;
        arg2 = 6'd3;
        `cycleClk;
        
        // 33: r3=r1 (10)
        op   = `movOp;
        arg1 = `r3;
        arg2 = `r1;
        `cycleClk;
               
        // 34: r3=r3+r2 (10+3=13)
        op   = `addOp;
        arg1 = `r3;
        arg2 = `r2;
        `cycleClk;
        
        
        // 35: [r3] = r1 ([13] = 10)
        op   = `storeOp;
        arg1 = `r3;
        arg2 = `r1;
        `cycleClk;

        // 36 smul r0, r2 (-1 * 3)
        op   = `smulOp;
        arg1 = `r0;
        arg2 = `r2;
        `cycleClk;

// LOOP START:
        // 37: r4 = [r3] (r3 = 13, [13] = 10, r4=10)
        op   = `loadOp;
        arg1 = `r4;
        arg2 = `r3;
        `cycleClk;
        
        // 38: smul r0, r5 (r5 = -1, flips r0)
        op   = `smulOp;
        arg1 = `r0;
        arg2 = `r5;
        `cycleClk;
        
        // 39: r4++
        op   = `incOp;
        arg1 = `r4;
        `cycleClk;
        
        // 40: store [r3], r4 ([13] = r4)
        op   = `storeOp;
        arg1 = `r3;
        arg2 = `r4;
        `cycleClk;
        
        // 41: cmp r3, r4
        op   = `cmpOp;
        arg1 = `r3;
        arg2 = `r4;
        `cycleClk;
        
        // 42: jne LOOP_START
        op   = `jneOp;
        arg1 = 6'd0;
        arg2 = 6'd37;
        `cycleClk;
        
        // 43: movMem [r1], r[0] (r1 = 10, [r0] = r0[11:0] (mem is initialized to its own address))
        op   = `movMemOp;
        arg1 = `r1;
        arg2 = `r0;
        `cycleClk;
        
        `halt;
        `cycleClk;
        
        // 44: jump to program start
        op   = `jmpOp;
        arg1 = 6'd0;
        arg2 = 6'd31;
        `cycleClk;
        
        `halt;
        `cycleClk;
        
        resetPc = 1'b1;
        loadInstr = 1'b0;
        #1;
        resetPc = 1'b0;
        // now the program should start running
        #500;
        $finish;
    end

endmodule
