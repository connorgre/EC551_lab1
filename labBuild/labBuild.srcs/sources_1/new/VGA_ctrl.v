`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2022 04:37:27 PM
// Design Name: 
// Module Name: VGA_ctrl
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

// Generate HS, VS signals from pixel clock.
// hcounter & vcounter are the index of the current pixel
// origin (0, 0) at top-left corner of the screen
// valid display range for hcounter: [0, 640)
// valid display range for vcounter: [0, 480)

// top module that instantiates the VGA controller and generates images
module top(
    input wire CLK100MHZ,
    input wire [15:0] SW,
    input wire        BTND, 
                      BTNR, 
                      BTNU, 
                      BTNL, 
                      BTNC,
    input wire        CPU_RESETN,
    
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B,
    output wire VGA_HS,
    output wire VGA_VS
);
    wire [15:0] instrIn = SW;
    wire        manualClk;
    wire        unHalt;
    wire        fullReset;
    wire        resetPc;
    wire        loadInstr;
    Btn_ctrl buttons ( CLK100MHZ, BTND, BTNR, BTNU, BTNL, BTNC, CPU_RESETN,
                        loadInstr, manualClk, unHalt, resetPc, fullReset);


    reg cpuClk;
    reg [25:0] cpuDivReg;
    
    always@(posedge CLK100MHZ) begin
        if (fullReset) begin
            cpuClk = 1'b0;
            cpuDivReg = 25'h0000000;
        end
        cpuDivReg = cpuDivReg + 1;
        if (cpuDivReg == 25'h0000000)
            cpuClk = ~cpuClk;
    end
    wire [127:0] rfStreamOut;
    CPU cpu (
            .out(),
            .clk(cpuClk),
            .fullReset(fullReset),
            .resetPc(resetPc),
            .resetHalt(unHalt),
            .loadInstr(loadInstr),
            .instr(instrIn),
            .rfStreamOut(rfStreamOut));
    
    reg pclk_div_cnt;
    reg pixel_clk;
    wire [10:0] vga_hcnt, vga_vcnt;
    wire vga_blank;
    // Clock divider. Generate 25MHz pixel_clk from 100MHz clock.
    always @(posedge CLK100MHZ) begin
        pclk_div_cnt <= !pclk_div_cnt;
        if (pclk_div_cnt == 1'b1) pixel_clk <= !pixel_clk;
    end
    // Instantiate VGA controller
    vga_controller_640_60 vga_controller(
                                            .pixel_clk(pixel_clk),
                                            .HS(VGA_HS),
                                            .VS(VGA_VS),
                                            .hcounter(vga_hcnt),
                                            .vcounter(vga_vcnt),
                                            .blank(vga_blank)
    );
    
    wire [3:0] colorR, colorG, colorB;
    VGA_Color vgaColor (.color1Out(colorR),
                        .color2Out(colorG),
                        .color3Out(colorB),
                        .rfStreamIn(rfStreamOut),
                        .x(vga_hcnt),
                        .y(vga_vcnt),
                        .clk(pixel_clk));
    
    
    // Generate figure to be displayed
    // Decide the color for the current pixel at index (hcnt, vcnt).
    // This example displays an white square at the center of the screen with a colored checkerboard background.
    always @(*) begin
        // Set pixels to black during Sync. Failure to do so will result in dimmed colors or black screens.
        if (vga_blank) begin
            VGA_R = 0;
            VGA_G = 0;
            VGA_B = 0;
        end
        // Image to be displayed
        else begin
            VGA_R = colorR;
            VGA_G = colorG;
            VGA_B = colorB;

        end
    end
endmodule