`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2022 06:51:11 PM
// Design Name: 
// Module Name: aluOpDecode
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
`include "opCodes.vh" // contains the opcodes
// translates an opCode into an Alu operation.
// This allows multiple opCodes to use the same alu operation, 
// ie for memory load / store, we want 
module aluOpDecode(
    input      [3:0] opCode,
    output reg [2:0] aluOp
    );
    //                  nop == mov
    // INC;          <- inc
    // JMP;          <- nop
    // JNE;          <- nop
    // JE;           <- nop
    // ADD;          <- add
    // SUB;          <- sub
    // XOR;          <- xor
    // CMP;          <- nop (this will get done in ID)
    // MOV Rn, num;  <- mov
    // MOV Rn, Rm;   <- mov
    // MOV [Rn], Rm; <- pass (memory needs Rn and Rm unchanged)
    // MOV Rn, [Rm]; <- pass (memory needs Rn and Rm unchanged)


    
    always@(opCode)
    begin
        // all jumps get the mov just bc
        // its simpler than reserving a nop
        // on the alu. Memory load and store
        // get the passthrough, which just
        // takes out a mux after the alu to 
        // simplify logic in the top module
        case(opCode)
          `incOp:
            aluOp = `incAlu;
          `addOp,
          `saddOp:
            aluOp = `addAlu;
          `subOp:
            aluOp = `subAlu;
          `xorOp:
            aluOp = `xorAlu;
          `loadOp,
          `storeOp,
          `movMemOp:
            aluOp = `passAlu;
          `smulOp:
            aluOp = `smulAlu;
          default:
            aluOp = `movAlu;
        endcase
    end
endmodule
