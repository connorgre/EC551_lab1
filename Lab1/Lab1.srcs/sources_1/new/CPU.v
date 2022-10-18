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
//
// These ~could~ each be put into their own module, however I don't think that is totally
// necessary, as each stage should really just be passing stuff into submodules and 
// passing into registers. Part of the reason this would be difficult is multiple 
// stages need to access memory (Fetch and Memory), and multiple need the register file
// (Decode and WriteBack).  Additionally, it would make finding hazards more difficult
module CPU(out, clk, fullReset, resetPC, loadInstr, instr);
    parameter bitLen = 16;
    parameter regBits = 3;
    input clk, fullReset, loadInstr, resetPC;
    input  [bitLen-1:0] instr;
    output [bitLen-1:0] out;

///////////////////////////////////////////////////////////////////////
////////////////        -- INSTRUCTION FETCH --        ////////////////
///////////////////////////////////////////////////////////////////////
    // the PC is NOT stored in the register file.  It is its OWN register,
    // to change this we'd need to add an extra input/output to register file
    wire [bitLen-1:0] pc_IF;
    wire [bitLen-1:0] firstPC;
    wire [bitLen-1:0] currPc;
    wire [bitLen-1:0] nextPc;
    wire [bitLen-1:0] instr_IF;
    
    // The simulator requires that the code be loaded into location 31 (decimal).
    // this muxes the pc_if (from nextPC -> reg -> pc_if), with this initial value
    assign firstPC[4:0] = 5'd31;
    Mux2to1 #(.N(bitLen)) PCMux(.out(currPc),  // <- need to expand this to handle jump target
                                .in1(firstPC),
                                .in2(pc_IF),
                                .select(resetPC));
    IncrementPC pcInc (.pcIn(currPc), .pcOut(nextPc));
    
    // reset resets all memory to 0
    // pcIn is the current program counter
    // instrOut is the instruction read from memory\

    // forward declarations
    wire writeMem_ME;
    wire [bitLen-1:0] memAddress_ME;
    wire [bitLen-1:0] memDataOut_ME;
    wire [bitLen-1:0] memDataIn_ME;
    Memory mem (.clk(clk),
                .write(writeMem_ME),
                .address(memAddress_ME),
                .dataIn(memDataIn_ME),
                .dataOut(memDataOut_ME),
                .reset(fullReset),
                .pcIn(currPc),
                .instrOut(instr_IF));

    // passes current instruction into decode
    NBitReg #(.N(bitLen)) regInstr_ID_EX (.inData(instr_IF), 
                                          .outData(instr_ID),
                                          .enable(1'b1),
                                          .clk(clk));
    // moves the next PC into the current PC on the clock edge
    NBitReg #(.N(bitLen)) regPC_ID_ID    (.inData(nextPC),
                                          .outData(pc_IF),
                                          .enable(1'b1),
                                          .clk(clk));
