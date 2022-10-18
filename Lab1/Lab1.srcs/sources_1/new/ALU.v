
`include "opCodes.vh"
module ALU(
    input [15:0] aluIn1,
    input [15:0] aluIn2,
    input [2:0] aluOp,
    output reg [15:0] ALUresult
    );
    always @(*)
    begin
        case(aluOp)           
            `incAlu:        // inc
                ALUresult <= aluIn1 + 1;
            `addAlu:        // add
                ALUresult <= aluIn1 + aluIn2;
            `subAlu:        // sub
                ALUresult <= aluIn1 - aluIn2;
            `xorAlu:        // xor
                ALUresult <= aluIn1 ^ aluIn2;
            `movAlu:        // mov  (out = in2)
                ALUresult <= aluIn2;
            `passAlu:       // pass (out = in1)
                ALUresult <= aluIn1;
            default: begin  // defualt to pass
                $display("undefined alu op");
                ALUresult <= aluIn1;
            end
        endcase
    end
endmodule
