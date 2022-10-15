module MemoryInterface(
    input [3:0] opcode,
    input [15:0] regData1,
    input [15:0] regData2,
    output reg [15:0] memAddress,
    output reg [15:0] memDataWrite,
    output reg memWriteSignal,
    output reg memReadSignal,
    output reg regWriteSignal
);
    always@(*)
    begin
        case(opcode)
            //4'b0000: // HALT;
            //4'b0010: // JMP;
            //4'b0011: // JNE;
            //4'b0100: // JE;
            //4'b1000: // CMP;
            //4'b1001: //MOV Rn, num;
            //4'b1010: // MOV Rn, Rm;
            4'b1011: // MOV [Rn], Rm; -> STORES arg2 in mem location arg1
                begin
                    memWriteSignal <= 1;
                    memAddress <= regData1;
                    memDataWrite <= regData2;
                    
                    memReadSignal <= 0;
                    regWriteSignal <= 0;
                end 
            4'b1100: // MOV Rn, [Rm]; -> LOADS RF arg1 with mem content arg2
                begin
                    memReadSignal <= 1;
                    regWriteSignal <= 1;
                    memAddress <= regData2;
                    
                    memWriteSignal <= 0;
                    memDataWrite <=0;
                    
                end
            //4'b1101: // SP1;
            //4'b1110: // SP2;
            //4'b1111: // SP3;
            default:
                begin
                    memAddress <= 0;
                    memDataWrite <= 0;
                    memWriteSignal <= 0;
                    memReadSignal <=0;
                    regWriteSignal <=0;
                end   
        endcase
    end
endmodule