////////////////////////////////////////////////////////////////////////////////////
////////////////              -- INSTRUCTION DECODE --             /////////////////
////////////////////////////////////////////////////////////////////////////////////
// decodes instruction, sets cmpReg (NEED TO DO), gets register data.
// INPUT:   instr_ID
// OUTPUT:  regData1_EX, 
//          regData2_EX, 
//          readReg1_EX, 
//          readReg2_EX, 
//          ctrlBus_EX,  
//          aluOp_EX,
//          writeReg_EX
    wire [3:0] opCode;
    wire [5:0] arg1;
    wire [5:0] arg2;

    InstrDecode decoder(.instr(instr_ID),
                        .opCode(opCode),
                        .arg1(arg1),
                        .arg2(arg2));
    
    wire [bitLen-1:0]   regData1_ID,
                        regData2_ID;

    wire [regBits-1:0]  writeReg_ID,
                        readReg1_ID,
                        readReg2_ID,
                        writeReg_EX,
                        readReg1_EX,
                        readReg2_EX;
                        
    assign readReg1_ID = arg1[2:0];
    assign readReg2_ID = arg2[2:0];
    wire regWrite_WB;
    wire [5:0] writeReg_WB;
    RegisterFile regFile (.clk(clk),
                          .reset(fullReset),
                          .writeData(outData_WB),
                          .writeReg(writeReg_WB),
                          .regWrite(regWrite_WB),
                          .readReg1(readReg1_ID),
                          .readReg2(readReg2_ID),
                          .readData1(regData1_ID),
                          .readData2(regData2_ID));
    wire [11:0] jumpTarget;
    assign jumpTarget[11:0] = {arg1, arg2};
    
    wire        regWrite_ID;
    wire        readMem_ID;
    wire        writeMem_ID;
    wire        aluImm_ID;
    wire        jump_ID;
    wire        halt_ID;
    wire        cmpWrite_ID;                    // <- need to handle cmp logic in ID
    wire [2:0]  aluOp_ID;
    control control_i ( .opCode(opCode),
                        .regWrite(regWrite_ID),
                        .readMem(readMem_ID),
                        .writeMem(writeMem_ID),
                        .aluImm(aluImm_ID),
                        .jump(jump_ID),
                        .halt(halt_ID),
                        .cmpWrite(cmpWrite_ID),             
                        .aluOp(aluOp_ID));

    wire [5:0] ctrlBus_ID;
    wire [5:0] ctrlBus_EX;
    assign ctrlBus_ID[5:0] = {regWrite_ID, readMem_ID, writeMem_ID, 
                           aluImm_ID, jump_ID, halt_ID};

    wire [bitLen-1:0] regData1_EX;
    wire [bitLen-1:0] regData2_EX;
    NBitReg #(.N(16)) arg1Reg_IDEX (.inData(regData1_ID),
                                    .outData(regData1_EX),
                                    .enable(1'b1),          // <- need to fix
                                    .clk(clk));
    NBitReg #(.N(16)) arg2Reg_IDEX (.inData(regData2_ID),
                                    .outData(regData2_EX),
                                    .enable(1'b1),          // <- need to fix
                                    .clk(clk));
    NBitReg #(.N(6)) read1Reg_IDEX  (.inData(readReg1_ID),
                                    .outData(readReg1_EX),
                                    .enable(1'b1),          // <- need to fix
                                    .clk(clk));
    NBitReg #(.N(6)) read2Reg_IDEX  (.inData(readReg2_ID),
                                    .outData(readReg2_EX),
                                    .enable(1'b1),          // <- need to fix
                                    .clk(clk));
    NBitReg #(.N(6)) writeReg_IDEX  (.inData(writeReg_ID),
                                    .outData(writeReg_EX),
                                    .enable(1'b1),          // <- need to fix
                                    .clk(clk));

    NBitReg #(.N(7)) ctrlReg_IDEX ( .inData(ctrlBus_ID),
                                    .outData(ctrlBus_EX),
                                    .enable(1'b1),          // <- need to fix
                                    .clk(clk));
    wire [2:0]  aluOp_EX;
    NBitReg #(.N(3)) aluOpReg_IDEX (.inData(aluOp_ID),
                                    .outData(aluOp_EX),
                                    .enable(1'b1),          // <- need to fix
                                    .clk(clk));
////////////////////////////////////////////////////////////////////////////////////
////////////////                   -- EXECUTION --                 /////////////////
////////////////////////////////////////////////////////////////////////////////////
                //  !! DOES NOT DO HAZARD DETECTION RIGHT NOW !!  //
