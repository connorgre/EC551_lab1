`timescale 1ns / 1ps

`include "opCodes.vh"
module ALU(
    input       [15:0]  aluIn1,
    input       [15:0]  aluIn2,
    input       [2:0]   aluOp,
    output reg  [15:0]  ALUresult,
    output reg          cmpRes
    );
    always @(aluIn1, aluIn2, aluOp)
    begin
        case(aluOp)           
            `incAlu:        // inc
                ALUresult = aluIn1 + 1;
            `addAlu:        // add
                ALUresult = aluIn1 + aluIn2;
            `subAlu:        // sub
                ALUresult = aluIn1 - aluIn2;
            `xorAlu:        // xor
                ALUresult = aluIn1 ^ aluIn2;
            `movAlu:        // mov  (out = in2)
                ALUresult = aluIn2;
            `passAlu:       // pass (out = in1)
                ALUresult = aluIn1;
            `smulAlu:
                ALUresult = aluIn1 * aluIn2;
            default: begin  // defualt to pass
                $display("undefined alu op");
                ALUresult = aluIn1;
            end
        endcase
        cmpRes = ((aluIn1 ^ aluIn2) == 0);
    end
endmodule
