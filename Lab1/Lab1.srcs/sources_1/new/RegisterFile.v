`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2022 07:32:30 PM
// Design Name: 
// Module Name: RegisterFile
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

// R6 is the program counter, and is NOT stored in the register file, it is
// much simpler implementation-wise to have the PC be its own independent register
module RegisterFile(clk, reset, writeData, writeReg, regWrite, readReg1, readReg2, 
                    readData1, readData2);
   parameter bitLen = 16; // bitlength of registers
   parameter regBits = 3; // number registers is 2**regBits
   
   output [bitLen-1:0] readData1, readData2;
   reg    [bitLen-1:0] readData1, readData2;
   input               reset;
   input [bitLen-1:0]  writeData;
   input [regBits-1:0] writeReg, readReg1, readReg2;
   input               regWrite, clk;
   
   integer       i;
   reg [bitLen-1:0]    Reg_File[(2**regBits)-1:0]; //2**regBits registers of bitLen length
   
   always @(*) // <- always want to be reading from the register file
   begin
        readData1 = Reg_File[readReg1];
        readData2 = Reg_File[readReg2];
        //Register File Write Through
        if ((readReg1 == writeReg) && (regWrite == 1'b1))
          readData1 = writeData;
        if ((readReg2 == writeReg) && (regWrite == 1'b1))
          readData2 = writeData;
   end
      
   always @(posedge clk)
   begin
        if (reset) 
          begin
             for (i=0; i<(2**regBits); i=i+1)
               Reg_File[i] <= -1;
          end
        else if (regWrite)
          begin
                Reg_File[writeReg] <= writeData;
          end
   end

endmodule
