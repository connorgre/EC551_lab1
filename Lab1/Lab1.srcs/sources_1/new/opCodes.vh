// the op codes we need to support
    //                             nop == mov
    //4'b0001: // INC;          <- inc
    //4'b0010: // JMP;          <- nop
    //4'b0011: // JNE;          <- nop
    //4'b0100: // JE;           <- nop
    //4'b0101: // ADD;          <- add
    //4'b0110: // SUB;          <- sub
    //4'b0111: // XOR;          <- xor
    //4'b1000: // CMP;          <- nop (this will get done in ID)
    //4'b1001: // MOV Rn, num;  <- mov
    //4'b1010: // MOV Rn, Rm;   <- mov
    //4'b1011: // MOV [Rn], Rm; <- mov (memory needs Rn and Rm unchanged)
    //4'b1100: // MOV Rn, [Rm]; <- mov (memory needs Rn and Rm unchanged)
    //4'b1101: // SP1;
    //4'b1110: // SP2;
    //4'b1111: // SP3;
`define haltOp  4'b0000
`define incOp   4'b0001
`define jmpOp   4'b0010
`define jneOp   4'b0011
`define jeOp    4'b0100
`define addOp   4'b0101
`define subOp   4'b0110
`define xorOp   4'b0111
`define cmpOp   4'b1000
`define movIOp  4'b1001 // MOV Rn, num  == move immediate
`define movOp   4'b1010 // MOV Rn, Rm   == move register
`define storeOp 4'b1011 // MOV [Rn], Rm == store to memory
`define loadOp  4'b1100 // MOV Rn, [Rm] == load from memory to register
`define sp1Op   4'b1101
`define sp2Op   4'b1110
`define sp3Op   4'b1111

// the ALU ops we need (can extend this)
`define movAlu  3'b000
`define incAlu  3'b001
`define addAlu  3'b010
`define subAlu  3'b011
`define xorAlu  3'b100
`define passAlu 3'b101  // aluOut = Rn
