`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2022 10:15:44 PM
// Design Name: 
// Module Name: CPU
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

// 5 stage pipelined cpu
//      all wires specific to 1 stage should be
//      suffixed with the below notation
//      at the end of each stage, all outputs from
//      the stage should enter a register, and
//      come out the other end with the next
//      stage suffix
// _if = instruction fetch
// _id = instruction decode
// _ex = execute (alu stage)
// _me = memory
// _wb = writeback
module CPU(out, clk, fullReset, resetPC, loadInstr, instr);
    parameter bitLen = 16;
    parameter regBits = 3;
    input clk, fullReset, loadInstr, resetPC;
    input  [bitLen-1:0] instr;
    output [bitLen-1:0] out;

///////////////////////////////////////////////////////////////////////
////////////////        -- INSTRUCTION FETCH --        ////////////////
///////////////////////////////////////////////////////////////////////
    wire [bitLen-1:0] pc_if;
    wire [bitLen-1:0] firstPC;
    wire [bitLen-1:0] currPc;
    wire [bitLen-1:0] nextPc;
    wire [bitLen-1:0] instr_if;
    
    // The simulator requires that the code be loaded into location 31 (decimal).
    // this muxes the pc_if (from nextPC -> reg -> pc_if), with this initial value
    assign firstPC[4:0] = 5'd31;
    Mux2to1 #(.N(bitLen)) PCMux(.out(currPc), 
                                .in1(firstPC),
                                .in2(pc_if),
                                .select(resetPC));
    IncrementPC pcInc (.pcIn(currPc), .pcOut(nextPc));
    
    // as of right now, these are unassigned
    wire memWrite;
    wire memAddress;
    wire memIn;
    wire memOut;

    // memWrite, memIn, memOut, memAddress should all ultimately come
    // from the _mm stage, once that gets implemented
    // reset resets all memory to 0
    // pcIn is the current program counter
    // instrOut is the instruction read from memory
    Memory mem (.clk(clk),
                .write(memWrite),
                .address(memAddress),
                .dataIn(memIn),
                .dataOut(memOut),
                .reset(fullReset),
                .pcIn(currPc),
                .instrOut(instr_if));

    // passes current instruction into decode
    NBitReg #(.N(bitLen)) regInstr_ID_EX (.inData(instr_if), 
                                          .outData(instr_id),
                                          .enable(1'b1),
                                          .clk(clk));
    // moves the next PC into the current PC on the clock edge
    NBitReg #(.N(bitLen)) regPC_ID_ID    (.inData(nextPC),
                                          .outData(pc_if),
                                          .enable(1'b1),
                                          .clk(clk));
///////////////////////////////////////////////////////////////////////
////////////////       -- INSTRUCTION DECODE --       /////////////////
///////////////////////////////////////////////////////////////////////

    wire [3:0] opCode;
    wire [regBits-1:0] arg1_id;
    wire [regBits-1:0] arg2_id;
    InstrDecode decoder(.instr(currInstr),
                        .opCode(opCode),
                        .arg1(arg1_id),
                        .arg2(arg2_id));
    
    wire [bitLen-1:0]   regWriteData,
                        regData1,
                        regData2;

    wire [regBits-1:0]  writeReg,
                        readReg1,
                        readReg2;

    RegisterFile regFile (.clk(clk),
                          .reset(fullReset),
                          .writeData(regWriteData),
                          .writeReg(writeReg),
                          .regWrite(regWriteData),
                          .readReg1(readReg1),
                          .readReg2(readReg2),
                          .readData1(regData1),
                          .readData2(regData2));

///////////////////////////////////////////////////////////////////////
////////////////           -- EXECUTION --            /////////////////
///////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////
////////////////            -- MEMORY --              /////////////////
///////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////
////////////////          -- WRITE BACK --            /////////////////
///////////////////////////////////////////////////////////////////////

endmodule
