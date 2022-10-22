`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2022 08:12:31 PM
// Design Name: 
// Module Name: Memory
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

// data is with address and dataOut
// instructions are read with pcIn and instrOut
// this is the most straightforward way to allow 
// both reading out data and instructions on the same clock cycle
// memory indexed by words (so 16 bits/2 bytes).

module Memory(clk, write, address, dataIn, dataOut, pcIn, instrOut, movMem, reset);
    parameter     bitLen = 16;
    parameter     memBits = 12;
    input         clk, write, reset, movMem;
    input  [15:0] address, dataIn, pcIn;
    output [15:0] dataOut, instrOut;
    integer       i;
   
    reg [bitLen-1:0]mem_array [0:2**memBits];
   
    always @(posedge clk, posedge reset) begin
        if (reset)
            for(i = 0; i < 2**memBits; i=i+1)
                mem_array[i] = i;
        else if(write && ~movMem)
            mem_array[address[11:0]] = dataIn;
        else if(movMem)
            mem_array[address[11:0]] = mem_array[dataIn[11:0]];
    end
   
    assign dataOut  = mem_array[address[11:0]];
    assign instrOut = mem_array[pcIn[11:0]];
endmodule
