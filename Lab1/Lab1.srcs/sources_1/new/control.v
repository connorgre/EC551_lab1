`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2022 06:10:35 PM
// Design Name: 
// Module Name: control
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

module control(
    input  [3:0]    opCode,
    output reg      regWrite,
    output reg      readMem,
    output reg      writeMem,
    output reg      aluImm,
    output reg      jump,
    output reg      halt,
    output reg      cmpWrite,
    output [2:0]    aluOp
);
    // decode the aluOp in here to simplify the logic in the top module
    aluOpDecode aluDecode(.opCode(opCode), .aluOp(aluOp));
    
    always@(opCode)
    begin
        // init all to 0, selectively set
        regWrite = 1'b0;
        readMem  = 1'b0;
        writeMem = 1'b0;
        aluImm   = 1'b0;
        jump     = 1'b0;
        halt     = 1'b0;
        case(opCode)
            `haltOp:
                halt     = 1'b1;
            `jmpOp,
            `jneOp,
            `jeOp:
                jump     = 1'b1;
            `incOp,
            `addOp,
            `subOp,
            `xorOp,
            `movOp:
                regWrite = 1'b1;
            `cmpOp:
                cmpWrite = 1'b1;
            `movIOp: begin
                regWrite = 1'b1;
                aluImm   = 1'b1;
                end
            `storeOp:
                writeMem = 1'b1;
            `loadOp: begin
                readMem  = 1'b1;
                regWrite = 1'b1;
                end
          endcase
    end
endmodule
