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
    input           forceZero,
    output reg      regWrite,
    output reg      readMem,
    output reg      writeMem,
    output reg      aluImm,
    output reg      movMem,
    output reg      halt,
    output reg      cmpWrite,
    output [2:0]    aluOp
);
    // decode the aluOp in here to simplify the logic in the top module
    aluOpDecode aluDecode(.opCode(opCode), .aluOp(aluOp));
    
    always@(opCode, forceZero)
    begin
        // init all to 0, selectively set
        regWrite = 1'b0;
        readMem  = 1'b0;
        writeMem = 1'b0;
        aluImm   = 1'b0;
        movMem   = 1'b0;
        halt     = 1'b0;
        cmpWrite = 1'b0;
        if (forceZero == 1'b0) begin
            case(opCode)
                `haltOp: begin
                    halt     = 1'b1;
                  end
                `addOp,
                `saddOp,
                `subOp,
                `xorOp,
                `movOp,
                `smulOp:
                    regWrite = 1'b1;
                `cmpOp:
                    cmpWrite = 1'b1;
                `movIOp,
                `incOp: begin
                    regWrite = 1'b1;
                    aluImm   = 1'b1;
                  end
                `storeOp:
                    writeMem = 1'b1;
                `loadOp: begin
                    readMem  = 1'b1;
                    regWrite = 1'b1;
                  end
                `movMemOp: begin
                    writeMem = 1'b1;
                    movMem   = 1'b1;
                  end
                `jmpOp,
                `jneOp,
                `jeOp:
                    // only here to complete the case
                    halt      = 1'b0;
              endcase
          end
    end
endmodule