// executes instruction
/* 
   INPUT:   readReg1_EX, 
            readReg2_EX, 
            regData1_EX, 
            regData2_EX, 
            writeReg_EX, 
            aluOp_EX,
   OUTPUT:  aluOut_ME,
            regData2_ME,
            ctrlBus_ME,
            readReg1_ME,
            readReg2_ME,
            writeReg_ME
*/
    wire aluImm_EX   = ctrlBus_EX[2];
    wire halt_EX     = ctrlBus_EX[0];
    wire [bitLen-1:0]   aluIn1,
                        aluIn2;
    assign aluIn1 = regData1_EX;
    ALU_Mux(.regData2(regData2_EX), 
            .arg2(readReg2_EX), 
            .ALUSrc(~aluImm_EX), 
            .ALU_Mux_out(aluIn2));

    // since pass and mov are alu ops, no need to mux the aluOut with anything
    wire [bitLen-1:0]   aluOut_EX;
    ALU alu (   .aluIn1(aluIn1), 
                .aluIn2(aluIn2), 
                .aluOp(aluOp_EX), 
                .ALUresult(aluOut_EX));
    
    wire [bitLen-1:0]   aluOut_ME;
    wire [bitLen-1:0]   regData2_ME;
    NBitReg #(.N(16)) aluOut_EXME ( .inData(aluOut_EX),
                                    .outData(aluOut_ME),
                                    .enable(1'b1),          // <- Need to fix
                                    .clk(clk));
    NBitReg #(.N(16)) regData2_EXME(.inData(regData2_EX),
                                    .outData(regData2_ME),
                                    .enable(1'b1),          // <- Need to fix
                                    .clk(clk));
    wire [5:0] ctrlBus_ME;          
    NBitReg #(.N(6))  ctrlReg_EXME (.inData(ctrlBus_EX),
                                    .outData(ctrlBus_ME),
                                    .enable(1'b1),          // <- Need to fix
                                    .clk(clk));
    wire [5:0] readReg1_ME;
    wire [5:0] readReg2_ME;
    wire [5:0] writeReg_ME;
    NBitReg #(.N(6)) read1Reg_EXME (.inData(readReg1_EX),
                                    .outData(readReg1_ME),
                                    .enable(1'b1),          // <- Need to fix
                                    .clk(clk));
    NBitReg #(.N(6)) read2Reg_EXME (.inData(readReg2_EX),
                                    .outData(readReg2_ME),
                                    .enable(1'b1),          // <- Need to fix
                                    .clk(clk));
    NBitReg #(.N(6)) writeReg_EXME (.inData(writeReg_EX),
                                    .outData(writeReg_ME),
                                    .enable(1'b1),          // <- Need to fix
                                    .clk(clk));
    
                
    
////////////////////////////////////////////////////////////////////////////////////
////////////////                    -- MEMORY --                   /////////////////
////////////////////////////////////////////////////////////////////////////////////
                //  !! DOES NOT DO HAZARD DETECTION RIGHT NOW !!  //
// handles memory
/*
   INPUT:   aluOut_ME,
            regData2_ME,
            ctrlBus_ME,
            readReg1_ME,
            readReg2_ME,
            writeReg_ME
    OUTPUT: outData_WB,
            ctrlBus_WB,
            writeReg_WB
*/
    //ctrlBus_ID[5:0] = {regWrite_ID, readMem_ID, writeMem_ID, 
    //                       aluImm_ID, jump_ID, halt_ID};
    wire readMem_ME  = ctrlBus_ME[4];
    assign writeMem_ME = ctrlBus_ME[3];
    wire halt_ME     = ctrlBus_ME[0];
    
    // THE MEMORY UNIT IS INSTANTIATED IN INSTRUCTION FETCH STAGE
    // memAddress_ME, memDataIn_ME, writeMem_ME, and readMem_ME are
    // all instantiated in Instruction Fetch
    MemoryInterface memCtrl (   .regData1(aluOut_ME),
                                .regData2(regData2_ME),
                                .memWrite(writeMem_ME),
                                .memAddress(memAddress_ME),
                                .memData(memDataIn_ME));
    wire [bitLen-1:0] memAluMuxOut;
    Mux2to1 memOutMux ( .out(memAluMuxOut),
                        .in1(memDataOut_ME),
                        .in2(aluOut_ME),
                        .select(readMem_ME));
    NBitReg #(.N(16)) out_MEWB (    .inData(memAluMuxOut),
                                    .outData(outData_WB),
                                    .enable(1'b1),              // <- Need to fix
                                    .clk(clk));
    wire [5:0] ctrlBus_WB;
    NBitReg #(.N(6)) ctrlBus_MEWB ( .inData(ctrlBus_ME),
                                    .outData(ctrlBus_WB),
                                    .enable(1'b1),              // <- Need to fix
                                    .clk(clk));
    NBitReg #(.N(6)) writeReg_MEWB (.inData(writeReg_ME),
                                    .outData(writeReg_WB),
                                    .enable(1'b1),              // <- Need to fix
                                    .clk(clk));
////////////////////////////////////////////////////////////////////////////////////
////////////////                  -- WRITE BACK --                 /////////////////
////////////////////////////////////////////////////////////////////////////////////
// writes data back to register file.  This is it's own stage to help avoid
// RAW and WAR hazards. While likely the clock will be slow enough that this isn't
// a problem, add it for completeness
/*
    INPUT:  outData_WB,
            ctrlBus_WB,
            writeReg_WB
    OUTPUT: NONE -- but writes to register file
*/
    // this is declared in ID stage, bc register file is instantiated there
    assign regWrite_WB = ctrlBus_WB[5];
    wire halt_WB       = ctrlBus_WB[0];

endmodule
