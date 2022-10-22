`timescale 1ns / 1ps

module ALU_Mux(
    input  [15:0] regData2,
    input  [5:0] arg2,
    input  ALUSrc,
    output [15:0] ALU_Mux_out 
    );
    wire [15:0] ext_arg2;
    assign ext_arg2[5:0] = arg2;
    assign ext_arg2[15:6] = 10'b0;
    assign ALU_Mux_out = ALUSrc ? regData2 : ext_arg2;
endmodule
