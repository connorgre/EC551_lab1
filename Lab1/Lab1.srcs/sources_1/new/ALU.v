module ALU(
    input [15:0] regdata1,
    input [15:0] AluMuxOut,
    input [3:0] opcode,
    output reg [15:0] ALUresult
    );
    always @(*)
    begin
        case(opcode)
            //4'b0000: // HALT;
            //4'b0010: // JMP;
            //4'b0011: // JNE;
            //4'b0100: // JE;
            //4'b1000: // CMP;
            //4'b1001: //MOV Rn, num;
            //4'b1010: // MOV Rn, Rm;
            //4'b1011: // MOV [Rn], Rm;
            //4'b1100: // MOV Rn, [Rm];
            //4'b1101: // SP1;
            //4'b1110: // SP2;
            //4'b1111: // SP3;
            
            4'b0001: // INC
                ALUresult <= regdata1 + 1;
            
            4'b0101: // ADD
                ALUresult <= regdata1 + AluMuxOut;
                
            4'b0110: // SUB
                ALUresult <= regdata1 - AluMuxOut;
                
            4'b0111: // XOR
                ALUresult <= regdata1 ^ AluMuxOut;
            default:
                ALUresult <= regdata1 + AluMuxOut;
        endcase    
    end
endmodule
