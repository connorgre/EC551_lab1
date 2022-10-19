
// I moved most of this into the control unit bc it makes more sense there
// I also modified the alu to pass regData1 as aluOut for memory instructions
module MemoryInterface(
    input       [15:0] regData1,
    input       [15:0] regData2,
    input              memWrite,
    output      [15:0] memAddress,
    output      [15:0] memData
);
    assign memAddress   = (memWrite == 1'b1) ? regData1 : regData2;
    assign memData      = (memWrite == 1'b0) ? regData1 : regData2;
endmodule
