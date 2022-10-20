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
`define haltOp      4'b0000
`define incOp       4'b0001
`define jmpOp       4'b0010
`define jneOp       4'b0011
`define jeOp        4'b0100
`define addOp       4'b0101
`define subOp       4'b0110
`define xorOp       4'b0111
`define cmpOp       4'b1000
`define movIOp      4'b1001 // mov Rn, num  -- move immediate
`define movOp       4'b1010 // mov Rn, Rm   -- move register
`define storeOp     4'b1011 // mov [Rn], Rm -- store to memory
`define loadOp      4'b1100 // mov Rn, [Rm] -- load from memory to register
`define smulOp      4'b1101 // special_1 - smul Rn, Rm
`define saddOp      4'b1110 // special_2 - sadd Rn, Rm
`define movMemOp    4'b1111 // special_3 - mov [Rn], [Rm] -- mov data at Rm to Rn

// the ALU ops we need (can extend this)
`define movAlu  3'b000
`define incAlu  3'b001
`define addAlu  3'b010
`define subAlu  3'b011
`define xorAlu  3'b100
`define passAlu 3'b101  // aluOut = Rn
`define smulAlu 3'b110

// convenient place to define register values to make generating
// instructions easier.
`define r0 6'b000000
`define r1 6'b000001
`define r2 6'b000010
`define r3 6'b000011
`define r4 6'b000100
`define r5 6'b000101
`define r6 6'b000111

//convenient place to define the forwarding signals
`define noFw 2'b00
`define fwME 2'b01
`define fwWB 2'b10
