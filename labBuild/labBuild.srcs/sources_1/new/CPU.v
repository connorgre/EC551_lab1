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
module CPU(out, clk, fullReset, resetPc, resetHalt, loadInstr, instr, rfStreamOut);
    parameter regBits = 3;
    input clk, fullReset, loadInstr, resetPc, resetHalt;
    input  [15:0] instr;
    output [16 * 8 - 1:0]  rfStreamOut; // large bus holding all the register data
    output [15:0] out;
// forward declarations         <- should eventually move all the register wires here
    wire [2:0]  readReg1_ME;
    wire [2:0]  readReg2_ME;
    wire [2:0]  writeReg_ME;
    wire        writeMem_ME;
    wire [15:0] memAddress_ME;
    wire [15:0] memDataOut_ME;
    wire [15:0] memDataIn_ME;
    wire [2:0]  writeReg_WB;
    wire        regWrite_WB;
    wire        regWrite_ME;
    wire [15:0] aluOut_ME;
    wire [15:0] outData_WB;
    wire        readMem_EX;
    wire        movMem_ME;
                  
    wire        loadStall;
    wire        doJump_ID;
    wire [11:0] jumpTarget;
    wire        cmpRes_EX;
    wire        globalHalt;
    // want to make sure we can write the 0s, and that we aren't halting
    // the registers during the load phase
    wire        globalRegEn = ~globalHalt | loadInstr | fullReset;


