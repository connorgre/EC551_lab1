`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2022 10:22:35 PM
// Design Name: 
// Module Name: VGA_Color2
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2022 06:47:05 PM
// Design Name: 
// Module Name: VGA_Color
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


module VGA_Color2(color1Out, color2Out, color3Out, rfStreamIn, x, y, clk);
    output reg  [3:0]   color1Out;
    output reg  [3:0]   color2Out;
    output reg  [3:0]   color3Out;
    input       [127:0] rfStreamIn;
    input       [10:0]    x, y;
    input               clk;
    
    integer maxX = 800; // total number of visible columns
    integer maxY = 525; // total number of visible lines
    integer columnWidth = 30;
    integer rowHeight  =  30;

    parameter regBits = 16;
    parameter sqSize = 10;
    
    integer i;
    integer j;
    reg colorBit;
    reg colorBorder;
    
    reg [479:0]vgaArr [639:0]; 
    
    
    always@(posedge clk) begin
        colorBit = 1'b0;
        colorBorder = 1'b0;

        for (i = 0; i < 8; i=i+1) begin
            for (j = 0; j < 16; j= j+1) begin
                if ((x > (columnWidth * j + 40)) && (x < ((columnWidth * j + 40) + sqSize)))
                    if (( y > (rowHeight * i + 30)) && (y < ((rowHeight * i + 30) + sqSize)))
                        colorBit = rfStreamIn[i*16 + j];
                if ((x > (columnWidth * j + 35)) && (x < ((columnWidth * j + 45) + sqSize)))
                    if (( y > (rowHeight * i + 25)) && (y < ((rowHeight * i + 45) + sqSize)))
                        colorBorder = 1'b1;
            end
        end
        if(colorBit)
            color1Out = 4'hF;
        else
            color1Out = 4'h4;
        if(colorBorder)
            color2Out = 4'hF;
        else
            color2Out = 4'h4;
        color3Out = 4'hF;
    end
endmodule