///////////////////////////////////////////////////////////////////////
////////////////        -- INSTRUCTION FETCH --        ////////////////
///////////////////////////////////////////////////////////////////////
    wire [15:0] pc_IF;      // comes from register file
    wire [15:0] firstPc;
    wire [15:0] nextPc;
    wire [15:0] instr_IF;
    
    // The simulator requires that the code be loaded into location 31 (decimal).
    // this muxes the pc_if (from nextPc -> reg -> pc_if), with this initial value
    assign firstPc = 16'd31;
    wire [15:0] currPc = (resetPc == 1'b1) ? firstPc : pc_IF;
    wire [15:0] memPcIn = ((doJump_ID == 1'b1) && (loadInstr == 1'b0)) ? {4'b0000, jumpTarget} : currPc;
    IncrementPC pcInc (.pcIn(memPcIn), .pcOut(nextPc));
    
    // reset resets all memory to 0
    // pcIn is the current program counter
    // instrOut is the instruction read from memory        // writeMem_ME, movMem_ME == 1'b0 until reset, so give guaranteed signal
    wire writeToMem       = (fullReset == 1'b1) ? 1'b0   : ((loadInstr == 1'b1) ? 1'b1 : writeMem_ME);
    wire movMem           = (fullReset == 1'b1) ? 1'b0   : ((loadInstr == 1'b1) ? 1'b0 : movMem_ME);
    wire [15:0] memAddrIn = (loadInstr == 1'b1) ? currPc : memAddress_ME;    // <- write to mem when loading instructions
    wire [15:0] memDataIn = (loadInstr == 1'b1) ? instr  : memDataIn_ME;
    
    Memory mem (.clk(clk),
                .write(writeToMem),
                .movMem(movMem),
                .address(memAddrIn),
                .dataIn(memDataIn),
                .dataOut(memDataOut_ME),
                .reset(fullReset),
                .pcIn(memPcIn),
                .instrOut(instr_IF));
                
    // this is an inut into the register file
    wire [15:0] nextPcToReg = (resetPc == 1'b1) ? firstPc : nextPc;
    
    // passes current instruction into decode
    wire [15:0] instr_ID;
    NBitReg #(.N(16)) regInstr_ID_EX (.inData(instr_IF), 
                                          .outData(instr_ID),
                                          .enable(~loadStall & globalRegEn),
                                          .clk(clk),
                                          .reset(fullReset));


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
    
    wire [15:0]         regData1_ID,
                        regData2_ID;

    wire [regBits-1:0]  writeReg_ID,
                        readReg1_ID,
                        readReg2_ID,
                        writeReg_EX,
                        readReg1_EX,
                        readReg2_EX;
                        
    assign readReg1_ID = arg1[2:0];
    assign writeReg_ID = arg1[2:0];
    assign readReg2_ID = arg2[2:0];
    wire writeToRegFile = ((fullReset == 1'b1) || (loadInstr == 1'b1)) ? 1'b0 : regWrite_WB;
    
    wire pcEnable = (~loadStall) & globalRegEn;
    RegisterFile regFile (.clk(clk),
                          .reset(fullReset),
                          .writeData(outData_WB),
                          .writeReg(writeReg_WB),
                          .regWrite(writeToRegFile),
                          .readReg1(readReg1_ID),
                          .readReg2(readReg2_ID),
                          .readData1(regData1_ID),
                          .readData2(regData2_ID),
                          .pcIn(nextPcToReg),
                          .pcOut(pc_IF),
                          .pcEnable(pcEnable),
                          .rfStreamOut(rfStreamOut));
    
    // see comment in module if je and jne have hazards with a cmp instruction
    // right before them.  This ~shouldn't~ be an issue but could be.
    JumpController jumpCtrl (   .opCode(opCode),
                                .cmpResult(cmpRes_EX),
                                .reset(fullReset | loadInstr),
                                .doJump(doJump_ID));
    assign jumpTarget[11:0] = {arg1, arg2};
    
    wire        regWrite_ID;
    wire        readMem_ID;
    wire        writeMem_ID;
    wire        aluImm_ID;
    wire        movMem_ID;            // <- unused. don't feel like fixing yet.
    wire        halt_ID;
    wire        cmpWrite_ID;
    wire [2:0]  aluOp_ID;
    wire        forceCtrlZero = (loadInstr || fullReset);
    control control_i ( .opCode(opCode),
                        .forceZero(forceCtrlZero),
                        .regWrite(regWrite_ID),
                        .readMem(readMem_ID),
                        .writeMem(writeMem_ID),
                        .aluImm(aluImm_ID),
                        .movMem(movMem_ID),
                        .halt(halt_ID),
                        .cmpWrite(cmpWrite_ID),             
                        .aluOp(aluOp_ID));
    
    wire haltOut;
    // want don't want to halt after we reset the program counter
    wire haltReset = resetHalt | resetPc;
    HaltController  haltCtrl  ( .haltOut(haltOut),
                                .haltSig(halt_ID),
                                .haltReset(haltReset),
                                .reset(fullReset));
    assign globalHalt = haltOut & ~loadInstr;
                        
    StallController stallCtrl ( .readMem_EX(readMem_EX),
                                .useReg2_ID(~aluImm_ID),
                                .readReg_EX(readReg1_EX),
                                .reg1_ID(readReg1_ID),
                                .reg2_ID(readReg2_ID),
                                .stall(loadStall));

    wire [6:0] ctrlBus;
    wire [6:0] ctrlBus_ID;
    wire [6:0] ctrlBus_EX;
    assign ctrlBus[6:0] = {movMem_ID, regWrite_ID, readMem_ID, writeMem_ID, 
                           aluImm_ID, cmpWrite_ID, halt_ID};
    assign ctrlBus_ID[6:0] = (loadStall == 1'b1) ? 7'b0000000 : ctrlBus;
    wire [15:0] regData1_EX;
    wire [15:0] regData2_EX;
    NBitReg #(.N(16)) arg1Reg_IDEX (.inData(regData1_ID),
                                    .outData(regData1_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(16)) arg2Reg_IDEX (.inData(regData2_ID),
                                    .outData(regData2_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(3)) read1Reg_IDEX  (.inData(readReg1_ID),
                                    .outData(readReg1_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(3)) read2Reg_IDEX  (.inData(readReg2_ID),
                                    .outData(readReg2_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(3)) writeReg_IDEX  (.inData(writeReg_ID),
                                    .outData(writeReg_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));

    NBitReg #(.N(7)) ctrlReg_IDEX ( .inData(ctrlBus_ID),
                                    .outData(ctrlBus_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    wire [2:0]  aluOp_EX;
    NBitReg #(.N(3)) aluOpReg_IDEX (.inData(aluOp_ID),
                                    .outData(aluOp_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    wire [5:0] imm_EX;
    NBitReg #(.N(6)) immReg_IDEX  ( .inData(arg2),
                                    .outData(imm_EX),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
                                    
    // THIS IS PURELY A FOR MAKING INSPECTION OF SIMULATION EASIER. CAN TAKE OUT FOR
    // SYNTHESIS
    wire [3:0] opCode_EX;
    NBitReg #(.N(4)) opCodeReg_IDEX (   .inData(opCode),
                                        .outData(opCode_EX),
                                        .enable(globalRegEn),
                                        .clk(clk),
                                        .reset(fullReset));
////////////////////////////////////////////////////////////////////////////////////
////////////////                   -- EXECUTION --                 /////////////////
////////////////////////////////////////////////////////////////////////////////////
// executes instruction
/* 
   INPUT:   readReg1_EX, 
            readReg2_EX, 
            regData1_EX, 
            regData2_EX, 
            writeReg_EX, 
            aluOp_EX,
            imm_EX
   OUTPUT:  aluOut_ME,
            regData2_ME,
            ctrlBus_ME,
            readReg1_ME,
            readReg2_ME,
            writeReg_ME
*/
    assign readMem_EX = ctrlBus_EX[4];
    wire aluImm_EX    = ctrlBus_EX[2];
    wire cmpWrite_EX  = ctrlBus_EX[1];
    wire halt_EX      = ctrlBus_EX[0];
    wire [15:0]         aluIn1,
                        aluIn2;

    // since pass and mov are alu ops, no need to mux the aluOut with anything
    wire [1:0]  fwReg1, fwReg2;
    ForwardingUnit fwUnit ( .reg1_EX(readReg1_EX), 
                            .reg2_EX(readReg2_EX), 
                            .wbReg_ME(writeReg_ME), 
                            .wbReg_WB(writeReg_WB), 
                            .write_ME(regWrite_ME), 
                            .write_WB(regWrite_WB), 
                            .fwReg1(fwReg1), 
                            .fwReg2(fwReg2));
    wire [15:0] fwResult1, fwResult2;
    ForwardMux fwMux1 ( .out(fwResult1),
                        .data_EX(regData1_EX),
                        .data_ME(aluOut_ME),
                        .data_WB(outData_WB),
                        .select(fwReg1));
    ForwardMux fwMux2 ( .out(fwResult2),
                        .data_EX(regData2_EX),
                        .data_ME(aluOut_ME),
                        .data_WB(outData_WB),
                        .select(fwReg2));

    assign aluIn1 = fwResult1;
    ALU_Mux aluMuxIn2 ( .regData2(fwResult2), 
                        .arg2(imm_EX), 
                        .ALUSrc(~aluImm_EX), 
                        .ALU_Mux_out(aluIn2));

    wire [15:0]   aluOut_EX;
    wire          aluCmpRes;
    ALU alu (   .aluIn1(aluIn1), 
                .aluIn2(aluIn2), 
                .aluOp(aluOp_EX), 
                .ALUresult(aluOut_EX),
                .cmpRes(aluCmpRes));
    
    CompareHandle cmpCtrl ( .cmpInstr(cmpWrite_EX), 
                            .aluEqRes(aluCmpRes),
                            .reset(fullReset), 
                            .cmpResult(cmpRes_EX));
    
    wire [15:0]   regData2_ME;
    NBitReg #(.N(16)) aluOut_EXME ( .inData(aluOut_EX),
                                    .outData(aluOut_ME),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(16)) regData2_EXME(.inData(fwResult2),
                                    .outData(regData2_ME),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    wire [6:0] ctrlBus_ME;          
    NBitReg #(.N(7))  ctrlReg_EXME (.inData(ctrlBus_EX),
                                    .outData(ctrlBus_ME),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    
    NBitReg #(.N(3)) read1Reg_EXME (.inData(readReg1_EX),
                                    .outData(readReg1_ME),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(3)) read2Reg_EXME (.inData(readReg2_EX),
                                    .outData(readReg2_ME),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(3)) writeReg_EXME (.inData(writeReg_EX),
                                    .outData(writeReg_ME),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    
                
    // THIS IS PURELY A FOR MAKING INSPECTION OF SIMULATION EASIER. CAN TAKE OUT FOR
    // SYNTHESIS
    wire [3:0] opCode_ME;
    NBitReg #(.N(4)) opCodeReg_EXME (   .inData(opCode_EX),
                                        .outData(opCode_ME),
                                        .enable(globalRegEn),
                                        .clk(clk),
                                        .reset(fullReset));
////////////////////////////////////////////////////////////////////////////////////
////////////////                    -- MEMORY --                   /////////////////
////////////////////////////////////////////////////////////////////////////////////
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
    assign movMem_ME   = ctrlBus_ME[6];
    assign regWrite_ME = ctrlBus_ME[5];
    wire readMem_ME    = ctrlBus_ME[4];
    assign writeMem_ME = ctrlBus_ME[3];
    wire halt_ME       = ctrlBus_ME[0];
    
    // THE MEMORY UNIT IS INSTANTIATED IN INSTRUCTION FETCH STAGE
    // memAddress_ME, memDataIn_ME, writeMem_ME, and readMem_ME are
    // all instantiated in Instruction Fetch
    MemoryInterface memCtrl (   .regData1(aluOut_ME),
                                .regData2(regData2_ME),
                                .memWrite(writeMem_ME),
                                .memAddress(memAddress_ME),
                                .memData(memDataIn_ME));
    wire [15:0] memAluMuxOut;
    Mux2to1 memOutMux ( .out(memAluMuxOut),
                        .in1(memDataOut_ME),
                        .in2(aluOut_ME),
                        .select(readMem_ME));
    NBitReg #(.N(16)) out_MEWB (    .inData(memAluMuxOut),
                                    .outData(outData_WB),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    wire [6:0] ctrlBus_WB;
    NBitReg #(.N(7)) ctrlBus_MEWB ( .inData(ctrlBus_ME),
                                    .outData(ctrlBus_WB),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
    NBitReg #(.N(3)) writeReg_MEWB (.inData(writeReg_ME),
                                    .outData(writeReg_WB),
                                    .enable(globalRegEn),
                                    .clk(clk),
                                    .reset(fullReset));
                                    
    wire [3:0] opCode_WB;
    NBitReg #(.N(4)) opCodeReg_MEWB (   .inData(opCode_ME),
                                        .outData(opCode_WB),
                                        .enable(globalRegEn),
                                        .clk(clk),
                                        .reset(fullReset));
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
    assign out = (regWrite_WB) ? outData_WB : ((globalHalt) ? 16'hAAAA : 16'hBBBB);
endmodule
